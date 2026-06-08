import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/brand_mark.dart';
import '../widgets/mn_card.dart';
import '../widgets/risk_pill.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final today = DateFormat("d MMMM yyyy · EEEE", "tr_TR").format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            const BrandMark(size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                      children: [
                        const TextSpan(text: 'İyi günler, '),
                        TextSpan(text: auth.userName.split(' ').first, style: TextStyle(fontStyle: FontStyle.italic, color: accent)),
                      ],
                    ),
                  ),
                  Text(today, style: GoogleFonts.inter(fontSize: 11.5, color: mn.textMuted)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: mn.textSoft),
            onPressed: themeProvider.toggle,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: UserAvatar(initials: auth.userInitials, size: 34, fontSize: 12),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Stat cards 2x2
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(label: 'Toplam Analiz', value: '24', sub: 'bu ay +8'),
                  _StatCard(label: 'Yüksek Riskli', value: '3', sub: 'dikkat', risk: RiskLevel.high),
                  _StatCard(label: 'Ort. Risk Skoru', value: '58', sub: 'orta seviye', risk: RiskLevel.mid),
                  _StatCard(label: 'Uygun', value: '14', sub: 'onaylı', risk: RiskLevel.safe),
                ],
              ),
              const SizedBox(height: 16),
              const MnLegalNote(
                boldPrefix: 'Analizler bilgilendirme amaçlıdır.',
                text: 'Bir avukata danışmanız önerilir.',
              ),
              const SizedBox(height: 24),
              // Son Analizler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Son Analizler', style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                  GestureDetector(
                    onTap: () => context.go('/documents'),
                    child: Row(
                      children: [
                        Text('Tümünü Gör', style: GoogleFonts.inter(fontSize: 12.5, color: accent)),
                        Icon(Icons.chevron_right, size: 14, color: accent),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _RecentRow(type: 'Kira Sözleşmesi', date: '03 Haz 2026', risk: RiskLevel.mid, score: 65, onTap: () => context.go('/results/1')),
              _RecentRow(type: 'İş Sözleşmesi', date: '29 May 2026', risk: RiskLevel.high, score: 82, onTap: () => context.go('/results/2')),
              _RecentRow(type: 'Tedarik Sözleşmesi', date: '22 May 2026', risk: RiskLevel.safe, score: 28, onTap: () => context.go('/results/3')),
              const SizedBox(height: 24),
              // Risk dağılımı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Risk Dağılımı', style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                  Text('SON 30 GÜN', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint, letterSpacing: 0.05)),
                ],
              ),
              const SizedBox(height: 10),
              MnCard(
                child: Column(
                  children: [
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
                    const SizedBox(height: 14),
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
            ],
          ),
          // FAB
          Positioned(
            right: 20,
            bottom: 20,
            child: _Fab(onTap: () => context.go('/upload')),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.sub, this.risk});
  final String label, value, sub;
  final RiskLevel? risk;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final color = risk == null ? Theme.of(context).colorScheme.onSurface
        : risk == RiskLevel.high ? mn.riskHigh
        : risk == RiskLevel.mid ? mn.riskMid
        : mn.riskSafe;

    return MnCard(
      glow: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: mn.textFaint, letterSpacing: 0.1)),
          const SizedBox(height: 6),
          Expanded(
            child: Text(value, style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500, letterSpacing: -0.03, color: color, height: 1)),
          ),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted)),
        ],
      ),
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
        decoration: BoxDecoration(
          color: mn.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: mn.border),
        ),
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
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: mn.textMuted)),
        const SizedBox(width: 4),
        Text(pct, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [mn.accentHover, Theme.of(context).colorScheme.primary]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: mn.accentDeep),
          boxShadow: [BoxShadow(color: mn.accentGlow, blurRadius: 28, spreadRadius: -6, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 22, color: mn.logoFg),
            const SizedBox(width: 10),
            Text('Yeni Analiz', style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w600, color: mn.logoFg)),
          ],
        ),
      ),
    );
  }
}
