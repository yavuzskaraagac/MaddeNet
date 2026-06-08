import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/mn_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Aura background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: mn.bgDeep,
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [mn.accentGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          // Grid lines
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: CustomPaint(painter: _GridPainter(mn.border)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BrandMark(size: 64),
                      const SizedBox(height: 20),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.newsreader(fontSize: 38, fontWeight: FontWeight.w600, letterSpacing: -0.035, color: Theme.of(context).colorScheme.onSurface),
                          children: [
                            const TextSpan(text: 'Madde'),
                            TextSpan(text: 'Net', style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sözleşmeni anla,\nriskini bil.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.newsreader(
                          fontSize: 19,
                          fontStyle: FontStyle.italic,
                          color: mn.textSoft,
                          letterSpacing: -0.01,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'RAG · 2.392 KANUN MADDESİ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          color: mn.textFaint,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [
                      MnPrimaryButton(
                        label: 'Ücretsiz Başla',
                        icon: Icons.chevron_right,
                        fullWidth: true,
                        height: 54,
                        onPressed: () => context.go('/dashboard'),
                      ),
                      const SizedBox(height: 10),
                      MnGhostButton(
                        label: 'Giriş Yap',
                        fullWidth: true,
                        height: 52,
                        onPressed: () => context.go('/auth'),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: mn.riskMidSoft,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: mn.riskMidRing),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.balance_outlined, size: 16, color: mn.riskMid),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(fontSize: 12.5, color: mn.textSoft, height: 1.55),
                                  children: [
                                    TextSpan(text: 'Bilgilendirme amaçlıdır. ', style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                                    const TextSpan(text: 'MaddeNet bir hukuki danışmanlık platformu değildir; sonuçlar tavsiye niteliği taşımaz.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
