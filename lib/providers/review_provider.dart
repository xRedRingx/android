import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import './auth_provider.dart';

class ReviewProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider? authProvider;

  ReviewProvider(this.authProvider);

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => [..._reviews];
  bool get isLoading => _isLoading;

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  Future<void> fetchReviewsForBarber(String barberId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(barberId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();
      _reviews = snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching reviews: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReview({
    required String barberId,
    required double rating,
    required String comment,
    required String bookingId,
  }) async {
    if (authProvider?.currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    final reviewRef = _firestore.collection('users').doc(barberId).collection('reviews').doc(bookingId); // Use bookingId as reviewId to prevent duplicate reviews

    final newReview = ReviewModel(
      id: reviewRef.id,
      barberId: barberId,
      customerId: authProvider!.currentUser!.id,
      customerName: authProvider!.currentUser!.name,
      rating: rating,
      comment: comment,
      timestamp: Timestamp.now(),
    );

    try {
      // Use a transaction to ensure both operations succeed or fail together
      await _firestore.runTransaction((transaction) async {
        // 1. Add the review
        transaction.set(reviewRef, newReview.toMap());

        // 2. Update the booking to mark that a review has been left
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        transaction.update(bookingRef, {'status': 'reviewed'});
      });

      // Optimistically add to local list
      _reviews.insert(0, newReview);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error adding review: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
