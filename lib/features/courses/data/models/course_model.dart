class CourseModel {
  final String id;
  final String? themeId;
  final String? departmentId;
  final String courseCode;
  final String courseName; // maps to 'title'
  final int creditHours;
  final List<String> topics;
  final List<String> materialUrls;
  final String? userId;
  final DateTime createdAt;

  // Blueprint metadata
  final double? themeShare;
  final double? courseShare;
  final String? theme;       // Human-readable theme name (e.g. "Programming and Algorithms")
  final List<String> learningDomains; // Knowledge, Skill, Attitude
  final List<String> learningOutcomes;
  final int? itemShareCount;
  final String? bandId;

  CourseModel({
    required this.id,
    this.themeId,
    this.departmentId,
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    this.topics = const [],
    this.materialUrls = const [],
    this.userId,
    required this.createdAt,
    this.themeShare,
    this.courseShare,
    this.theme,
    this.learningDomains = const [],
    this.learningOutcomes = const [],
    this.itemShareCount,
    this.bandId,
  });

  CourseModel copyWith({
    String? id,
    String? themeId,
    String? departmentId,
    String? courseCode,
    String? courseName,
    int? creditHours,
    List<String>? topics,
    List<String>? materialUrls,
    String? userId,
    DateTime? createdAt,
    double? themeShare,
    double? courseShare,
    String? theme,
    List<String>? learningDomains,
    List<String>? learningOutcomes,
    int? itemShareCount,
    String? bandId,
  }) {
    return CourseModel(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
      departmentId: departmentId ?? this.departmentId,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      creditHours: creditHours ?? this.creditHours,
      topics: topics ?? this.topics,
      materialUrls: materialUrls ?? this.materialUrls,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      themeShare: themeShare ?? this.themeShare,
      courseShare: courseShare ?? this.courseShare,
      theme: theme ?? this.theme,
      learningDomains: learningDomains ?? this.learningDomains,
      learningOutcomes: learningOutcomes ?? this.learningOutcomes,
      itemShareCount: itemShareCount ?? this.itemShareCount,
      bandId: bandId ?? this.bandId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_id': themeId,
      'departmentId': departmentId,
      'courseCode': courseCode,
      'title': courseName, // Mapping courseName to 'title'
      'credit_hours': creditHours,
      'topics': topics,
      'materialUrls': materialUrls,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'themeShare': themeShare,
      'courseShare': courseShare,
      'theme': theme,
      'learningDomains': learningDomains,
      'learningOutcomes': learningOutcomes,
      'item_share_count': itemShareCount,
      'bandId': bandId,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String docId) {
    return CourseModel(
      id: docId,
      themeId: map['theme_id'] ?? map['themeId'],
      departmentId: map['departmentId'],
      courseCode: map['courseCode'] ?? '',
      courseName: map['title'] ?? map['courseName'] ?? '',
      creditHours: map['credit_hours'] ?? map['creditHours'] ?? 0,
      topics: List<String>.from(map['topics'] ?? []),
      materialUrls: List<String>.from(map['materialUrls'] ?? []),
      userId: map['userId'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      themeShare: (map['themeShare'] as num?)?.toDouble(),
      courseShare: (map['courseShare'] as num?)?.toDouble(),
      theme: map['theme'],
      learningDomains: List<String>.from(map['learningDomains'] ?? []),
      learningOutcomes: List<String>.from(map['learningOutcomes'] ?? []),
      itemShareCount: map['item_share_count'] ?? map['item_count'] ?? map['questionCount'],
      bandId: map['bandId'],
    );
  }
}
