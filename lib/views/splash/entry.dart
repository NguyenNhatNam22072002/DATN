import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../resources/assets_manager.dart';
import '../../controllers/route_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({
    Key? key,
    required this.isAppPreviouslyRun,
    required this.isCustomer,
  }) : super(key: key);
  final bool isAppPreviouslyRun;
  final bool isCustomer;

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  Timer? _timer;

  void isFirstRun() {
    if (widget.isAppPreviouslyRun) {
      // app has ran before
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          // user is logged in
          if (widget.isCustomer) {
            // user is a customer
            _timer = Timer(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteManager.customerMainScreen, (route) => false);
              }
            });
          } else {
            // user is a vendor
            _timer = Timer(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteManager.vendorEntryScreen, (route) => false);
              }
            });
          }
        } else {
          // user is not logged in
          _timer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteManager.accountType, (route) => false);
            }
          });
        }
      });
    } else {
      // app has not ran before
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              RouteManager.splashScreen, (router) => false);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Permission.storage.request();
    isFirstRun();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(AssetManager.logoTransparent, width: 150),
      ),
    );
  }
}
