import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MnCard extends StatelessWidget {
  const MnCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glow = false,
    this.onTap,
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool glow;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Material(
      color: mn.bgCard,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: mn.border),
          ),
          child: glow
              ? Stack(children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: RadialGradient(
                          center: const Alignment(1, -1),
                          radius: 1.2,
                          colors: [mn.accentGlow, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  child,
                ])
              : child,
        ),
      ),
    );
  }
}

class MnLegalNote extends StatelessWidget {
  const MnLegalNote({super.key, required this.text, this.boldPrefix});
  final String text;
  final String? boldPrefix;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Container(
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
                  if (boldPrefix != null)
                    TextSpan(text: '$boldPrefix ', style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
