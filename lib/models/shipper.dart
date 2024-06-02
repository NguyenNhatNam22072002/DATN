import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoes_shop/resources/assets_manager.dart';

class Shipper {
  final String shipperId;
  final String fullname;
  final String email;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String image;
  final String? address;
  final String authType;
  final String? vehicleType;
  bool isApproved;

  Shipper({
    required this.shipperId,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.image,
    required this.address,
    required this.authType,
    required this.vehicleType,
    this.isApproved = false,
  });

  factory Shipper.initial() => Shipper(
        shipperId: '',
        fullname: '',
        email: '',
        phone: '',
        country: '',
        state: '',
        city: '',
        image: AssetManager.avatarPlaceholderUrl,
        address: '',
        authType: '',
        vehicleType: '',
      );

  Shipper.fromJson(Map<String, dynamic> data)
      : this(
          shipperId: data['shipperId'],
          fullname: data['fullname'],
          email: data['email'],
          phone: data['phone'],
          country: data['country'],
          state: data['state'],
          city: data['city'],
          address: data['address'],
          authType: data['authType'],
          image: data['image'],
          isApproved: data['isApproved'],
          vehicleType: data['vehicleType'],
        );

  Shipper.fromDoc(DocumentSnapshot data)
      : this(
          shipperId: data['shipperId'],
          fullname: data['fullname'],
          email: data['email'],
          phone: data['phone'],
          country: data['country'],
          state: data['state'],
          city: data['city'],
          address: data['address'],
          authType: data['authType'],
          image: data['image'],
          isApproved: data['isApproved'],
          vehicleType: data['vehicleType'],
        );

  Map<String, dynamic> toJson() => {
        'shipperId': shipperId,
        'fullName': fullname,
        'email': email,
        'phone': phone,
        'country': country,
        'state': state,
        'city': city,
        'address': address,
        'authType': authType,
        'isApproved': isApproved,
        'image': image,
        'vehicleType': vehicleType,
      };
}
