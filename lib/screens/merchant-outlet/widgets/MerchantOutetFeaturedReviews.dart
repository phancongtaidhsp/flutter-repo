import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/values/date-time-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';

class MerchantOutletFeaturedReviews extends StatelessWidget {
  final Function function;
  final Map<String, dynamic> merchantOutletData;

  const MerchantOutletFeaturedReviews(this.function, this.merchantOutletData);

  @override
  Widget build(BuildContext context) {
    List listReview = merchantOutletData['reviews']
        .where((i) => !i["isHidden"])
        .take(5)
        .toList();
    print("Check List Length");
    print(listReview);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ViewMerchantOutlet.FeaturedReviews'.tr(),
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              TextButton(
                onPressed: () {
                  print('aaaa');
                },
                child: Row(
                  children: [
                    Text(
                      'ViewMerchantOutlet.ViewAll'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    SvgPicture.asset(
                      'assets/images/icon-arrow-right.svg',
                      width: 8,
                      height: 12,
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _productList(context, merchantOutletData)
        ],
      ),
    );
  }
}

Widget _productList(BuildContext context, Map<String, dynamic> data) {
  List listReview =
      data['reviews'].where((i) => !i["isHidden"]).take(5).toList();
  print("Check List Length");
  print(listReview);

  return listReview.length > 0
      ? ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: listReview.length,
          itemBuilder: (BuildContext context, int index) {
            List listReviewsImage = listReview[index]['reviewPhotos'];
            return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: EdgeInsets.only(right: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedImage(
                          imageUrl: listReview[index]['user']['photoUrl'],
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listReview[index]['user']['displayName'] ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        RatingBar(
                          initialRating:
                              (listReview[index]['score']).toDouble() ?? 0,
                          minRating: 0.0,
                          maxRating: 5.0,
                          ignoreGestures: true,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemPadding: EdgeInsets.symmetric(horizontal: 1.5),
                          itemCount: 5,
                          itemSize: 12,
                          onRatingUpdate: (context) {},
                          ratingWidget: RatingWidget(
                              half: SvgPicture.asset(
                                'assets/images/full-star.svg',
                              ),
                              full: SvgPicture.asset(
                                'assets/images/full-star.svg',
                              ),
                              empty: SvgPicture.asset(
                                'assets/images/empty-star.svg',
                              )),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          listReview[index]['content'].toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        listReviewsImage.length > 0
                            ? GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                childAspectRatio: 1,
                                shrinkWrap: true,
                                children: List.generate(
                                    listReviewsImage.length,
                                    (index) => Container(
                                          padding: EdgeInsets.only(right: 3),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedImage(
                                              imageUrl: listReviewsImage[index],
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        )))
                            : Container(),
                        SizedBox(
                          height: listReviewsImage.length > 0 ? 12 : 0,
                        ),
                        Text(
                          DateTimeHelper.timeAgo(
                              listReview[index]['createdAt']),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 10),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          })
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 45.0),
          child: Center(
              child: Text(
            'ViewMerchantOutlet.EmptyReviews',
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Arial Rounded MT Light',
                color: Colors.black87),
          ).tr()),
        );
}
