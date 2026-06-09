import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/mn_button.dart';
import '../widgets/mn_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showConfirm = false;
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final _emailConfirmCtrl = TextEditingController();

  @override
  void dispose() {
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    _emailConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mn.textSoft),
          onPressed: () => context.go('/profile'),
        ),
        title: Text('Ayarlar', style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // E-posta
          _SectionLabel('E-POSTA'),
          MnCard(
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
                  child: Icon(Icons.mail_outline, size: 16, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.userEmail, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                      Text('Ana e-posta adresi', style: GoogleFonts.inter(fontSize: 11.5, color: mn.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: mn.riskSafeSoft, borderRadius: BorderRadius.circular(9999), border: Border.all(color: mn.riskSafeRing)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: mn.riskSafe, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('Doğrulandı', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: mn.riskSafe)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Görünüm
          _SectionLabel('GÖRÜNÜM'),
          MnCard(
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
                  child: Icon(themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 16, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tema', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(fontSize: 11.5, color: mn.textMuted),
                          children: [
                            const TextSpan(text: 'Aktif: '),
                            TextSpan(text: themeProvider.isDark ? 'Koyu' : 'Açık', style: TextStyle(color: mn.textSoft, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _ThemeSwitch(isDark: themeProvider.isDark, onToggle: themeProvider.toggle, mn: mn, accent: accent),
              ],
            ),
          ),

          // Şifre
          _SectionLabel('ŞİFRE DEĞİŞTİR'),
          MnCard(
            child: Column(
              children: [
                _FieldLabel('Yeni Şifre'),
                _InputWrap(child: TextField(
                  controller: _newPwCtrl,
                  obscureText: true,
                  decoration: _dec(context, hint: 'En az 8 karakter', icon: Icons.lock_outline, mn: mn),
                )),
                const SizedBox(height: 12),
                _FieldLabel('Onayla'),
                _InputWrap(child: TextField(
                  controller: _confirmPwCtrl,
                  obscureText: true,
                  decoration: _dec(context, hint: 'Yeni şifrenizi tekrar girin', icon: Icons.lock_outline, mn: mn),
                )),
                const SizedBox(height: 14),
                MnPrimaryButton(label: 'Şifreyi Güncelle', fullWidth: true, onPressed: () {}),
              ],
            ),
          ),

          // Oturum
          _SectionLabel('OTURUM'),
          MnCard(
            child: MnGhostButton(
              label: 'Çıkış Yap',
              icon: Icons.logout,
              fullWidth: true,
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/');
              },
            ),
          ),

          // Tehlikeli Bölge
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mn.riskHighSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: mn.riskHighRing),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: mn.riskHigh),
                    const SizedBox(width: 8),
                    Text('Tehlikeli Bölge', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: mn.riskHigh)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hesabınızı kalıcı olarak sileceksiniz. Tüm belgeler ve analiz geçmişiniz ',
                  style: GoogleFonts.inter(fontSize: 12.5, color: mn.textSoft, height: 1.5),
                ),
                Text('geri alınamayacak', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                Text(' şekilde kaldırılır.', style: GoogleFonts.inter(fontSize: 12.5, color: mn.textSoft)),
                const SizedBox(height: 12),
                if (!_showConfirm) ...[
                  MnDangerButton(
                    label: 'Hesabımı Sil',
                    fullWidth: true,
                    onPressed: () => setState(() => _showConfirm = true),
                  ),
                ] else ...[
                  _FieldLabel('Onaylamak için e-postanızı girin'),
                  _InputWrap(child: TextField(
                    controller: _emailConfirmCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec(context, hint: auth.userEmail, icon: Icons.mail_outline, mn: mn),
                  )),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: MnGhostButton(label: 'Vazgeç', onPressed: () => setState(() => _showConfirm = false), fullWidth: true)),
                      const SizedBox(width: 8),
                      Expanded(child: MnDangerButton(label: 'Kalıcı Olarak Sil', fullWidth: true, onPressed: () {})),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              'MADDENET v1.0.0',
              style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: mn.textFaint, letterSpacing: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(BuildContext context, {required String hint, required IconData icon, required MnColors mn}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: mn.textMuted),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Text(text, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint, letterSpacing: 0.12)),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: mn.textMuted)),
    );
  }
}

class _InputWrap extends StatelessWidget {
  const _InputWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Container(
      decoration: BoxDecoration(color: mn.bgInset, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.border)),
      child: child,
    );
  }
}

class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch({required this.isDark, required this.onToggle, required this.mn, required this.accent});
  final bool isDark;
  final VoidCallback onToggle;
  final MnColors mn;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52, height: 30,
        decoration: BoxDecoration(
          color: isDark ? accent : mn.bgInset,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: isDark ? mn.accentDeep : mn.border),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24, height: 24,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isDark ? mn.logoFg : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}
