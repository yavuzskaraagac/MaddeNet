import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AnalyzingSheet extends StatefulWidget {
  const AnalyzingSheet({
    super.key,
    required this.fileName,
    required this.contractType,
    required this.analysisFuture,
    required this.onDone,
    required this.onError,
  });

  final String fileName;
  final String contractType;
  final Future<String> analysisFuture;
  final void Function(String analysisId) onDone;
  final void Function(String error) onError;

  @override
  State<AnalyzingSheet> createState() => _AnalyzingSheetState();
}

class _AnalyzingSheetState extends State<AnalyzingSheet> {
  static const _stages = [
    'PDF okunuyor ve metne dönüştürülüyor',
    'Sözleşme maddeleri tespit ediliyor',
    'RAG — kanun veritabanında arama',
    'GPT-4o ile her madde değerlendiriliyor',
    'Risk seviyeleri ve öneriler oluşturuluyor',
    'Sonuçlar kaydediliyor',
  ];

  double _pct = 0;
  int _step = 0;
  Timer? _timer;
  bool _apiDone = false;
  String? _analysisId;
  bool _finalizing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    widget.analysisFuture.then((id) {
      if (!mounted) return;
      _apiDone = true;
      _analysisId = id;
      // If animation already at 90%+, finalize immediately
      if (_pct >= 90) _finalize();
    }).catchError((e) {
      if (!mounted) return;
      _timer?.cancel();
      widget.onError(e.toString().replaceFirst('Exception: ', ''));
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        if (_pct < 90) {
          // Reach 90% in ~24 seconds (0.3 per 80ms)
          _pct = min(90, _pct + 0.3);
          _step = (_pct / (100 / _stages.length)).floor().clamp(0, _stages.length - 1);
        } else if (_apiDone && !_finalizing) {
          _finalize();
        }
        // At 90%, freeze and wait for API
      });
    });
  }

  void _finalize() {
    _finalizing = true;
    _timer?.cancel();
    setState(() {
      _pct = 100;
      _step = _stages.length - 1;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) widget.onDone(_analysisId!);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mn = MnColors.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final isWaiting = _pct >= 90 && !_apiDone;

    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
            decoration: BoxDecoration(
              color: mn.bgElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: mn.border)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, -20))],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: mn.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: mn.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: mn.accentRing)),
                        child: Icon(Icons.auto_awesome, size: 18, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(text: isWaiting ? 'Yapay zeka analiz ediyor' : 'Analiz yapılıyor', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                  TextSpan(text: '…', style: TextStyle(color: accent)),
                                ],
                              ),
                            ),
                            Text(
                              '${widget.fileName} · ${widget.contractType}',
                              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: mn.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isWaiting ? 'GPT-4o yanıt bekliyor...' : '${_step + 1}/${_stages.length} aşama',
                        style: GoogleFonts.inter(fontSize: 12, color: mn.textMuted),
                      ),
                      Text('%${_pct.round()}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _pct / 100,
                      minHeight: 6,
                      backgroundColor: mn.bgInset,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_stages.length, (i) {
                    final isDone = i < _step || _pct >= 100;
                    final isActive = i == _step && _pct < 100;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: i == 0 ? null : Border(top: BorderSide(color: mn.border)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone ? mn.riskSafeSoft : isActive ? mn.accentSoft : mn.bgInset,
                              border: Border.all(color: isDone ? mn.riskSafeRing : isActive ? mn.accentRing : mn.border),
                            ),
                            child: Center(
                              child: isDone
                                  ? Icon(Icons.check, size: 12, color: mn.riskSafe)
                                  : isActive
                                      ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: accent))
                                      : Text('${i + 1}', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w600, color: mn.textMuted)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _stages[i],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDone || isActive ? Theme.of(context).colorScheme.onSurface : mn.textMuted,
                                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.balance_outlined, size: 14, color: mn.textMuted),
                      const SizedBox(width: 8),
                      Text('Bilgilendirme amaçlıdır.', style: GoogleFonts.inter(fontSize: 11.5, color: mn.textMuted)),
                    ],
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
