import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check current auth state on init
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
        _loadUserFromFirebase(user);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  void _loadUserFromFirebase(User user) {
    _currentUser = UserModel(
      id: user.uid,
      fullName: user.displayName ?? 'User',
      email: user.email!,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
    notifyListeners();
  }

  // Login with Firebase Auth
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        _setError('Please verify your email before logging in. Check your inbox and spam folder.');
        return false;
      }

      _loadUserFromFirebase(userCredential.user!);
      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      _setError(message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with Firebase Auth and send verification email
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      final newUser = UserModel(
        id: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        universityName: university,
        college: college,
        department: department,
        stream: stream,
        academicYear: year,
        createdAt: DateTime.now(),
      );

      // Update profile and save to Firestore in parallel for better speed
      await Future.wait([
        userCredential.user!.updateDisplayName(fullName),
        _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap()),
        userCredential.user!.sendEmailVerification(),
      ]);

      // Sign out until verified
      await _auth.signOut();

      return {
        'success': true,
        'email': email,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      _setError(message);
      return {'success': false};
    } catch (e) {
      _setError(e.toString());
      return {'success': false};
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? universityName,
    String? bio,
    String? department,
    String? stream,
    String? academicYear,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          fullName: fullName,
          universityName: universityName,
          bio: bio,
          department: department,
          stream: stream,
          academicYear: academicYear,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
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
