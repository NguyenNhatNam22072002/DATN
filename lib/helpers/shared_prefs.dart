import 'package:shared_preferences/shared_preferences.dart';

import '../constants/enums/account_type.dart';

// check if app has ran before
Future<bool> checkIfAppPreviouslyRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isAppPreviouslyRun') ?? false;
}

// set appIsPreviouslyRun
Future<void> setAppPreviouslyRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAppPreviouslyRun', true);
}

Future<void> setAccountType({required AccountType accountType}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Reset all account type flags to false
  await prefs.setBool('isCustomer', false);
  await prefs.setBool('isVendor', false);
  await prefs.setBool('isShipper', false);

  // Set the selected account type to true
  switch (accountType) {
    case AccountType.customer:
      await prefs.setBool('isCustomer', true);
      break;
    case AccountType.vendor:
      await prefs.setBool('isVendor', true);
      break;
    case AccountType.shipper:
      await prefs.setBool('isShipper', true);
      break;
  }
}

Future<bool> checkIfCustomer() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isCustomer') ?? false;
}

Future<bool> checkIfVendor() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isVendor') ?? false;
}

Future<bool> checkIfShipper() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isShipper') ?? false;
}
