class QuoteModel {
  final int id;
  final String advice;

  QuoteModel({required this.id, required this.advice});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    final slip = json['slip'] as Map<String, dynamic>? ?? {};
    return QuoteModel(
      id: slip['id'] as int? ?? 0,
      advice: slip['advice'] as String? ?? 'Keep moving forward, adventurer!',
    );
  }
}