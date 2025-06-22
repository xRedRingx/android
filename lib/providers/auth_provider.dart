import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/schedule_model.dart';
import './notification_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationProvider _notificationProvider = NotificationProvider();

  UserModel? _currentUser;
  bool _isLoading = false; // For login/register process
  bool _isAuthLoading = true; // For initial app startup check
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthLoading => _isAuthLoading; // New getter
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      await _fetchUserProfile(firebaseUser.uid);
      await _saveDeviceToken(firebaseUser.uid);
    }

    // After the first check completes, set loading to false.
    if (_isAuthLoading) {
      _isAuthLoading = false;
    }
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      _currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    }
  }

  Future<void> _saveDeviceToken(String uid) async {
    String? token = await _notificationProvider.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    }
  }

  Future<bool> login(String email, String password, UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        // This case should ideally be caught by FirebaseAuthException if signIn fails
        _errorMessage = "Authentication failed. User not found.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Directly fetch the user profile to ensure we have it before proceeding
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // User authenticated with Firebase, but no profile in Firestore.
        await _auth.signOut(); // Important: sign them out
        _currentUser = null; // Clear any stale current user
        _errorMessage = "Your account exists but profile data is missing. Please register or contact support.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      UserModel tempUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      if (tempUser.role != role) {
        await _auth.signOut(); // Sign out if role does not match
        _currentUser = null; // Clear any stale current user
        _errorMessage = "Role mismatch. You logged in as a ${tempUser.role.toString().split('.').last}, but selected ${role.toString().split('.').last}. Please select the correct role.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // If role matches, update _currentUser and save device token
      // _onAuthStateChanged will also set _currentUser, but this ensures it's set before login returns true
      _currentUser = tempUser;
      await _saveDeviceToken(firebaseUser.uid); // Explicitly save/update token

      _isLoading = false;
      // _onAuthStateChanged will also call notifyListeners(), but one here is fine.
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        _errorMessage = "Invalid email or password.";
      } else if (e.code == 'user-disabled') {
        _errorMessage = "This account has been disabled.";
      } else if (e.code == 'invalid-email') {
        _errorMessage = "The email address is badly formatted.";
      }
      else {
        _errorMessage = "Login failed: ${e.message}";
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred during login.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        Map<String, dynamic>? defaultSchedule;
        if (role == UserRole.barber) {
          defaultSchedule = {
            'Monday': DaySchedule(startTime: '09:00', endTime: '17:00').toMap(),
            'Tuesday': DaySchedule(startTime: '09:00', endTime: '17:00').toMap(),
            'Wednesday': DaySchedule(startTime: '09:00', endTime: '17:00').toMap(),
            'Thursday': DaySchedule(startTime: '09:00', endTime: '17:00').toMap(),
            'Friday': DaySchedule(startTime: '09:00', endTime: '17:00').toMap(),
            'Saturday': DaySchedule(startTime: '10:00', endTime: '16:00').toMap(),
            'Sunday': DaySchedule(startTime: '', endTime: '', isDayOff: true).toMap(),
          };
        }

        UserModel newUser = UserModel(
          id: firebaseUser.uid,
          email: email,
          name: name,
          phone: '',
          role: role,
          schedule: defaultSchedule,
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "An unknown error occurred.";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred. Please try again.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update(data);
      await _fetchUserProfile(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
