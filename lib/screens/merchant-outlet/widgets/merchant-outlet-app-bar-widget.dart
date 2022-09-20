import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MerchantOutletAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
        color: Colors.transparent,
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      height: 36.0,
                      width: 36.0,
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1)),
                          ]
                      ),
                      child: IconButton(
                          icon: SvgPicture.asset('assets/images/icon-back.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            Navigator.pop(context);
                          })),
                ])));
  }
}
