import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/color.dart';
import '../../constants/enums/yes_no.dart';
import '../../constants/enums/status.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../providers/cart.dart';
import '../../resources/font_manager.dart';
import '../../resources/styles_manager.dart';
import '../customer/relational_screens/product_details.dart';
import '../widgets/k_cached_image.dart';
import '../widgets/msg_snackbar.dart';
import '../widgets/text_action.dart';

class SingleCartItem extends StatefulWidget {
  const SingleCartItem({
    Key? key,
    required this.item,
    required this.cartData,
  }) : super(key: key);

  final Cart item;
  final CartProvider cartData;

  @override
  State<SingleCartItem> createState() => _SingleCartItemState();
}

class _SingleCartItemState extends State<SingleCartItem> {
  Product product = Product.initial();
  late TextEditingController _quantityController;

  Future<Product> fetchProduct() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.item.prodId)
        .get()
        .then((item) {
      product = Product(
        prodId: item['prodId'],
        vendorId: item['vendorId'],
        productName: item['productName'],
        price: item['price'],
        quantity: item['quantity'],
        category: item['category'],
        description: item['description'],
        scheduleDate: item['scheduleDate'].toDate(),
        isCharging: item['isCharging'],
        billingAmount: item['billingAmount'],
        brandName: item['brandName'],
        sizesAvailable: item['sizesAvailable'].cast<String>(),
        imgUrls: item['imgUrls'].cast<String>(),
        uploadDate: item['uploadDate'].toDate(),
        isApproved: item['isApproved'],
        isFav: item['isFav'],
      );
    });

    return product;
  }

  @override
  void initState() {
    super.initState();
    fetchProduct();
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void showWarningMsg({required String message}) {
    displaySnackBar(
      status: Status.error,
      message: message,
      context: context,
    );
  }

  void updateQuantity(String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity > 0) {
      if (newQuantity <= product.quantity) {
        widget.cartData.updateQuantity(widget.item.prodId, newQuantity);
      } else {
        showWarningMsg(
            message: 'Ops! You can\'t exceed available product quantity!');
        _quantityController.text = widget.item.quantity.toString();
      }
    } else {
      showWarningMsg(message: 'Please enter a valid quantity');
      _quantityController.text = widget.item.quantity.toString();
    }
  }

  void incrementQuantity() {
    int currentQuantity = int.parse(_quantityController.text);
    if (currentQuantity < product.quantity) {
      currentQuantity++;
      _quantityController.text = currentQuantity.toString();
      widget.cartData.updateQuantity(widget.item.prodId, currentQuantity);
    } else {
      showWarningMsg(
          message: 'Ops! You can\'t exceed available product quantity!');
    }
  }

  void decrementQuantity() {
    int currentQuantity = int.parse(_quantityController.text);
    if (currentQuantity > 1) {
      currentQuantity--;
      _quantityController.text = currentQuantity.toString();
      widget.cartData.updateQuantity(widget.item.prodId, currentQuantity);
    } else {
      showWarningMsg(message: 'Ops! Item quantity can\'t go any lower');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.item.prodId),
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          elevation: 3,
          title: Text(
            'Are you sure?',
            style: getMediumStyle(
              color: Colors.black,
              fontSize: FontSize.s18,
            ),
          ),
          content: Text(
            'Do you want to remove ${widget.item.prodName} from cart?',
            style: getRegularStyle(
              color: Colors.black,
              fontSize: FontSize.s14,
            ),
          ),
          actions: [
            textAction('No', YesNo.no, context),
            textAction('Yes', YesNo.yes, context),
          ],
        ),
      ),
      onDismissed: (direction) =>
          widget.cartData.removeFromCart(widget.item.prodId),
      direction: DismissDirection.endToStart,
      background: Container(
        height: 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: product,
            ),
          ),
        ),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                KCachedImage(
                  image: widget.item.prodImg,
                  isCircleAvatar: true,
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.prodName,
                        style: getMediumStyle(
                          color: Colors.black,
                          fontSize: FontSize.s16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.item.price}',
                            style: getMediumStyle(
                              color: accentColor,
                              fontSize: FontSize.s14,
                            ),
                          ),
                          Text(
                            'Size: ${widget.item.prodSize}',
                            style: getMediumStyle(
                              color: accentColor,
                              fontSize: FontSize.s14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity:',
                            style: getRegularStyle(
                              color: accentColor,
                              fontSize: FontSize.s14,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: decrementQuantity,
                              ),
                              SizedBox(
                                width: 40,
                                child: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    // Delay the update to allow for multi-digit input
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      if (_quantityController.text == value) {
                                        updateQuantity(value);
                                      }
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: incrementQuantity,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
