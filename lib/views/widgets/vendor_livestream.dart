import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoes_shop/views/vendor/livestream/livestream_page.dart';

class VendorLivestream extends StatefulWidget {
  const VendorLivestream({Key? key}) : super(key: key);

  @override
  State<VendorLivestream> createState() => _VendorLivestreamState();
}

class _VendorLivestreamState extends State<VendorLivestream> {
  // Replace with your Agora App ID
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showLivestreamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Livestream'),
          content: Text('Are you sure you want to start the livestream?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Start'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LivestreamPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showLivestreamDialog,
      icon: const Icon(
        Icons.video_call,
        color: Colors.green,
        size: 30,
      ),
    );
  }
}
