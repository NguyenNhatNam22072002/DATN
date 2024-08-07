import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shoes_shop/api/apis.dart';
import 'package:shoes_shop/helpers/dialogs.dart';
import 'package:shoes_shop/models/chat_user.dart';
import 'package:shoes_shop/providers/cart.dart';
import 'package:shoes_shop/views/components/review_widget.dart';
import 'package:shoes_shop/views/customer/store/store_details.dart';
import 'package:shoes_shop/views/vendor/chat/chat_screen.dart';
import '../../../constants/color.dart';
import '../../../constants/enums/status.dart';
import '../../../constants/firebase_refs/collections.dart';
import '../../../helpers/word_reverse.dart';
import '../../../models/cart.dart';
import '../../../models/product.dart';
import '../../../models/vendor.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import '../../widgets/item_row.dart';
import '../../widgets/k_cached_image.dart';
import '../../widgets/loading_widget.dart';
import 'package:intl/intl.dart' as intl;
import 'package:uuid/uuid.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../widgets/msg_snackbar.dart';
import '../main_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  String selectedProductSize = '';
  int? selectedProductSizeIndex;
  bool isLoadingVendor = true;
  bool isLoadingRating = true;
  bool isLoadingReviews = true;
  String vendorName = '';
  String vendorImage = '';
  String vendorAddress = '';
  Uuid uuid = const Uuid();
  bool isFav = false;
  double _averageRating = 0.0;
  int _ratingCount = 0;
  Vendor vendor = Vendor.initial();
  ChatUser user = ChatUser(
      image: '',
      about: '',
      name: '',
      createdAt: '',
      isOnline: false,
      id: '',
      lastActive: '',
      email: '',
      pushToken: '');

  List<Map<String, dynamic>> _reviews = [];

  // fetch vendorDetails
  Future<void> fetchVendorDetails() async {
    try {
      final doc = await FirebaseCollections.vendorsCollection
          .doc(widget.product.vendorId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          vendor = Vendor(
            storeId: data['storeId'],
            storeName: data['storeName'],
            email: data['email'],
            phone: data['phone'],
            taxNumber: data['taxNumber'],
            storeNumber: data['storeNumber'],
            country: data['country'],
            state: data['state'],
            city: data['city'],
            storeImgUrl: data['storeImgUrl'],
            address: data['address'],
            authType: data['authType'],
          );

          vendorName = data['storeName'];
          vendorImage = data['storeImgUrl'];
          vendorAddress =
              '${data['city']} ${data['state']} ${reversedWord(data['country'])}';
          isLoadingVendor = false;
        });
      } else {
        // Show dialog if the document does not exist
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Vendor details not found.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle any other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while fetching vendor details.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.product.vendorId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          user = ChatUser(
            about: data['about'],
            createdAt: data['created_at'],
            email: data['email'],
            id: data['id'],
            image: data['image'],
            isOnline: data['is_online'],
            lastActive: data['last_active'],
            name: data['name'],
            pushToken: data['push_token'],
          );
        });
      } else {
        // Show dialog if the document does not exist
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Vendor details not found.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle any other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while fetching vendor details.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('prodId', isEqualTo: widget.product.prodId)
          .get();

      final reviews = await Future.wait(querySnapshot.docs.map(
        (doc) async {
          final reviewData = doc.data();
          final customerId = reviewData['customerId'];

          final customerDoc = await FirebaseFirestore.instance
              .collection('customers')
              .doc(customerId)
              .get();

          final customerData = customerDoc.data();
          final fullname = customerData?['fullname'] ?? 'Unknown';

          return {
            'reviewText': reviewData['reviewText'],
            'date': (reviewData['date'] as Timestamp).toDate(),
            'fullname': fullname,
            'rating': reviewData['rating'] ?? 0,
          };
        },
      ));

      setState(() {
        _reviews = reviews;
      });
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase Error getting reviews: ${e.code}: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('General Error getting reviews: $e');
      }
    }
  }

  Future<void> _fetchAverageRating() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('prodId', isEqualTo: widget.product.prodId)
          .get();
      List<double> ratings = querySnapshot.docs
          .map((doc) => (doc['rating'] as num).toDouble())
          .toList();
      if (ratings.isEmpty) return;
      double averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      setState(() {
        _averageRating = averageRating;
        _ratingCount = ratings.length;
      });
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.prodId)
          .update({
        'averageRating': averageRating,
        'ratingCount': ratings.length,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting average rating: $e');
      }
    }
  }

  // navigate to store
  void navigateToVendorStore() {
    // Todo: Navigate to vendor store
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoreDetailsScreen(vendor: vendor),
      ),
    );
  }

  void setProductSize(String size, int index) {
    if (index == selectedProductSizeIndex) {
      setState(() {
        selectedProductSize = '';
        selectedProductSizeIndex = null;
      });
    } else {
      setState(() {
        selectedProductSize = size;
        selectedProductSizeIndex = index;
      });
    }
  }

