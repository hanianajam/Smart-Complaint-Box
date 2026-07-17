import 'package:flutter/material.dart';
import 'package:smart_complaint_box/models/complaint_model.dart';
import 'package:smart_complaint_box/services/complaint_service.dart';
import 'package:intl/intl.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Complaint complaint;
  final Function(String)? onStatusUpdated;

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
    this.onStatusUpdated,
  });

  @override
  State<ComplaintDetailScreen> createState() =>
      _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState
    extends State<ComplaintDetailScreen> {
  final _complaintService = ComplaintService();

  final TextEditingController _responseController =
      TextEditingController();

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _responseController.text =
        widget.complaint.adminResponse ?? '';
  }

  Future<void> _resolveComplaint() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter resolution message',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    final success =
        await _complaintService.updateComplaint(
      complaintId: widget.complaint.complaintId,
      newStatus: 'Resolved',
      adminResponse:
          _responseController.text.trim(),
    );

    setState(() => _isUpdating = false);

    if (success) {
      if (widget.onStatusUpdated != null) {
        widget.onStatusUpdated!('Resolved');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Complaint resolved successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update complaint',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.complaint.complaintId),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // STATUS CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          widget.complaint.status,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.complaint.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CATEGORY
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.category),

                    const SizedBox(width: 10),

                    Text(
                      widget.complaint.category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DATE
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),

                    const SizedBox(width: 10),

                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(
                        widget.complaint.timestamp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complaint Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.complaint.description,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // EXISTING RESPONSE
            if (widget.complaint.adminResponse !=
                    null &&
                widget.complaint.adminResponse!
                    .isNotEmpty)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Response',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        widget
                            .complaint
                            .adminResponse!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // RESOLVE SECTION
            if (widget.complaint.status ==
                'Pending')
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resolution Message',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller:
                            _responseController,
                        maxLines: 4,
                        decoration:
                            InputDecoration(
                          hintText:
                              'Enter action taken or resolution details...',
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed: _isUpdating
                              ? null
                              : _resolveComplaint,

                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),

                          label: Text(
                            _isUpdating
                                ? 'Updating...'
                                : 'Mark as Resolved',
                          ),

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.green,
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;

      case 'Pending':
      default:
        return Colors.orange;
    }
  }
}