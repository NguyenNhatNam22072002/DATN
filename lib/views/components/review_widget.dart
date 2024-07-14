import 'package:flutter/material.dart';
import 'package:shoes_shop/resources/font_manager.dart';
import 'package:shoes_shop/resources/styles_manager.dart';

class ReviewsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const ReviewsWidget({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: getRegularStyle(
              color: Colors.black,
              fontSize: FontSize.s16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            padding: const EdgeInsets.only(top: 8.0),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['fullname'] ?? 'Anonymous',
                              style: getRegularStyle(
                                color: Colors.black,
                                fontSize: FontSize.s14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStarRating(review['rating'] ?? 0),
                          ],
                        ),
                        Text(
                          _formatDate(review['date']),
                          style: getRegularStyle(
                            color: Colors.grey,
                            fontSize: FontSize.s12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review['reviewText'] ?? '',
                          style: getRegularStyle(
                            color: Colors.black,
                            fontSize: FontSize.s14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(num rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18,
          );
        }),
        const SizedBox(width: 5),
        Text(
          rating.toStringAsFixed(1),
          style: getRegularStyle(
            color: Colors.black,
            fontSize: FontSize.s14,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
