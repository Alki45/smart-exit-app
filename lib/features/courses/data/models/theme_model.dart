class ThemeModel {
  final String id;
  final String? blueprintId;
  final String name;
  final double sharePercent;

  ThemeModel({
    required this.id,
    this.blueprintId,
    required this.name,
    required this.sharePercent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blueprint_id': blueprintId,
      'name': name,
      'share_percent': sharePercent,
    };
  }

  factory ThemeModel.fromMap(Map<String, dynamic> map, String docId) {
    return ThemeModel(
      id: docId,
      blueprintId: map['blueprint_id'],
      name: map['name'] ?? '',
      sharePercent: (map['share_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
