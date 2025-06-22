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
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: role.index)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'No user found for that role.');
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
