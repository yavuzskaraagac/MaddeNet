import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum RiskLevel { high, mid, safe }

RiskLevel riskFromString(String s) {
  switch (s) {
    case 'high': return RiskLevel.high;
    case 'mid': return RiskLevel.mid;
    default: return RiskLevel.safe;
  }
}

class RiskPill extends StatelessWidget {
  const RiskPill({super.key, required this.risk, this.small = false});
  final RiskLevel risk;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final (color, bg, border, label) = switch (risk) {
      RiskLevel.high => (mn.riskHigh, mn.riskHighSoft, mn.riskHighRing, 'Yüksek'),
      RiskLevel.mid  => (mn.riskMid,  mn.riskMidSoft,  mn.riskMidRing,  'Dikkat'),
      RiskLevel.safe => (mn.riskSafe, mn.riskSafeSoft, mn.riskSafeRing, 'Uygun'),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 9, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: small ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

class RiskScoreBadge extends StatelessWidget {
  const RiskScoreBadge({super.key, required this.score, required this.risk});
  final int score;
  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final (color, bg, border) = switch (risk) {
      RiskLevel.high => (mn.riskHigh, mn.riskHighSoft, mn.riskHighRing),
      RiskLevel.mid  => (mn.riskMid,  mn.riskMidSoft,  mn.riskMidRing),
      RiskLevel.safe => (mn.riskSafe, mn.riskSafeSoft, mn.riskSafeRing),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(
            switch (risk) {
              RiskLevel.high => 'YÜKSEK RİSK',
              RiskLevel.mid  => 'ORTA RİSK',
              RiskLevel.safe => 'DÜŞÜK RİSK',
            },
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.04),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9999)),
            child: Text(
              '$score',
              style: GoogleFonts.newsreader(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
