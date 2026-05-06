class DepartmentModel {
  final String id;
  final String name;
  final String faculty;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.faculty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'faculty': faculty,
    };
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DepartmentModel(
      id: docId,
      name: map['name'] ?? '',
      faculty: map['faculty'] ?? '',
    );
  }

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? faculty,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
    );
  }
}
