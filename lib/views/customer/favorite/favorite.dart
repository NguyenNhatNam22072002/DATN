import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../constants/color.dart';
import '../../../models/product.dart';
import '../../../resources/assets_manager.dart';
import '../../components/single_product_grid.dart';
import '../../widgets/loading_widget.dart';
import '../relational_screens/product_details.dart';
import '../../widgets/msg_snackbar.dart';
import '../../../constants/enums/status.dart';
import '../../../constants/firebase_refs/collections.dart';

class FavoriteProducts extends StatefulWidget {
  const FavoriteProducts({Key? key}) : super(key: key);

  @override
  State<FavoriteProducts> createState() => _FavoriteProductsState();
}

class _FavoriteProductsState extends State<FavoriteProducts> {
  bool isLoading = true;
  bool isEmpty = false;
  List<String> prodIds = [];
  var isEnableSke = false;
  int _productLimit = 6; // Initial limit of products to load

  Future<void> fetchWishListProdIds() async {
    await FirebaseFirestore.instance
        .collection('products')
        .where('isFav', isEqualTo: true)
        .get()
        .then((QuerySnapshot data) {
      for (var doc in data.docs) {
        setState(() {
          prodIds.add(doc['prodId']);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWishListProdIds();
  }

  // get context
  get cxt => context;

  Future<void> _refreshProducts() async {
    setState(() {
      isEnableSke = true;
      isEmpty = false;
      prodIds.clear();
    });
    await Future.delayed(const Duration(seconds: 2));
    await fetchWishListProdIds();
    setState(() {
      isEnableSke = false;
    });
  }

  // remove all wishlist items
  void removeAllWishListItems() async {
    Navigator.pop(cxt);

    for (var id in prodIds) {
      await FirebaseCollections.productsCollection.doc(id).update(
        {'isFav': false},
      );
    }

    setState(() {
      prodIds.clear();
    });

    // show message
    displaySnackBar(
      status: Status.success,
      message: 'Removed all wishlist items',
      context: cxt,
    );
  }

  // remove all wishlist items dialog
  void removeAllWishListItemsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove all wishlist items'),
          content:
              const Text('Are you sure you want to remove all wishlist items?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: removeAllWishListItems,
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _loadMoreProducts() {
    setState(() {
      _productLimit += 6; // Increase the product limit by 6
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> searchProductsStream = FirebaseFirestore.instance
        .collection('products')
        .where('isApproved', isEqualTo: true)
        .where('isFav', isEqualTo: true)
        .limit(_productLimit) // Limit number of products fetched
        .snapshots();

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Favorite Products',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (prodIds.isEmpty) ...[
            const SizedBox.shrink(),
          ] else ...[
            GestureDetector(
              onTap: () => removeAllWishListItemsDialog(),
              child: const Icon(
                Icons.delete_forever,
                color: iconColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 18),
          ]
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.black87,
        onRefresh: _refreshProducts,
        child: StreamBuilder<QuerySnapshot>(
          stream: searchProductsStream,
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
              // Show skeleton loader while waiting for data
              return Center(
                child: ListView.builder(
                  itemCount: 1, // Number of skeleton items
                  itemBuilder: (context, index) {
                    return const LoadingWidget(size: 1);
                  },
                ),
              );
            } else {
              isLoading = false;
            }

            if (snapshot.data!.docs.isEmpty) {
              isEmpty = true;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        AssetManager.love,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Ops! Wish list is empty'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    padding: const EdgeInsets.only(
                      top: 0,
                      right: 18,
                      left: 18,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data!.docs[index];

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
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}
