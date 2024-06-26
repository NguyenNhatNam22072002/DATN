import 'package:flutter/material.dart';
import '../../resources/styles_manager.dart';

class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.value,
    required this.title,
  });

  final dynamic value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: title,
        style: getRegularStyle(
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: value,
            style: getMediumStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
