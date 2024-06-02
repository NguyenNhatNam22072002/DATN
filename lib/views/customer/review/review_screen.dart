import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/models/review.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';

class ReviewScreen extends StatefulWidget {
  final String customerId;
  final String prodId;

  const ReviewScreen({
    Key? key,
    required this.customerId,
    required this.prodId,
  }) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewTextController = TextEditingController();
  double _rating = 0.0;
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final review = Review(
        reviewId: FirebaseFirestore.instance.collection('reviews').doc().id,
        customerId: widget.customerId,
        prodId: widget.prodId,
        reviewText: _reviewTextController.text,
        rating: _rating,
        date: DateTime.now(),
      );

      await FirebaseCollections.reviewsCollection.doc(review.reviewId).set({
        'reviewId': review.reviewId,
        'customerId': review.customerId,
        'prodId': review.prodId,
        'reviewText': review.reviewText,
        'rating': review.rating,
        'date': review.date,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _reviewTextController,
                decoration: const InputDecoration(labelText: 'Review'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Rating: $_rating',
                style: const TextStyle(fontSize: 18),
              ),
              Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 5,
                label: _rating.toString(),
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
