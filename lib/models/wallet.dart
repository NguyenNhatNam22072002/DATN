import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  final String transactionId;
  final String refundId;
  final String customerId;
  final double amount;
  final DateTime transactionDate;
  final int status; // 0: Pending, 1: Completed, 2: Failed

  Wallet({
    required this.transactionId,
    required this.refundId,
    required this.customerId,
    required this.amount,
    required this.transactionDate,
    required this.status,
  });

  Wallet.fromJson(QueryDocumentSnapshot item)
      : this(
          transactionId: item['transactionId'],
          refundId: item['refundId'],
          customerId: item['customerId'],
          amount: double.parse(item['amount'].toString()),
          transactionDate: item['transactionDate'].toDate(),
          status: item['status'],
        );

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'refundId': refundId,
      'customerId': customerId,
      'amount': amount,
      'transactionDate': transactionDate,
      'status': status,
    };
  }
}
