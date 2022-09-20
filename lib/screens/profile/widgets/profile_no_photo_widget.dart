import 'package:flutter/material.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class ProfileNoPhotoWidget extends StatelessWidget {
  final bool isSetColor;
  final bool isCenterText;

  const ProfileNoPhotoWidget(
      {this.isSetColor = false, this.isCenterText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSetColor ? lightPrimaryColor : Colors.white,
      padding: EdgeInsets.only(top: 8),
      child: Center(
        child: Column(
          mainAxisAlignment:
              isCenterText ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Text(
              'No',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.normal, color: Colors.grey[600]),
            ),
            Text(
              'Photo',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.normal, color: Colors.grey[600]),
            )
          ],
        ),
      ),
    );
  }
}
