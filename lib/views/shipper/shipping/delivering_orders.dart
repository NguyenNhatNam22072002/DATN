import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shoes_shop/constants/color.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:shoes_shop/resources/assets_manager.dart';
import 'package:shoes_shop/views/components/single_shipper_list.dart';
import 'package:shoes_shop/views/widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';

class DeliveringOrdersScreen extends StatefulWidget {
  const DeliveringOrdersScreen({Key? key}) : super(key: key);

  @override
  State<DeliveringOrdersScreen> createState() => _DeliveringOrdersScreenState();
}

class _DeliveringOrdersScreenState extends State<DeliveringOrdersScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final Uuid uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> ordersStream = FirebaseCollections.ordersCollection
        .where('status', isEqualTo: 2) // Status 2 means 'delivering'
        .where('shipperId', isEqualTo: userId)
        .snapshots();

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(ordersStream),
    );
  }

  // Builds the AppBar widget
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Delivering Orders',
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
    );
  }

  // Builds the main body of the screen
  Widget _buildBody(Stream<QuerySnapshot> ordersStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: ordersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LoadingWidget(size: 30),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return _buildEmptyOrderWidget();
        }

        return _buildOrderList(snapshot);
      },
    );
  }

  // Builds the error widget
  Widget _buildErrorWidget() {
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

  // Builds the widget shown when there are no delivering orders
  Widget _buildEmptyOrderWidget() {
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

  // Builds the list of delivering orders
  Widget _buildOrderList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final item = snapshot.data!.docs[index];
        final checkedOutItem = CheckedOutItem.fromJson(item);

        return _buildOrderItem(checkedOutItem);
      },
    );
  }

  // Builds a single order item widget
  Widget _buildOrderItem(CheckedOutItem checkedOutItem) {
    return Slidable(
      key: ValueKey(checkedOutItem.orderId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(10),
            onPressed: (context) {
              markAsDelivered(checkedOutItem, userId);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.done,
            label: 'Delivered',
          ),
        ],
      ),
      child: SingleShipperCheckOutList(
        checkoutItem: checkedOutItem,
      ),
    );
  }

  void markAsDelivered(CheckedOutItem item, String shipperId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference orderRef =
            FirebaseCollections.ordersCollection.doc(item.orderId);
        DocumentReference shipperRef =
            FirebaseCollections.shippersCollection.doc(shipperId);

        DocumentSnapshot orderSnapshot = await transaction.get(orderRef);
        DocumentSnapshot shipperSnapshot = await transaction.get(shipperRef);

        if (orderSnapshot.get('status') != 2) {
          throw Exception(
              'Order must be in Delivering status before marking as Delivered');
        }

        // Getting current earnings
        double currentEarnings = shipperSnapshot['earnings'] ?? 0.0;
        double newEarnings = currentEarnings + 1.0;

        // Getting vendor data
        String vendorId = orderSnapshot.get('vendorId');
        DocumentReference vendorRef =
            FirebaseCollections.vendorsCollection.doc(vendorId);
        DocumentSnapshot vendorSnapshot = await transaction.get(vendorRef);

        // Calculating total amount
        double totalAmount =
            orderSnapshot['prodPrice'] * orderSnapshot['prodQuantity'];
        double currentBalance = vendorSnapshot['balanceAvailable'] ?? 0.0;

        // Writing updates to order, shipper, and vendor
        transaction.update(orderRef, {
          'status': 1, // Change status to delivered
        });
        transaction.update(shipperRef, {'earnings': newEarnings});
        transaction.update(
            vendorRef, {'balanceAvailable': currentBalance + totalAmount});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Order delivered, earnings updated, and vendor balance incremented')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}
