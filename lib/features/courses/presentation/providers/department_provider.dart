import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../auth/data/models/department_model.dart';

class DepartmentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _departmentsBox = Hive.box('departmentsBox');
  
  List<DepartmentModel> _departments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<DepartmentModel> get departments {
    if (_searchQuery.isEmpty) return _departments;
    final q = _searchQuery.toLowerCase();
    return _departments.where((d) => 
      d.name.toLowerCase().contains(q) || 
      d.faculty.toLowerCase().contains(q)
    ).toList();
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadDepartments({bool isDemo = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isDemo || !kIsWeb) { // Simple check for demo/offline
        _departments = _departmentsBox.values
            .map((e) => DepartmentModel.fromMap(Map<String, dynamic>.from(e), e['id']))
            .toList();
      } else {
        final snapshot = await _firestore.collection('departments').get();
        _departments = snapshot.docs.map((doc) => DepartmentModel.fromMap(doc.data(), doc.id)).toList();
      }
      
      // Sort alphabetically by name
      _departments.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Error loading departments: $e');
      _errorMessage = 'Failed to load departments. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DepartmentModel?> addDepartment(String name, String faculty, {bool isDemo = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final newDept = DepartmentModel(
        id: id,
        name: name,
        faculty: faculty,
      );
      
      if (isDemo || !kIsWeb) {
        await _departmentsBox.put(id, newDept.toMap());
      } else {
        await _firestore.collection('departments').doc(id).set(newDept.toMap());
      }
      
      _departments.add(newDept);
      _departments.sort((a, b) => a.name.compareTo(b.name));
      
      _isLoading = false;
      notifyListeners();
      return newDept;
    } catch (e) {
      debugPrint('Error adding department: $e');
      _errorMessage = 'Failed to add department. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
