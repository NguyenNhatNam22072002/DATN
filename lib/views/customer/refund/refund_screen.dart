import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shoes_shop/helpers/media_picker.dart';
import 'package:shoes_shop/models/refund.dart';

class RefundScreen extends StatefulWidget {
  final String orderId;
  final String customerId;
  final double orderAmount;
  final String vendorId;

  const RefundScreen({
    super.key,
    required this.orderId,
    required this.customerId,
    required this.orderAmount,
    required this.vendorId,
  });

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  bool isLoading = false;
  File? selectedMediaFile;
  String? selectedMediaType; // 'image' or 'video'
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  Future<String> uploadMediaFile(
      File file, String refundId, String mediaType) async {
    try {
      String filePath =
          'refunds/$refundId/$mediaType/${file.path.split('/').last}';
      TaskSnapshot uploadTask =
          await FirebaseStorage.instance.ref(filePath).putFile(file);
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading media file: $e');
      }
      return '';
    }
  }

  Future<void> requestRefund() async {
    if (selectedMediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload evidence for your refund request.')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      String refundId =
          FirebaseFirestore.instance.collection('refunds').doc().id;
      Refund refund = Refund(
        refundId: refundId,
        vendorId: widget.vendorId,
        orderId: widget.orderId,
        customerId: widget.customerId,
        amount: widget.orderAmount,
        status: 0,
        requestDate: DateTime.now(),
        reason: _reasonController.text,
        comment: _commentController.text,
        isVendorCheck: false,
      );
      String mediaUrl = await uploadMediaFile(
          selectedMediaFile!, refundId, selectedMediaType!);
      await FirebaseFirestore.instance
          .collection('refunds')
          .doc(refundId)
          .set(refund.toJson()
            ..['mediaUrl'] = mediaUrl
            ..['mediaType'] = selectedMediaType);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refund requested successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to request refund: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Refund',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 14),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upload Evidence',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              MediaPicker(
                                selectMedia: (File file, String mediaType) {
                                  setState(() {
                                    selectedMediaFile = file;
                                    selectedMediaType = mediaType;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'Reason for Refund',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Additional Comments',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: requestRefund,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit Refund Request',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
