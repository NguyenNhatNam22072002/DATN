import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shoes_shop/constants/firebase_refs/collections.dart';
import '../../../../resources/styles_manager.dart';
import '../../../../resources/font_manager.dart';

class RefundDetailsPage extends StatefulWidget {
  final String orderId;

  const RefundDetailsPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<RefundDetailsPage> createState() => _RefundDetailsPageState();
}

class _RefundDetailsPageState extends State<RefundDetailsPage> {
  late String refundId;
  late int currentStatus;
  late TextEditingController statusController;
  late TextEditingController customerNameController;
  late TextEditingController amountController;
  late TextEditingController reasonController;
  late TextEditingController commentController;
  bool isLoading = true;
  Map<String, dynamic>? refundDetails;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    statusController = TextEditingController();
    customerNameController = TextEditingController();
    amountController = TextEditingController();
    reasonController = TextEditingController();
    commentController = TextEditingController();
    // Fetch refund details
    fetchRefundDetails(widget.orderId);
  }

  @override
  void dispose() {
    statusController.dispose();
    customerNameController.dispose();
    amountController.dispose();
    reasonController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> fetchRefundDetails(String orderId) async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot refundSnapshot = await FirebaseCollections.refundsCollection
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (refundSnapshot.docs.isNotEmpty) {
        DocumentSnapshot refundDoc = refundSnapshot.docs.first;
        setRefundDetails(refundDoc);
      } else {
        showNoRefundFoundMessage();
      }
    } catch (e) {
      handleFetchError(e);
    }
  }

  void setRefundDetails(DocumentSnapshot refundDoc) async {
    refundId = refundDoc.id;
    refundDetails = refundDoc.data() as Map<String, dynamic>;
    currentStatus = refundDetails!['status'];
    statusController.text = getStatusText(currentStatus);

    // Fetch and set customer details
    String customerId = refundDetails!['customerId'];
    DocumentSnapshot customerDoc =
        await FirebaseCollections.customersCollection.doc(customerId).get();
    customerNameController.text = customerDoc['fullname'] ?? '';
    amountController.text = '\$${refundDetails!['amount']}';
    reasonController.text = refundDetails!['reason'];
    commentController.text = refundDetails!['comment'];

    setState(() => isLoading = false);
  }

  void showNoRefundFoundMessage() {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No refund request found for this order')),
    );
  }

  void handleFetchError(dynamic error) {
    if (kDebugMode) {
      print('Failed to fetch refund details: $error');
    }
    setState(() => isLoading = false);
  }

  Future<void> updateRefundStatus(BuildContext context, int newStatus) async {
    try {
      // Fetch the current status from Firestore
      DocumentSnapshot refundSnapshot = await FirebaseFirestore.instance
          .collection('refunds')
          .doc(refundId)
          .get();

      if (refundSnapshot.exists) {
        await handleStatusUpdate(context, refundSnapshot, newStatus);
      } else {
        showDocumentNotFoundError();
      }
    } catch (e) {
      handleUpdateError(e);
    }
  }

  Future<void> handleStatusUpdate(BuildContext context,
      DocumentSnapshot refundSnapshot, int newStatus) async {
    int currentStatus = refundSnapshot['status'];

    if (newStatus != currentStatus) {
      bool isVendorCheck = (newStatus == 1);
      await updateFirestoreStatus(refundId, newStatus, isVendorCheck);

      if (newStatus == 1) {
        await processRefund(
            refundSnapshot['customerId'], refundSnapshot['amount'], refundId);
        showSuccessMessage('Status updated successfully and refund processed!');
      } else {
        showSuccessMessage('Status updated successfully!');
      }

      await fetchRefundDetails(widget.orderId); // Refresh state
    } else {
      showStatusAlreadySetMessage();
    }
  }

  Future<void> updateFirestoreStatus(
      String refundId, int newStatus, bool isVendorCheck) async {
    await FirebaseFirestore.instance
        .collection('refunds')
        .doc(refundId)
        .update({
      'status': newStatus,
      'isVendorCheck': isVendorCheck,
    });
  }

  void showDocumentNotFoundError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refund document does not exist.')),
    );
  }

  void handleUpdateError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating status: $error')),
    );
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showStatusAlreadySetMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('The status is already set to the selected value.')),
    );
  }

  Future<void> processRefund(
      String customerId, double amount, String refundId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference customerRef =
            FirebaseFirestore.instance.collection('customers').doc(customerId);
        DocumentSnapshot customerSnapshot = await transaction.get(customerRef);

        if (customerSnapshot.exists) {
          double currentRefundAmount =
              customerSnapshot.get('refundAmount') ?? 0.0;
          transaction.update(
              customerRef, {'refundAmount': currentRefundAmount + amount});
        } else {
          throw Exception('Customer not found');
        }

        DocumentReference walletTransactionRef =
            FirebaseFirestore.instance.collection('walletTransactions').doc();

        transaction.set(walletTransactionRef, {
          'transactionId': walletTransactionRef.id,
          'refundId': refundId,
          'customerId': customerId,
          'amount': amount,
          'transactionDate': DateTime.now(),
          'type': 'refund',
          'status': 'completed',
        });
      });
    } catch (error) {
      print('Error processing refund: $error');
    }
  }

  Future<void> _showStatusSelectionDialog(BuildContext context) async {
    int? newStatus = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Status'),
          content: buildStatusDropdown(),
          actions: [
            buildDialogCancelButton(context),
          ],
        );
      },
    );

    if (newStatus != null) {
      await updateRefundStatus(context, newStatus);
    }
  }

  DropdownButton<int> buildStatusDropdown() {
    return DropdownButton<int>(
      value: currentStatus,
      items: <int>[0, 1, 2].map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(getStatusText(value)),
        );
      }).toList(),
      onChanged: (int? newValue) {
        if (newValue != null) {
          updateRefundStatus(context,
              newValue);
        }
      },
    );
  }

  ElevatedButton buildDialogCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text('Cancel'),
    );
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Denied';
      default:
        return 'Unknown';
    }
  }

  Widget buildDetailRow(String label, TextEditingController controller,
      {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: getMediumStyle(
              color: Colors.black,
              fontSize: FontSize.s16,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: !isEditable,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Refund Details',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          letterSpacing: 1.0,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (refundDetails == null) {
      return const Center(child: Text('No refund request available'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          buildDetailRow('Customer name', customerNameController),
          buildDetailRow('Amount', amountController),
          buildDetailRow('Reason', reasonController),
          buildDetailRow('Comment', commentController),
          buildEvidentSection(),
          buildDetailRow(
            'Status',
            statusController,
            isEditable: false,
          ),
          const SizedBox(height: 20),
          buildUpdateStatusButton(),
        ],
      ),
    );
  }

  Widget buildEvidentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evident',
            style: getMediumStyle(
              color: Colors.black,
              fontSize: FontSize.s16,
            ),
          ),
          const SizedBox(height: 5),
          if (refundDetails!['mediaUrl'] != null)
            Image.network(refundDetails!['mediaUrl']),
        ],
      ),
    );
  }

  ElevatedButton buildUpdateStatusButton() {
    return ElevatedButton(
      onPressed: currentStatus == 1 || currentStatus == 2
          ? null
          : () {
              _showStatusSelectionDialog(context);
            },
      child: const Text('Update Status'),
    );
  }
}
