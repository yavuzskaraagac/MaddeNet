import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/analysis.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mn_card.dart';
import '../widgets/risk_pill.dart';

class AnalysesScreen extends StatefulWidget {
  const AnalysesScreen({super.key});

  @override
  State<AnalysesScreen> createState() => _AnalysesScreenState();
}

class _AnalysesScreenState extends State<AnalysesScreen> {
  late Future<List<AnalysisSummary>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final token = context.read<AuthProvider>().token ?? '';
    _future = ApiService().getAnalyses(token).then((data) {
      final list = data['analizler'] as List<dynamic>? ?? [];
      return list.map((e) => AnalysisSummary.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Analizlerim', style: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: mn.textSoft), onPressed: () => setState(() => _load())),
        ],
      ),
      body: FutureBuilder<List<AnalysisSummary>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: mn.riskHigh),
                  const SizedBox(height: 12),
                  Text('Bağlantı hatası', style: GoogleFonts.inter(fontSize: 15, color: mn.textSoft)),
                  TextButton(onPressed: () => setState(() => _load()), child: const Text('Tekrar dene')),
                ],
              ),
            );
          }
          final analyses = snap.data ?? [];
          if (analyses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 56, color: mn.textFaint),
                  const SizedBox(height: 16),
                  Text('Henüz analiz yapılmadı', style: GoogleFonts.inter(fontSize: 15, color: mn.textSoft)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Analiz'),
                    onPressed: () => context.go('/upload'),
                  ),
                ],
              ),
            );
          }

          // Stats from analyses
          final avgScore = analyses.isEmpty ? 0 : analyses.map((a) => a.genelRiskSkoru).reduce((a, b) => a + b) ~/ analyses.length;
          final highCount = analyses.where((a) => a.genelRiskSeviyesi == 'red').length;
          final riskLevel = avgScore > 60 ? RiskLevel.high : avgScore > 35 ? RiskLevel.mid : RiskLevel.safe;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Big score card
              MnCard(
                glow: true,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ORT. RİSK SKORU', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: MnColors.of(context).textFaint, letterSpacing: 0.1)),
                        const SizedBox(height: 6),
                        Text('$avgScore', style: GoogleFonts.newsreader(fontSize: 52, fontWeight: FontWeight.w500, letterSpacing: -0.04, color: Theme.of(context).colorScheme.onSurface, height: 1)),
                        const SizedBox(height: 6),
                        RiskPill(risk: riskLevel),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${analyses.length}', style: GoogleFonts.newsreader(fontSize: 28, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                        Text('Toplam Analiz', style: GoogleFonts.inter(fontSize: 11, color: MnColors.of(context).textMuted)),
                        const SizedBox(height: 12),
                        Text('$highCount', style: GoogleFonts.newsreader(fontSize: 28, fontWeight: FontWeight.w500, color: MnColors.of(context).riskHigh)),
                        Text('Yüksek Riskli', style: GoogleFonts.inter(fontSize: 11, color: MnColors.of(context).textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Son Analizler', style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 10),
              ...analyses.map((a) => _AnalysisRow(
                analysis: a,
                onTap: () => context.go('/results/${a.id}'),
              )),
            ],
          );
        },
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({required this.analysis, required this.onTap});
  final AnalysisSummary analysis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final date = DateFormat('d MMM yyyy', 'tr_TR').format(analysis.createdAt.toLocal());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: mn.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: mn.border)),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
              child: Icon(Icons.description_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(analysis.sozlesmeTuruLabel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  Text('$date · SKOR ${analysis.genelRiskSkoru}', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: mn.textFaint)),
                ],
              ),
            ),
            RiskPill(risk: analysis.riskLevel, small: true),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: mn.textFaint),
          ],
        ),
      ),
    );
  }
}
