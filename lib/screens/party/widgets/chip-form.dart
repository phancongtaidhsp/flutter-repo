import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class ChipForm extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final bool isShowIcon;
  final bool isEnable;
  String? iconPath;
  double? iconWidth;
  double? iconHeight;
  final FontWeight? fontWeight;
  final bool? isOnBoardingPage;

  ChipForm({
    required this.text,
    this.width,
    this.height,
    this.isShowIcon = true,
    this.isEnable = true,
    this.fontWeight,
    this.iconPath,
    this.iconWidth = 8,
    this.iconHeight = 8,
    this.isOnBoardingPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? null,
      height: height ?? null,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23.0),
          color: isEnable
              ? isOnBoardingPage != null
                  ? Color.fromRGBO(253, 190, 0, 1)
                  : Color.fromRGBO(255, 213, 107, 1)
              : Colors.grey[200]), //Color.fromRGBO(255, 213, 107, 1) :
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grayTextColor,
                fontSize: 16,
                fontWeight: fontWeight ?? FontWeight.w400,
                fontFamily: 'Arial Rounded MT Bold',
              ),
            ),
          ),
          SizedBox(width: isShowIcon ? 2 : 0),
          isShowIcon
              ? SvgPicture.asset(
                  iconPath ?? 'assets/images/dropdown-button.svg',
                  color: grayTextColor,
                  width: iconWidth,
                  height: iconHeight,
                )
              : Container(height: 0, width: 0)
        ],
      ),
    );
  }
}
