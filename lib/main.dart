// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:shoes_shop/controllers/route_manager.dart';
import 'package:shoes_shop/providers/cart.dart';
import 'package:shoes_shop/providers/category.dart';
import 'package:shoes_shop/providers/order.dart';
import 'package:shoes_shop/providers/product.dart';
import 'package:shoes_shop/resources/theme_manager.dart';
import 'package:shoes_shop/views/splash/entry.dart';

import 'constants/color.dart';
import 'controllers/configs.dart';
import 'firebase_options.dart';
import 'helpers/shared_prefs.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void setupFlutterNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'channel id',
    'channel name',
    channelDescription: 'Notification',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification!.title,
    message.notification!.body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');

  log('\nNotification Channel Result: $result');

  await Config.fetchApiKeys(); // fetching api keys

  bool isAppPreviouslyRun = await checkIfAppPreviouslyRun();
  bool isCustomer = await checkIfCustomer();
  bool isVendor = await checkIfVendor();
  bool isShipper = await checkIfShipper();

  setupFlutterNotifications();

  requestNotificationPermission();

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      showNotification(message);
    }
  });

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $fcmToken');

  runApp(MyApp(
    isAppPreviouslyRun: isAppPreviouslyRun,
    isCustomer: isCustomer,
    isVendor: isVendor,
    isShipper: isShipper,
  ));
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.isAppPreviouslyRun,
    required this.isCustomer,
    required this.isVendor,
    required this.isShipper,
  }) : super(key: key);

  final bool isAppPreviouslyRun;
  final bool isCustomer;
  final bool isVendor;
  final bool isShipper;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: accentColor,
        statusBarBrightness: Brightness.dark,
      ),
    );

    EasyLoading.instance
      ..backgroundColor = primaryColor
      ..progressColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductData()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => CategoryData()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: getLightTheme(),
            title: 'Shoe\'s Store',
            home: child,
            routes: routes,
            builder: EasyLoading.init(),
          );
        },
        child: EntryScreen(
          isAppPreviouslyRun: isAppPreviouslyRun,
          isCustomer: isCustomer,
          isVendor: isVendor,
          isShipper: isShipper,
        ),
      ),
    );
  }
}
