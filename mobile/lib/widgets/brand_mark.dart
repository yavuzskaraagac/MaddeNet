import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mn.accentHover, mn.accentDeep],
        ),
        borderRadius: BorderRadius.circular(size * 0.29),
        boxShadow: [BoxShadow(color: mn.accentGlow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(Icons.balance, size: size * 0.6, color: mn.logoFg),
    );
  }
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.markSize = 28, this.fontSize = 16});
  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            children: [
              const TextSpan(text: 'Madde'),
              TextSpan(
                text: 'Net',
                style: TextStyle(fontWeight: FontWeight.w400, color: textColor.withValues(alpha: 0.78)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.initials, this.size = 36, this.fontSize = 12});
  final String initials;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mn.accentHover, mn.accentDeep],
        ),
        boxShadow: [BoxShadow(color: mn.accentGlow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: mn.logoFg,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.02,
          ),
        ),
      ),
    );
  }
}
