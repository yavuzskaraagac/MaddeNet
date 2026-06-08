class Clause {
  const Clause({
    required this.id,
    required this.articleNumber,
    required this.riskLevel,
    required this.quote,
    required this.description,
    this.lawName,
    this.lawArticle,
    this.recommendation,
  });

  final String id;
  final String articleNumber;
  final String riskLevel; // 'high' | 'mid' | 'safe'
  final String quote;
  final String description;
  final String? lawName;
  final String? lawArticle;
  final String? recommendation;

  String get riskLabel {
    switch (riskLevel) {
      case 'high': return 'Yüksek';
      case 'mid': return 'Dikkat';
      default: return 'Uygun';
    }
  }

  factory Clause.fromJson(Map<String, dynamic> j) => Clause(
    id: j['id']?.toString() ?? '',
    articleNumber: j['article_number'] ?? '',
    riskLevel: j['risk_level'] ?? 'safe',
    quote: j['quote'] ?? '',
    description: j['description'] ?? '',
    lawName: j['law_name'],
    lawArticle: j['law_article'],
    recommendation: j['recommendation'],
  );
}

class Analysis {
  const Analysis({
    required this.id,
    required this.fileName,
    required this.contractType,
    required this.riskScore,
    required this.createdAt,
    required this.clauses,
  });

  final String id;
  final String fileName;
  final String contractType;
  final int riskScore;
  final DateTime createdAt;
  final List<Clause> clauses;

  String get riskLevel {
    if (riskScore >= 70) return 'high';
    if (riskScore >= 40) return 'mid';
    return 'safe';
  }

  String get riskLabel {
    if (riskScore >= 70) return 'Yüksek Risk';
    if (riskScore >= 40) return 'Orta Risk';
    return 'Düşük Risk';
  }

  int get highCount => clauses.where((c) => c.riskLevel == 'high').length;
  int get midCount => clauses.where((c) => c.riskLevel == 'mid').length;
  int get safeCount => clauses.where((c) => c.riskLevel == 'safe').length;

  factory Analysis.fromJson(Map<String, dynamic> j) => Analysis(
    id: j['id']?.toString() ?? '',
    fileName: j['file_name'] ?? '',
    contractType: j['contract_type'] ?? '',
    riskScore: j['risk_score'] ?? 0,
    createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
    clauses: (j['clauses'] as List<dynamic>? ?? [])
        .map((c) => Clause.fromJson(c as Map<String, dynamic>))
        .toList(),
  );
}
