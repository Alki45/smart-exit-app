class BlueprintModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final String? userId;
  final DateTime uploadedAt;
  final String? deptId;
  final int? academicYearEc;
  final int? totalItems;
  final Map<String, int> topicWeights; // Topic Name -> Weight percentage

  BlueprintModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.userId,
    required this.uploadedAt,
    this.deptId,
    this.academicYearEc,
    this.totalItems,
    this.topicWeights = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'userId': userId,
      'uploadedAt': uploadedAt.toIso8601String(),
      'dept_id': deptId,
      'academic_year_ec': academicYearEc,
      'total_items': totalItems,
      'topicWeights': topicWeights,
    };
  }

  factory BlueprintModel.fromMap(Map<String, dynamic> map, String docId) {
    return BlueprintModel(
      id: docId,
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      userId: map['userId'],
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt']) ?? DateTime.now()
          : DateTime.now(),
      deptId: map['dept_id'],
      academicYearEc: map['academic_year_ec'],
      totalItems: map['total_items'],
      topicWeights: Map<String, int>.from(map['topicWeights'] ?? {}),
    );
  }
}
