import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
import 'auth_provider.dart';

class ScheduleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider? authProvider;

  // Data for the logged-in barber
  Map<String, DaySchedule> _mySchedule = {};
  List<DateTime> _myUnavailableDates = [];

  // Data for barbers being viewed by customers
  final Map<String, Map<String, DaySchedule>> _viewedSchedules = {};
  final Map<String, List<DateTime>> _viewedUnavailableDates = {};

  bool _isLoading = false;

  ScheduleProvider(this.authProvider);

  // Getters for logged-in barber
  Map<String, DaySchedule> get mySchedule => {..._mySchedule};
  List<DateTime> get myUnavailableDates => [..._myUnavailableDates];

  // Getters for viewed barber
  Map<String, DaySchedule> getViewedSchedule(String barberId) => _viewedSchedules[barberId] ?? {};
  List<DateTime> getViewedUnavailableDates(String barberId) => _viewedUnavailableDates[barberId] ?? [];

  bool get isLoading => _isLoading;

  String? get _userId => authProvider?.currentUser?.id;

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> fetchSchedule() async {
    if (_userId == null) return;
    await fetchScheduleForBarber(_userId!, isForLoggedInUser: true);
  }

  Future<void> fetchUnavailableDates() async {
    if (_userId == null) return;
    await fetchUnavailableDatesForBarber(_userId!, isForLoggedInUser: true);
  }

  Future<void> fetchScheduleForBarber(String barberId, {bool isForLoggedInUser = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(barberId).get();
      final data = doc.data();
      Map<String, DaySchedule> schedule = {};
      if (data != null && data.containsKey('schedule')) {
        final scheduleData = data['schedule'] as Map<String, dynamic>;
        schedule = scheduleData.map((key, value) =>
            MapEntry(key, DaySchedule.fromMap(value as Map<String, dynamic>)));
      }
      if (isForLoggedInUser) {
        _mySchedule = schedule;
      } else {
        _viewedSchedules[barberId] = schedule;
      }
    } catch (e) {
      print("Error fetching schedule for $barberId: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnavailableDatesForBarber(String barberId, {bool isForLoggedInUser = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(barberId)
          .collection('unavailableDates')
          .get();

      final dates = snapshot.docs
          .map((doc) => (doc.data()['date'] as Timestamp).toDate())
          .toList();

      if (isForLoggedInUser) {
        _myUnavailableDates = dates;
      } else {
        _viewedUnavailableDates[barberId] = dates;
      }
    } catch (e) {
      print("Error fetching unavailable dates for $barberId: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDaySchedule(String day, DaySchedule newDaySchedule) async {
    if (_userId == null) return;
    try {
      await _firestore.collection('users').doc(_userId).update({
        'schedule.$day': newDaySchedule.toMap(),
      });
      _mySchedule[day] = newDaySchedule;
      notifyListeners();
    } catch(e) {
      print("Error updating schedule for $day: $e");
    }
  }

  Future<void> addUnavailableDate(DateTime date) async {
    if (_userId == null) return;
    try {
      final dateId = DateFormat('yyyy-MM-dd').format(date);
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('unavailableDates')
          .doc(dateId)
          .set({'date': Timestamp.fromDate(date)});

      if (!_myUnavailableDates.any((d) => _isSameDay(d, date))) {
        _myUnavailableDates.add(date);
        _myUnavailableDates.sort((a, b) => a.compareTo(b));
        notifyListeners();
      }
    } catch (e) {
      print("Error adding unavailable date: $e");
    }
  }

  Future<void> removeUnavailableDate(DateTime date) async {
    if (_userId == null) return;
    try {
      final dateId = DateFormat('yyyy-MM-dd').format(date);
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('unavailableDates')
          .doc(dateId)
          .delete();

      _myUnavailableDates.removeWhere((d) => _isSameDay(d, date));
      notifyListeners();
    } catch(e) {
      print("Error removing unavailable date: $e");
    }
  }
}
