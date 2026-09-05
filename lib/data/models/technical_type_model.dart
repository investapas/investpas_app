class TechnicalTypeModel {
  final String name;
  final String value;
  final String action;

  const TechnicalTypeModel({
    required this.name,
    required this.value,
    required this.action,
  });

  factory TechnicalTypeModel.fromJson(Map<String, dynamic> json) {
    return TechnicalTypeModel(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      action: json['action'] as String? ?? 'Neutral',
    );
  }
}
