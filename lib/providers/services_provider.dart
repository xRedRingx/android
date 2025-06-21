import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import './auth_provider.dart';
import '../models/service_model.dart';

class ServicesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider? _authProvider;

  // Stores services for the logged-in barber
  List<BarberService> _myServices = [];
  // Stores services for any barber being viewed by a customer
  Map<String, List<BarberService>> _viewedBarberServices = {};

  ServicesProvider(this._authProvider) {
    if (_authProvider?.currentUser != null && _authProvider?.currentUser?.role == UserRole.barber) {
      fetchServices();
    }
  }

  List<BarberService> get myServices => [..._myServices];
  List<BarberService> getViewedBarberServices(String barberId) => _viewedBarberServices[barberId] ?? [];

  String? get _userId => _authProvider?.currentUser?.id;

  // Fetches services for the logged-in barber
  Future<void> fetchServices() async {
    if (_userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('services')
          .orderBy('name')
          .get();

      _myServices = snapshot.docs.map((doc) => BarberService.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (error) {
      print("Error fetching services: $error");
    }
  }

  // Fetches services for a specific barber (for customers to view)
  Future<void> fetchServicesForBarber(String barberId) async {
    if (barberId.isEmpty) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(barberId)
          .collection('services')
          .orderBy('name')
          .get();

      final services = snapshot.docs.map((doc) => BarberService.fromMap(doc.data())).toList();
      _viewedBarberServices[barberId] = services;
      notifyListeners();

    } catch (error) {
      print("Error fetching services for barber $barberId: $error");
    }
  }


  Future<void> addService(BarberService service) async {
    if (_userId == null) return;

    try {
      final newServiceRef = _firestore.collection('users').doc(_userId).collection('services').doc();
      service.id = newServiceRef.id;
      await newServiceRef.set(service.toMap());
      _myServices.add(service);
      notifyListeners();
    } catch (error) {
      print("Error adding service: $error");
    }
  }
}
