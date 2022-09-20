import 'package:flutter/material.dart';

class ColorHelper {
  static Color parseColor(String hexColor) {
    String hex = hexColor.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex =
          '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }
}

final Color primaryColor = ColorHelper.parseColor("#FDC400");
final Color lightPrimaryColor = ColorHelper.parseColor("#FFD56B");
final Color grayTextColor = ColorHelper.parseColor("#413C32");
final Color disableColor = Colors.grey.shade200;
final Color lightYellow = Color(0xFFFFEDC5);
final Color lightBack = Color(0xFF4B4A49);
