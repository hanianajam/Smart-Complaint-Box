import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:smart_complaint_box/models/complaint_model.dart';
import 'package:smart_complaint_box/services/complaint_service.dart';
import 'package:smart_complaint_box/widgets/custom_button.dart';
import 'package:smart_complaint_box/widgets/image_picker_widget.dart';
import 'success_screen.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() =>
      _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState
    extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _complaintService = ComplaintService();

  File? _selectedImage;
  Uint8List? _webImage;

  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Academic',
    'Hostel',
    'Facilities',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final complaint = Complaint(
        complaintId: '',
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        timestamp: DateTime.now(),
      );

      final complaintId =
          await _complaintService.submitComplaint(
        complaint,
        _selectedImage,
      );

      if (complaintId != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SuccessScreen(complaintId: complaintId),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to submit complaint. Please try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe your complaint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // CATEGORY
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                validator: (value) =>
                    value == null
                        ? 'Please select a category'
                        : null,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText:
                      'Please provide detailed description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter complaint description';
                  }

                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // IMAGE PICKER
              ImagePickerWidget(
                onImageSelected: (image, webImage) {
                  setState(() {
                    _selectedImage = image;
                    _webImage = webImage;
                  });
                },
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              CustomButton(
                text: _isLoading
                    ? 'Submitting...'
                    : 'Submit Complaint',
                onPressed:
                    _isLoading ? null : _submitComplaint,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}