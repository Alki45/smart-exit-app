class BlueprintModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final String? userId;
  final DateTime uploadedAt;
  final Map<String, int> topicWeights; // Topic Name -> Weight percentage

  BlueprintModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.userId,
    required this.uploadedAt,
    this.topicWeights = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'userId': userId,
      'uploadedAt': uploadedAt.toIso8601String(),
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
      topicWeights: Map<String, int>.from(map['topicWeights'] ?? {}),
    );
  }
}
