import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../resources/font_manager.dart';
import '../../resources/styles_manager.dart';
import '../widgets/k_cached_image.dart';

class SingleProductGridItem extends StatefulWidget {
  const SingleProductGridItem({
    super.key,
    required this.product,
    required this.size,
  });

  final Product product;
  final Size size;

  @override
  _SingleProductGridItemState createState() => _SingleProductGridItemState();
}

class _SingleProductGridItemState extends State<SingleProductGridItem> {
  double _averageRating = 0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAverageRating();
  }

  Future<void> _fetchAverageRating() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('prodId', isEqualTo: widget.product.prodId)
          .get();
      List<double> ratings = querySnapshot.docs
          .map((doc) => (doc['rating'] as num).toDouble())
          .toList();
      if (ratings.isEmpty) return;
      double averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      setState(() {
        _averageRating = averageRating;
        _ratingCount = ratings.length;
      });
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.prodId)
          .update({
        'averageRating': averageRating,
        'ratingCount': ratings.length,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting average rating: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KCachedImage(
          image: widget.product.imgUrls[1],
          height: 205,
          width: double.infinity,
        ),
        Positioned(
          bottom: 3,
          left: 3,
          right: 3,
          child: Container(
            height: widget.size.height / 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.topCenter,
                stops: const [0, 1],
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(.03),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        widget.product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getMediumStyle(
                          color: Colors.black,
                          fontSize: FontSize.s14,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price}',
                          style: getBoldStyle(
                            color: Colors.black,
                            fontSize: FontSize.s14,
                          ),
                        ),
                        _ratingCount > 0
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  Text(
                                    '$_averageRating ($_ratingCount)',
                                    style: getRegularStyle(
                                      color: Colors.black,
                                      fontSize: FontSize.s14,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Icon(
                                    Icons.star_border,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                  Text(
                                    '0 (0)',
                                    style: getRegularStyle(
                                      color: Colors.black,
                                      fontSize: FontSize.s14,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
