import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import 'package:shoes_shop/views/widgets/kcool_alert.dart';
import '../../../constants/color.dart';
import '../../../constants/enums/status.dart';
import '../../../providers/order.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../components/single_order_item.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../main_screen.dart';
import '../../../models/buyer.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:uuid/uuid.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Buyer buyer = Buyer.initial();
  bool profileIncomplete = false;
  bool isAddressEmpty = false;
  bool isPhoneNumberEmpty = false;
  String? apiPublicKey;
  String? apiEncryptKey;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isTestMode = true;
  final Uuid uuid = const Uuid();
  double refundAmount = 0.0;

  // fetch Api keys
  Future<void> fetchAPIKeys() async {
    apiPublicKey = await storage.read(key: 'flutterwave_public_key');
    apiEncryptKey = await storage.read(key: 'flutterwave_encrypt_key');
    print("Public Key: $apiPublicKey");
    print("Encrypt Key: $apiEncryptKey");
  }

  // fetch customer details
  Future<void> fetchCustomerDetails() async {
    await FirebaseCollections.customersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot data) {
      setState(() {
        buyer = Buyer.fromJson(data);
        print("buyer=" + buyer.email);
      });

      if (data['phone'].toString().isEmpty ||
          data['address'].toString().isEmpty) {
        setState(() {
          profileIncomplete = true;
        });
      }

      if (data['phone'].toString().isEmpty) {
        setState(() {
          isPhoneNumberEmpty = true;
        });
      }

      if (data['address'].toString().isEmpty) {
        setState(() {
          isAddressEmpty = true;
        });
      }
    });
  }

  Future<void> _fetchRefundAmount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('customerId',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      double totalRefund = 0.0;
      for (var doc in snapshot.docs) {
        totalRefund += doc['refundAmount'];
      }

      setState(() {
        refundAmount = totalRefund;
      });
    } catch (e) {
      // Handle errors
      print("Error fetching refund amount: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    saveAPIKeys();
    fetchCustomerDetails();
    fetchAPIKeys();
    _fetchRefundAmount();
  }

  Future<void> saveAPIKeys() async {
    await storage.write(
        key: 'flutterwave_public_key',
        value: 'FLWPUBK_TEST-8702ae0933b8391716dc72a1eda6049c-X');
    await storage.write(
        key: 'flutterwave_encrypt_key', value: 'FLWSECK_TEST0bf8411bf744');
  }

  // pop out
  void popOut() {
    Navigator.of(context).pop();
  }

  // show loading
  Future<void> showLoading(String message, Status status) async {
    kCoolAlert(
      message: message,
      context: context,
      alert:
          status == Status.error ? CoolAlertType.error : CoolAlertType.success,
      action: popOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);

    // remove cart items
    void removeAllOrderItems() {
      orderData.clearOrder();
      popOut();
    }

    // remove all cart items dialog
    void removeAllOrderItemsDialog() {
      areYouSureDialog(
        title: 'Remove all cart items',
        content: 'Are you sure you want to remove all order items?',
        context: context,
        action: removeAllOrderItems,
      );
    }

    // navigate to profile
    void navigateToProfile() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CustomerMainScreen(index: 5),
        ),
      );
    }

    // submit individual order to firebase
    Future<void> submitOrderToFirebase() async {
      for (var order in orderData.orders) {
        for (var item in order.products) {
          var id = uuid.v4();
          FirebaseCollections.ordersCollection.doc(id).set({
            'orderId': id,
            'vendorId': item.vendorId,
            'customerId': buyer.customerId,
            'prodId': item.prodId,
            'prodName': item.prodName,
            'prodImg': item.prodImg,
            'prodSize': item.prodSize,
            'prodPrice': item.price,
            'prodQuantity': item.quantity,
            'date': item.date,
            'status': 5
          });
        }
      }
    }

    // order now button
    Future<void> orderNow() async {
      if (profileIncomplete) {
        kCoolAlert(
          message: isAddressEmpty && isPhoneNumberEmpty
              ? 'Your profile is incomplete! Update your address and phone number'
              : isPhoneNumberEmpty
                  ? 'Your profile is incomplete! Update your phone number'
                  : 'Your profile is incomplete! Update your address',
          context: context,
          alert: CoolAlertType.error,
          action: navigateToProfile,
          confirmBtnText: 'Update Profile',
        );
      } else {
        // handle payment
        if (apiPublicKey == null) {
          return;
        }
        final Customer customer = Customer(
            email: buyer.email.toString(),
            name: buyer.fullname.toString(),
            phoneNumber: buyer.phone.toString());

        final Flutterwave flutterwave = Flutterwave(
          context: context,
          publicKey: apiPublicKey!,
          currency: "USD",
          redirectUrl: "https://www.google.com",
          txRef: "${buyer.customerId}_${Timestamp.now().toString()}",
          amount: orderData.getTotal.toString(),
          customer: customer,
          paymentOptions: "card, payattitude, barter, bank transfer, ussd",
          customization: Customization(
            title: "Make Payment",
            description: "Make payment for the order items",
          ),
          isTestMode: false,
        );

        try {
          final ChargeResponse response = await flutterwave.charge();
          print("NAMNAMNAMANMAN");
          if (response.success == true) {
            showLoading(
                "You have successfully placed your order", Status.success);
            await submitOrderToFirebase(); // upload to firebase
            removeAllOrderItems(); // remove order
          } else {
            showLoading(
              'Ops! Payment was not successful',
              Status.error,
            );
          }
        } catch (e, stacktrace) {
          print("Error: $e");
          print("Stacktrace: $stacktrace");
          showLoading('Ops! Payment was not successful', Status.error);
        }
      }
    }

    Future<void> orderNowWithWallet() async {
      if (profileIncomplete) {
        kCoolAlert(
          message: isAddressEmpty && isPhoneNumberEmpty
              ? 'Your profile is incomplete! Update your address and phone number'
              : isPhoneNumberEmpty
                  ? 'Your profile is incomplete! Update your phone number'
                  : 'Your profile is incomplete! Update your address',
          context: context,
          alert: CoolAlertType.error,
          action: navigateToProfile,
          confirmBtnText: 'Update Profile',
        );
      } else {
        double totalAmount = orderData.getTotal;
        String userId = FirebaseAuth.instance.currentUser!.uid;

        try {
          DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
              .collection('customers')
              .doc(userId)
              .get();

          if (customerSnapshot.exists) {
            Map<String, dynamic> customerData =
                customerSnapshot.data() as Map<String, dynamic>;
            double refundAmount = customerData['refundAmount'] ?? 0.0;

            if (refundAmount >= totalAmount) {
              double newRefundAmount = refundAmount - totalAmount;

              // Cập nhật refundAmount
              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(userId)
                  .update({'refundAmount': newRefundAmount});

              // Tiến hành đặt hàng
              await submitOrderToFirebase();
              removeAllOrderItems();

              showLoading(
                  "You have successfully placed your order", Status.success);
            } else {
              showLoading(
                  'Ops! Insufficient funds in your wallet', Status.error);
            }
          } else {
            showLoading('Ops! Customer not found', Status.error);
          }
        } catch (e, stacktrace) {
          if (kDebugMode) {
            print("Error: $e");
          }
          if (kDebugMode) {
            print("Stacktrace: $stacktrace");
          }
          showLoading('Ops! An error occurred while processing your order',
              Status.error);
        }
      }
    }

    void showPaymentMethodDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Payment Method',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.blue),
                    title: const Text('Using Card',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.of(context).pop();
                      orderNow();
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet,
                        color: Colors.green),
                    title: const Text('Using Wallet',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Current amount: \$${refundAmount.toStringAsFixed(2)}',
                      style: getRegularStyle(
                          color: greyFontColor, fontSize: FontSize.s12),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      orderNowWithWallet();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Orders',
        ),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.chevron_left, color: iconColor),
            );
          },
        ),
        actions: [
          orderData.orders.isEmpty
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () => removeAllOrderItemsDialog(),
                  child: const Icon(
                    Icons.delete_forever,
                    color: iconColor,
                    size: 30,
                  ),
                ),
          const SizedBox(width: 18),
        ],
      ),
      body: orderData.orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AssetManager.empty),
                  const SizedBox(height: 20),
                  const Text('Ops! Order is empty'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const CustomerMainScreen(index: 0),
                      ),
                    ),
                    child: const Text('Start shopping'),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleOrderItem(
                        id: orderData.orders[index].id,
                        totalAmount: orderData.orders[index].totalAmount,
                        date: orderData.orders[index].orderDate,
                        orders: orderData.orders[index],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomSheet: orderData.orders.isNotEmpty
          ? Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price',
                          style: getRegularStyle(
                            color: greyFontColor,
                            fontWeight: FontWeight.w500,
                            fontSize: FontSize.s14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '\$${orderData.getTotal.toStringAsFixed(2)}',
                          style: getMediumStyle(
                            color: accentColor,
                            fontSize: FontSize.s25,
                          ),
                        )
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 80,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              topLeft: Radius.circular(5),
                            ),
                          ),
                          child: Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white),
                                const SizedBox(width: 15),
                                Text(
                                  orderData.orders.length.toString(),
                                  style: getRegularStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showPaymentMethodDialog(),
                          child: Container(
                            height: 50,
                            width: 120,
                            decoration: const BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(5),
                                topRight: Radius.circular(5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Buy Now',
                                style: getMediumStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
