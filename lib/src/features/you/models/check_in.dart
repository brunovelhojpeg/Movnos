class CheckIn {
  final String id;
  final DateTime createdAt;
  final double weightKg;
  final double waistCm;
  final double hipCm;

  CheckIn({
    required this.id,
    required this.createdAt,
    required this.weightKg,
    required this.waistCm,
    required this.hipCm,
  });

  factory CheckIn.fromMap(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      weightKg: (json['weight_kg'] as num).toDouble(),
      waistCm: (json['waist_cm'] as num).toDouble(),
      hipCm: (json['hip_cm'] as num).toDouble(),
    );
  }
}
