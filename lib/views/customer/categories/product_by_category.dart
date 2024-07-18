import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants/color.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../components/single_product_grid.dart';
import '../../widgets/loading_widget.dart';
import '../relational_screens/product_details.dart';

class ProductByCategoryScreen extends StatefulWidget {
  const ProductByCategoryScreen({Key? key, required this.category})
      : super(key: key);

  final Category category;

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  int _productLimit = 8; // Initial limit of products to load
  DocumentSnapshot? _lastDocument; // To store the last document snapshot

  // Function to load more products
  void _loadMoreProducts() {
    setState(() {
      _productLimit += 8; // Increase the product limit
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Stream to fetch products based on category and limit
    Stream<QuerySnapshot> productStream = FirebaseFirestore.instance
        .collection('products')
        .orderBy('uploadDate', descending: true)
        .where('isApproved', isEqualTo: true)
        .where('category', isEqualTo: widget.category.title)
        .limit(_productLimit) // Limit number of products fetched
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.chevron_left,
            color: accentColor,
            size: 35,
          ),
        ),
        actions: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: widget.category.imgUrl,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => const CircleAvatar(
                  backgroundImage: AssetImage(
                    AssetManager.placeholderImg,
                  ),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  backgroundImage: AssetImage(
                    AssetManager.placeholderImg,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.category.title,
                style: getMediumStyle(color: Colors.black),
              ),
              const SizedBox(width: 18),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: productStream,
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final DocumentSnapshot document =
                          snapshot.data!.docs[index];
                      final Product product = Product(
                        prodId: document.id,
                        vendorId: document[
                            'vendorId'], // Example: Retrieve vendorId from document
                        productName: document['productName'],
                        price: document['price'],
                        quantity: document['quantity'],
                        category: document['category'],
                        description: document['description'],
                        scheduleDate: document['scheduleDate'].toDate(),
                        isCharging: document['isCharging'],
                        billingAmount: document['billingAmount'],
                        brandName: document['brandName'],
                        sizesAvailable:
                            List<String>.from(document['sizesAvailable']),
                        imgUrls: List<String>.from(document['imgUrls']),
                        uploadDate: document['uploadDate'].toDate(),
                        isFav: document['isFav'] ?? false,
                        isApproved:
                            document['isApproved'] ?? false, // Additional field
                      );

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
                    },
                  ),
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
      ),
    );
  }
}
