import 'package:flutter/material.dart';
import 'package:smart_complaint_box/models/complaint_model.dart';
import 'package:smart_complaint_box/screens/admin_login_screen.dart';
import 'package:smart_complaint_box/screens/complaint_detail_screen.dart';
import 'package:smart_complaint_box/services/auth_service.dart';
import 'package:smart_complaint_box/services/complaint_service.dart';
import 'package:smart_complaint_box/widgets/complaint_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  final ComplaintService _complaintService =
      ComplaintService();

  final AuthService _authService = AuthService();

  String? _selectedCategory;
  String? _selectedStatus;

  final List<String> _categories = [
    'Academic',
    'Hostel',
    'Facilities',
    'Other',
  ];

  final List<String> _statuses = [
    'Pending',
    'Resolved',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminLoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // FILTERS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Filter by Category',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),

                    ..._categories.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),

                    ..._statuses.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // COMPLAINT LIST
          Expanded(
            child: StreamBuilder<List<Complaint>>(
              stream:
                  _complaintService.getFilteredComplaints(
                category: _selectedCategory,
                status: _selectedStatus,
              ),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                    ),
                  );
                }

                final complaints = snapshot.data ?? [];

                if (complaints.isEmpty) {
                  return const Center(
                    child: Text(
                      'No complaints found',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: complaints.length,
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  itemBuilder: (context, index) {
                    final complaint =
                        complaints[index];

                    return ComplaintCard(
                      complaint: complaint,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ComplaintDetailScreen(
                              complaint: complaint,
                              onStatusUpdated:
                                  (newStatus) {
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}