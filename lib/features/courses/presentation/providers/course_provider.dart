import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/course_model.dart';
import '../../data/models/blueprint_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../../../core/services/blueprint_parser_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();
  final _courseBox = Hive.box('coursesBox');
  final _blueprintBox = Hive.box('blueprintsBox');
  
  List<CourseModel> _courses = [];
  List<BlueprintModel> _blueprints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CourseModel> get courses => _courses;
  List<BlueprintModel> get blueprints => _blueprints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get courseCount => _courses.length;

  // Lab Search, Filter, & Multi-Select State
  String _searchQuery = '';
  int _activeFilterIndex = 0; // 0: All, 1: Department, 2: Year/Theme
  bool _isSelectionMode = false;
  final Set<String> _selectedCourseIds = {};

  String get searchQuery => _searchQuery;
  int get activeFilterIndex => _activeFilterIndex;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedCourseIds => _selectedCourseIds;

  List<CourseModel> get filteredCourses {
    List<CourseModel> result = _courses;
    
    // 1. Search text filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) => 
        c.courseName.toLowerCase().contains(q) || 
        c.courseCode.toLowerCase().contains(q) ||
        (c.theme?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    // 2. Tab Filter
    if (_activeFilterIndex == 1) {
      result.sort((a, b) => a.courseCode.compareTo(b.courseCode));
    }
    else if (_activeFilterIndex == 2) {
      result.sort((a, b) => (a.theme ?? '').compareTo(b.theme ?? ''));
    }

    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterIndex(int index) {
    _activeFilterIndex = index;
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedCourseIds.clear();
    }
    notifyListeners();
  }

  void toggleCourseSelection(String courseId) {
    if (_selectedCourseIds.contains(courseId)) {
      _selectedCourseIds.remove(courseId);
    } else {
      _selectedCourseIds.add(courseId);
    }
    notifyListeners();
  }

  void selectAllCourses(bool selectAll) {
    if (selectAll) {
      _selectedCourseIds.addAll(filteredCourses.map((c) => c.id));
    } else {
      _selectedCourseIds.clear();
    }
    notifyListeners();
  }

  Future<void> deleteSelectedCourses(String userId) async {
    _setLoading(true);
    try {
      if (userId != 'demo_user') {
        for (var id in _selectedCourseIds) {
          await _repository.deleteCourse(userId, id);
        }
      } else {
        for (var id in _selectedCourseIds) {
          await _courseBox.delete(id);
        }
      }
      _courses.removeWhere((c) => _selectedCourseIds.contains(c.id));
      _selectedCourseIds.clear();
      _isSelectionMode = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load user data from Firestore (or Hive for demo/offline)
  Future<void> loadUserData(String userId, {bool isDemo = false}) async {
    _setLoading(true);
    _clearError();
    try {
      if (isDemo || userId == 'demo_user') {
        _courses = _courseBox.values
            .map((e) => CourseModel.fromMap(Map<String, dynamic>.from(e), e['id']))
            .toList();
        _blueprints = _blueprintBox.values
            .map((e) => BlueprintModel.fromMap(Map<String, dynamic>.from(e), e['id']))
            .toList();
        notifyListeners();
        return;
      }
      final results = await Future.wait([
        _repository.getCourses(userId),
        _repository.getBlueprints(userId),
      ]);
      _courses = results[0] as List<CourseModel>;
      _blueprints = results[1] as List<BlueprintModel>;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<CourseModel> getCoursesByDepartment(String? departmentId) {
    if (departmentId == null) return _courses;
    return _courses.where((c) => c.departmentId == departmentId).toList();
  }

  // Generate courses from blueprint text
  Future<void> generateCoursesFromBlueprint({
    required String userId, 
    required String blueprintText,
    String? departmentId,
  }) async {
     _setLoading(true);
     try {
        final parser = BlueprintParserService();
        final coursesData = await parser.extractCourses(blueprintText);
        
        if (coursesData.isEmpty) {
           throw Exception("No courses detected. Please ensure the Blueprint format is correct.");
        }
        
        for (var data in coursesData) {
           final newCourse = CourseModel(
             id: DateTime.now().millisecondsSinceEpoch.toString() + _courses.length.toString(),
             departmentId: departmentId,
             courseCode: data['course_code'] ?? data['courseCode'] ?? 'CODE${_courses.length + 1}',
             courseName: data['course_name'] ?? data['courseName'] ?? 'Unnamed Course',
             creditHours: data['credit_hours'] ?? data['creditHours'] ?? 3,
             theme: data['theme_name'] ?? data['themeName'],
             themeShare: (data['theme_share_percent'] ?? data['themeSharePercent'] as num?)?.toDouble(),
             courseShare: (data['course_share_percent'] ?? data['courseSharePercent'] as num?)?.toDouble(),
             itemShareCount: (data['item_count'] as num?)?.toInt() ?? (data['questionCount'] as num?)?.toInt(),
             learningDomains: List<String>.from(data['learning_domains'] ?? data['learningDomains'] ?? []),
             learningOutcomes: List<String>.from(data['learning_outcomes'] ?? data['learningOutcomes'] ?? []),
             topics: List<String>.from(data['learning_outcomes'] ?? data['learningOutcomes'] ?? []), 
             bandId: data['band'],
             createdAt: DateTime.now(),
             userId: userId,
           );
           
           if (userId != 'demo_user') {
             await _repository.saveCourse(userId, newCourse);
           } else {
             await _courseBox.put(newCourse.id, newCourse.toMap());
           }
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

  Future<bool> addCourse({
    required String userId,
    required String code, 
    required String name, 
    required int creditHours
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newCourse = CourseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courseCode: code,
        courseName: name,
        creditHours: creditHours,
        createdAt: DateTime.now(),
        topics: [],
        userId: userId,
      );
      
      if (userId != 'demo_user') {
        await _repository.saveCourse(userId, newCourse);
      } else {
        await _courseBox.put(newCourse.id, newCourse.toMap());
      }
      _courses.insert(0, newCourse); 
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBlueprint(String userId, BlueprintModel blueprint) async {
    _setLoading(true);
    try {
      if (userId != 'demo_user') {
        await _repository.saveBlueprint(userId, blueprint);
      } else {
        await _blueprintBox.put(blueprint.id, blueprint.toMap());
      }
      _blueprints.add(blueprint);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCourse(String userId, String courseId) async {
    _setLoading(true);
    try {
      if (userId != 'demo_user') {
        await _repository.deleteCourse(userId, courseId);
      } else {
        await _courseBox.delete(courseId);
      }
      _courses.removeWhere((c) => c.id == courseId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBlueprint(String userId, String blueprintId) async {
    _setLoading(true);
    try {
      if (userId != 'demo_user') {
        await _repository.deleteBlueprint(userId, blueprintId);
      } else {
        await _blueprintBox.delete(blueprintId);
      }
      _blueprints.removeWhere((b) => b.id == blueprintId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
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
