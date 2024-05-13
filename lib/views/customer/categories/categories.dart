import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../constants/firebase_refs/collections.dart';
import '../../../models/category.dart';
import '../../../resources/assets_manager.dart';
import '../../components/single_category_grid.dart';
import '../../widgets/loading_widget.dart';
import 'product_by_category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Stream<QuerySnapshot> categoryStream;
  var isEnableSke = false;
  @override
  void initState() {
    super.initState();
    categoryStream = FirebaseCollections.categoriesCollection.snapshots();
  }

  Future<void> _refreshCategories() async {
    setState(() {
      isEnableSke = true;
    });
    // Simulate a delay of 2 seconds
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isEnableSke = false;
      // Reset the stream with new data
      categoryStream = FirebaseCollections.categoriesCollection.snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.black87,
        onRefresh: _refreshCategories,
        child: StreamBuilder<QuerySnapshot>(
          stream: categoryStream,
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
                    const SizedBox(width: 5),
                    const Text('An error occurred!'),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show skeleton loader while waiting for data
              return ListView.builder(
                itemCount: 6, // Number of skeleton items
                itemBuilder: (context, index) {
                  return LoadingWidget(size: 30);
                },
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
                    const SizedBox(width: 5),
                    const Text('Category list is empty'),
                  ],
                ),
              );
            }

            return Skeletonizer(
              enabled: isEnableSke,
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.only(
                  top: 0,
                  right: 18,
                  left: 18,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data!.docs[index];

                  Category category = Category.fromJson(item);

                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductByCategoryScreen(
                          category: category,
                        ),
                      ),
                    ),
                    child: SingleCategoryGridItem(
                      category: category,
                      size: size,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
