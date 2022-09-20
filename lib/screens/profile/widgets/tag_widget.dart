import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final double textSize;
  final Color backgroundColor;
  final Color textColor;

  const TagWidget(
      {required this.text,
      required this.textSize,
      required this.backgroundColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14), color: backgroundColor),
      child: Text(
        text,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
            color: textColor,
            fontWeight: FontWeight.normal,
            fontSize: textSize),
      ),
    );
  }
}
