import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/models/checked_out_item.dart';
import 'package:shoes_shop/models/vendor.dart';
import 'package:shoes_shop/resources/styles_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/firebase_refs/collections.dart';
import '../../models/buyer.dart';
import '../../resources/assets_manager.dart';
import '../../resources/font_manager.dart';
import '../widgets/item_row.dart';
import 'package:intl/intl.dart' as intl;
import '../widgets/k_cached_image.dart';

class SingleShipperCheckOutList extends StatefulWidget {
  const SingleShipperCheckOutList({
    super.key,
    required this.checkoutItem,
  });

  final CheckedOutItem checkoutItem;

  @override
  State<SingleShipperCheckOutList> createState() =>
      _SingleShipperCheckOutListState();
}

class _SingleShipperCheckOutListState extends State<SingleShipperCheckOutList> {
  Buyer buyer = Buyer.initial();
  Vendor vendor = Vendor.initial();

  // fetch customer details
  Future<void> fetchCustomerDetails() async {
    await FirebaseCollections.customersCollection
        .doc(widget.checkoutItem.customerId)
        .get()
        .then((DocumentSnapshot data) {
      setState(() {
        buyer = Buyer.fromJson(data);
      });
    });
  }

  // fetch vendor details
  Future<void> fetchVendorDetails() async {
    await FirebaseCollections.vendorsCollection
        .doc(widget.checkoutItem.vendorId)
        .get()
        .then((DocumentSnapshot data) {
      setState(() {
        vendor = Vendor.fromJson(data.data() as Map<String, dynamic>);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
    fetchVendorDetails();
  }

  @override
  void dispose() {
    super.dispose();
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
      case 6:
        return 'Ready to Deliver';
      default:
        return 'Unknown';
    }
  }

  // Method to launch map with directions from vendor to buyer
  Future<void> openMap() async {
    final String buyerAddress = buyer.address;
    final String vendorAddress = vendor.address ?? '';

    final Uri googleMapsUri = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(vendorAddress)}&destination=${Uri.encodeComponent(buyerAddress)}");
    final Uri appleMapsUri = Uri.parse(
        "https://maps.apple.com/?saddr=${Uri.encodeComponent(vendorAddress)}&daddr=${Uri.encodeComponent(buyerAddress)}");

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else if (await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri);
    } else {
      throw 'Could not launch map';
    }
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
                // Product Information Box
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        value: intl.DateFormat.yMMMEd()
                            .format(widget.checkoutItem.date),
                        title: 'Order Date: ',
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemRow(
                        value: buyer.fullname,
                        title: 'Customer Name: ',
                      ),
                      const SizedBox(height: 10),
                      ItemRow(
                        value: buyer.phone,
                        title: 'Customer Contact: ',
                      ),
                      const SizedBox(height: 10),
                      ItemRow(
                        value: buyer.address,
                        title: 'Customer Address: ',
                      ),
                    ],
                  ),
                ),
                // Vendor Information Box
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemRow(
                        value: vendor.storeName,
                        title: 'Vendor Name: ',
                      ),
                      const SizedBox(height: 10),
                      ItemRow(
                        value: vendor.phone,
                        title: 'Vendor Contact: ',
                      ),
                      const SizedBox(height: 10),
                      ItemRow(
                        value: vendor.address,
                        title: 'Vendor Address: ',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    await openMap();
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  child: const Text('Open Map'),
                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
