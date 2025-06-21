import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class BarberProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _barbers = [];
  bool _isLoading = false;

  List<UserModel> get barbers => [..._barbers];
  bool get isLoading => _isLoading;

  Future<void> fetchBarbers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.barber.index)
          .get();

      _barbers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

    } catch (error) {
      print("Error fetching barbers: $error");
      // In a real app, you would handle this error more gracefully
    }

    _isLoading = false;
    notifyListeners();
  }
}
