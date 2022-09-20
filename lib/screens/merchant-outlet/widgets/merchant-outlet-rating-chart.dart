import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class RatingReviewChart extends StatelessWidget {
  final int oneStartReviews,
      twoStarReviews,
      threeStarReviews,
      fourStarReviews,
      fiveStarReviews;

  RatingReviewChart({
    required this.fiveStarReviews,
    required this.fourStarReviews,
    required this.threeStarReviews,
    required this.oneStartReviews,
    required this.twoStarReviews,
  });

  double tempTotalFormula() {
    int largestNumberReview = [
      oneStartReviews,
      twoStarReviews,
      threeStarReviews,
      fourStarReviews,
      fiveStarReviews
    ].reduce(max);
    return 1.1 * largestNumberReview;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16),
      child: Column(
        children: [
          getHorizontalBar(
              percentage: fiveStarReviews, index: 5, context: context),
          SizedBox(
            height: 4,
          ),
          getHorizontalBar(
              percentage: fourStarReviews, index: 4, context: context),
          SizedBox(
            height: 4,
          ),
          getHorizontalBar(
              percentage: threeStarReviews, index: 3, context: context),
          SizedBox(
            height: 4,
          ),
          getHorizontalBar(
              percentage: twoStarReviews, index: 2, context: context),
          SizedBox(
            height: 4,
          ),
          getHorizontalBar(
              percentage: oneStartReviews, index: 1, context: context),
        ],
      ),
    );
  }

  Widget getHorizontalBar(
      {required int percentage,
      required int index,
      required BuildContext context}) {
    Size size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Text(
            index.toString(),
            style: TextStyle(
                fontFamily: 'Arial Rounded MT Bold',
                fontSize: 12,
                color: grayTextColor,
                fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Container(
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: size.width * 0.5 - 76,
                height: 12,
                color: Colors.grey[200],
              ),
              Container(
                width: tempTotalFormula() == 0
                    ? 0
                    : percentage * (size.width * 0.5 - 76) / tempTotalFormula(),
                height: 12,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
