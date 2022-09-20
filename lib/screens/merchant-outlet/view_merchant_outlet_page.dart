import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/gql/merchant-outlet.gql.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-app-bar-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-details-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-carousel.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ViewMerchantOutletPage extends StatelessWidget {
  static String routeName = '/view-merchant-outlet';
  Position? position;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as ViewMerchantOutletPageArguments;
    getCurrentLocation();

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder<Position?>(
              future: getCurrentLocation(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Stack(children: <Widget>[
                    Query(
                        options: QueryOptions(
                            variables: {
                              'id': args.merchantOutletId,
                              'userLatitude': position!.latitude,
                              'userLongitude': position!.longitude
                            },
                            document:
                                gql(MerchantOutletGQL.GET_MERCHANT_OUTLET),
                            fetchPolicy: FetchPolicy.cacheAndNetwork),
                        builder: (QueryResult result,
                            {VoidCallback? refetch, FetchMore? fetchMore}) {
                          if (result.isLoading) {
                            return LoadingController();
                          }
                          if (result.data != null) {
                            final merchantOutletData =
                                result.data!['MerchantOutlet'];
                            final distance = merchantOutletData['distance'];
                            double averageReview = 0.0;
                            if (merchantOutletData['reviews'] != null &&
                                merchantOutletData['reviews'].length > 0) {
                              averageReview = (merchantOutletData['reviews']
                                      .map((e) => e['score'])
                                      .reduce((a, b) => a + b)) /
                                  merchantOutletData['reviews'].length;
                            }
                            double totalDeliveryFee = 0.0;
                            var deliveryCollectionType =
                                (merchantOutletData['collectionTypes'] as List)
                                    .firstWhere(
                                        (element) =>
                                            element['type'] == 'DELIVERY',
                                        orElse: () => null);
                            if (deliveryCollectionType != null) {
                              if (deliveryCollectionType['firstNthKM'] !=
                                      null &&
                                  deliveryCollectionType[
                                          'firstNthKMDeliveryFee'] !=
                                      null &&
                                  deliveryCollectionType['deliveryFeePerKM'] !=
                                      null) {
                                int firstNthKM =
                                    deliveryCollectionType['firstNthKM'];
                                double firstNthKMDeliveryFee =
                                    deliveryCollectionType[
                                            'firstNthKMDeliveryFee']
                                        .toDouble();
                                double deliveryFeePerKM =
                                    deliveryCollectionType['deliveryFeePerKM']
                                        .toDouble();

                                double calculateDeliveryFee() {
                                  if (firstNthKM >= distance) {
                                    return double.parse(firstNthKMDeliveryFee
                                        .toStringAsFixed(2));
                                  }
                                  double subDistance =
                                      (distance - firstNthKM).toDouble();
                                  double deliveryFee = (firstNthKMDeliveryFee) +
                                      (subDistance.ceil() * deliveryFeePerKM);
                                  return double.parse(
                                      deliveryFee.toStringAsFixed(2));
                                }

                                if (distance != null) {
                                  totalDeliveryFee = calculateDeliveryFee();
                                }
                              }
                            }

                            List businessCategoriesList =
                                List.empty(growable: true);
                            var tempBusinessCategoriesList = groupBy(
                                merchantOutletData["businessCategories"],
                                (obj) {
                              obj = obj as Map;
                              return obj['businessCategory']['name'];
                            });
                            businessCategoriesList =
                                tempBusinessCategoriesList.keys.toList();

                            return Container(
                              color: Colors.white,
                              child: NestedScrollView(
                                  headerSliverBuilder: (BuildContext context,
                                      bool innerBoxIsScrolled) {
                                    return [
                                      SliverToBoxAdapter(
                                        child: MerchantOutletPhotoCarousel(
                                            args.merchantOutletId,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3),
                                      ),
                                      SliverToBoxAdapter(
                                          child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        color: Colors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20.0),
                                            Text(merchantOutletData['name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1!
                                                    .copyWith(
                                                        color: Colors.black)),
                                            SizedBox(height: 16.0),
                                            Row(children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Icon(Icons.star,
                                                      size: 12.0,
                                                      color: Color(0xFFF4B920)),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                      averageReview
                                                          .toStringAsFixed(2),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFFF4B920)))
                                                ],
                                              ),
                                              SizedBox(width: 8.0),
                                              distance != null
                                                  ? Text("Product.DistanceDeliveryPrice",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline3!
                                                              .copyWith(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal))
                                                      .tr(namedArgs: {
                                                      "distance": StringHelper
                                                          .formatCurrency(
                                                              distance),
                                                      "price": "RM " +
                                                          StringHelper
                                                              .formatCurrency(
                                                                  totalDeliveryFee)
                                                    })
                                                  : Text("- km • RM - • ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline3!
                                                          .copyWith(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                              _buildPriceIndicator(
                                                  context,
                                                  merchantOutletData[
                                                      'priceRange'])
                                            ]),
                                            SizedBox(height: 4.0),
                                            Text(
                                              businessCategoriesList
                                                  .join(" • "),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3!
                                                  .copyWith(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ))
                                    ];
                                  },
                                  body: Padding(
                                    padding: EdgeInsets.only(top: 44),
                                    child: Container(
                                        color: Colors.white,
                                        child: MerchantOutletDetailsWidget(
                                            merchantOutletData,
                                            distance?.toDouble() ?? '-')),
                                  )),
                            );
                          }
                          return Container(width: 0.0, height: 0.0);
                        }),
                    Positioned(top: 12.0, child: MerchantOutletAppBar()),
                  ]);
                } else {
                  return LoadingController();
                }
              }),
        ),
      ),
    );
  }

  Future<Position?>? getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    return position;
  }
}

Widget _buildPriceIndicator(BuildContext context, String priceIndicator) {
  List<Widget> widgets = [];
  String priceStr = "";
  String greyPriceStr = "";
  int price = priceIndicator != null ? int.parse(priceIndicator.toString()) : 0;

  for (int i = 0; i < price; i++) {
    priceStr += "\$";
  }
  if (priceStr != "") {
    widgets.add(Text(priceStr,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 12)));
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

class ViewMerchantOutletPageArguments {
  final String merchantOutletId;
  ViewMerchantOutletPageArguments(this.merchantOutletId);
}
