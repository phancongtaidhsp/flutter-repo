import 'package:flutter/material.dart';

import '../../values/color-helper.dart';

class VariationIcon extends StatelessWidget {
  const VariationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
      ),
      padding: const EdgeInsets.only(
        top: 0,
      ),
      margin: const EdgeInsets.only(
        right: 12,
        top: 1.5,
      ),
      child: Icon(
        Icons.check,
        color: Colors.black,
        size: 8,
      ),
    );
  }
}
