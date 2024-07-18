import 'dart:async';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shoes_shop/constants/color.dart';
import 'package:shoes_shop/views/widgets/kcool_alert.dart';
import '../../resources/assets_manager.dart';
import '../../resources/font_manager.dart';
import '../../controllers/route_manager.dart';
import '../../resources/styles_manager.dart';
import '../../resources/values_manager.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({Key? key}) : super(key: key);

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  StreamSubscription<PermissionStatus>? _permissionSubscription;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  @override
  void dispose() {
    _permissionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    kCoolAlert(
      message: 'We need storage permission to function properly.',
      context: context,
      alert: CoolAlertType.error,
      confirmBtnText: 'Allow',
      action: _handlePermissionAction,
      barrierDismissible: false,
    );
  }

  Future<void> _handlePermissionAction() async {
    Navigator.pop(context); // Close the dialog
    await openAppSettings();
    await Future.delayed(const Duration(seconds: 1));
    _listenToPermissionChanges();
  }

  void _listenToPermissionChanges() {
    _permissionSubscription =
        Permission.storage.status.asStream().listen((status) {
      if (status.isGranted) {
      } else {
        _requestStoragePermission();
      }
    });
  }

  Widget _authWidget({required String title, required String routeName}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Column(
        children: [
          Image.asset(AssetManager.avatar, width: 100, color: accentColor),
          const SizedBox(height: 10),
          Text(title, style: getRegularStyle(color: accentColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Image.asset(AssetManager.logoTransparent, width: 200, height: 200),
            const SizedBox(height: 20),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.person_outline, color: accentColor),
                Text(
                  'Select account type',
                  style: getMediumStyle(
                      color: accentColor, fontSize: FontSize.s18),
                ),
              ],
            ),
            const SizedBox(height: AppSize.s30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _authWidget(
                    title: 'Customer',
                    routeName: RouteManager.customerAuthScreen),
                _authWidget(
                    title: 'Vendor', routeName: RouteManager.vendorAuthScreen),
                _authWidget(
                    title: 'Shipper',
                    routeName: RouteManager.shipperAuthScreen),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                        text: 'Organized by: ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: 'namnguyen@hitek.com.vn',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
