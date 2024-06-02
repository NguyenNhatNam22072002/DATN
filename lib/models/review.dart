import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewId;
  final String customerId;
  final String prodId;
  final String reviewText;
  final double rating;
  final DateTime date;

  Review({
    required this.reviewId,
    required this.customerId,
    required this.prodId,
    required this.reviewText,
    required this.rating,
    required this.date,
  });

  Review.fromJson(DocumentSnapshot item)
      : this(
          reviewId: item['reviewId'],
          customerId: item['customerId'],
          prodId: item['prodId'],
          reviewText: item['reviewText'],
          rating: double.parse(item['rating'].toString()),
          date: item['date'].toDate(),
        );
}
