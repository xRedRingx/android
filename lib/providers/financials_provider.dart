// Manages fetching financial transactions.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart' as TransactionModel; // Use alias to avoid conflict
import 'auth_provider.dart';

class FinancialsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider? authProvider;

  List<TransactionModel.Transaction> _transactions = [];
  bool _isLoading = false;

  FinancialsProvider(this.authProvider);

  List<TransactionModel.Transaction> get transactions => [..._transactions];
  bool get isLoading => _isLoading;
  String? get _userId => authProvider?.currentUser?.id;

  double get totalEarnings => _transactions.where((t) => !t.isExpense).map((t) => t.amount).fold(0.0, (prev, amount) => prev + amount);
  double get totalSpendings => _transactions.where((t) => t.isExpense).map((t) => t.amount).fold(0.0, (prev, amount) => prev + amount);
  double get netProfit => totalEarnings - totalSpendings;

  Future<void> fetchTransactions() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('barberId', isEqualTo: _userId)
          .orderBy('date', descending: true)
          .limit(20) // Get the last 20 transactions
          .get();

      _transactions = snapshot.docs.map((doc) => TransactionModel.Transaction.fromMap(doc.data())).toList();
    } catch(e) {
      print("Error fetching transactions: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add the missing addTransaction method
  Future<void> addTransaction(TransactionModel.Transaction transaction) async {
    if (_userId == null) return;

    try {
      final docRef = _firestore.collection('transactions').doc();
      final newTransaction = TransactionModel.Transaction(
        id: docRef.id,
        barberId: transaction.barberId,
        title: transaction.title,
        category: transaction.category,
        amount: transaction.amount,
        date: transaction.date,
        isExpense: transaction.isExpense,
      );

      await docRef.set(newTransaction.toMap());

      // Add to local list and notify listeners
      _transactions.insert(0, newTransaction);
      notifyListeners();
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }
}