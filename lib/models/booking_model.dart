
class BookingModel {
  final String id;
  final String barberId;
  final String barberName;
  final String customerId;
  final String customerName;
  final List<String> serviceNames;
  final double totalPrice;
  final int totalDuration;
  final DateTime appointmentTime;
  String status; // e.g., 'pending', 'confirmed', 'completed', 'canceled'

  BookingModel({
    required this.id,
    required this.barberId,
    required this.barberName,
    required this.customerId,
    required this.customerName,
    required this.serviceNames,
    required this.totalPrice,
    required this.totalDuration,
    required this.appointmentTime,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barberId': barberId,
      'barberName': barberName,
      'customerId': customerId,
      'customerName': customerName,
      'serviceNames': serviceNames,
      'totalPrice': totalPrice,
      'totalDuration': totalDuration,
      'appointmentTime': appointmentTime.toIso8601String(),
      'status': status,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      barberId: map['barberId'],
      barberName: map['barberName'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      serviceNames: List<String>.from(map['serviceNames']),
      totalPrice: map['totalPrice'],
      totalDuration: map['totalDuration'],
      appointmentTime: DateTime.parse(map['appointmentTime']),
      status: map['status'],
    );
  }
}