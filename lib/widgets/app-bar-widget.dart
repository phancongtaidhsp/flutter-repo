import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  AppBarWidget(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.grey[200],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.5,
                        blurRadius: 2,
                        offset: Offset(0, 1.5))
                  ]),
              child: IconButton(
                  icon: SvgPicture.asset('assets/images/icon-back.svg'),
                  iconSize: 36.0,
                  onPressed: () {
                    Navigator.pop(context);
                  })),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontWeight: FontWeight.normal),
          ).tr(),
          Container(
            width: 36,
            height: 36,
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 56);
}
