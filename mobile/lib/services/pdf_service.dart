import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/analysis.dart';

class PdfService {
  static Future<void> shareAnalysisPdf(AnalysisDetail analysis) async {
    final doc = pw.Document();

    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontItalic = await PdfGoogleFonts.interItalic();

    final highColor = PdfColor.fromHex('C75D5D');
    final midColor = PdfColor.fromHex('C99B4B');
    final safeColor = PdfColor.fromHex('6FA88A');
    final accentColor = PdfColor.fromHex('C89A5C');
    final bgColor = PdfColor.fromHex('FAFAF6');
    final textColor = PdfColor.fromHex('1A1A1F');
    final mutedColor = PdfColor.fromHex('6E6E78');
    final borderColor = PdfColor.fromHex('E5E2D6');

    PdfColor riskColor(String sev) => sev == 'red' ? highColor : sev == 'yellow' ? midColor : safeColor;
    String riskLabel(String sev) => sev == 'red' ? 'YÜKSEK RİSK' : sev == 'yellow' ? 'DİKKAT' : 'UYGUN';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold, italic: fontItalic),
        build: (ctx) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: textColor,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('MaddeNet', style: pw.TextStyle(font: fontBold, fontSize: 22, color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('Sözleşme Risk Analiz Raporu', style: pw.TextStyle(font: font, fontSize: 11, color: PdfColor.fromHex('C89A5C'))),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: riskColor(analysis.genelRiskSeviyesi),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    '${analysis.genelRiskSkoru}',
                    style: pw.TextStyle(font: fontBold, fontSize: 26, color: PdfColors.white),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Bilgi satırı
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: bgColor,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _infoCell('Sözleşme Türü', analysis.sozlesmeTuruLabel, font, fontBold, textColor, mutedColor),
                _infoCell('Risk Seviyesi', riskLabel(analysis.genelRiskSeviyesi), font, fontBold, riskColor(analysis.genelRiskSeviyesi), mutedColor),
                _infoCell('Toplam Madde', '${analysis.maddeler.length}', font, fontBold, textColor, mutedColor),
                _infoCell('Yüksek', '${analysis.highCount}', font, fontBold, highColor, mutedColor),
                _infoCell('Dikkat', '${analysis.midCount}', font, fontBold, midColor, mutedColor),
                _infoCell('Uygun', '${analysis.safeCount}', font, fontBold, safeColor, mutedColor),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Maddeler
          pw.Text('Madde Analizleri', style: pw.TextStyle(font: fontBold, fontSize: 14, color: textColor)),
          pw.SizedBox(height: 12),

          ...analysis.maddeler.map((clause) {
            final color = riskColor(clause.riskSeviyesi);
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: borderColor),
                  right: pw.BorderSide(color: borderColor),
                  bottom: pw.BorderSide(color: borderColor),
                  left: pw.BorderSide(color: color, width: 4),
                ),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('MADDE ${clause.maddeNo}', style: pw.TextStyle(font: fontBold, fontSize: 9, color: mutedColor, letterSpacing: 0.5)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(99)),
                          child: pw.Text(riskLabel(clause.riskSeviyesi), style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.white)),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('"${clause.maddMetni}"', style: pw.TextStyle(font: fontItalic, fontSize: 11, color: textColor)),
                    pw.SizedBox(height: 6),
                    pw.Text(clause.sadeAciklama, style: pw.TextStyle(font: font, fontSize: 10, color: mutedColor, lineSpacing: 3)),
                    if (clause.kanunDayanagi != null) ...[
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          pw.Text('⚖ ', style: pw.TextStyle(font: font, fontSize: 10, color: accentColor)),
                          pw.Expanded(
                            child: pw.Text(
                              '${clause.kanunDayanagi}${clause.kanunMaddesi != null ? " — ${clause.kanunMaddesi}" : ""}',
                              style: pw.TextStyle(font: fontBold, fontSize: 9, color: accentColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (clause.oneri != null && clause.oneri!.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('ECF4EF'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('✓ ', style: pw.TextStyle(font: fontBold, fontSize: 10, color: safeColor)),
                            pw.Expanded(
                              child: pw.Text(clause.oneri!, style: pw.TextStyle(font: font, fontSize: 10, color: textColor, lineSpacing: 2)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

          pw.SizedBox(height: 20),
          pw.Divider(color: borderColor),
          pw.SizedBox(height: 8),
          pw.Text(
            'Bu rapor MaddeNet tarafından bilgilendirme amacıyla oluşturulmuştur. Bağlayıcı hukuki danışmanlık niteliği taşımaz. Bir avukata danışmanız önerilir.',
            style: pw.TextStyle(font: fontItalic, fontSize: 9, color: mutedColor),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'MaddeNet_${analysis.sozlesmeTuruLabel.replaceAll(' ', '_')}_Analiz.pdf',
    );
  }

  static pw.Widget _infoCell(String label, String value, pw.Font font, pw.Font bold, PdfColor valColor, PdfColor labelColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 14, color: valColor)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 8, color: labelColor)),
      ],
    );
  }
}
