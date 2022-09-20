import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? rippleColor;
  final Function onPressed;
  final bool? isUppercase;
  final double? width;
  final double? height;
  final double? textSize;
  final double? verticalTextPadding;
  final bool? isMinWidth;

  const SubmitButton(
      {required this.text,
      this.textColor,
      this.backgroundColor,
      this.rippleColor,
      required this.onPressed,
      this.isUppercase = false,
      this.width,
      this.height,
      this.textSize,
      this.verticalTextPadding,
      this.isMinWidth = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () => onPressed(),
        splashColor: rippleColor ?? Colors.grey,
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: verticalTextPadding ?? 16, horizontal: 24.0),
          width:
              isMinWidth! ? null : width ?? MediaQuery.of(context).size.width,
          child: Text(
            isUppercase! ? text.tr().toUpperCase() : text.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: textColor,
                fontFamily: 'Arial Rounded MT Bold',
                fontSize: textSize ?? 16,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
