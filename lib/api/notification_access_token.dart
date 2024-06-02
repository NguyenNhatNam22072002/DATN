import 'dart:developer';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationAccessToken {
  static String? _token;

  // To generate token only once for an app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // To get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      // Load the environment variables
      await dotenv.load(fileName: ".env");

      // Get the service account credentials from environment variable
      final credentialsJson = dotenv.env['SERVICE_ACCOUNT_CREDENTIALS'];
      if (credentialsJson == null) {
        throw Exception('Service account credentials not found');
      }

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(jsonDecode(credentialsJson)),
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
