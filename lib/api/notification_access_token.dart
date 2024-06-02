import 'dart:developer';

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

      final client = await clientViaServiceAccount(
        // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
        // > Click on 'Generate new private key' Btn & Json file will be downloaded

        // Paste Your Generated Json File Content
        ServiceAccountCredentials.fromJson({
          // "type": "service_account",
          // "project_id": "shoe-shop-3ef3a",
          // "private_key_id": "ed43c19510c45062ab305736bff4856dae95c39b",
          // "private_key":
          //     "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDb1n4gaxy5E5Tf\n8bP/Mmi/NaFBiACBy87tkODpXVsizrNnbgySAXYaEhkntavKk9NY5xrOnKnQOfd2\nSB+HTknOAOg6GMDG7pHJWF39/WUkAY3wulVLnRg4rckGlBJbkktHTZm9+Juqnlq1\nI9M9HA8l7ESXeXM0kzklOKFKejzFh2iCSYZ19PfVF7RMgcmxu9WwywzvdV3Wgf8T\nqa/CK5ROnnu/+9I05914jee4JFxj3HxXjwR40fNZOEX9Y71XXhkkmupx0iPRfsBf\n06d6d6MiUEIn1kdJr+5OUNl0YpY/sIo7ldDfEi83Jv1j28FYVeQajHXo42QRgFMc\nwxQopdR/AgMBAAECggEAJbCshxpWHlUBHTPvTD10P/QN5ZJPo/ExVQGVzey3h0ww\n7fasKQwfF3Eq5uf6wAyAG6njqrCpXI3To2/SF/yQIsV9CxjbVD/qtr5zvuwGvxmV\nIESSAxi34l/JK1uPmiuGxH7FcRCCf8oOeyfdO4jn//R1/hJQch8bmQoQfRhf+u1e\nvByvUVdu6bOmn66VxMEZzcuqA+hS5Jc8HxYi0hd9Awind1Lh8JMY+u6AtZ9VWPhj\nSgn7LW6MvxJb8mCRkmlmogtn8LW9YcUGZbfxV2Dw4Y/nslOMmxio6t/GBHm/1nbv\n04lRB//ft/z5y0GV99ZMZcYzjweAI5J8J/R7j0jAgQKBgQD7z9RRebTgs61qXDAa\nFE6Qzm3TTKkJaaYhmBDYCE7yX+2Fv52rffFitKJ9vDJasUhi51v1DsytjHD+4MiX\n0TEHYaPzFv/9DpkE0OLy8JyP7gHT1bqdkLNv2gKBZdWwTqnGqaH+4HrFOcIxB52M\nGg8CWa+rQGpiibCOkcBNmxe38QKBgQDffoYUfrGjuhmgWbxIGZRO19mhLP9koGSk\nvlkYbViwRjwRbwtHt9m8hN2Rzr233uwKEnuq56hDwgt4N5IIv51qcv4HkwNoezW+\n9YFzNa+BmorqlDLV9ElpgPVIvYk+4pBTmWZGEkGSF7dTma67i3ZzBZxUEAYxq9dt\n6JezyMlDbwKBgGtXh9mHeSyES3tYewTS/T7LUJPPTQt/JtuRODTvLcAyVk06hprR\nIDIEcHQK4qg4hHPszg1j1qpwgMaVycy11yGfZMU+W7djHqWn6ebH3OWZ/ttvc5Kx\nWVxn4cOJRpNWpRbTvwOoa41hdr9x0J4liZpl4vWsiu0gZswPo5sxbuXxAoGAdYaU\nPWzOPznaxf7KSuPgoIFTeTUvbBwIMLXEJltB+xhD+Cr7tJASmNcJqOYdz/YTC8zi\naWH+kvsUivg1/BG/Vr33pcYCUcwQ3EU/+HSvwSiiim66ONaIUEm3MrQw2vfLS5rs\nNEbfYlLEXdsADrFs7Vly9qWijDZASBS6yZj5dVMCgYAJVJv60/bcn6s0fX3DeYLN\nOU7amwSdXmeezAvokRu5J9k7Pb5F14DAJnwr7M72G2VaIBoCZcE+WAH8rZ+309wo\nsIGwYGbjoFlUXtyyIPxdnFKR5NVtiZwxQZ5ncJtkBTuO52v5714oeDBSEk7SH1tg\n3OqwIBhJ4Aq1Zly944ZkXA==\n-----END PRIVATE KEY-----\n",
          // "client_email":
          //     "firebase-adminsdk-rp6vl@shoe-shop-3ef3a.iam.gserviceaccount.com",
          // "client_id": "115541648370837783357",
          // "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          // "token_uri": "https://oauth2.googleapis.com/token",
          // "auth_provider_x509_cert_url":
          //     "https://www.googleapis.com/oauth2/v1/certs",
          // "client_x509_cert_url":
          //     "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-rp6vl%40shoe-shop-3ef3a.iam.gserviceaccount.com",
          // "universe_domain": "googleapis.com"
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
