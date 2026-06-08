class Document {
  const Document({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.uploadedAt,
    required this.status,
    this.analysisId,
    this.riskScore,
  });

  final String id;
  final String fileName;
  final String fileSize;
  final DateTime uploadedAt;
  final String status; // 'done' | 'processing' | 'error'
  final String? analysisId;
  final int? riskScore;

  String get statusLabel {
    switch (status) {
      case 'done': return 'Tamamlandı';
      case 'processing': return 'İşleniyor';
      default: return 'Hata';
    }
  }

  factory Document.fromJson(Map<String, dynamic> j) => Document(
    id: j['id']?.toString() ?? '',
    fileName: j['file_name'] ?? '',
    fileSize: j['file_size'] ?? '',
    uploadedAt: DateTime.tryParse(j['uploaded_at'] ?? '') ?? DateTime.now(),
    status: j['status'] ?? 'error',
    analysisId: j['analysis_id']?.toString(),
    riskScore: j['risk_score'],
  );
}
