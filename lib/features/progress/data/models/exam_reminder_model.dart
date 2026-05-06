class ExamReminderModel {
  final String id;
  final String userId;
  final DateTime examDate;
  final bool isReminderActive;
  final String? customMessage;

  ExamReminderModel({
    required this.id,
    required this.userId,
    required this.examDate,
    this.isReminderActive = true,
    this.customMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'exam_date': examDate.toIso8601String(),
      'is_reminder_active': isReminderActive,
      'custom_message': customMessage,
    };
  }

  factory ExamReminderModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExamReminderModel(
      id: docId,
      userId: map['user_id'] ?? '',
      examDate: map['exam_date'] != null
          ? DateTime.tryParse(map['exam_date']) ?? DateTime.now()
          : DateTime.now(),
      isReminderActive: map['is_reminder_active'] ?? true,
      customMessage: map['custom_message'],
    );
  }

  ExamReminderModel copyWith({
    String? id,
    String? userId,
    DateTime? examDate,
    bool? isReminderActive,
    String? customMessage,
  }) {
    return ExamReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      examDate: examDate ?? this.examDate,
      isReminderActive: isReminderActive ?? this.isReminderActive,
      customMessage: customMessage ?? this.customMessage,
    );
  }
}
