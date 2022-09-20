import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/MerchantOutetFeaturedReviews.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-amenities-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-description-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-directions-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-information.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-map-widget.dart';
import 'package:collection/collection.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-rating-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-remark-widget.dart';

class MerchantOutletDetailsWidget extends StatelessWidget {
  MerchantOutletDetailsWidget(this.merchantData, this.distance);

  final Map<String, dynamic> merchantData;
  final dynamic distance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List tabList = ["INFO", "REVIEWS"];
    List amenitiesList = List.empty(growable: true);

    var tempAmenitiesList = groupBy(merchantData["amenities"], (obj) {
      obj = obj as Map;
      return obj['amenity']['name'];
    });
    amenitiesList = tempAmenitiesList.keys.toList();

    return Container(
        width: size.width,
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Expanded(
            child: DefaultTabController(
              length: tabList.length,
              child: Scaffold(
                  backgroundColor: Colors.white,
                  primary: false,
                  appBar: PreferredSize(
                    preferredSize: Size(MediaQuery.of(context).size.width, 45),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: TabBar(
                        labelStyle: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(fontWeight: FontWeight.normal),
                        unselectedLabelStyle: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(fontSize: 14),
                        isScrollable: true,
                        labelPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 5.0),
                        indicatorWeight: 4,
                        indicatorColor: Color.fromRGBO(253, 196, 0, 1),
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: List.generate(
                          tabList.length,
                          (index) => Text(
                            tabList.toList()[index].toString(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: Container(
                    margin: EdgeInsets.only(top: 2.5),
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        offset: Offset(0.0, -2.0), //(x,y)
                        blurRadius: 4.0,
                      )
                    ]),
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 25),
                          child: ListView(children: [
                            merchantData['remark'] != null
                                ? MerchantOutletRemark(merchantData['remark'])
                                : Container(width: 0.0, height: 0.0),
                            merchantData['remark'] != null
                                ? SizedBox(height: 20)
                                : Container(width: 0.0, height: 0.0),
                            merchantData['introduction'] != null
                                ? MerchantOutletDescriptions(
                                    merchantData['introduction'])
                                : Container(width: 0.0, height: 0.0),
                            merchantData['introduction'] != null
                                ? SizedBox(height: 20)
                                : Container(width: 0.0, height: 0.0),
                            MerchantOutletInformation(merchantData),
                            SizedBox(height: 35),
                            MerchantOutletMap(merchantData["latitude"],
                                merchantData["longitude"]),
                            SizedBox(height: 20),
                            MerchantOutletDirections(
                                "${merchantData["address1"]}, ${merchantData["address2"]}, ${merchantData["state"]}, ${merchantData["postalCode"]}, ${merchantData["city"]}",
                                distance),
                            SizedBox(height: 20),
                            amenitiesList.length > 0
                                ? MerchantOutletAmenities(amenitiesList)
                                : Container(width: 0.0, height: 0.0),
                            amenitiesList.length > 0
                                ? SizedBox(height: 20)
                                : Container(width: 0.0, height: 0.0)
                          ]),
                        ),
                        SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MerchantOutletRating(merchantData),
                                Container(
                                  color: Colors.grey[200],
                                  height: 10,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                MerchantOutletFeaturedReviews(
                                    goToViewAll(), merchantData)
                              ]),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ]));
  }

  goToViewAll() {
    print('go to view all');
  }
}
