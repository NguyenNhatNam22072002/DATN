import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import 'package:shoes_shop/views/components/single_user_checkout_list.dart';
import 'package:shoes_shop/views/widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../resources/assets_manager.dart';

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
        .where('status', isEqualTo: 3)
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
          );
        },
      ),
    );
  }
}
