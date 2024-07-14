import 'package:cloud_firestore/cloud_firestore.dart';

class Refund {
  final String refundId;
  final String orderId;
  final String vendorId;
  final String customerId;
  final String reason;
  final String comment;
  final double amount;
  final DateTime requestDate;
  final int status; // 0: Requested, 1: Approved, 2: Denied, 3: Processed
  final bool isVendorCheck;

  Refund({
    required this.refundId,
    required this.orderId,
    required this.vendorId,
    required this.customerId,
    required this.reason,
    required this.comment,
    required this.amount,
    required this.requestDate,
    required this.status,
    this.isVendorCheck = false,
  });

  Refund.fromJson(QueryDocumentSnapshot item)
      : this(
          refundId: item['refundId'],
          orderId: item['orderId'],
          vendorId: item['vendorId'],
          customerId: item['customerId'],
          reason: item['reason'],
          comment: item['comment'],
          amount: double.parse(item['amount'].toString()),
          requestDate: item['requestDate'].toDate(),
          status: item['status'],
          isVendorCheck: item['isVendorCheck'],
        );

  Map<String, dynamic> toJson() {
    return {
      'refundId': refundId,
      'orderId': orderId,
      'vendorId': vendorId,
      'customerId': customerId,
      'reason': reason,
      'comment': comment,
      'amount': amount,
      'requestDate': requestDate,
      'status': status,
      'isVendorCheck': isVendorCheck,
    };
  }
}
