import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/question_generator_service.dart';
import '../../../../features/quizzes/presentation/providers/quiz_provider.dart';
import '../../../../features/quizzes/data/models/quiz_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/blueprint_model.dart';
import '../providers/course_provider.dart';

class UploadLogic {
  final BuildContext context; 
  final VoidCallback onUpdate;
  final String? courseId;
  final String? departmentId;
  
  UploadLogic(this.context, this.onUpdate, {this.courseId, this.departmentId});

  String? fileName, filePath;
  Uint8List? fileBytes;
  bool isUploading = false;
  String status = '', type = 'material';

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result != null) { 
      fileName = result.files.single.name; 
      filePath = result.files.single.path; 
      fileBytes = result.files.single.bytes;
      onUpdate(); 
    }
  }

  void clearFile() { fileName = null; filePath = null; fileBytes = null; onUpdate(); }

  Future<void> upload() async {
    if (fileName == null || (filePath == null && fileBytes == null)) return;
    final uid = Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? 'demo_user';

    isUploading = true; status = 'Starting...'; onUpdate();
    try {
      if (type == 'material') await _processMaterial(uid);
      else await _processBlueprint(uid);
      _showSuccess();
    } catch (e) { _showError(e.toString()); }
    finally { isUploading = false; onUpdate(); }
  }

  Future<void> _processMaterial(String uid) async {
    status = 'Extracting text...'; onUpdate();
    final text = await PdfService().extractText(path: filePath, bytes: fileBytes);
    status = 'Generating quizzes...'; onUpdate();
    final qs = await QuestionGeneratorService().generateQuestions(text);
    
    status = 'Saving...'; onUpdate();
    final targetCourseId = courseId ?? '1'; // Fallback to 1 if not specific
    
    await Provider.of<QuizProvider>(context, listen: false).saveQuiz(uid, QuizModel(
      id: const Uuid().v4(), 
      courseId: targetCourseId, 
      title: 'Quiz: $fileName', 
      duration: 20, 
      questions: qs, 
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _processBlueprint(String uid) async {
    status = 'Analyzing blueprint...'; onUpdate();
    final text = await PdfService().extractText(path: filePath, bytes: fileBytes);
    await Provider.of<CourseProvider>(context, listen: false).generateCoursesFromBlueprint(
      userId: uid, 
      blueprintText: text,
      departmentId: departmentId,
    );
    await Provider.of<CourseProvider>(context, listen: false).addBlueprint(uid, BlueprintModel(
      id: const Uuid().v4(), 
      fileName: fileName!, 
      fileUrl: filePath ?? 'uploaded_locally', 
      uploadedAt: DateTime.now(),
      deptId: departmentId,
    ));
  }

  void _showSuccess() { /* Implementation omitted for brevity or moved to widget */ }
  void _showError(String m) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))); }
}
