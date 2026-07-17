import 'package:flutter/material.dart';
import 'package:smart_complaint_box/models/complaint_model.dart';
import 'package:smart_complaint_box/services/complaint_service.dart';
import 'package:smart_complaint_box/widgets/complaint_card.dart';
import 'package:smart_complaint_box/widgets/custom_button.dart';

class TrackComplaintScreen
    extends StatefulWidget {
  const TrackComplaintScreen({
    super.key,
  });

  @override
  State<TrackComplaintScreen>
      createState() =>
          _TrackComplaintScreenState();
}

class _TrackComplaintScreenState
    extends State<
        TrackComplaintScreen> {
  final _complaintIdController =
      TextEditingController();

  final _complaintService =
      ComplaintService();

  Complaint? _complaint;

  bool _isLoading = false;

  Future<void> _trackComplaint() async {
    if (_complaintIdController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter Complaint ID',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final complaint =
          await _complaintService
              .getComplaintById(
        _complaintIdController.text
            .trim(),
      );

      if (complaint != null) {
        setState(() {
          _complaint = complaint;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Complaint ID not found',
            ),
            backgroundColor:
                Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor:
              Colors.red,
        ),
      );
    } finally {
      setState(
          () => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _complaintIdController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Track Complaint'),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(
                24,
              ),

              decoration: BoxDecoration(
                color: Colors.blue
                    .withOpacity(0.1),

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    size: 60,
                    color: Theme.of(
                            context)
                        .colorScheme
                        .primary,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Enter your Complaint ID',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Get it from the success screen after submission',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors
                          .grey[600],
                    ),
                    textAlign:
                        TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            TextFormField(
              controller:
                  _complaintIdController,

              decoration:
                  InputDecoration(
                labelText:
                    'Complaint ID',

                prefixIcon:
                    const Icon(
                  Icons
                      .confirmation_number,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),

                suffixIcon:
                    IconButton(
                  icon: const Icon(
                    Icons.clear,
                  ),

                  onPressed: () {
                    _complaintIdController
                        .clear();
                  },
                ),
              ),

              textCapitalization:
                  TextCapitalization
                      .characters,
            ),

            const SizedBox(height: 20),

            CustomButton(
              text: 'Track Status',
              onPressed: _isLoading
                  ? null
                  : _trackComplaint,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 30),

            if (_complaint != null)
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Complaint Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  ComplaintCard(
                    complaint:
                        _complaint!,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ADMIN RESPONSE
                  if (_complaint!
                              .adminResponse !=
                          null &&
                      _complaint!
                          .adminResponse!
                          .isNotEmpty)
                    Card(
                      color: Colors
                          .green
                          .shade50,

                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(20),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons
                                      .admin_panel_settings,
                                  color: Colors
                                      .green,
                                ),

                                SizedBox(
                                  width: 8,
                                ),

                                Text(
                                  'Admin Response',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              _complaint!
                                  .adminResponse!,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}