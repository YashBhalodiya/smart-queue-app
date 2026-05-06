class Appointment {
  final String id;
  final String name;
  final String serviceType;
  final DateTime date;
  final String timeSlot;
  final String status; // Scheduled, In Progress, Completed, Cancelled
  final int queuePosition;
  final bool isSynced;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.queuePosition,
    this.isSynced = false,
    required this.createdAt,
  });

  // Convert to Map for Hive & Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'queuePosition': queuePosition,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      serviceType: map['serviceType'] ?? '',
      date: DateTime.parse(map['date']),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'Scheduled',
      queuePosition: map['queuePosition'] ?? 0,
      isSynced: map['isSynced'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Create copy with modified fields
  Appointment copyWith({
    String? id,
    String? name,
    String? serviceType,
    DateTime? date,
    String? timeSlot,
    String? status,
    int? queuePosition,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      queuePosition: queuePosition ?? this.queuePosition,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
