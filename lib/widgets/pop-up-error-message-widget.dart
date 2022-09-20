import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class PopUpErrorMessageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  Text("Error.ErrorTitle",
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.normal))
                  .tr(),
                  Spacer(),
                  Container(
                      height: 36.0,
                      width: 36.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: Offset(0, 1.5))
                          ]),
                      child: IconButton(
                          icon:
                              SvgPicture.asset('assets/images/icon-close.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            Navigator.pop(context);
                          })),
                          
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: size.width,
                child: Text(
                  "Error.ErrorMessage",
                  style: textTheme.bodyText2!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  textAlign: TextAlign.left,
                ).tr(),
              ),
              SizedBox(
                height: 24,
              ),
              SubmitButton(
                  text: "Button.Okay",
                  textColor: Colors.black,
                  backgroundColor: primaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ]),
          ),
        ));
  }
}
