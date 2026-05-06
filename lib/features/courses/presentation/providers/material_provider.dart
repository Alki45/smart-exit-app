import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/document_service.dart';
import '../../data/models/course_material.dart';
import 'dart:io';

class MaterialProvider extends ChangeNotifier {
  final AIService _aiService;
  bool _isLoading = false;
  String? _error;
  
  final Box<Map> _materialBox = Hive.box<Map>('materialsBox');

  MaterialProvider(this._aiService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Full Pipeline: Extract -> Analyze -> Save
  Future<CourseMaterial?> processNewMaterial({
    required String courseId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Extract Text
      String extractedText;
      if (file != null) {
        extractedText = await DocumentService.extractTextFromPdf(file);
      } else if (bytes != null) {
        extractedText = await DocumentService.extractTextFromBytes(bytes);
      } else {
        throw Exception('No file or bytes provided');
      }

      if (extractedText.isEmpty) throw Exception('Failed to extract text from document');

      // 2. Analyze Text with AI
      final analysis = await _aiService.analyzeStudyMaterial(extractedText);

      // 3. Create Model
      final material = CourseMaterial(
        id: const Uuid().v4(),
        courseId: courseId,
        fileName: fileName,
        rawText: extractedText,
        analysis: analysis,
        uploadedAt: DateTime.now(),
      );

      // 4. Save to Database (Local Hive)
      await _materialBox.put(material.id, material.toMap());

      _isLoading = false;
      notifyListeners();
      return material;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Retrieves materials for a specific course
  List<CourseMaterial> getMaterialsForCourse(String courseId) {
    return _materialBox.values
        .where((m) => m['courseId'] == courseId)
        .map((m) => CourseMaterial.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// Generates a quiz from specific material
  Future<String?> generateQuizFromMaterial(CourseMaterial material, {int count = 10}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final quizJson = await _aiService.generateQuizJson(
        material.rawText, 
        count: count,
      );
      _isLoading = false;
      notifyListeners();
      return quizJson;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
