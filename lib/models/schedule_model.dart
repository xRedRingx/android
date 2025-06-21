class DaySchedule {
  String startTime; // e.g., "09:00"
  String endTime;   // e.g., "17:00"
  bool isDayOff;

  DaySchedule({required this.startTime, required this.endTime, this.isDayOff = false});

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isDayOff': isDayOff,
    };
  }

  factory DaySchedule.fromMap(Map<String, dynamic> map) {
    return DaySchedule(
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '17:00',
      isDayOff: map['isDayOff'] ?? false,
    );
  }
}