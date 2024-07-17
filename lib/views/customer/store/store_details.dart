import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants/color.dart';
import '../../../helpers/word_reverse.dart';
import '../../../models/product.dart';
import '../../../models/vendor.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../components/single_product_grid.dart';
import '../../widgets/item_row.dart';
import '../../widgets/k_cached_image.dart';
import '../../widgets/loading_widget.dart';
import '../relational_screens/product_details.dart';

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({Key? key, required this.vendor}) : super(key: key);

  final Vendor vendor;

  @override
  _StoreDetailsScreenState createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  int _productLimit = 6; // Initial limit of products to load
  DocumentSnapshot? _lastDocument; // To store the last document snapshot

  // Function to load more products
  void _loadMoreProducts() {
    setState(() {
      _productLimit += 2; // Increase the product limit
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Stream to fetch products based on vendorId and limit
    Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('isApproved', isEqualTo: true)
        .where('vendorId', isEqualTo: widget.vendor.storeId)
        .limit(_productLimit) // Limit number of products fetched
        .snapshots();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.chevron_left,
            color: primaryColor,
            size: 35,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KCachedImage(
              image: widget.vendor.storeImgUrl,
              height: size.height / 2.3,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vendor.storeName,
                    style: getBoldStyle(
                      color: Colors.black,
                      fontSize: FontSize.s30,
                    ),
                  ),
                  Text(
                    '${widget.vendor.city} ${widget.vendor.state} ${reversedWord(widget.vendor.country)}',
                    style: getRegularStyle(
                      color: Colors.black,
                      fontSize: FontSize.s16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ItemRow(
                    value: widget.vendor.email,
                    title: 'Email: ',
                  ),
                  const SizedBox(height: 5),
                  ItemRow(
                    value: widget.vendor.phone,
                    title: 'Phone Number: ',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Products',
                    style: getRegularStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.s16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Product StreamBuilder
                  StreamBuilder<QuerySnapshot>(
                    stream: productsStream,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  AssetManager.warningImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text('An error occurred!'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: LoadingWidget(size: 30),
                        );
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  AssetManager.addImage,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text('Product list is empty'),
                            ],
                          ),
                        );
                      }

                      List<Widget> productWidgets =
                          snapshot.data!.docs.map((doc) {
                        final item = doc;
                        Product product = Product.fromJson(item);

                        return InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                product: product,
                              ),
                            ),
                          ),
                          child: SingleProductGridItem(
                            product: product,
                            size: size,
                          ),
                        );
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: productWidgets,
                          ),
                          if (snapshot.data!.docs.length >= _productLimit)
                            // Show load more button if more products can be loaded
                            Center(
                              child: ElevatedButton(
                                onPressed: _loadMoreProducts,
                                child: Text('Load More'),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
