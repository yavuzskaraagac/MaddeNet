import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _future;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final token = context.read<AuthProvider>().token ?? '';
    final api = ApiService();
    _future = api.getProfile(token);
    _statsFuture = api.getAnalyses(token);
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profil', style: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: mn.textSoft),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([_future, _statsFuture]),
        builder: (context, snap) {
          final profile = snap.data?[0];
          final statsData = snap.data?[1];
          final totalAnalyses = (statsData?['toplam'] as num?)?.toInt() ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              // Avatar + name
              Center(
                child: Column(
                  children: [
                    UserAvatar(initials: auth.userInitials, size: 72, fontSize: 24),
                    const SizedBox(height: 14),
                    Text(
                      profile?['full_name'] as String? ?? auth.userName,
                      style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.userEmail,
                      style: GoogleFonts.inter(fontSize: 13, color: mn.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      value: '$totalAnalyses',
                      label: 'Toplam Analiz',
                      loading: snap.connectionState == ConnectionState.waiting,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      value: snap.connectionState == ConnectionState.waiting ? '...' : _memberSince(profile),
                      label: 'Üye Tarihi',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Menu rows
              _ProfileRow(
                icon: Icons.analytics_outlined,
                label: 'Analizlerim',
                onTap: () => context.go('/analyses'),
              ),
              _ProfileRow(
                icon: Icons.folder_outlined,
                label: 'Belgelerim',
                onTap: () => context.go('/documents'),
              ),
              _ProfileRow(
                icon: Icons.settings_outlined,
                label: 'Ayarlar',
                onTap: () => context.go('/settings'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _ProfileRow(
                icon: Icons.logout,
                label: 'Çıkış Yap',
                danger: true,
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _memberSince(Map<String, dynamic>? profile) {
    final created = profile?['created_at'] as String?;
    if (created == null) return '—';
    final dt = DateTime.tryParse(created);
    if (dt == null) return '—';
    return '${dt.year}';
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, this.loading = false});
  final String value;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: mn.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: mn.border)),
      child: Column(
        children: [
          loading
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
              : Text(value, style: GoogleFonts.newsreader(fontSize: 28, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface, height: 1)),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: mn.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, required this.onTap, this.danger = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final color = danger ? mn.riskHigh : Theme.of(context).colorScheme.primary;
    final bgColor = danger ? mn.riskHighSoft : mn.accentSoft;
    final borderColor = danger ? mn.riskHighRing : mn.accentRing;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: mn.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: mn.border)),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w500, color: danger ? mn.riskHigh : Theme.of(context).colorScheme.onSurface))),
            Icon(Icons.chevron_right, size: 18, color: mn.textFaint),
          ],
        ),
      ),
    );
  }
}
