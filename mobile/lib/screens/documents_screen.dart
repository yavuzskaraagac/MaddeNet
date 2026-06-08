import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_pill.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String _filter = 'all';

  static const _docs = [
    (name: 'kira-sozlesmesi-2026.pdf', size: '247 KB', date: '03 Haz 2026', status: 'done', risk: 65),
    (name: 'is-sozlesmesi-yavuz.pdf', size: '512 KB', date: '29 May 2026', status: 'done', risk: 82),
    (name: 'tedarik-anlasmasi-q2.pdf', size: '1.2 MB', date: '22 May 2026', status: 'done', risk: 28),
    (name: 'gizlilik-sozlesmesi.pdf', size: '184 KB', date: '20 May 2026', status: 'processing', risk: 0),
    (name: 'sigorta-policesi.pdf', size: '8.1 MB', date: '18 May 2026', status: 'error', risk: 0),
  ];

  List<int> get _visible => List.generate(_docs.length, (i) => i).where((i) {
    if (_filter == 'all') return true;
    return _docs[i].status == _filter;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Belgelerim', style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: mn.textSoft), onPressed: () {}),
          IconButton(icon: Icon(Icons.add, color: mn.textSoft), onPressed: () => context.go('/upload')),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text('Sisteme yüklediğiniz tüm PDF belgeleri ve analiz durumları.',
              style: GoogleFonts.inter(fontSize: 13.5, color: mn.textMuted)),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Chip(label: 'Tümü', count: 5, active: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                const SizedBox(width: 8),
                _Chip(label: 'Tamamlandı', count: 3, active: _filter == 'done', onTap: () => setState(() => _filter = 'done')),
                const SizedBox(width: 8),
                _Chip(label: 'İşleniyor', count: 1, active: _filter == 'processing', onTap: () => setState(() => _filter = 'processing')),
                const SizedBox(width: 8),
                _Chip(label: 'Hata', count: 1, active: _filter == 'error', onTap: () => setState(() => _filter = 'error')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: _visible.map((i) => _DocCard(doc: _docs[i], onAnalysisTap: () => context.go('/results/$i'))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.count, required this.active, required this.onTap});
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? mn.accentSoft : mn.bgCard,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: active ? mn.accentRing : mn.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Theme.of(context).colorScheme.primary : mn.textSoft)),
            const SizedBox(width: 6),
            Text('$count', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: active ? Theme.of(context).colorScheme.primary : mn.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc, required this.onAnalysisTap});
  final ({String name, String size, String date, String status, int risk}) doc;
  final VoidCallback onAnalysisTap;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    Widget statusBadge;
    if (doc.status == 'done') {
      final risk = doc.risk >= 70 ? RiskLevel.high : doc.risk >= 40 ? RiskLevel.mid : RiskLevel.safe;
      statusBadge = RiskPill(risk: risk, small: true);
    } else if (doc.status == 'processing') {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: mn.riskMidSoft, borderRadius: BorderRadius.circular(9999), border: Border.all(color: mn.riskMidRing)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: mn.riskMid)),
            const SizedBox(width: 6),
            Text('İşleniyor', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: mn.riskMid)),
          ],
        ),
      );
    } else {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: mn.riskHighSoft, borderRadius: BorderRadius.circular(9999), border: Border.all(color: mn.riskHighRing)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: mn.riskHigh, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text('Hata', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: mn.riskHigh)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: mn.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: mn.border)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
                child: Icon(Icons.picture_as_pdf_outlined, size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                    Text('${doc.size} · ${doc.date}', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: mn.textFaint)),
                  ],
                ),
              ),
              statusBadge,
            ],
          ),
          if (doc.status == 'done') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: mn.borderSubtle))),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onAnalysisTap,
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(color: mn.bgInset, borderRadius: BorderRadius.circular(9999), border: Border.all(color: mn.border)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart, size: 14, color: mn.textSoft),
                            const SizedBox(width: 6),
                            Text('Analizi Gör', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: mn.textSoft)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(icon: Icons.download_outlined, mn: mn),
                  const SizedBox(width: 8),
                  _IconBtn(icon: Icons.delete_outline, mn: mn),
                ],
              ),
            ),
          ],
          if (doc.status == 'error') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: mn.riskHigh),
                const SizedBox(width: 6),
                Text('Dosya boyutu çok büyük. ', style: GoogleFonts.inter(fontSize: 12, color: mn.riskHigh)),
                Text('Tekrar Dene', style: GoogleFonts.inter(fontSize: 12, color: accent)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.mn});
  final IconData icon;
  final MnColors mn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: mn.bgInset, borderRadius: BorderRadius.circular(9999), border: Border.all(color: mn.border)),
      child: Icon(icon, size: 16, color: mn.textSoft),
    );
  }
}
