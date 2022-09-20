import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class OnboardingPageView extends StatelessWidget {
  final String imageBackground;
  final String title1;
  final String title2;

  OnboardingPageView(
      {required this.imageBackground,
      required this.title1,
      required this.title2});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(imageBackground),
        fit: BoxFit.cover,
      )),
      child: ClipRRect(
        child: Container(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
          child: Column(
            children: [
              Text(
                title1,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 32, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                title2,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline1!.copyWith(
                    fontSize: 32,
                    color: primaryColor,
                    fontWeight: FontWeight.normal),
              )
            ],
          ),
        ),
      ),
    );
  }
}
