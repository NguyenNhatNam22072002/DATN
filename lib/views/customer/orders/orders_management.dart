import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/constants/color.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import 'package:shoes_shop/views/components/single_user_checkout_list.dart';
import 'package:shoes_shop/views/widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../resources/assets_manager.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  Uuid uid = const Uuid();
  int _orderLimit = 6; // Initial limit of orders to load

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> ordersStream = FirebaseCollections.ordersCollection
        .where('customerId', isEqualTo: userId)
        //.orderBy('date', descending: true) // Order by date descending
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Orders Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left,
                color: primaryColor,
                size: 35,
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
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
                  Text(
                      'An error occurred: ${snapshot.error}'), // Hiển thị lỗi cụ thể
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
                  const Text('Order list is empty'),
                ],
              ),
            );
          }

          // Lấy danh sách dữ liệu và sắp xếp theo ngày nhập
          List<QueryDocumentSnapshot> sortedDocs = snapshot.data!.docs.toList();
          sortedDocs.sort((a, b) {
            Timestamp dateA = a['date'];
            Timestamp dateB = b['date'];
            return dateA.compareTo(dateB);
          });

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final item = sortedDocs[index];

              CheckedOutItem checkedOutItem = CheckedOutItem.fromJson(item);

                    return Slidable(
                      key: Key(item.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            borderRadius: BorderRadius.circular(10),
                            onPressed: (context) {},
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.info,
                            label: 'Details',
                          ),
                        ],
                      ),
                      child: SingleUserCheckOutList(
                        checkoutItem: checkedOutItem,
                      ),
                    );
                  },
                ),
              ),
              if (_orderLimit < snapshot.data!.docs.length)
                // Show load more button if more orders can be loaded
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _orderLimit += 6; // Increase the order limit by 6
                      });
                    },
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
