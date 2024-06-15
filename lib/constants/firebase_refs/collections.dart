import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCollections {
  static final productsCollection =
      FirebaseFirestore.instance.collection('products');

  static final vendorsCollection =
      FirebaseFirestore.instance.collection('vendors');

  static final shippersCollection =
      FirebaseFirestore.instance.collection('shippers');

  static final customersCollection =
      FirebaseFirestore.instance.collection('customers');

  static final bannersCollection =
      FirebaseFirestore.instance.collection('banners');

  static final categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  static final ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  static final cashOutCollection =
      FirebaseFirestore.instance.collection('cash_outs');

  static final reviewsCollection =
      FirebaseFirestore.instance.collection('reviews');

  static final refundsCollection =
      FirebaseFirestore.instance.collection('refunds');

  static final walletTransactionsCollection =
      FirebaseFirestore.instance.collection('walletTransactions');
}
