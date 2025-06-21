// The Transaction class, moved to its own file.
class Transaction {
  final String id;
  final String barberId;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isExpense;

  Transaction({
    required this.id,
    required this.barberId,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.isExpense = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barberId': barberId,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      barberId: map['barberId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date']),
      isExpense: map['isExpense'] ?? false,
    );
  }
}
