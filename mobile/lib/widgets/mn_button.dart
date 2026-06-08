import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MnPrimaryButton extends StatelessWidget {
  const MnPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final enabled = onPressed != null && !loading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [mn.accentHover, accent],
                )
              : null,
          color: enabled ? null : mn.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: enabled ? mn.accentDeep : mn.border),
          boxShadow: enabled
              ? [BoxShadow(color: mn.accentGlow, blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -8)]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: mn.logoFg),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[Icon(icon, size: 18, color: enabled ? mn.logoFg : mn.textFaint), const SizedBox(width: 8)],
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: enabled ? mn.logoFg : mn.textFaint,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class MnGhostButton extends StatelessWidget {
  const MnGhostButton({super.key, required this.label, this.onPressed, this.icon, this.fullWidth = false, this.height = 48});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18, color: mn.textSoft) : const SizedBox.shrink(),
        label: Text(label, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w500, color: mn.textSoft)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: mn.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

class MnDangerButton extends StatelessWidget {
  const MnDangerButton({super.key, required this.label, this.onPressed, this.fullWidth = false});
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
        label: Text(label, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w500, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: mn.riskHigh,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
