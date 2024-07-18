import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shoes_shop/constants/color.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:shoes_shop/resources/assets_manager.dart';
import 'package:shoes_shop/views/components/single_user_checkout_list.dart';
import 'package:shoes_shop/views/widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({Key? key}) : super(key: key);

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  Uuid uid = const Uuid();
  int _orderLimit = 6; // Initial limit of orders to load

  void markAsReceived(String orderId) async {
    try {
      await FirebaseCollections.ordersCollection.doc(orderId).update({
        'isReceived': true,
        'receivedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as received')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark order as received: $e')),
      );
    }
  }

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
                  const Text('Order list is empty'),
                ],
              ),
            );
          }

          // Only load orders up to _orderLimit
          List<QueryDocumentSnapshot> orders = snapshot.data!.docs.sublist(
            0,
            _orderLimit <= snapshot.data!.docs.length
                ? _orderLimit
                : snapshot.data!.docs.length,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                    bottom: 10, // Bottom padding for load more button
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final item = orders[index];

                    CheckedOutItem checkedOutItem =
                        CheckedOutItem.fromJson(item);

                    return Slidable(
                      key: Key(item.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            borderRadius: BorderRadius.circular(10),
                            onPressed: (context) {
                              markAsReceived(checkedOutItem.orderId);
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'Received',
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
