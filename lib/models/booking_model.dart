class BookingModel {
  final String id;
  final String barberId;
  final String barberName;
  final String customerId;
  final String customerName;
  final String? customerFcmToken;
  final List<String> serviceNames;
  final double totalPrice;
  final int totalDuration;
  final DateTime appointmentTime;
  String status;
  bool reminderSent; // NEW FIELD

  BookingModel({
    required this.id,
    required this.barberId,
    required this.barberName,
    required this.customerId,
    required this.customerName,
    this.customerFcmToken,
    required this.serviceNames,
    required this.totalPrice,
    required this.totalDuration,
    required this.appointmentTime,
    this.status = 'pending',
    this.reminderSent = false, // Default to false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barberId': barberId,
      'barberName': barberName,
      'customerId': customerId,
      'customerName': customerName,
      'customerFcmToken': customerFcmToken,
      'serviceNames': serviceNames,
      'totalPrice': totalPrice,
      'totalDuration': totalDuration,
      'appointmentTime': appointmentTime.toIso8601String(),
      'status': status,
      'reminderSent': reminderSent, // Add to map
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      barberId: map['barberId'],
      barberName: map['barberName'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      customerFcmToken: map['customerFcmToken'],
      serviceNames: List<String>.from(map['serviceNames']),
      totalPrice: map['totalPrice'],
      totalDuration: map['totalDuration'],
      appointmentTime: DateTime.parse(map['appointmentTime']),
      status: map['status'],
      reminderSent: map['reminderSent'] ?? false, // Handle new field
    );
  }
}
