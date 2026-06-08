import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/mn_card.dart';
import '../widgets/risk_pill.dart';

class AnalysesScreen extends StatelessWidget {
  const AnalysesScreen({super.key});

  static const _trendData = [72, 64, 78, 58, 61, 58];
  static const _trendLabels = ['H1', 'H2', 'H3', 'H4', 'H5', 'H6'];

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Analizler', style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(icon: Icon(Icons.filter_list, color: mn.textSoft), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Text(
            'Tüm sözleşmelerinizin risk dağılımı ve trendi.',
            style: GoogleFonts.inter(fontSize: 13.5, color: mn.textMuted),
          ),
          const SizedBox(height: 16),
          // Big score card
          MnCard(
            glow: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('ORTALAMA RİSK SKORU', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint, letterSpacing: 0.12)),
                const SizedBox(height: 8),
                Text('58', style: GoogleFonts.newsreader(fontSize: 56, fontWeight: FontWeight.w500, letterSpacing: -0.04, color: mn.riskMid, height: 1)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('orta seviye · son 30 günde ', style: GoogleFonts.inter(fontSize: 12, color: mn.textMuted)),
                    Text('↓ 7', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: mn.riskSafe)),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Flexible(flex: 18, child: Container(height: 8, color: mn.riskHigh)),
                      Flexible(flex: 34, child: Container(height: 8, color: mn.riskMid)),
                      Flexible(flex: 48, child: Container(height: 8, color: mn.riskSafe)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Legend(color: mn.riskHigh, label: 'Yüksek', pct: '18%'),
                    _Legend(color: mn.riskMid, label: 'Dikkat', pct: '34%'),
                    _Legend(color: mn.riskSafe, label: 'Uygun', pct: '48%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Son 6 Hafta', style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
              Text('RİSK TRENDİ', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint, letterSpacing: 0.05)),
            ],
          ),
          const SizedBox(height: 10),
          MnCard(
            child: SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_trendData.length, (i) {
                  final v = _trendData[i];
                  final color = v >= 70 ? mn.riskHigh : v >= 50 ? mn.riskMid : mn.riskSafe;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$v', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textMuted)),
                          const SizedBox(height: 4),
                          Container(
                            height: (v / 100) * 72,
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                          ),
                          const SizedBox(height: 6),
                          Text(_trendLabels[i], style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: mn.textFaint, letterSpacing: 0.04)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Son Analizler', style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
              GestureDetector(
                onTap: () => context.go('/documents'),
                child: Row(
                  children: [
                    Text('Tümü', style: GoogleFonts.inter(fontSize: 12.5, color: Theme.of(context).colorScheme.primary)),
                    Icon(Icons.chevron_right, size: 14, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RecentRow(type: 'Kira Sözleşmesi', date: '03 Haz 2026', risk: RiskLevel.mid, score: 65, onTap: () => context.go('/results/1')),
          _RecentRow(type: 'İş Sözleşmesi', date: '29 May 2026', risk: RiskLevel.high, score: 82, onTap: () => context.go('/results/2')),
          _RecentRow(type: 'Tedarik Sözleşmesi', date: '22 May 2026', risk: RiskLevel.safe, score: 28, onTap: () => context.go('/results/3')),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.pct});
  final Color color;
  final String label, pct;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11.5, color: mn.textMuted)),
        const SizedBox(width: 4),
        Text(pct, style: GoogleFonts.jetBrainsMono(fontSize: 11.5, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.type, required this.date, required this.risk, required this.score, required this.onTap});
  final String type, date;
  final RiskLevel risk;
  final int score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
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
                  Text(type, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  Text('$date · SKOR $score', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: mn.textFaint)),
                ],
              ),
            ),
            RiskPill(risk: risk, small: true),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: mn.textFaint),
          ],
        ),
      ),
    );
  }
}
