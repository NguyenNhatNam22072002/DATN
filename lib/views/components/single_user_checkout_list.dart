import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:shoes_shop/resources/styles_manager.dart';
import 'package:shoes_shop/views/customer/refund/refund_screen.dart';
import 'package:shoes_shop/views/customer/review/review_screen.dart';
import '../../constants/firebase_refs/collections.dart';
import '../../models/buyer.dart';
import '../../resources/assets_manager.dart';
import '../../resources/font_manager.dart';
import '../widgets/item_row.dart';
import 'package:intl/intl.dart' as intl;
import '../widgets/k_cached_image.dart';

class SingleUserCheckOutList extends StatefulWidget {
  const SingleUserCheckOutList({
    super.key,
    required this.checkoutItem,
  });

  final CheckedOutItem checkoutItem;

  @override
  State<SingleUserCheckOutList> createState() => _SingleUserCheckOutListState();
}

class _SingleUserCheckOutListState extends State<SingleUserCheckOutList> {
  Buyer buyer = Buyer.initial();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  // fetch customer details
  Future<void> fetchCustomerDetails() async {
    try {
      DocumentSnapshot data = await FirebaseCollections.customersCollection
          .doc(widget.checkoutItem.customerId)
          .get();
      setState(() {
        buyer = Buyer.fromJson(data);
        isLoading = false;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      setState(() {
        isLoading = false;
      });
      print('Failed to fetch customer details: $e');
    }
  }

  // Method to get the status label based on the status value
  String getStatusLabel(int status) {
    switch (status) {
      case 1:
        return 'Delivered';
      case 2:
        return 'Delivering';
      case 3:
        return 'Processing';
      case 4:
        return 'Approved';
      case 5:
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  Future<void> cancelOrder() async {
    DateTime orderDateTime = widget.checkoutItem.date;
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(orderDateTime);
    if (difference.inMinutes <= 30) {
      try {
        await FirebaseCollections.ordersCollection
            .doc(widget.checkoutItem.orderId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel order: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Order cannot be cancelled as the 30-minute window has passed.')),
      );
    }
  }

  // Method to show the return button only after delivery and within 7 days
  Widget showReturnButton() {
    DateTime deliveryDate = widget.checkoutItem.date;
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(deliveryDate);

    return ElevatedButton(
      onPressed: () {
        if (difference.inDays <= 7) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RefundScreen(
                  orderId: widget.checkoutItem.orderId,
                  vendorId: widget.checkoutItem.vendorId,
                  customerId: widget.checkoutItem.customerId,
                  orderAmount: widget.checkoutItem.prodPrice,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Refund Window Closed'),
                content: const Text(
                    'The refund window for this order has passed. Returns are only allowed within 7 days of delivery.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      },
      child: const Text(
        'Refund Product',
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }

  // Method to show the review button only after delivery
  Widget showReviewButton() {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReviewScreen(
                customerId: widget.checkoutItem.customerId,
                prodId: widget.checkoutItem.prodId,
              ),
            ),
          );
        },
        child: const Text(
          'Review Product',
          style: TextStyle(fontWeight: FontWeight.normal),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // bottom sheet modal
    Future<void> showCheckOutInBottom() async {
      return await showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                KCachedImage(
                  image: widget.checkoutItem.prodImg,
                  height: 100,
                  width: 120,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.checkoutItem.prodName,
                  style: getMediumStyle(
                    color: Colors.black,
                    fontSize: FontSize.s20,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ItemRow(
                      value: widget.checkoutItem.prodPrice.toString(),
                      title: 'Product Price: ',
                    ),
                    ItemRow(
                      value: getStatusLabel(widget.checkoutItem.status),
                      title: 'Status: ',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ItemRow(
                      value: widget.checkoutItem.prodSize,
                      title: 'Selected Size: ',
                    ),
                    ItemRow(
                      value: widget.checkoutItem.prodQuantity.toString(),
                      title: 'Product Quantity: ',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ItemRow(
                  value:
                      intl.DateFormat.yMMMEd().format(widget.checkoutItem.date),
                  title: 'Order Date: ',
                ),
                const SizedBox(height: 15),
                if (widget.checkoutItem.status == 5)
                  ElevatedButton(
                    onPressed: () async {
                      await cancelOrder();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel Order',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ),
                if (widget.checkoutItem.status == 1) showReviewButton(),
                if (widget.checkoutItem.status == 1) showReturnButton(),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => showCheckOutInBottom(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: widget.checkoutItem.prodImg,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 30,
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
            title: Text(widget.checkoutItem.prodName),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${widget.checkoutItem.prodPrice}'),
                Text('Quantity: ${widget.checkoutItem.prodQuantity}'),
                Text(getStatusLabel(widget.checkoutItem.status)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
