import 'package:flutter/material.dart';
import 'package:shoes_shop/constants/color.dart';

import '../../constants/enums/yes_no.dart';

Widget textAction(String text, YesNo operation, BuildContext context) {
  return ElevatedButton(
    child: Text(
      text,
      style: const TextStyle(
        color: accentColor,
        fontWeight: FontWeight.normal,
      ),
    ),
    onPressed: () {
      switch (operation) {
        case YesNo.yes:
          Navigator.of(context).pop(true);
          break;
        case YesNo.no:
          Navigator.of(context).pop(false);
          break;
        default:
      }
    },
  );
}
