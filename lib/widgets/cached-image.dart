import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:shimmer/shimmer.dart';

class CachedImage extends StatelessWidget {
  final double width;
  final double height;
  final String imageUrl;

  CachedImage(
      {required this.width, required this.height, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      memCacheWidth: 1200,
      memCacheHeight: 1200, //this line
      fit: BoxFit.cover,
      width: width,
      height: height,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          color: Colors.grey[300],
        ),
      ),
      errorWidget: (context, url, error) =>
          DefaultImageHelper.defaultImageWithSize(
        width,
        height,
      ),
    );
  }
}
