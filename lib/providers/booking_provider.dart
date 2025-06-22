import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Add this import
import '../models/booking_model.dart';

import '../models/transaction_model.dart' as TransactionModel; // Use alias to avoid conflict
import 'auth_provider.dart';
import 'financials_provider.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final AuthProvider? authProvider;
  final FinancialsProvider? financialsProvider;

  BookingProvider(this.authProvider, this.financialsProvider);

  List<BookingModel> _myCustomerBookings = [];
  List<BookingModel> get myCustomerBookings => [..._myCustomerBookings];

  // Add this getter that the CustomerDashboard is looking for
  List<BookingModel> get myBookings => [..._myCustomerBookings];

  List<BookingModel> _myBarberBookings = [];
  List<BookingModel> get myBarberBookings => [..._myBarberBookings];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<BookingModel>> getMyCustomerBookingsStream() {
    if (authProvider?.currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: authProvider!.currentUser!.id)
        .orderBy('appointmentTime', descending: true)
        .snapshots() // Use snapshots() for a stream
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data()))
        .toList());
  }

  Stream<List<BookingModel>> getMyBarberBookingsStream() {
    if (authProvider?.currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('bookings')
        .where('barberId', isEqualTo: authProvider!.currentUser!.id)
        .orderBy('appointmentTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data()))
        .toList());
  }

  // Fetches bookings for a specific barber on a given day
  Future<List<DateTime>> fetchBookedSlots(String barberId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('barberId', isEqualTo: barberId)
          .where('appointmentTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('appointmentTime', isLessThan: endOfDay.toIso8601String())
          .get();
      return snapshot.docs.map((doc) => DateTime.parse(doc['appointmentTime'])).toList();
    } catch (e) {
      print('Error fetching booked slots: $e');
      return [];
    }
  }

  // Fetches all bookings for the currently logged-in customer
  Future<void> fetchMyBookings() async {
    if (authProvider?.currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: authProvider!.currentUser!.id)
          .orderBy('appointmentTime', descending: true)
          .get();

      _myCustomerBookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data()))
          .toList();

    } catch (e) {
      print('Error fetching my bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetches all bookings for the currently logged-in barber
  Future<void> fetchBarberBookings() async {
    if (authProvider?.currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('barberId', isEqualTo: authProvider!.currentUser!.id)
          .orderBy('appointmentTime')
          .get();

      _myBarberBookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data()))
          .toList();

    } catch (e) {
      print('Error fetching barber bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();
    try {
      final docRef = _firestore.collection('bookings').doc();
      final newBooking = BookingModel(
        id: docRef.id,
        barberId: booking.barberId,
        barberName: booking.barberName,
        customerId: authProvider!.currentUser!.id,
        customerName: authProvider!.currentUser!.name,
        customerFcmToken: authProvider!.currentUser!.fcmToken,
        serviceNames: booking.serviceNames,
        totalPrice: booking.totalPrice,
        totalDuration: booking.totalDuration,
        appointmentTime: booking.appointmentTime,
        reminderSent: false, // Ensure this is set on creation
      );
      await docRef.set(newBooking.toMap());
      await fetchMyBookings();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating booking: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- NEW METHOD FOR WALK-INS ---
  Future<bool> createWalkInBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();
    try {
      final docRef = _firestore.collection('bookings').doc();
      final newBooking = BookingModel(
        id: docRef.id,
        barberId: authProvider!.currentUser!.id,
        barberName: authProvider!.currentUser!.name,
        customerId: 'walk-in', // Special ID for walk-in customers
        customerName: booking.customerName, // Name is provided manually
        serviceNames: booking.serviceNames,
        totalPrice: booking.totalPrice,
        totalDuration: booking.totalDuration,
        appointmentTime: booking.appointmentTime,
        status: 'completed', // Walk-ins are typically completed on the spot
      );
      await docRef.set(newBooking.toMap());

      // ✅ Fixed: use TransactionModel.Transaction
      final newTransaction = TransactionModel.Transaction(
        id: '', // Will be generated by provider
        barberId: authProvider!.currentUser!.id,
        title: 'Walk-in: ${booking.customerName}',
        category: 'Earnings',
        amount: booking.totalPrice,
        date: DateTime.now(),
        isExpense: false,
      );
      await financialsProvider?.addTransaction(newTransaction);

      await fetchBarberBookings();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error creating walk-in booking: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  // Updates a booking's status and creates a transaction if completed
  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (authProvider?.currentUser == null) return;

    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      await bookingRef.update({'status': status});

      // Update the local list to reflect the change immediately
      final index = _myBarberBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _myBarberBookings[index].status = status;

        // If the booking is marked as 'completed', create a financial transaction
        if (status == 'completed') {
          final booking = _myBarberBookings[index];
          final newTransaction = TransactionModel.Transaction(
            id: '', // Will be generated by addTransaction method
            barberId: authProvider!.currentUser!.id,
            title: 'Service: ${booking.customerName}',
            category: 'Earnings',
            amount: booking.totalPrice,
            date: DateTime.now(),
            isExpense: false,
          );
          // Use the financialsProvider to add the transaction
          await financialsProvider?.addTransaction(newTransaction);
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error updating booking status: $e");
    }
  }
  // --- NEW METHOD TO ACTIVATE BUSY MODE ---
  Future<String> activateBusyMode({required int durationInMinutes}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final callable = _functions.httpsCallable('activateBusyMode');
      final response = await callable.call<Map<String, dynamic>>(
        {'durationInMinutes': durationInMinutes},
      );

      // Refresh barber's bookings to show updated times
      await fetchBarberBookings();

      _isLoading = false;
      notifyListeners();
      return response.data['message'] as String;
    } on FirebaseFunctionsException catch (e) {
      print('Functions Error: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      return "An error occurred: ${e.message}";
    } catch (e) {
      print('Generic Error: $e');
      _isLoading = false;
      notifyListeners();
      return "An unexpected error occurred.";
    }
  }
  Future<void> cancelBooking(String bookingId) async {
    if (authProvider?.currentUser == null) return;

    try {
      await _firestore.collection('bookings').doc(bookingId).update({'status': 'canceled'});

      // Update local state for immediate UI feedback
      final index = _myCustomerBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _myCustomerBookings[index].status = 'canceled';
        notifyListeners();
      }
    } catch (e) {
      print("Error canceling booking: $e");
    }
  }
}