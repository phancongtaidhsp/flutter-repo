import 'package:flutter/material.dart';

class DefaultImageHelper {
  static Image defaultImage = Image.asset('assets/images/default-img.jpg');
  static Image defaultImageWithCover(
    BuildContext context,
  ) {
    return Image.asset(
      'assets/images/default-img.jpg',
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.25,
      fit: BoxFit.cover,
    );
  }

  static Image defaultImageWithSize(double width, double height) {
    //print('problem $width :: $height');
    return Image.asset(
      'assets/images/default-img.jpg',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
