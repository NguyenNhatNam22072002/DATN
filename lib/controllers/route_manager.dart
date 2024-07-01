import 'package:shoes_shop/views/auth/shipper/forgot_password.dart';
import 'package:shoes_shop/views/auth/shipper/shipper_auth.dart';
import 'package:shoes_shop/views/auth/vendor/forgot_password.dart';
import 'package:shoes_shop/views/auth/vendor/vendor_auth.dart';
import 'package:shoes_shop/views/customer/favorite/favorite.dart';
import 'package:shoes_shop/views/customer/orders/orders.dart';
import 'package:shoes_shop/views/customer/orders/orders_management.dart';
import 'package:shoes_shop/views/shipper/main_screen.dart';
import 'package:shoes_shop/views/shipper/shipper_entry_screen.dart';
import 'package:shoes_shop/views/vendor/banned_screen.dart';
import 'package:shoes_shop/views/vendor/profile/store_data_analysis.dart';

import '../views/auth/account_type.dart';
import '../views/auth/customer/customer_auth.dart';
import '../views/auth/customer/forgot_password.dart';
import '../views/customer/main_screen.dart';
import '../views/customer/relational_screens/wishlist_products.dart';
import '../views/vendor/entry_screen.dart';
import '../views/splash/splash.dart';
import '../views/vendor/main_screen.dart';
import '../views/vendor/products/create.dart';

class RouteManager {
  // General routes
  static const String splashScreen = "/splash";
  static const String accountType = "/accountType";

  // Customer routes
  static const String customerAuthScreen = "/customerAuthScreen";
  static const String customerForgotPass = "/customerForgotPass";
  static const String signUpAccountScreen = "/sigUpAccountScreen";
  static const String customerMainScreen = '/customerHomeScreen';
  static const String ordersScreen = '/OrdersScreen';
  static const String orderManageScreen = '/orderManagementScreen';
  static const String wishList = '/wishList';
  static const String favoriteList = '/favoriteList';
  static const String editAddress = '/editAddressScreen';

  // Vendor routes
  static const String vendorAuthScreen = "/vendorAuthScreen";
  static const String vendorForgotPass = "/vendorForgotPass";
  static const String vendorEntryScreen = '/vendorEntryScreen';
  static const String vendorMainScreen = '/vendorMainScreen';
  static const String vendorCreatePost = '/vendorCreatePost';
  static const String vendorDataAnalysis = '/vendorDataAnalysis';
  static const String vendorBannedScreen = '/vendorBanned';

  // Shipper routes
  static const String shipperAuthScreen = "/shipperAuthScreen";
  static const String shipperForgotPass = "/shipperForgotPass";
  static const String shipperEntryScreen = "/shipperEntryScreen";
  static const String shipperMainScreen = '/shipperMainScreen';
}

final routes = {
  RouteManager.splashScreen: (context) => const SplashScreen(),
  RouteManager.accountType: (context) => const AccountTypeScreen(),

  // Customer routes
  RouteManager.customerAuthScreen: (context) => const CustomerAuthScreen(),
  RouteManager.customerForgotPass: (context) => const CustomerForgotPassword(),
  RouteManager.customerMainScreen: (context) =>
      const CustomerMainScreen(index: 0),
  RouteManager.ordersScreen: (context) => const OrdersScreen(),
  RouteManager.orderManageScreen: (context) => const OrdersManagementScreen(),
  RouteManager.wishList: (context) => const WishListProducts(),
  RouteManager.favoriteList: (context) => const FavoriteProducts(),
  RouteManager.editAddress: (context) => const CustomerForgotPassword(),

  // Vendor routes
  RouteManager.vendorAuthScreen: (context) => const VendorAuthScreen(),
  RouteManager.vendorForgotPass: (context) => const VendorForgotPassword(),
  RouteManager.vendorEntryScreen: (context) => const VendorEntryScreen(),
  RouteManager.vendorMainScreen: (context) => const VendorMainScreen(index: 0),
  RouteManager.vendorCreatePost: (context) => const VendorCreateProduct(),
  RouteManager.vendorDataAnalysis: (context) => const StoreDataAnalysis(),
  RouteManager.vendorBannedScreen: (context) => const VendorBannedScreen(),

  // Shipper routes
  RouteManager.shipperAuthScreen: (context) => const ShipperAuthScreen(),
  RouteManager.shipperForgotPass: (context) => const ShipperForgotPassword(),
  RouteManager.shipperEntryScreen: (context) => const ShipperEntryScreen(),
  RouteManager.shipperMainScreen: (context) =>
      const ShipperMainScreen(index: 0),
};
