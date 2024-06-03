import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
      // > Click on 'Generate new private key' Btn & Json file will be downloaded

      // Paste Your Generated Json File Content
      // Load dotenv
      await dotenv.load(fileName: "assets/.env");

      // Retrieve values
      String type = dotenv.env['TYPE']!;
      String projectId = dotenv.env['PROJECT_ID']!;
      String privateKeyId = dotenv.env['PRIVATE_KEY_ID']!;
      String privateKey = dotenv.env['PRIVATE_KEY']!;
      String clientEmail = dotenv.env['CLIENT_EMAIL']!;
      String clientId = dotenv.env['CLIENT_ID']!;
      String authUri = dotenv.env['AUTH_URI']!;
      String tokenUri = dotenv.env['TOKEN_URI']!;
      String authProviderX509CertUrl =
          dotenv.env['AUTH_PROVIDER_X509_CERT_URL']!;
      String clientX509CertUrl = dotenv.env['CLIENT_X509_CERT_URL']!;
      String universeDomain = dotenv.env['UNIVERSE_DOMAIN']!;

      print('Type: $type');
      print('Project ID: $projectId');
      print('Private Key ID: $privateKeyId');
      print('Private Key: $privateKey');
      print('Client Email: $clientEmail');
      print('Client ID: $clientId');
      print('Auth URI: $authUri');
      print('Token URI: $tokenUri');
      print('Auth Provider X509 Cert URL: $authProviderX509CertUrl');
      print('Client X509 Cert URL: $clientX509CertUrl');
      print('Universe Domain: $universeDomain');

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": type,
          "project_id": projectId,
          "private_key_id": privateKeyId,
          "private_key": privateKey,
          "client_email": clientEmail,
          "client_id": clientId,
          "auth_uri": authUri,
          "token_uri": tokenUri,
          "auth_provider_x509_cert_url": authProviderX509CertUrl,
          "client_x509_cert_url": clientX509CertUrl,
          "universe_domain": universeDomain
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
