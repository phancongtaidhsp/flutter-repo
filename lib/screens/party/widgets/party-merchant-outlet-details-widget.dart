import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/view_merchant_outlet_page.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-carousel.dart';
import 'package:collection/collection.dart';

class PartyMerchantOutletDetailsWidget extends StatelessWidget {
  PartyMerchantOutletDetailsWidget(
      this.merchantData, this.distance, this.averageReview);

  final Map<String, dynamic> merchantData;
  final double distance;
  final double averageReview;

  @override
  Widget build(BuildContext context) {
    print("build");
    Size size = MediaQuery.of(context).size;
    List businessCategoriesList = List.empty(growable: true);
    var tempBusinessCategoriesList =
        groupBy(merchantData["businessCategories"], (obj) {
      obj = obj as Map;
      return obj['businessCategory']['name'];
    });
    businessCategoriesList = tempBusinessCategoriesList.keys.toList();

    return Stack(children: <Widget>[
      Column(children: <Widget>[
        MerchantOutletPhotoCarousel(merchantData['id'],
            height: MediaQuery.of(context).size.height * 0.3),
        Container(
            width: size.width,
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(merchantData['name'],
                          style: Theme.of(context)
                              .textTheme
                              .headline1!
                              .copyWith(color: Colors.black)),
                      SizedBox(height: 16.0),
                      Row(children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // Row(
                            //   mainAxisSize: MainAxisSize.min,
                            //   children: <Widget>[
                            //     Icon(Icons.star,
                            //         size: 13.0, color: Color(0xFFF4B920)),
                            //     SizedBox(width: 4.0),
                            //     Text('${averageReview.toStringAsFixed(1)}  ',
                            //         style: Theme.of(context)
                            //             .textTheme
                            //             .subtitle2!
                            //             .copyWith(
                            //                 fontSize: 12,
                            //                 color: Color(0xFFF4B920)))
                            //   ],
                            // ),
                            merchantData['priceRange'] != null
                                ? _buildPriceIndicator(
                                    context, merchantData['priceRange'])
                                : Container(width: 0.0, height: 0.0),
                            Text( merchantData['priceRange'] != null ? " • " : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(fontSize: 12)),
                            Icon(
                              Icons.people,
                              size: 12.0,
                            ),
                            Text(" ${merchantData['maxPax'].toString()} pax",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400))
                          ],
                        ),
                        // Text(" • ${distance.toStringAsFixed(1)} km",
                        //     style: Theme.of(context)
                        //         .textTheme
                        //         .subtitle2!
                        //         .copyWith(
                        //             fontSize: 12, fontWeight: FontWeight.w400))
                      ]),
                      SizedBox(height: 4.0),
                      Text(businessCategoriesList.join(" • "),
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.normal)),
                    ]))),
      ]),
      Positioned(
          top: MediaQuery.of(context).size.height * 0.265,
          right: 20,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(), primary: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, ViewMerchantOutletPage.routeName,
                  arguments:
                      ViewMerchantOutletPageArguments(merchantData['id']));
            },
            child: SvgPicture.asset('assets/images/icon-info.svg',
                width: 10, height: MediaQuery.of(context).size.height * 0.055),
          ))
    ]);
  }

  Widget _buildPriceIndicator(BuildContext context, String priceIndicator) {
    List<Widget> widgets = [];
    String priceStr = "";
    String greyPriceStr = "";
    int price =
        priceIndicator != null ? int.parse(priceIndicator.toString()) : 0;

    for (int i = 0; i < price; i++) {
      priceStr += "\$";
    }
    if (priceStr != "") {
      widgets.add(Text(priceStr,
          style:
              Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 12)));
    }
    if (priceStr.length < 4) {
      for (int j = 0; j < 4 - priceStr.length; j++) {
        greyPriceStr += "\$";
      }
      if (greyPriceStr != "") {
        widgets.add(Text(greyPriceStr,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontSize: 12, color: Colors.grey)));
      }
    }

    return Row(children: widgets);
  }
}
