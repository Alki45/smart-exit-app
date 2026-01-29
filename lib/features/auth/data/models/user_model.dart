class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? universityName;
  final String? college;
  final String? bio;
  final String? department;
  final String? stream;
  final String? academicYear;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.universityName,
    this.college,
    this.bio,
    this.department,
    this.stream,
    this.academicYear,
    this.profileImageUrl,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'universityName': universityName,
      'college': college,
      'bio': bio,
      'department': department,
      'stream': stream,
      'academicYear': academicYear,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      universityName: map['universityName'],
      college: map['college'],
      bio: map['bio'],
      department: map['department'],
      stream: map['stream'],
      academicYear: map['academicYear'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Create empty user
  factory UserModel.empty() {
    return UserModel(
      id: '',
      fullName: '',
      email: '',
      createdAt: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? universityName,
    String? college,
    String? bio,
    String? department,
    String? stream,
    String? academicYear,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      universityName: universityName ?? this.universityName,
      college: college ?? this.college,
      bio: bio ?? this.bio,
      department: department ?? this.department,
      stream: stream ?? this.stream,
      academicYear: academicYear ?? this.academicYear,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
    );
  }
}
