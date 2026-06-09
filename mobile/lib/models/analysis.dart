import '../widgets/risk_pill.dart';

class ClauseModel {
  final String maddeNo;
  final String maddMetni;
  final String riskSeviyesi;
  final String sadeAciklama;
  final String? kanunDayanagi;
  final String? kanunMaddesi;
  final String? oneri;

  ClauseModel({
    required this.maddeNo,
    required this.maddMetni,
    required this.riskSeviyesi,
    required this.sadeAciklama,
    this.kanunDayanagi,
    this.kanunMaddesi,
    this.oneri,
  });

  factory ClauseModel.fromJson(Map<String, dynamic> j) => ClauseModel(
        maddeNo: j['madde_no']?.toString() ?? '',
        maddMetni: j['madde_metni']?.toString() ?? '',
        riskSeviyesi: j['risk_seviyesi']?.toString() ?? 'green',
        sadeAciklama: j['sade_aciklama']?.toString() ?? '',
        kanunDayanagi: j['kanun_dayanagi']?.toString(),
        kanunMaddesi: j['kanun_maddesi']?.toString(),
        oneri: j['oneri']?.toString(),
      );

  RiskLevel get riskLevel => riskSeviyesi == 'red'
      ? RiskLevel.high
      : riskSeviyesi == 'yellow'
          ? RiskLevel.mid
          : RiskLevel.safe;
}

class AnalysisSummary {
  final String id;
  final String belgeId;
  final String sozlesmeTuru;
  final int genelRiskSkoru;
  final String genelRiskSeviyesi;
  final int maddeSayisi;
  final DateTime createdAt;

  AnalysisSummary({
    required this.id,
    required this.belgeId,
    required this.sozlesmeTuru,
    required this.genelRiskSkoru,
    required this.genelRiskSeviyesi,
    required this.maddeSayisi,
    required this.createdAt,
  });

  factory AnalysisSummary.fromJson(Map<String, dynamic> j) => AnalysisSummary(
        id: j['id']?.toString() ?? '',
        belgeId: j['belge_id']?.toString() ?? '',
        sozlesmeTuru: j['sozlesme_turu']?.toString() ?? '',
        genelRiskSkoru: (j['genel_risk_skoru'] as num?)?.toInt() ?? 0,
        genelRiskSeviyesi: j['genel_risk_seviyesi']?.toString() ?? 'green',
        maddeSayisi: (j['madde_sayisi'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
      );

  RiskLevel get riskLevel => genelRiskSeviyesi == 'red'
      ? RiskLevel.high
      : genelRiskSeviyesi == 'yellow'
          ? RiskLevel.mid
          : RiskLevel.safe;

  String get sozlesmeTuruLabel => switch (sozlesmeTuru) {
        'kira' => 'Kira Sözleşmesi',
        'is_sozlesmesi' => 'İş Sözleşmesi',
        'ticari' => 'Ticari Sözleşme',
        'tuketici' => 'Tüketici Sözleşmesi',
        _ => 'Genel Sözleşme',
      };
}

class AnalysisDetail {
  final String id;
  final String belgeId;
  final String sozlesmeTuru;
  final int genelRiskSkoru;
  final String genelRiskSeviyesi;
  final List<ClauseModel> maddeler;
  final DateTime createdAt;

  AnalysisDetail({
    required this.id,
    required this.belgeId,
    required this.sozlesmeTuru,
    required this.genelRiskSkoru,
    required this.genelRiskSeviyesi,
    required this.maddeler,
    required this.createdAt,
  });

  factory AnalysisDetail.fromJson(Map<String, dynamic> j) => AnalysisDetail(
        id: j['id']?.toString() ?? '',
        belgeId: j['belge_id']?.toString() ?? '',
        sozlesmeTuru: j['sozlesme_turu']?.toString() ?? '',
        genelRiskSkoru: (j['genel_risk_skoru'] as num?)?.toInt() ?? 0,
        genelRiskSeviyesi: j['genel_risk_seviyesi']?.toString() ?? 'green',
        maddeler: (j['maddeler'] as List<dynamic>? ?? [])
            .map((m) => ClauseModel.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
      );

  int get highCount => maddeler.where((m) => m.riskSeviyesi == 'red').length;
  int get midCount => maddeler.where((m) => m.riskSeviyesi == 'yellow').length;
  int get safeCount => maddeler.where((m) => m.riskSeviyesi == 'green').length;

  RiskLevel get riskLevel => genelRiskSeviyesi == 'red'
      ? RiskLevel.high
      : genelRiskSeviyesi == 'yellow'
          ? RiskLevel.mid
          : RiskLevel.safe;

  String get sozlesmeTuruLabel => switch (sozlesmeTuru) {
        'kira' => 'Kira Sözleşmesi',
        'is_sozlesmesi' => 'İş Sözleşmesi',
        'ticari' => 'Ticari Sözleşme',
        'tuketici' => 'Tüketici Sözleşmesi',
        _ => 'Genel Sözleşme',
      };
}