// images in bottom sheet
  void showImageBottom() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) => SizedBox(
        height: 500,
        child: CarouselSlider.builder(
          itemCount: widget.product.imgUrls.length,
          itemBuilder: (context, index, i) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '${index + 1}/${widget.product.imgUrls.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.product.imgUrls[index],
                    placeholder: (context, url) =>
                        Image.asset(AssetManager.placeholderImg),
                    errorWidget: (context, url, error) =>
                        Image.asset(AssetManager.placeholderImg),
                  ),
                )
              ],
            ),
          ),
          options: CarouselOptions(
            viewportFraction: 1,
            aspectRatio: 1.5,
            height: 500,
            autoPlay: true,
          ),
        ),
      ),
    );
  }

  // toggle isFav
  void toggleIsFav(bool status, String id) {
    final db = FirebaseCollections.productsCollection.doc(id);
    setState(() {
      db.update({'isFav': !status});
      isFav = !isFav;
    });
  }

  Animation<double>? _animation;
  AnimationController? _animationController;
  var isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      );

      final curvedAnimation = CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _animationController!,
      );
      _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

      //  fetching store details
      fetchVendorDetails();
      _fetchAverageRating();
      _fetchReviews();
      fetchUserDetails();
      setState(() {
        isFav = widget.product.isFav;
      });
    }
    setState(() {
      isInit = false;
    });
    super.didChangeDependencies();
  }

  // get context
  get cxt => context;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    CartProvider cartProvider = Provider.of<CartProvider>(context);

    // buy now fnc
    void buyNow() {
      // prompt if the size is not selected
      if (selectedProductSize.isEmpty) {
        EasyLoading.dismiss();
        displaySnackBar(
            message: 'Select product size',
            context: context,
            status: Status.error);
        return;
      }

      if (cartProvider.isItemOnCart(widget.product.prodId)) {
        // navigate to cart
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CustomerMainScreen(index: 4),
          ),
        );
      } else {
        Cart cartItem = Cart(
          cartId: uuid.v4(),
          prodId: widget.product.prodId,
          prodName: widget.product.productName,
          prodImg: widget.product.imgUrls[0],
          vendorId: widget.product.vendorId,
          quantity: 1,
          prodSize: selectedProductSize,
          date: DateTime.now(),
          price: widget.product.price,
        );

        cartProvider.addToCart(cartItem);

        // navigate to cart
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CustomerMainScreen(index: 4),
          ),
        );
      }
    }

    // toggle cart action
    void toggleCartAction(Product product) async {
      await EasyLoading.show(status: 'loading...');
      if (cartProvider.isItemOnCart(product.prodId)) {
        cartProvider.removeFromCart(product.prodId);
        Future.delayed(const Duration(seconds: 2));
        EasyLoading.dismiss();

        // msg for user after adding item to cart
        displaySnackBar(
          status: Status.success,
          message: '${product.productName} removed from cart successfully',
          context: cxt,
        );
      } else {
        // prompt if the size is not selected
        if (selectedProductSize.isEmpty) {
          EasyLoading.dismiss();
          displaySnackBar(
            message: 'Select product size',
            context: cxt,
            status: Status.error,
          );
          return;
        }

        Cart cartItem = Cart(
          cartId: uuid.v4(),
          prodId: product.prodId,
          prodName: product.productName,
          prodImg: product.imgUrls[0],
          vendorId: product.vendorId,
          quantity: 1,
          prodSize: selectedProductSize,
          date: DateTime.now(),
          price: product.price,
        );

        cartProvider.addToCart(cartItem);
        Future.delayed(const Duration(seconds: 2));
        EasyLoading.dismiss();

        // msg for user after adding item to cart
        displaySnackBar(
          status: Status.success,
          message: '${product.productName} added to cart successfully',
          context: cxt,
        );
      }
    }

    // similar products query
    final Stream<QuerySnapshot> similarProducts = FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.product.category)
        .where('prodId', isNotEqualTo: widget.product.prodId)
        .snapshots();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: cartProvider.isItemOnCart(widget.product.prodId)
                ? 'Remove from cart'
                : "Add to cart",
            iconColor: Colors.white,
            bubbleColor: Colors.black87,
            icon: cartProvider.isItemOnCart(widget.product.prodId)
                ? Icons.shopping_cart
                : Icons.shopping_cart_outlined,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            onPress: () {
              toggleCartAction(widget.product);
              _animationController!.reverse();
            },
          ),
          Bubble(
            title: "Buy now",
            iconColor: Colors.white,
            bubbleColor: accentColor,
            icon: Icons.shopping_cart_checkout,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            onPress: () {
              buyNow();
              _animationController!.reverse();
            },
          ),
        ],
        animation: _animation!,
        onPress: () => _animationController!.isCompleted
            ? _animationController!.reverse()
            : _animationController!.forward(),
        iconColor: Colors.white,
        iconData: Icons.add,
        backGroundColor: accentColor,
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
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
        actions: [
          GestureDetector(
            onTap: () => toggleIsFav(isFav, widget.product.prodId),
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
                size: 35,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => showImageBottom(),
              child: Hero(
                tag: widget.product.prodId,
                child: Container(
                  height: size.height / 2,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Swiper(
                    autoplay: true,
                    pagination: const SwiperPagination(
                      builder: SwiperPagination.dots,
                    ),
                    itemCount: widget.product.imgUrls.length,
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: widget.product.imgUrls[index],
                      imageBuilder: (context, imageProvider) => PhotoView(
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        maxScale: 100.0,
                        imageProvider: imageProvider,
                        // fit: BoxFit.cover,
                      ),
                      placeholder: (context, url) =>
                          Image.asset(AssetManager.placeholderImg),
                      errorWidget: (context, url, error) =>
                          Image.asset(AssetManager.placeholderImg),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: getBoldStyle(
                      color: Colors.black,
                      fontSize: FontSize.s30,
                    ),
                  ),
                  Text(
                    '\$${widget.product.price}',
                    style: getRegularStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.s25,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RatingBarIndicator(
                        rating: _averageRating,
                        unratedColor: greyShade2,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 30.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '${(_averageRating.toStringAsFixed(1))}/5',
                        style: getRegularStyle(
                          color: Colors.black,
                          fontSize: FontSize.s16,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        '($_ratingCount sold)',
                        style: getRegularStyle(
                          color: Colors.black,
                          fontSize: FontSize.s16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ItemRow(
                            value: widget.product.category,
                            title: 'Shoe category: ',
                          ),
                          const SizedBox(height: 5),
                          ItemRow(
                            value: widget.product.brandName,
                            title: 'Brand: ',
                          ),
                          const SizedBox(height: 5),
                          ItemRow(
                            value: widget.product.isCharging ? 'Yes' : 'No',
                            title: 'Charging for shipping: ',
                          ),
                          const SizedBox(height: 5),
                          ItemRow(
                            value: '\$${widget.product.billingAmount}',
                            title: 'Shipping amount: ',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Scheduled:  ${intl.DateFormat.yMMMEd().format(widget.product.scheduleDate)}',
                            style: getRegularStyle(color: Colors.black),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.product.quantity} available',
                            style: getRegularStyle(
                              color: greyFontColor,
                              fontSize: FontSize.s16,
                            ),
                          ),
                          Text(
                            widget.product.quantity > 0
                                ? 'in stock'
                                : 'out of stock',
                            style: getRegularStyle(
                              color: widget.product.quantity > 0
                                  ? accentColor
                                  : greyFontColor,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: size.height / 13,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.sizesAvailable.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () => setProductSize(
                              widget.product.sizesAvailable[index], index),
                          child: CircleAvatar(
                            backgroundColor: selectedProductSizeIndex == index
                                ? Colors.black12
                                : gridBg,
                            child: Text(
                              widget.product.sizesAvailable[index],
                              style: getRegularStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sold by:',
                    style: getRegularStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.s16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // store
                  !isLoadingVendor
                      ? SizedBox(
                          height: 150,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KCachedImage(
                                image: vendorImage,
                                isCircleAvatar: true,
                                radius: 35,
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vendorName,
                                    style: getMediumStyle(
                                      color: accentColor,
                                      fontSize: FontSize.s18,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.65, // 80% of screen width
                                    child: Text(
                                      vendorAddress,
                                      style: getRegularStyle(
                                        color: Colors.black87,
                                        fontSize: FontSize.s14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          side: const BorderSide(
                                              color: accentColor),
                                        ),
                                        onPressed: () =>
                                            navigateToVendorStore(),
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            const Icon(Icons.storefront,
                                                color: accentColor),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Visit store',
                                              style: getRegularStyle(
                                                color: accentColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          side: const BorderSide(
                                              color: accentColor),
                                        ),
                                        onPressed: () async {
                                          if (user.email.isNotEmpty) {
                                            await APIs.addChatUser(user.email)
                                                .then((value) {
                                              if (!value) {
                                                Dialogs.showSnackbar(context,
                                                    'User does not Exists!');
                                              }
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ChatScreen(
                                                        user: user)));
                                          }
                                        },
                                        child: const Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Icon(Icons.chat,
                                                color: accentColor),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const LoadingWidget(size: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: getRegularStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.s16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ReadMoreText(
                        widget.product.description,
                        trimLines: 2,
                        colorClickableText: accentColor,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Show more ⌄',
                        trimExpandedText: '\nShow less ^',
                        style: getRegularStyle(
                          color: Colors.black,
                          fontSize: FontSize.s16,
                        ),
                        lessStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                        delimiter: '\n',
                        moreStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Similar products you might like',
                    style: getRegularStyle(
                      color: Colors.black,
                      fontSize: FontSize.s16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                height: size.height / 3.5,
                width: double.infinity,
                child: StreamBuilder<QuerySnapshot>(
                  stream: similarProducts,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: LoadingWidget(
                          size: 30,
                        ),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Column(
                        children: [
                          Image.asset(
                            AssetManager.addImage,
                            width: 150,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No similar products available!',
                            style: TextStyle(
                              color: primaryColor,
                            ),
                          )
                        ],
                      );
                    }
                    return CarouselSlider.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index, i) {
                        final item = snapshot.data!.docs[index];
                        Product product = Product.fromJson(item);
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                  product: product,
                                ),
                              ),
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    Stack(children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: KCachedImage(
                                          image: product.imgUrls[0],
                                          height: 160,
                                          width: 173,
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () => toggleIsFav(
                                              product.isFav, product.prodId),
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor:
                                                accentColor.withOpacity(0.3),
                                            child: Icon(
                                              size: 15,
                                              product.isFav
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: GestureDetector(
                                          onTap: () =>
                                              toggleCartAction(product),
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor:
                                                accentColor.withOpacity(0.3),
                                            child: Icon(
                                              cartProvider.isItemOnCart(
                                                      product.prodId)
                                                  ? Icons.shopping_cart
                                                  : Icons
                                                      .shopping_cart_outlined,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          product.productName.length > 9
                                              ? '${product.productName.substring(0, 9)}...'
                                              : product.productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text('\$${product.price}')
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        viewportFraction: 0.5,
                        aspectRatio: 1.5,
                        height: size.height / 3.5,
                        autoPlay: true,
                      ),
                    );
                  },
                ),
              ),
            ),
            ReviewsWidget(
              reviews: _reviews,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
