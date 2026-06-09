import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/document.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_pill.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<List<DocumentModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final token = context.read<AuthProvider>().token ?? '';
    _future = ApiService().getDocuments(token).then((data) {
      final list = data['belgeler'] as List<dynamic>? ?? [];
      return list.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<void> _delete(String id) async {
    final token = context.read<AuthProvider>().token ?? '';
    try {
      await ApiService().deleteDocument(id, token);
      setState(() => _load());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Belgelerim', style: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: mn.textSoft),
            onPressed: () => setState(() => _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: mn.riskHigh),
                  const SizedBox(height: 12),
                  Text('Bağlantı hatası', style: GoogleFonts.inter(fontSize: 15, color: mn.textSoft)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => setState(() => _load()), child: const Text('Tekrar dene')),
                ],
              ),
            );
          }
          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_outlined, size: 56, color: mn.textFaint),
                  const SizedBox(height: 16),
                  Text('Henüz belge yüklemediniz', style: GoogleFonts.inter(fontSize: 15, color: mn.textSoft)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Belge Yükle'),
                    onPressed: () => context.go('/upload'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: docs.length,
            itemBuilder: (_, i) => _DocRow(
              doc: docs[i],
              token: context.read<AuthProvider>().token ?? '',
              onView: () => context.go('/analyses'),
              onDelete: () => _delete(docs[i].id),
            ),
          );
        },
      ),
    );
  }
}

class _DocRow extends StatefulWidget {
  const _DocRow({required this.doc, required this.token, required this.onView, required this.onDelete});
  final DocumentModel doc;
  final String token;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  State<_DocRow> createState() => _DocRowState();
}

class _DocRowState extends State<_DocRow> {
  bool _pdfLoading = false;

  Future<void> _openPdf() async {
    setState(() => _pdfLoading = true);
    try {
      final result = await ApiService().getDownloadUrl(widget.doc.id, widget.token);
      final url = result['url'] as String? ?? result['signedURL'] as String?;
      if (url == null) throw Exception('URL alınamadı');
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Tarayıcı açılamadı');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final doc = widget.doc;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mn.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mn.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
            child: Icon(Icons.picture_as_pdf_outlined, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.fileName, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (doc.isDone)
                      RiskPill(risk: RiskLevel.safe, small: true)
                    else if (doc.isProcessing)
                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: mn.riskMid))
                    else
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: mn.riskHigh, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(doc.statusLabel, style: GoogleFonts.inter(fontSize: 11, color: mn.textMuted)),
                    const SizedBox(width: 8),
                    Text('· ${doc.sizeLabel}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // PDF görüntüle butonu
              GestureDetector(
                onTap: _pdfLoading ? null : _openPdf,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: mn.bgInset, borderRadius: BorderRadius.circular(8), border: Border.all(color: mn.border)),
                  child: _pdfLoading
                      ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: accent))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_outlined, size: 13, color: mn.textMuted),
                            const SizedBox(width: 4),
                            Text('PDF', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: mn.textMuted)),
                          ],
                        ),
                ),
              ),
              if (doc.isDone) ...[
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: widget.onView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(8), border: Border.all(color: mn.accentRing)),
                    child: Text('Analizi Gör', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: accent)),
                  ),
                ),
              ],
              const SizedBox(height: 5),
              GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: mn.riskHighSoft, borderRadius: BorderRadius.circular(8), border: Border.all(color: mn.riskHighRing)),
                  child: Icon(Icons.delete_outline, size: 16, color: mn.riskHigh),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
