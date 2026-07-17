import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String complaintId;
  final String description;
  final String category;
  final String status;
  final DateTime timestamp;
  final String? imageUrl;
  final String? adminResponse;

  Complaint({
    required this.complaintId,
    required this.description,
    required this.category,
    this.status = 'Pending',
    required this.timestamp,
    this.imageUrl,
    this.adminResponse,
  });

  // Convert Complaint to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'description': description,
      'category': category,
      'status': status,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'adminResponse': adminResponse,
    };
  }

  // Create Complaint from Firestore document
  factory Complaint.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return Complaint(
      complaintId: map['complaintId'] ?? id,
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'Pending',
      timestamp:
          (map['timestamp'] as Timestamp?)
                  ?.toDate() ??
              DateTime.now(),
      imageUrl: map['imageUrl'],
      adminResponse: map['adminResponse'],
    );
  }
}