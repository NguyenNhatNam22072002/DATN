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
        title: const Text('Request Refund'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MediaPicker(
                        selectMedia: (File file, String mediaType) {
                          setState(() {
                            selectedMediaFile = file;
                            selectedMediaType = mediaType;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Comment',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: requestRefund,
                        child: const Text('Request Refund'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
