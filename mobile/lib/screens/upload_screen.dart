import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mn_button.dart';
import '../widgets/mn_card.dart';
import 'analyzing_sheet.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _file;
  String _contractType = 'Kira Sözleşmesi';
  bool _showTypes = false;
  bool _uploading = false;
  bool _analyzing = false;
  Future<String>? _analysisFuture;

  static const _types = [
    'Kira Sözleşmesi',
    'İş Sözleşmesi',
    'Ticari Sözleşme',
    'Tüketici Sözleşmesi',
    'Genel Sözleşme',
  ];

  static const _typeToCode = {
    'Kira Sözleşmesi': 'kira',
    'İş Sözleşmesi': 'is_sozlesmesi',
    'Ticari Sözleşme': 'ticari',
    'Tüketici Sözleşmesi': 'tuketici',
    'Genel Sözleşme': 'genel',
  };

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) setState(() => _file = result.files.first);
  }

  Future<void> _startAnalysis() async {
    if (_file == null || _file!.path == null) return;

    final token = context.read<AuthProvider>().token;
    if (token == null) {
      context.go('/auth');
      return;
    }

    setState(() => _uploading = true);

    try {
      final api = ApiService();
      final docResult = await api.uploadDocument(_file!.path!, token);
      final documentId = docResult['id'] as String;

      final typeCode = _typeToCode[_contractType] ?? 'genel';
      final future = api
          .startAnalysis(documentId, typeCode, token)
          .then((data) => data['id'] as String);

      setState(() {
        _uploading = false;
        _analyzing = true;
        _analysisFuture = future;
      });
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: mn.textSoft),
              onPressed: () => context.go('/dashboard'),
            ),
            title: Text('Yeni Analiz', style: GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w500)),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    Text(
                      'PDF\'inizi yükleyin, yapay zekâ dakikalar içinde analiz eder.',
                      style: GoogleFonts.inter(fontSize: 13.5, color: mn.textMuted),
                    ),
                    const SizedBox(height: 20),
                    _StepRow(fileSelected: _file != null),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _file == null ? _pickFile : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _file != null ? mn.riskSafeSoft : mn.bgInset,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _file != null ? mn.riskSafeRing : mn.border,
                            width: 1.5,
                          ),
                        ),
                        child: _file != null
                            ? Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(color: mn.riskSafe, shape: BoxShape.circle),
                                    child: const Icon(Icons.check, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_file!.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                                        Text('PDF · ${_formatSize(_file!.size)}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: mn.textMuted)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 18, color: mn.textMuted),
                                    onPressed: () => setState(() => _file = null),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    width: 56, height: 56,
                                    decoration: BoxDecoration(color: mn.bgCard, shape: BoxShape.circle, border: Border.all(color: mn.border)),
                                    child: Icon(Icons.upload_outlined, size: 26, color: mn.textMuted),
                                  ),
                                  const SizedBox(height: 14),
                                  Text('PDF\'inizi seçin', style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('SADECE PDF · MAKSIMUM 20 MB', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint, letterSpacing: 0.08)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('SÖZLEŞME TÜRÜ', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: mn.textFaint, letterSpacing: 0.1)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showTypes = !_showTypes),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: mn.bgInset,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: mn.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.description_outlined, size: 18, color: mn.textMuted),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_contractType, style: GoogleFonts.inter(fontSize: 14.5, color: Theme.of(context).colorScheme.onSurface))),
                            Icon(_showTypes ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: mn.textMuted),
                          ],
                        ),
                      ),
                    ),
                    if (_showTypes) ...[
                      const SizedBox(height: 6),
                      MnCard(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          children: _types.map((t) => GestureDetector(
                            onTap: () => setState(() { _contractType = t; _showTypes = false; }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: _contractType == t ? mn.accentSoft : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(t, style: GoogleFonts.inter(fontSize: 14, color: _contractType == t ? accent : mn.textSoft)),
                                  if (_contractType == t) Icon(Icons.check, size: 16, color: accent),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    MnCard(
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
                            child: Icon(Icons.balance_outlined, size: 18, color: accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                                    children: [
                                      TextSpan(text: '2.392 ', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, color: accent)),
                                      const TextSpan(text: 'kanun maddesiyle karşılaştırılır'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('TBK · İŞ KANUNU · TKHK · TTK', style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: mn.textMuted, letterSpacing: 0.04)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: mn.borderSubtle)),
                ),
                child: _uploading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: accent)),
                              const SizedBox(width: 12),
                              Text('PDF yükleniyor...', style: GoogleFonts.inter(fontSize: 14, color: mn.textMuted)),
                            ],
                          ),
                        ),
                      )
                    : MnPrimaryButton(
                        label: 'Analizi Başlat',
                        icon: Icons.auto_awesome,
                        fullWidth: true,
                        height: 52,
                        onPressed: _file != null ? _startAnalysis : null,
                      ),
              ),
            ],
          ),
        ),
        if (_analyzing && _analysisFuture != null)
          AnalyzingSheet(
            fileName: _file?.name ?? '',
            contractType: _contractType,
            analysisFuture: _analysisFuture!,
            onDone: (analysisId) {
              setState(() => _analyzing = false);
              context.go('/results/$analysisId');
            },
            onError: (error) {
              setState(() => _analyzing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Analiz hatası: $error')),
              );
            },
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.fileSelected});
  final bool fileSelected;

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final steps = [('01', 'Yükle'), ('02', 'İşle'), ('03', 'Analiz'), ('04', 'Bitti')];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) return Expanded(child: Container(height: 1, color: mn.border));
        final idx = i ~/ 2;
        final (n, label) = steps[idx];
        final isDone = idx == 0 && fileSelected;
        final isActive = idx == 1 && fileSelected || idx == 0 && !fileSelected;
        return Column(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? mn.riskSafeSoft : isActive ? Theme.of(context).colorScheme.primary : mn.bgInset,
                border: Border.all(color: isDone ? mn.riskSafeRing : isActive ? Theme.of(context).colorScheme.primary : mn.border),
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check, size: 14, color: mn.riskSafe)
                    : Text(n, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? mn.logoFg : mn.textMuted)),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: isDone ? mn.riskSafe : isActive ? Theme.of(context).colorScheme.primary : mn.textMuted, letterSpacing: 0.04)),
          ],
        );
      }),
    );
  }
}
