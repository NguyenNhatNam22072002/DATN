import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:shoes_shop/resources/assets_manager.dart';
import 'package:shoes_shop/views/components/single_shipper_list.dart';
import 'package:shoes_shop/views/widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';

class DeliveredOrdersScreen extends StatefulWidget {
  const DeliveredOrdersScreen({Key? key}) : super(key: key);

  @override
  _DeliveredOrdersScreenState createState() => _DeliveredOrdersScreenState();
}

class _DeliveredOrdersScreenState extends State<DeliveredOrdersScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final Uuid uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    // Stream of delivered orders for the current shipper
    Stream<QuerySnapshot> ordersStream = FirebaseCollections.ordersCollection
        .where('status', isEqualTo: 1) // Status 1 means 'delivered'
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
      title: const Text(
        'Delivered Orders',
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

  // Builds the widget shown when there are no delivered orders
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

  // Builds the list of delivered orders
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
              // Action for order details
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.info,
            label: 'Details',
          ),
        ],
      ),
      child: SingleShipperCheckOutList(
        checkoutItem: checkedOutItem,
      ),
    );
  }
}
