import 'package:firebase_auth/firebase_auth.dart';

String authErrorFormatter(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return "Email not recognized!";
    case 'account-exists-with-different-credential':
      return "Email already in use!";
    case 'wrong-password':
      return 'Email or Password Incorrect!';
    case 'network-request-failed':
      return 'Network error!';
    default:
      return e.message ?? 'An unknown error occurred';
  }
}

String extractErrorMessage(String exceptionMessage) {
  // Use a regular expression to find the first value before the comma inside the parentheses
  final regex = RegExp(r'\((.*?)\)');
  final match = regex.firstMatch(exceptionMessage);
  if (match != null) {
    final bracketContent = match.group(1);
    if (bracketContent != null) {
      final parts = bracketContent.split(',');
      if (parts.isNotEmpty) {
        return parts.first.trim();
      }
    }
  }
  return 'Unknown error';
}
