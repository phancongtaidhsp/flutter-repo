import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class LoadingController extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: SpinKitFadingCircle(
          color: primaryColor,
          size: 42.0,
        ),
      );
}
