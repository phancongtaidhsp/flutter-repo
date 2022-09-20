import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-rating-chart.dart';

class MerchantOutletRating extends StatelessWidget {
  final Map<String, dynamic> merchantOutletData;

  MerchantOutletRating(this.merchantOutletData);

  int countNumberRatedStar(int ratingStar) {
    if (merchantOutletData['reviews'] != null &&
        merchantOutletData['reviews'].length > 0) {
      return merchantOutletData['reviews']
          .where((e) => e['score'] == ratingStar)
          .length;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Average rating
    var listReview = merchantOutletData['reviews'];
    // listReview.add({'score': 2});
    // listReview.add({'score': 5});
    // listReview.add({'score': 4});
    // listReview.add({'score': 3});
    // listReview.add({'score': 1});
    // listReview.add({'score': 5});
    // listReview.add({'score': 5});
    // listReview.add({'score': 5});
    // listReview.add({'score': 5});
    // listReview.add({'score': 5});
    // listReview.add({'score': 5});
    // listReview.add({'score': 4});

    double averageReview = 0.0;
    if (listReview != null && listReview.length > 0) {
      averageReview =
          (listReview.map((e) => e['score']).reduce((a, b) => a + b)) /
              listReview.length;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ViewMerchantOutlet.Overall'.tr(),
                    style: TextStyle(
                        fontFamily: 'Arial Rounded MT Bold',
                        color: Colors.grey[600],
                        fontSize: 12),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    averageReview.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 36,
                        color: Colors.black,
                        fontFamily: 'Arial Rounded MT Bold'),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  RatingBar(
                    initialRating: averageReview,
                    minRating: 0.0,
                    maxRating: 5.0,
                    itemPadding: EdgeInsets.symmetric(horizontal: 1.5),
                    ignoreGestures: true,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 12,
                    onRatingUpdate: (context) {},
                    ratingWidget: RatingWidget(
                        half: SvgPicture.asset(
                          'assets/images/full-star.svg',
                        ),
                        full: SvgPicture.asset(
                          'assets/images/full-star.svg',
                          width: 8,
                          height: 8,
                        ),
                        empty: SvgPicture.asset(
                          'assets/images/empty-star.svg',
                          width: 8,
                          height: 8,
                        )),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: RatingReviewChart(
                oneStartReviews: countNumberRatedStar(1),
                twoStarReviews: countNumberRatedStar(2),
                threeStarReviews: countNumberRatedStar(3),
                fourStarReviews: countNumberRatedStar(4),
                fiveStarReviews: countNumberRatedStar(5),
              ),
            ),
          )
        ],
      ),
    );
  }
}
