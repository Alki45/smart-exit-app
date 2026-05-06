class UserModel {
  final String id;
  final String? username;
  final String fullName;
  final String email;
  final String? universityName;
  final String? college;
  final String? bioGoals;
  final String? department; // Legacy or explicit string
  final String? departmentId; // Multi-tenant mapping
  final String? stream;
  final int? academicYear;
  final String? profileImageUrl;
  final String? bandId;
  final DateTime createdAt;
  final DateTime? examDate;
  final String? reminderTime; // e.g., "08:00 AM"

  UserModel({
    required this.id,
    this.username,
    required this.fullName,
    required this.email,
    this.universityName,
    this.college,
    this.bioGoals,
    this.department,
    this.departmentId,
    this.stream,
    this.academicYear,
    this.profileImageUrl,
    this.bandId,
    required this.createdAt,
    this.examDate,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'university_name': universityName,
      'college': college,
      'bio_goals': bioGoals,
      'department': department,
      'department_id': departmentId,
      'stream': stream,
      'academic_year': academicYear,
      'profileImageUrl': profileImageUrl,
      'bandId': bandId,
      'createdAt': createdAt.toIso8601String(),
      'exam_date': examDate?.toIso8601String(),
      'reminderTime': reminderTime,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      username: map['username'],
      fullName: map['full_name'] ?? map['fullName'] ?? '',
      email: map['email'] ?? '',
      universityName: map['university_name'] ?? map['universityName'],
      college: map['college'],
      bioGoals: map['bio_goals'] ?? map['bio'],
      department: map['department'],
      departmentId: map['department_id'],
      stream: map['stream'],
      academicYear: map['academic_year'] ?? map['academicYear'] != null ? int.tryParse(map['academicYear'].toString()) : null,
      profileImageUrl: map['profileImageUrl'],
      bandId: map['bandId'],
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      examDate: map['exam_date'] != null
          ? DateTime.tryParse(map['exam_date'])
          : (map['examDate'] != null
              ? DateTime.tryParse(map['examDate'])
              : null),
      reminderTime: map['reminderTime'],
    );
  }

  factory UserModel.empty() {
    return UserModel(
      id: '',
      fullName: '',
      email: '',
      createdAt: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? username,
    String? fullName,
    String? email,
    String? universityName,
    String? college,
    String? bioGoals,
    String? department,
    String? departmentId,
    String? stream,
    int? academicYear,
    String? profileImageUrl,
    String? bandId,
    DateTime? examDate,
    String? reminderTime,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      universityName: universityName ?? this.universityName,
      college: college ?? this.college,
      bioGoals: bioGoals ?? this.bioGoals,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      stream: stream ?? this.stream,
      academicYear: academicYear ?? this.academicYear,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bandId: bandId ?? this.bandId,
      createdAt: createdAt,
      examDate: examDate ?? this.examDate,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
