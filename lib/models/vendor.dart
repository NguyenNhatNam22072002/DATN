import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop/resources/assets_manager.dart';

class Vendor {
  final String storeId;
  final String storeName;
  final String email;
  final String phone;
  final String? taxNumber;
  final String? storeNumber;
  final String country;
  final String state;
  final String city;
  final String storeImgUrl;
  final String? address;
  final String authType;
  //final double lat; // Add latitude field
  //final double lng; // Add longitude field
  double balanceAvailable;
  bool isApproved;
  bool isStoreRegistered;

  Vendor({
    required this.storeId,
    required this.storeName,
    required this.email,
    required this.phone,
    required this.taxNumber,
    required this.storeNumber,
    required this.country,
    required this.state,
    required this.city,
    required this.storeImgUrl,
    required this.address,
    required this.authType,
    //required this.lat, // Add latitude to constructor
    //required this.lng, // Add longitude to constructor
    this.isApproved = false,
    this.isStoreRegistered = false,
    this.balanceAvailable = 0.0,
  });

  factory Vendor.initial() => Vendor(
        storeId: '',
        storeName: '',
        email: '',
        phone: '',
        taxNumber: '',
        storeNumber: '',
        country: '',
        state: '',
        city: '',
        storeImgUrl: AssetManager.avatarPlaceholderUrl,
        address: '',
        authType: '',
        //lat: 0.0, // Default value for latitude
        //lng: 0.0, // Default value for longitude
      );

  Vendor.fromJson(Map<String, dynamic> data)
      : this(
          storeId: data['storeId'],
          storeName: data['storeName'],
          email: data['email'],
          phone: data['phone'],
          taxNumber: data['taxNumber'],
          storeNumber: data['storeNumber'],
          country: data['country'],
          state: data['state'],
          city: data['city'],
          address: data['address'],
          authType: data['authType'],
          storeImgUrl: data['storeImgUrl'],
          //lat: data['lat'], // Initialize latitude from data
          //lng: data['lng'], // Initialize longitude from data
          balanceAvailable: double.parse(data['balanceAvailable'].toString()),
          isApproved: data['isApproved'],
          isStoreRegistered: data['isStoreRegistered'],
        );

  Vendor.fromDoc(DocumentSnapshot data)
      : this(
          storeId: data['storeId'],
          storeName: data['storeName'],
          email: data['email'],
          phone: data['phone'],
          taxNumber: data['taxNumber'],
          storeNumber: data['storeNumber'],
          country: data['country'],
          state: data['state'],
          city: data['city'],
          address: data['address'],
          authType: data['authType'],
          storeImgUrl: data['storeImgUrl'],
          // lat: data['lat'], // Initialize latitude from DocumentSnapshot
          // lng: data['lng'], // Initialize longitude from DocumentSnapshot
          balanceAvailable: double.parse(data['balanceAvailable'].toString()),
          isApproved: data['isApproved'],
          isStoreRegistered: data['isStoreRegistered'],
        );

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'storeName': storeName,
        'email': email,
        'phone': phone,
        'taxNumber': taxNumber,
        'storeNumber': storeNumber,
        'country': country,
        'state': state,
        'city': city,
        'address': address,
        'authType': authType,
        'storeImgUrl': storeImgUrl,
        //'lat': lat, // Add latitude to toJson method
        // 'lng': lng, // Add longitude to toJson method
        'isStoreRegistered': isStoreRegistered,
        'isApproved': isApproved,
        'balanceAvailable': balanceAvailable,
      };
}
