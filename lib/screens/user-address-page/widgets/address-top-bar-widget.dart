import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';

class AddressTopBarWidget extends StatelessWidget {
  AddressTopBarWidget(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      height: size.height * 0.073,
      width: size.width,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(0, 1)),
      ]),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Container(
              margin: EdgeInsets.only(left: 25),
              height: 36.0,
              width: 36.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1)),
                  ]),
              child: IconButton(
                  icon: SvgPicture.asset('assets/images/icon-back.svg'),
                  iconSize: 18.0,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ),
          Center(
              child: Text(title,
                      style: textTheme.subtitle2!
                          .copyWith(fontWeight: FontWeight.normal))
                  .tr()),
        ],
      ),
    );
  }
}
