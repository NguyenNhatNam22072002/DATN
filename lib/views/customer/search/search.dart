import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/product.dart';
import '../../../resources/assets_manager.dart';
import '../../components/single_product_grid.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/search_box.dart';
import '../relational_screens/product_details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchText = TextEditingController();
  int _productLimit = 20; // Initial limit of products to load

  @override
  void initState() {
    super.initState();

    searchText.addListener(() {
      setState(() {});
    });
  }

  void _loadMoreProducts() {
    setState(() {
      _productLimit += 10; // Increase the product limit by 6
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> searchProductsStream = FirebaseFirestore.instance
        .collection('products')
        .where('isApproved', isEqualTo: true)
        .snapshots();

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchBox(
            searchText: searchText,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(
              child: LoadingWidget(size: 30),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return searchText.text.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            AssetManager.ops,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Ops! No product matches search word'),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          }

          final searchedData = snapshot.data!.docs.where((doc) {
            final productName = doc['productName'].toString().toLowerCase();
            final category = doc['category'].toString().toLowerCase();
            final description = doc['description'].toString().toLowerCase();
            return productName.contains(searchText.text.toLowerCase()) ||
                category.contains(searchText.text.toLowerCase()) ||
                description.contains(searchText.text.toLowerCase());
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    top: 10,
                    right: 18,
                    left: 18,
                    bottom: 18, // Bottom padding for load more button
                  ),
                  itemCount: _productLimit <= searchedData.length
                      ? _productLimit
                      : searchedData.length,
                  itemBuilder: (context, index) {
                    final item = searchedData[index];

                    Product product = Product.fromJson(item);

                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            product: product,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SingleProductGridItem(
                            product: product,
                            size: size,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 12); // Space between items
                  },
                ),
              ),
              if (_productLimit < searchedData.length)
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
    );
  }
}
