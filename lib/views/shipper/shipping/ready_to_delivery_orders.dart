import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import 'package:shoes_shop/views/components/single_shipper_list.dart';
import 'package:shoes_shop/views/widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../resources/assets_manager.dart';

class ReadyDeliveryScreen extends StatefulWidget {
  const ReadyDeliveryScreen({super.key});

  @override
  State<ReadyDeliveryScreen> createState() => _ReadyDeliveryScreenState();
}

class _ReadyDeliveryScreenState extends State<ReadyDeliveryScreen> {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  Uuid uid = const Uuid();

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> ordersStream = FirebaseCollections.ordersCollection
        .where('status', isEqualTo: 6)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ready to Delivery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
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

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final item = snapshot.data!.docs[index];

              CheckedOutItem checkedOutItem = CheckedOutItem.fromJson(item);

              return Slidable(
                key: const ValueKey(0),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      borderRadius: BorderRadius.circular(10),
                      onPressed: (context) {
                        // Handle the delivery action here
                        markAsDelivered(checkedOutItem, userId);
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.local_shipping,
                      label: 'Delivery',
                    ),
                  ],
                ),
                child: SingleShipperCheckOutList(
                  checkoutItem: checkedOutItem,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void markAsDelivered(CheckedOutItem item, String shipperId) async {
    try {
      // Start a batch write to ensure atomic updates
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Reference to the order document
      DocumentReference orderRef =
          FirebaseCollections.ordersCollection.doc(item.orderId);

      // Update the order status and shipperId
      batch.update(orderRef, {
        'status': 1,
        'shipperId': shipperId,
      });

      // Reference to the shipper document
      DocumentReference shipperRef =
          FirebaseCollections.shippersCollection.doc(shipperId);

      // Get the current earnings of the shipper
      DocumentSnapshot shipperSnapshot = await shipperRef.get();
      Map<String, dynamic>? shipperData =
          shipperSnapshot.data() as Map<String, dynamic>?;

      // Check if earnings field exists, otherwise default to 0.0
      double currentEarnings =
          shipperData != null && shipperData.containsKey('earnings')
              ? shipperData['earnings'] as double
              : 0.0;

      // Increment the earnings by $1.0
      double newEarnings = currentEarnings + 1.0;

      // Update the shipper's earnings in the batch
      batch.update(shipperRef, {
        'earnings': newEarnings,
      });

      // Commit the batch
      await batch.commit();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Order marked as delivered and earnings updated')),
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as delivered: $error')),
      );
    }
  }
}
