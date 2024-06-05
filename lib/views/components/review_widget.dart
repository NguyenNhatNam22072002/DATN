import 'package:flutter/material.dart';
import 'package:shoes_shop/resources/font_manager.dart';
import 'package:shoes_shop/resources/styles_manager.dart';

class ReviewsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reviewTexts;

  const ReviewsWidget({super.key, required this.reviewTexts});

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

          ///const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviewTexts.length,
            padding: const EdgeInsets.only(top: 8.0),
            itemBuilder: (context, index) {
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
                        Text(
                          reviewTexts[index]['fullname'],
                          style: getRegularStyle(
                            color: Colors.black,
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight
                                .bold, // hoặc có thể dùng FontWeight.w500
                          ),
                        ),
                        Text(
                          reviewTexts[index]['date']
                              .toString()
                              .substring(0, 10),
                          style: getRegularStyle(
                            color: Colors.grey,
                            fontSize: FontSize.s12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          reviewTexts[index]['reviewText'],
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
}
