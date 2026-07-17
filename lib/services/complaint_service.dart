import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_complaint_box/models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Submit new complaint
  Future<String?> submitComplaint(
    Complaint complaint,
    File? imageFile,
  ) async {
    try {
      String complaintId =
          _generateComplaintId();

      final complaintData =
          complaint.copyWith(
        complaintId: complaintId,
        imageUrl: null,
      );

      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .set(complaintData.toMap());

      return complaintId;
    } catch (e) {
      print(
        'Error submitting complaint: $e',
      );
      return null;
    }
  }

  // Get complaint by ID
  Future<Complaint?> getComplaintById(
    String complaintId,
  ) async {
    try {
      final doc = await _firestore
          .collection('complaints')
          .doc(complaintId)
          .get();

      if (doc.exists) {
        return Complaint.fromMap(
          doc.data()!,
          doc.id,
        );
      }

      return null;
    } catch (e) {
      print(
        'Error fetching complaint: $e',
      );
      return null;
    }
  }

  // Get all complaints
  Stream<List<Complaint>>
      getAllComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Complaint.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Update status only
  Future<bool> updateStatus(
    String complaintId,
    String newStatus,
  ) async {
    try {
      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .update({
        'status': newStatus,
      });

      return true;
    } catch (e) {
      print(
        'Error updating status: $e',
      );
      return false;
    }
  }

  // Update complaint with response
  Future<bool> updateComplaint({
    required String complaintId,
    required String newStatus,
    required String adminResponse,
  }) async {
    try {
      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .update({
        'status': newStatus,
        'adminResponse':
            adminResponse,
      });

      return true;
    } catch (e) {
      print(
        'Error updating complaint: $e',
      );
      return false;
    }
  }

  // Filter complaints
  Stream<List<Complaint>>
      getFilteredComplaints({
    String? category,
    String? status,
  }) {
    Query query = _firestore
        .collection('complaints')
        .orderBy(
          'timestamp',
          descending: true,
        );

    if (category != null &&
        category != 'All') {
      query = query.where(
        'category',
        isEqualTo: category,
      );
    }

    if (status != null &&
        status != 'All') {
      query = query.where(
        'status',
        isEqualTo: status,
      );
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Complaint.fromMap(
                  doc.data()
                      as Map<String,
                          dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Generate complaint ID
  String _generateComplaintId() {
    return 'CMP${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
  }
}

// Extension
extension ComplaintExtension on Complaint {
  Complaint copyWith({
    String? complaintId,
    String? description,
    String? category,
    String? status,
    DateTime? timestamp,
    String? imageUrl,
    String? adminResponse,
  }) {
    return Complaint(
      complaintId:
          complaintId ??
              this.complaintId,
      description:
          description ??
              this.description,
      category:
          category ?? this.category,
      status: status ?? this.status,
      timestamp:
          timestamp ?? this.timestamp,
      imageUrl:
          imageUrl ?? this.imageUrl,
      adminResponse:
          adminResponse ??
              this.adminResponse,
    );
  }
}