import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isDemoMode = false;
  String? _errorMessage;
  final _settingsBox = Hive.box('settingsBox');
  static const _lastLoginKey = 'last_login_timestamp';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null || _isDemoMode;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check current auth state on init
  AuthProvider() {
    _checkSession();
    _auth.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
        _loadUserFromFirebase(user);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  void _checkSession() {
    final lastLogin = _settingsBox.get(_lastLoginKey);
    if (lastLogin != null) {
      final lastLoginDate = DateTime.fromMillisecondsSinceEpoch(lastLogin);
      final difference = DateTime.now().difference(lastLoginDate);
      
      // If session is older than 24 hours, sign out
      if (difference.inHours >= 24) {
        debugPrint('Session expired (24h). Logging out.');
        logout();
      }
    }
  }

  void _updateLoginTimestamp() {
    _settingsBox.put(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _loadUserFromFirebase(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Fallback for unexpected cases
        _currentUser = UserModel(
          id: user.uid,
          fullName: user.displayName ?? 'User',
          email: user.email!,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Login with Firebase Auth
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    _isDemoMode = false;

    try {
      if (kIsWeb && dotenv.env['DEMO_MODE_ENABLED'] == 'true') {
        await _fallbackToMockLogin(email);
        return true;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        _setError('Please verify your email before logging in.');
        return false;
      }

      await _loadUserFromFirebase(userCredential.user!);
      _updateLoginTimestamp();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.message != null && e.message!.contains('API key not valid')) {
        await _fallbackToMockLogin(email);
        return true;
      }
      _setError(e.message ?? 'Login failed');
      return false;
    } catch (e) {
      if (e.toString().contains('API key not valid')) {
        await _fallbackToMockLogin(email);
        return true;
      }
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fallbackToMockLogin(String email) async {
    debugPrint('Dummy API key detected. Bypassing Firebase and creating mock session for $email.');
    _isDemoMode = true;
    _currentUser = UserModel(
      id: 'mock_user_123',
      fullName: email.split('@').first,
      email: email,
      createdAt: DateTime.now(),
    );
    _updateLoginTimestamp();
  }

  // Demo Login
  Future<void> loginAsDemo() async {
    _setLoading(true);
    _clearError();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    _isDemoMode = true;
    _currentUser = UserModel(
      id: 'demo_user',
      fullName: 'Demo Student',
      email: 'demo@example.com',
      createdAt: DateTime.now(),
    );
    
    _setLoading(false);
    notifyListeners();
  }

  // Register with Firebase Auth
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String university,
    required String college,
    required String department,
    required String stream,
    required String year,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (kIsWeb && dotenv.env['DEMO_MODE_ENABLED'] == 'true') {
        return {'success': true, 'email': email};
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        id: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        universityName: university,
        college: college,
        department: department,
        stream: stream,
        academicYear: int.tryParse(year.replaceAll(RegExp(r'[^0-9]'), '')),
        createdAt: DateTime.now(),
      );

      // 1. Update Display Name
      await userCredential.user!.updateDisplayName(fullName);

      // 2. Save to Firestore with Timeout
      try {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap())
            .timeout(const Duration(seconds: 10)); // Prevent infinite hang
      } catch (e) {
        // If Firestore fails, we still want to send email verification but notify the user
        debugPrint('Firestore registration error: $e');
        _setError('Database connection error. Your account was created but profile data might be delayed. Please try logging in.');
        return {'success': false};
      }

      // 3. Send Verification Email
      await userCredential.user!.sendEmailVerification();

      await _auth.signOut();
      _setLoading(false);

      return {
        'success': true,
        'email': email,
      };
    } on FirebaseAuthException catch (e) {
      if (e.message != null && e.message!.contains('API key not valid')) {
        return {'success': true, 'email': email};
      }
      _setError(e.message ?? 'Registration failed');
      return {'success': false};
    } catch (e) {
      if (e.toString().contains('API key not valid')) {
        return {'success': true, 'email': email};
      }
      _setError(e.toString());
      return {'success': false};
    } finally {
      if (_isLoading) _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? universityName,
    String? universityCollege,
    String? bio,
    String? department,
    String? stream,
    String? academicYear,
    DateTime? examDate,
    String? reminderTime,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        fullName: fullName,
        universityName: universityName,
        college: universityCollege,
        bioGoals: bio,
        department: department,
        stream: stream,
        academicYear: academicYear != null
            ? int.tryParse(academicYear.replaceAll(RegExp(r'[^0-9]'), ''))
            : null,
        examDate: examDate,
        reminderTime: reminderTime,
      );

      await _firestore.collection('users').doc(_currentUser!.id).update(updatedUser.toMap());
      
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (!_isDemoMode) {
      await _auth.signOut();
    }
    _currentUser = null;
    _isDemoMode = false;
    await _settingsBox.delete(_lastLoginKey);
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

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
