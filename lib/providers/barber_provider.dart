import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class BarberProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // No longer need internal list or loading state, StreamBuilder handles this.

  Stream<List<UserModel>> getBarbersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.barber.index)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList());
  }
}
