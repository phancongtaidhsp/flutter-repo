import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/screens/home/home.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class EmailResendSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                    height: 36.0,
                    width: 36.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1.75,
                              blurRadius: 1,
                              offset: Offset(0, 1)),
                        ]),
                    child: IconButton(
                        icon: SvgPicture.asset('assets/images/icon-close.svg'),
                        iconSize: 36.0,
                        onPressed: () {
                          Navigator.pop(context);
                        })),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'EmailVerification.ResendCompleted'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.w400),
              ),
              Container(
                height: 170,
                child: SvgPicture.asset(
                  'assets/images/logo-tick.svg',
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Home.routeName, (route) => false);
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Center(
                        child: Text("Button.BackToHomePage".tr().toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Arial Rounded MT Bold',
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center),
                      )),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)))),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
