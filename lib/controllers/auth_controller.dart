import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shoes_shop/api/apis.dart';
import '../constants/enums/account_type.dart';
import '../helpers/auth_error_formatter.dart';
import '../models/auth_result.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  Future<AuthResult?> signInUser(String email, String password) async {
    try {
      var credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      var errorMessage = authErrorFormatter(e);
      return AuthResult.error(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<AuthResult?> signUpUser({
    required String email,
    required String fullname,
    required String phone,
    required String password,
    required AccountType accountType,
    required File? profileImage,
    String country = '',
    String state = '',
    String city = '',
    String taxNumber = '',
    String storeRegNo = '',
    bool isStoreRegistered = false,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // upload img
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(
            accountType == AccountType.vendor ? 'vendor-images' : 'user-images',
          )
          .child('${credential.user!.uid}.jpg');

      File? file;
      file = File(profileImage!.path);

      await storageRef.putFile(file);
      var downloadUrl = await storageRef.getDownloadURL();
      await APIs.createUser(fullname, downloadUrl);
      if (accountType == AccountType.vendor) {
        firebase.collection('vendors').doc(credential.user!.uid).set({
          'storeName': fullname,
          'email': email,
          'storeImgUrl': downloadUrl,
          'authType': 'email',
          'phone': phone,
          'address': '',
          'country': country,
          'state': state,
          'city': city,
          'taxNumber': taxNumber,
          'storeNumber': storeRegNo,
          'balanceAvailable': 0.0,
          'isApproved': false,
          'isBanned': false,
          'isStoreRegistered': isStoreRegistered,
          'storeId': credential.user!.uid,
        });
      } else {
        firebase.collection('customers').doc(credential.user!.uid).set({
          'fullname': fullname,
          'email': email,
          'image': downloadUrl,
          'authType': 'email',
          'phone': phone,
          'address': '',
          'refundAmount': 0.0,
          'customerId': credential.user!.uid,
        });
      }
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      var response = 'error';
      var error = authErrorFormatter(e);
      response = error;
      return AuthResult.error(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<AuthResult?> signUpShipper({
    required String email,
    required String fullname,
    required String phone,
    required String password,
    required AccountType accountType,
    required File profileImage,
    String country = '',
    String state = '',
    String city = '',
    String vehicleType = '',
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('shipper-images')
          .child('${credential.user!.uid}.jpg');

      await storageRef.putFile(profileImage);
      var downloadUrl = await storageRef.getDownloadURL();

      // Save shipper information to Firestore
      await FirebaseFirestore.instance
          .collection('shippers')
          .doc(credential.user!.uid)
          .set({
        'fullname': fullname,
        'email': email,
        'image': downloadUrl,
        'authType': 'email',
        'phone': phone,
        'address': '',
        'country': country,
        'state': state,
        'city': city,
        'vehicleType': vehicleType,
        'earnings': 0.0,
        'shipperId': credential.user!.uid,
        'isApproved': false,
      });

      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      var error = authErrorFormatter(e);
      return AuthResult.error(error);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<AuthResult?> googleAuth(AccountType accountType) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      // Sign in with Google credential
      var logCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (accountType == AccountType.vendor) {
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(logCredential.user!.uid)
            .set(
          {
            'storeName': googleUser!.displayName,
            'email': googleUser.email,
            'storeImgUrl': googleUser.photoUrl,
            'authType': 'google',
            'phone': '',
            'address': '',
            'country': '',
            'state': '',
            'city': '',
            'taxNumber': '',
            'storeNumber': '',
            'balanceAvailable': 0.0,
            'isApproved': false,
            'isBanned': false,
            'isStoreRegistered': false,
            'storeId': logCredential.user!.uid,
          },
        );
      } else if (accountType == AccountType.shipper) {
        await FirebaseFirestore.instance
            .collection('shippers')
            .doc(logCredential.user!.uid)
            .set(
          {
            'fullname': googleUser!.displayName,
            'email': googleUser.email,
            'image': googleUser.photoUrl,
            'authType': 'google',
            'phone': '',
            'address': '',
            'country': '',
            'state': '',
            'city': '',
            'vehicleType': '',
            'earnings': 0.0,
            'shipperId': logCredential.user!.uid,
            'isApproved': false,
          },
        );
      } else {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(logCredential.user!.uid)
            .set(
          {
            'fullname': googleUser!.displayName,
            'email': googleUser.email,
            'image': googleUser.photoUrl,
            'authType': 'google',
            'phone': '',
            'address': '',
            'refundAmount': 0.0,
            'customerId': logCredential.user!.uid,
          },
        );
      }

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      var response = 'error';
      var error = authErrorFormatter(e);
      response = error;
      return AuthResult.error(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
    }
  }
}
