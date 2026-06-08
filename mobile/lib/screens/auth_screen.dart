import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/brand_mark.dart';
import '../widgets/mn_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _showPw = false;
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    bool ok;
    if (_isLogin) {
      ok = await auth.login(_emailCtrl.text.trim(), _pwCtrl.text);
    } else {
      ok = await auth.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _pwCtrl.text);
    }
    if (ok && mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mn.textSoft),
          onPressed: () => context.go('/'),
        ),
        title: BrandLogo(markSize: 22, fontSize: 14),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: mn.textSoft),
            onPressed: themeProvider.toggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs
              Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: mn.border))),
                child: Row(
                  children: [
                    _Tab(label: 'Giriş Yap', active: _isLogin, onTap: () => setState(() => _isLogin = true)),
                    _Tab(label: 'Kayıt Ol', active: !_isLogin, onTap: () => setState(() => _isLogin = false)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.newsreader(fontSize: 26, fontWeight: FontWeight.w500, letterSpacing: -0.025, color: Theme.of(context).colorScheme.onSurface),
                  children: _isLogin
                      ? [const TextSpan(text: 'Tekrar '), TextSpan(text: 'hoşgeldiniz', style: TextStyle(fontStyle: FontStyle.italic, color: accent)), const TextSpan(text: '.')]
                      : [const TextSpan(text: 'Hesabınızı '), TextSpan(text: 'oluşturun', style: TextStyle(fontStyle: FontStyle.italic, color: accent)), const TextSpan(text: '.')],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isLogin ? 'E-posta ve şifrenizle devam edin.' : 'Birkaç saniye sürer. Kart bilgisi gerekmez.',
                style: GoogleFonts.inter(fontSize: 13.5, color: mn.textMuted),
              ),
              const SizedBox(height: 24),

              if (!_isLogin) ...[
                _FieldLabel('Adınız Soyadınız'),
                _InputWrap(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: _inputDec(context, hint: 'Yavuz Atalay', icon: Icons.person_outline),
                    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Ad gerekli' : null,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _FieldLabel('E-posta'),
              _InputWrap(
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDec(context, hint: 'ornek@maddenet.app', icon: Icons.mail_outline),
                  validator: (v) => (v?.contains('@') ?? false) ? null : 'Geçerli e-posta girin',
                ),
              ),
              const SizedBox(height: 12),

              _FieldLabel('Şifre'),
              _InputWrap(
                child: TextFormField(
                  controller: _pwCtrl,
                  obscureText: !_showPw,
                  decoration: _inputDec(
                    context,
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(_showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: mn.textMuted),
                      onPressed: () => setState(() => _showPw = !_showPw),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) >= 6 ? null : 'En az 6 karakter',
                ),
              ),

              if (_isLogin) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Şifremi unuttum?', style: GoogleFonts.inter(fontSize: 12.5, color: mn.textMuted)),
                ),
              ],

              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: mn.riskHighSoft, borderRadius: BorderRadius.circular(8), border: Border.all(color: mn.riskHighRing)),
                  child: Text(auth.error!, style: GoogleFonts.inter(fontSize: 13, color: mn.riskHigh)),
                ),
              ],

              const SizedBox(height: 20),
              MnPrimaryButton(
                label: _isLogin ? 'Giriş Yap' : 'Hesap Oluştur',
                icon: Icons.chevron_right,
                fullWidth: true,
                height: 52,
                loading: auth.loading,
                onPressed: auth.loading ? null : _submit,
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(fontSize: 13, color: mn.textMuted),
                      children: [
                        TextSpan(text: _isLogin ? "Hesabın yok mu? " : "Hesabın var mı? "),
                        TextSpan(text: _isLogin ? 'Kayıt Ol' : 'Giriş Yap', style: TextStyle(color: accent, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(BuildContext context, {required String hint, required IconData icon, Widget? suffix}) {
    final mn = MnColors.of(context);
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: mn.textMuted),
      suffixIcon: suffix,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mn = MnColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? accent : Colors.transparent, width: 2)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: active ? Theme.of(context).colorScheme.onSurface : mn.textMuted),
          ),
        ),
      ),
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
      decoration: BoxDecoration(
        color: mn.bgInset,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mn.border),
      ),
      child: child,
    );
  }
}
