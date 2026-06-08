import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/brand_mark.dart';
import '../widgets/mn_card.dart';
import '../widgets/risk_pill.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profil', style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: mn.textSoft),
            onPressed: themeProvider.toggle,
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: mn.textSoft),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Profile header
          MnCard(
            glow: true,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                UserAvatar(initials: auth.userInitials, size: 72, fontSize: 22),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(auth.userName, style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: -0.02, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(width: 8),
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: mn.bgInset, shape: BoxShape.circle, border: Border.all(color: mn.border)),
                      child: Icon(Icons.edit_outlined, size: 14, color: mn.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(auth.userEmail, style: GoogleFonts.inter(fontSize: 13, color: mn.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats 2-col
          Row(
            children: [
              Expanded(child: MnCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  children: [
                    Text('24', style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: -0.02, color: Theme.of(context).colorScheme.onSurface, height: 1)),
                    const SizedBox(height: 6),
                    Text('Toplam Analiz', style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted), textAlign: TextAlign.center),
                  ],
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: MnCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('3', style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: -0.02, color: Theme.of(context).colorScheme.onSurface, height: 1)),
                        const SizedBox(width: 4),
                        Text('Ay', style: GoogleFonts.inter(fontSize: 12, color: mn.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Kullanım Süresi', style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted), textAlign: TextAlign.center),
                  ],
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),
          Text('Hesap Bilgileri', style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 10),
          MnCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ProfileRow(icon: Icons.mail_outline, label: 'E-posta', value: auth.userEmail),
                Divider(height: 1, color: mn.borderSubtle),
                _ProfileRow(icon: Icons.person_outline, label: 'Kullanıcı Adı', value: '@${auth.userName.toLowerCase().replaceAll(' ', '.')}', editable: true),
                Divider(height: 1, color: mn.borderSubtle),
                _ProfileRow(icon: Icons.shield_outlined, label: 'Kimlik Doğrulama', value: 'Doğrulandı', last: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Etkinlik', style: GoogleFonts.newsreader(fontSize: 17, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
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
          MnCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ActivityRow(doc: 'Kira Sözleşmesi', date: '03 Haz', risk: RiskLevel.mid),
                Divider(height: 1, color: mn.borderSubtle),
                _ActivityRow(doc: 'İş Sözleşmesi', date: '29 May', risk: RiskLevel.high, last: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, required this.value, this.editable = false, this.last = false});
  final IconData icon;
  final String label, value;
  final bool editable, last;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted, letterSpacing: 0.02)),
                Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (editable) Icon(Icons.edit_outlined, size: 14, color: mn.textFaint),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.doc, required this.date, required this.risk, this.last = false});
  final String doc, date;
  final RiskLevel risk;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 18, color: mn.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                Text('$date 2026', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: mn.textFaint)),
              ],
            ),
          ),
          RiskPill(risk: risk, small: true),
        ],
      ),
    );
  }
}
