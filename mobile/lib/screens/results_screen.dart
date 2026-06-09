import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/analysis.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mn_card.dart';
import '../widgets/risk_pill.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.analysisId});
  final String analysisId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _filter = 'all';
  int _openIdx = -1;
  late Future<AnalysisDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final token = context.read<AuthProvider>().token ?? '';
    _future = ApiService()
        .getAnalysis(widget.analysisId, token)
        .then((data) => AnalysisDetail.fromJson(data));
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);

    return FutureBuilder<AnalysisDetail>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(leading: BackButton(color: mn.textSoft)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(leading: BackButton(color: mn.textSoft)),
            body: Center(child: Text(snap.error.toString())),
          );
        }
        final analysis = snap.data!;
        return _AnalysisView(analysis: analysis, filter: _filter, openIdx: _openIdx,
          onFilterChange: (f) => setState(() => _filter = f),
          onToggle: (i) => setState(() => _openIdx = _openIdx == i ? -1 : i),
        );
      },
    );
  }
}

class _AnalysisView extends StatelessWidget {
  const _AnalysisView({
    required this.analysis,
    required this.filter,
    required this.openIdx,
    required this.onFilterChange,
    required this.onToggle,
  });
  final AnalysisDetail analysis;
  final String filter;
  final int openIdx;
  final void Function(String) onFilterChange;
  final void Function(int) onToggle;

  List<int> get _visible {
    return List.generate(analysis.maddeler.length, (i) => i).where((i) {
      if (filter == 'all') return true;
      final r = analysis.maddeler[i].riskSeviyesi;
      return filter == 'high' && r == 'red' ||
          filter == 'mid' && r == 'yellow' ||
          filter == 'safe' && r == 'green';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mn.textSoft),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ANALİZ · ${analysis.sozlesmeTuru.toUpperCase()}', style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted, letterSpacing: 0.04)),
            Text(analysis.sozlesmeTuruLabel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        actions: [
          RiskScoreBadge(score: analysis.genelRiskSkoru, risk: analysis.riskLevel),
          const SizedBox(width: 8),
          _PdfButton(analysis: analysis),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(
            children: [
              Expanded(child: _SumCard(num: '${analysis.maddeler.length}', lbl: 'Toplam Madde')),
              const SizedBox(width: 8),
              Expanded(child: _SumCard(num: '${analysis.highCount}', lbl: 'Yüksek', risk: RiskLevel.high)),
              const SizedBox(width: 8),
              Expanded(child: _SumCard(num: '${analysis.safeCount}', lbl: 'Uygun', risk: RiskLevel.safe)),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Tümü', count: analysis.maddeler.length, active: filter == 'all', onTap: () => onFilterChange('all')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Yüksek Risk', count: analysis.highCount, active: filter == 'high', risk: RiskLevel.high, onTap: () => onFilterChange('high')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Dikkat', count: analysis.midCount, active: filter == 'mid', risk: RiskLevel.mid, onTap: () => onFilterChange('mid')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Uygun', count: analysis.safeCount, active: filter == 'safe', risk: RiskLevel.safe, onTap: () => onFilterChange('safe')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._visible.map((i) => _ClauseCard(
            clause: analysis.maddeler[i],
            expanded: openIdx == i,
            onToggle: () => onToggle(i),
          )),
          const SizedBox(height: 16),
          const MnLegalNote(
            boldPrefix: 'Bir avukata danışmanızı öneririz.',
            text: ' MaddeNet analizleri yalnızca farkındalık amaçlıdır.',
          ),
        ],
      ),
    );
  }
}

class _PdfButton extends StatefulWidget {
  const _PdfButton({required this.analysis});
  final AnalysisDetail analysis;

  @override
  State<_PdfButton> createState() => _PdfButtonState();
}

class _PdfButtonState extends State<_PdfButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return GestureDetector(
      onTap: _loading ? null : _export,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: mn.accentSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: mn.accentRing),
        ),
        child: _loading
            ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_outlined, size: 15, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 5),
                  Text('PDF', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                ],
              ),
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      await PdfService.shareAnalysisPdf(widget.analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF oluşturulamadı: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _SumCard extends StatelessWidget {
  const _SumCard({required this.num, required this.lbl, this.risk});
  final String num, lbl;
  final RiskLevel? risk;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final color = risk == null
        ? Theme.of(context).colorScheme.onSurface
        : risk == RiskLevel.high
            ? mn.riskHigh
            : risk == RiskLevel.safe
                ? mn.riskSafe
                : mn.riskMid;
    return MnCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Text(num, style: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: -0.025, color: color, height: 1)),
          const SizedBox(height: 4),
          Text(lbl, style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.count, required this.active, required this.onTap, this.risk});
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final RiskLevel? risk;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final Color bg, border, textColor;
    if (active && risk != null) {
      final (c, s, r) = switch (risk!) {
        RiskLevel.high => (mn.riskHigh, mn.riskHighSoft, mn.riskHighRing),
        RiskLevel.mid  => (mn.riskMid,  mn.riskMidSoft,  mn.riskMidRing),
        RiskLevel.safe => (mn.riskSafe, mn.riskSafeSoft, mn.riskSafeRing),
      };
      bg = s; border = r; textColor = c;
    } else if (active) {
      bg = mn.accentSoft; border = mn.accentRing; textColor = Theme.of(context).colorScheme.primary;
    } else {
      bg = mn.bgCard; border = mn.border; textColor = mn.textSoft;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9999), border: Border.all(color: border)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(width: 6),
            Text('$count', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: textColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _ClauseCard extends StatelessWidget {
  const _ClauseCard({required this.clause, required this.expanded, required this.onToggle});
  final ClauseModel clause;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final risk = clause.riskLevel;
    final borderColor = switch (risk) {
      RiskLevel.high => mn.riskHigh,
      RiskLevel.mid  => mn.riskMid,
      RiskLevel.safe => mn.riskSafe,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: mn.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mn.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: borderColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('MADDE ${clause.maddeNo}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textMuted, letterSpacing: 0.08, fontWeight: FontWeight.w600)),
                          RiskPill(risk: risk, small: true),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(border: Border(left: BorderSide(color: mn.accentRing, width: 2))),
                        child: Text('"${clause.maddMetni}"', style: GoogleFonts.newsreader(fontStyle: FontStyle.italic, fontSize: 13.5, color: mn.textSoft, height: 1.55)),
                      ),
                      if (expanded) ...[
                        const SizedBox(height: 12),
                        Text(clause.sadeAciklama, style: GoogleFonts.inter(fontSize: 13, color: mn.textSoft, height: 1.55)),
                        if (clause.kanunDayanagi != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: mn.bgInset, borderRadius: BorderRadius.circular(8), border: Border.all(color: mn.borderSubtle)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.balance_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(clause.kanunDayanagi!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                                      if (clause.kanunMaddesi != null)
                                        Text(clause.kanunMaddesi!, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: mn.textMuted)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (clause.oneri != null && clause.oneri!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: mn.riskSafeSoft, borderRadius: BorderRadius.circular(8), border: Border.all(color: mn.riskSafeRing)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline, size: 16, color: mn.riskSafe),
                                const SizedBox(width: 8),
                                Expanded(child: Text(clause.oneri!, style: GoogleFonts.inter(fontSize: 12.5, color: mn.textSoft, height: 1.5))),
                              ],
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onToggle,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(expanded ? 'Daralt' : 'Detayları gör', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500, color: mn.textMuted)),
                              const SizedBox(width: 4),
                              Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: mn.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
