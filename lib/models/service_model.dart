class BarberService {
  String? id;
  final String name;
  final int duration; // in minutes
  final double price;

  BarberService({
    this.id,
    required this.name,
    required this.duration,
    required this.price,
  });

  factory BarberService.fromMap(Map<String, dynamic> map) {
    return BarberService(
      id: map['id'],
      name: map['name'] ?? '',
      duration: map['duration'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
    };
  }
}
