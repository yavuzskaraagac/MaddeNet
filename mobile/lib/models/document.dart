class DocumentModel {
  final String id;
  final String fileName;
  final int fileSize;
  final String status;
  final DateTime createdAt;
  final String? analysisId;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.status,
    required this.createdAt,
    this.analysisId,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> j) => DocumentModel(
        id: j['id']?.toString() ?? '',
        fileName: j['file_name']?.toString() ?? '',
        fileSize: (j['file_size'] as num?)?.toInt() ?? 0,
        status: j['status']?.toString() ?? 'uploaded',
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
        analysisId: j['analysis_id']?.toString(),
      );

  bool get isDone => status == 'analyzed';
  bool get isProcessing => status == 'processing' || status == 'uploaded';
  bool get isError => status == 'error';

  String get statusLabel => switch (status) {
        'analyzed' => 'Analiz Edildi',
        'processing' => 'İşleniyor',
        'uploaded' => 'Yüklendi',
        'error' => 'Hata',
        _ => status,
      };

  String get sizeLabel {
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(0)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
