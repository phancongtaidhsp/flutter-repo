import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/screens/login/login.dart';
import 'package:gem_consumer_app/screens/onboarding/onboarding-page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/values/key-storage.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';

import 'screens/user-address-page/widgets/pop-up-set-location-service.dart';

class Splash extends StatefulWidget {
  static String routeName = '/splash';
  static late Auth auth;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<void> startApp() async {
    Timer(Duration(milliseconds: 500), () async {
      var box = await Hive.openBox('tokens');
      bool? isOpenAppFirstTime = box.get(KEY_OPEN_APP_FIRST_TIME);
      if (isOpenAppFirstTime == null || !isOpenAppFirstTime) {
        box.put(KEY_OPEN_APP_FIRST_TIME, true);
        Navigator.pushReplacementNamed(context, OnboardingPage.routeName);
      } else {
        Navigator.pushReplacementNamed(context, Login.routeName);
      }
    });
  }

  @override
  void initState() {
    startApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/GemspotVerLogoBlack.svg',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // Text(
                //   'General.GEMSPOT'.tr(),
                //   style: Theme.of(context).textTheme.headline2,
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
