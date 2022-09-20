import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductTagWidget extends StatelessWidget {
  final String text;
  final double? textSize;
  final Color backgroundColor;
  final Color textColor;
  final String iconPath;

  const ProductTagWidget({
    required this.text,
    this.textSize,
    required this.backgroundColor,
    required this.textColor,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14), color: backgroundColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            color: Colors.black,
            width: 12.5,
            height: 12.5,
          ),
          SizedBox(
            width: 5,
          ),
          Text(text,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.normal,
                  fontSize: textSize))
        ],
      ),
    );
  }
}
