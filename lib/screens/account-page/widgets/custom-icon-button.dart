import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';

class CustomIconButton extends StatelessWidget {
  CustomIconButton(this.iconPicturePath, this.iconText, this.iconFunction);
  final String iconPicturePath;
  final String iconText;
  final Function iconFunction;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => iconFunction(),
        child: Container(
            width: MediaQuery.of(context).size.width / 3.5,
            height: MediaQuery.of(context).size.width / 3.5,
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 4.0,
                  )
                ]),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(iconPicturePath),
                  SizedBox(height: 12.0),
                  Text(iconText,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button!.copyWith(
                              fontSize: 12, fontWeight: FontWeight.bold))
                      .tr(),
                ])));
  }
}
