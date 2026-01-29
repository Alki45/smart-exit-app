import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';
import '../../data/models/blueprint_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../../../core/services/blueprint_parser_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();
  
  List<CourseModel> _courses = [];
  List<BlueprintModel> _blueprints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CourseModel> get courses => _courses;
  List<BlueprintModel> get blueprints => _blueprints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get courseCount => _courses.length;

  // Load user data from Firestore
  Future<void> loadUserData(String userId) async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _repository.getCourses(userId),
        _repository.getBlueprints(userId),
      ]);
      _courses = results[0] as List<CourseModel>;
      _blueprints = results[1] as List<BlueprintModel>;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Generate courses from blueprint text
  Future<void> generateCoursesFromBlueprint(String userId, String blueprintText) async {
     _setLoading(true);
     try {
        final parser = BlueprintParserService();
        final courseNames = parser.extractCourses(blueprintText);
        
        if (courseNames.isEmpty) {
           throw Exception("No course names detected. Please ensure the Blueprint format is correct.");
        }
        
        for (var name in courseNames) {
           final newCourse = CourseModel(
             id: DateTime.now().millisecondsSinceEpoch.toString() + _courses.length.toString(),
             courseCode: 'CODE${_courses.length + 1}',
             courseName: name,
             creditHours: 3,
             topics: [],
             createdAt: DateTime.now(),
           );
           
           await _repository.saveCourse(userId, newCourse);
           _courses.add(newCourse);
        }
        notifyListeners();
     } catch (e) {
        _setError(e.toString());
        rethrow;
     } finally {
        _setLoading(false);
     }
  }

  Future<void> addCourse({
    required String userId,
    required String code, 
    required String name, 
    required int creditHours
  }) async {
    _setLoading(true);
    try {
      final newCourse = CourseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courseCode: code,
        courseName: name,
        creditHours: creditHours,
        createdAt: DateTime.now(),
        topics: [],
      );
      
      await _repository.saveCourse(userId, newCourse);
      _courses.add(newCourse);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add blueprint
  Future<void> addBlueprint(String userId, BlueprintModel blueprint) async {
    _setLoading(true);
    try {
      await _repository.saveBlueprint(userId, blueprint);
      _blueprints.add(blueprint);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }
}
