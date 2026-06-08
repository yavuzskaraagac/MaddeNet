import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_pill.dart';
import '../widgets/mn_card.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.analysisId});
  final String analysisId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _filter = 'all';
  int _openIdx = -1;

  static const _clauses = [
    (
      n: 'MADDE 7',
      risk: 'high',
      quote: '"Kiracı, sözleşmeyi süresinden önce feshederse 6 (altı) ay kira bedeli tutarında cezai şart ödemekle yükümlüdür."',
      desc: 'TBK m.299 ile çelişiyor olabilir. Türk Borçlar Kanunu kiracının makul ihbar süresiyle sözleşmeyi sonlandırma hakkını korur; 6 aylık ceza-i şart fahiş kabul edilir.',
      lawName: 'Türk Borçlar Kanunu',
      lawArt: 'Madde 299',
      tip: 'Bedelin "kalan süre içinde yeniden kiraya verilemeyen süre" ile sınırlanmasını öneriyoruz.',
    ),
    (
      n: 'MADDE 9',
      risk: 'mid',
      quote: '"Yıllık kira artışı TÜFE\'nin 1.5 katı oranında belirlenir."',
      desc: 'TBK m.344, konut kira artışını bir önceki yılın 12 aylık TÜFE ortalamasıyla sınırlar. Bu hüküm yasal sınırı aşmaktadır.',
      lawName: 'Türk Borçlar Kanunu',
      lawArt: 'Madde 344',
      tip: 'Maddenin "12 aylık TÜFE ortalamasını aşmayacak şekilde" cümlesiyle değiştirilmesi gerekir.',
    ),
    (
      n: 'MADDE 12',
      risk: 'safe',
      quote: '"Depozito, sözleşme bitiminden itibaren 15 gün içinde, kiracının banka hesabına faizsiz olarak iade edilir."',
      desc: 'Depozito iadesi koşulları açık, ölçülebilir ve TBK m.342 ile uyumludur.',
      lawName: 'Türk Borçlar Kanunu',
      lawArt: 'Madde 342',
      tip: '',
    ),
  ];

  List<int> get _visible => List.generate(_clauses.length, (i) => i)
      .where((i) => _filter == 'all' || _clauses[i].risk == _filter)
      .toList();

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
            Text('ANALİZ · KİRA', style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted, letterSpacing: 0.04)),
            Text('kira-sozlesmesi-2026.pdf', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          RiskScoreBadge(score: 65, risk: RiskLevel.mid),
          const SizedBox(width: 4),
          IconButton(icon: Icon(Icons.download_outlined, color: mn.textSoft), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Summary 3-col
          Row(
            children: [
              Expanded(child: _SumCard(num: '14', lbl: 'Toplam Madde')),
              const SizedBox(width: 8),
              Expanded(child: _SumCard(num: '3', lbl: 'Yüksek', risk: RiskLevel.high)),
              const SizedBox(width: 8),
              Expanded(child: _SumCard(num: '6', lbl: 'Uygun', risk: RiskLevel.safe)),
            ],
          ),
          const SizedBox(height: 16),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Tümü', count: 14, active: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Yüksek Risk', count: 3, active: _filter == 'high', risk: RiskLevel.high, onTap: () => setState(() => _filter = 'high')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Dikkat', count: 5, active: _filter == 'mid', risk: RiskLevel.mid, onTap: () => setState(() => _filter = 'mid')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Uygun', count: 6, active: _filter == 'safe', risk: RiskLevel.safe, onTap: () => setState(() => _filter = 'safe')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Clause cards
          ..._visible.map((i) => _ClauseCard(
            clause: _clauses[i],
            expanded: _openIdx == i,
            onToggle: () => setState(() => _openIdx = _openIdx == i ? -1 : i),
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

class _SumCard extends StatelessWidget {
  const _SumCard({required this.num, required this.lbl, this.risk});
  final String num, lbl;
  final RiskLevel? risk;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final color = risk == null ? Theme.of(context).colorScheme.onSurface
        : risk == RiskLevel.high ? mn.riskHigh
        : risk == RiskLevel.safe ? mn.riskSafe : mn.riskMid;
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
  final ({String n, String risk, String quote, String desc, String lawName, String lawArt, String tip}) clause;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final risk = riskFromString(clause.risk);
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
        border: Border(
          top: BorderSide(color: mn.border),
          right: BorderSide(color: mn.border),
          bottom: BorderSide(color: mn.border),
          left: BorderSide(color: borderColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(clause.n, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint, letterSpacing: 0.08, fontWeight: FontWeight.w600)),
                RiskPill(risk: risk, small: true),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(border: Border(left: BorderSide(color: mn.accentRing, width: 2))),
              child: Text(clause.quote, style: GoogleFonts.newsreader(fontStyle: FontStyle.italic, fontSize: 13.5, color: mn.textSoft, height: 1.55)),
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              Text(clause.desc, style: GoogleFonts.inter(fontSize: 13, color: mn.textSoft, height: 1.55)),
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
                          Text(clause.lawName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                          Text(clause.lawArt, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: mn.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (clause.tip.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: mn.riskSafeSoft, borderRadius: BorderRadius.circular(8), border: Border.all(color: mn.riskSafeRing)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16, color: mn.riskSafe),
                      const SizedBox(width: 8),
                      Expanded(child: Text(clause.tip, style: GoogleFonts.inter(fontSize: 12.5, color: mn.textSoft, height: 1.5))),
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
    );
  }
}
