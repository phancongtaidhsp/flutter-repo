import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;
import 'package:gem_consumer_app/screens/home/widgets/search-bar.dart';
import '../../../widgets/banner-carousel.dart';

class CelebrationHeaderSliverFixedHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  CelebrationHeaderSliverFixedHeaderDelegate(
      {required this.minHeight, required this.maxHeight, required this.child});
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    print('celebration-fixed-headerr');
    final screenOffsetRatio = 0.555;
    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Stack(fit: StackFit.expand, children: <Widget>[
          containerHeight(shrinkOffset) > screenOffsetRatio
              ? AnimatedPositioned(
                  top: 0.0,
                  duration: Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                      opacity: containerHeight(shrinkOffset) > screenOffsetRatio
                          ? 1.0
                          : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: BannerCarousel('CELEBRATION',
                          height: MediaQuery.of(context).size.width * 0.6,
                          child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              color: Color.fromRGBO(255, 213, 107, 1),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                      padding: EdgeInsets.only(
                                          top: 80.0, left: 25.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.52,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'CelebrationHome.Title',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Arial Rounded MT Bold',
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 32,
                                              ),
                                              textAlign: TextAlign.left,
                                            ).tr(),
                                            SizedBox(height: 8.0),
                                            Text(
                                              'CelebrationHome.SubTitle',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Arial Rounded MT Light',
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.left,
                                            ).tr(),
                                          ])))))))
              : Container(
                  height: 80.0, color: Color.fromRGBO(255, 213, 107, 1)),
          Positioned(
            top: 20.0,
            child: SearchBar(
              showBackButton: true,
            ),
          ),
          AnimatedPositioned(
              duration: Duration(milliseconds: 100),
              top: containerHeight(shrinkOffset) > screenOffsetRatio
                  ? 205.0
                  : 80.0,
              width: MediaQuery.of(context).size.width,
              child: Container(
                  padding: EdgeInsets.only(
                      top: containerHeight(shrinkOffset) > screenOffsetRatio
                          ? 30.0
                          : 20.0,
                      left: 25.0,
                      bottom: containerHeight(shrinkOffset) > screenOffsetRatio
                          ? 25.0
                          : 10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(18))),
                  child: child))
        ]));
  }

  double containerHeight(double shrinkOffset) {
    // when shrinkOffset > minExtend
    // return 1.0 - math.max(0.0, (shrinkOffset - minHeight)) / (maxExtent - minHeight);
    return 1.0 - math.max(0.0, shrinkOffset) / maxExtent;
  }

  @override
  bool shouldRebuild(CelebrationHeaderSliverFixedHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }
}
