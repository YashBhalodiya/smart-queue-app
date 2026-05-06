import 'package:flutter/material.dart';

class ServiceType {
  final String name;
  final int averageDurationMinutes; // Used to calculate queue times
  final IconData icon;

  const ServiceType({
    required this.name,
    required this.averageDurationMinutes,
    required this.icon,
  });
}

class ServiceConstants {
  static const List<ServiceType> services = [
    ServiceType(name: 'General Consultation', averageDurationMinutes: 15, icon: Icons.health_and_safety),
    ServiceType(name: 'Specialist Visit', averageDurationMinutes: 30, icon: Icons.medical_services),
    ServiceType(name: 'Follow-up', averageDurationMinutes: 10, icon: Icons.event_repeat),
    ServiceType(name: 'Emergency', averageDurationMinutes: 20, icon: Icons.warning),
    ServiceType(name: 'Diagnostics', averageDurationMinutes: 45, icon: Icons.science),
    // College Offices
    ServiceType(name: 'Document Verification', averageDurationMinutes: 10, icon: Icons.verified_user),
    ServiceType(name: 'Fee Payment', averageDurationMinutes: 5, icon: Icons.payment),
    ServiceType(name: 'Faculty Meeting', averageDurationMinutes: 30, icon: Icons.meeting_room),
    // Salons
    ServiceType(name: 'Haircut & Styling', averageDurationMinutes: 40, icon: Icons.content_cut),
    ServiceType(name: 'Spa & Massage', averageDurationMinutes: 60, icon: Icons.spa),
    ServiceType(name: 'Manicure / Pedicure', averageDurationMinutes: 45, icon: Icons.back_hand),
    // Service Centers
    ServiceType(name: 'Device Repair', averageDurationMinutes: 120, icon: Icons.build),
    ServiceType(name: 'Regular Servicing', averageDurationMinutes: 60, icon: Icons.miscellaneous_services),
    ServiceType(name: 'Warranty Claim', averageDurationMinutes: 20, icon: Icons.assignment_turned_in),
  ];
}
