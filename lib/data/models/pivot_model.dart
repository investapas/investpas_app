class PivotModel {
  final String pivot;
  final String classic;
  final String fibonacci;
  final String action;

  const PivotModel({
    required this.pivot,
    required this.classic,
    required this.fibonacci,
    required this.action,
  });

  factory PivotModel.fromJson(Map<String, dynamic> json) {
    return PivotModel(
      pivot: json['pivot'] as String? ?? '',
      classic: json['classic'] as String? ?? '',
      fibonacci: json['fibonacci'] as String? ?? '',
      action: json['action'] as String? ?? 'Neutral',
    );
  }
}
