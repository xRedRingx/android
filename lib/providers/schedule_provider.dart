import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';
import 'auth_provider.dart';

class ScheduleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider? authProvider;

  Map<String, DaySchedule> _schedule = {};
  bool _isLoading = false;

  ScheduleProvider(this.authProvider);

  Map<String, DaySchedule> get schedule => {..._schedule};
  bool get isLoading => _isLoading;

  String? get _userId => authProvider?.currentUser?.id;

  Future<void> fetchSchedule() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      final data = doc.data();
      if (data != null && data.containsKey('schedule')) {
        final scheduleData = data['schedule'] as Map<String, dynamic>;
        _schedule = scheduleData.map((key, value) =>
            MapEntry(key, DaySchedule.fromMap(value as Map<String, dynamic>)));
      } else {
        // Handle case where schedule doesn't exist yet, maybe create a default one
      }
    } catch (e) {
      print("Error fetching schedule: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- NEW METHOD ---
  Future<void> updateDaySchedule(String day, DaySchedule newDaySchedule) async {
    if (_userId == null) return;

    try {
      // Update the schedule map in the user's document
      await _firestore.collection('users').doc(_userId).update({
        'schedule.$day': newDaySchedule.toMap(),
      });
      // Update local state and notify listeners for immediate UI update
      _schedule[day] = newDaySchedule;
      notifyListeners();
    } catch(e) {
      print("Error updating schedule for $day: $e");
      // Optionally, show an error message to the user
    }
  }
}
