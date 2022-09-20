import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/providers/user-position-provider.dart';
import 'package:gem_consumer_app/screens/party/gql/party.gql.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class SelectOutletWidget extends StatefulWidget {
  final Map<String, dynamic> merchantInfo;
  final String productType;
  final Function onPressed;

  SelectOutletWidget(this.merchantInfo, this.productType,
      {required this.onPressed});

  @override
  _SelectOutletWidgetState createState() => _SelectOutletWidgetState();
}

class _SelectOutletWidgetState extends State<SelectOutletWidget> {
  late List<dynamic> outlets;
  late UserPositionProvider positionProvider;
  late PlanAParty party;

  @override
  void initState() {
    party = context.read<PlanAParty>();
    positionProvider = context.read<UserPositionProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime combineDateTime = new DateTime(
      party.date!.year,
      party.date!.month,
      party.date!.day,
      party.timeOfDay!.hour,
      party.timeOfDay!.minute,
    );
    bool venueNoFoodOrDecoration =
        (!party.currentVenueAnyDeco && widget.productType == "GIFT") ||
            (!party.currentVenueAnyFB && widget.productType == "FOOD");
    bool isDeliveryToVenue = party.collectionType == "DINE_IN" &&
        venueNoFoodOrDecoration &&
        party.venueProduct != null;

    return Query(
        options: QueryOptions(
            document: gql(PartyGQL.GET_MERCHANT_OUTLET_BY_MERCHANT_ID),
            variables: {
              "selectedServiceType":
                  isDeliveryToVenue ? "DELIVERY" : party.collectionType,
              "selectedServiceTime": isDeliveryToVenue
                  ? combineDateTime
                      .subtract(Duration(hours: 1))
                      .toUtc()
                      .toIso8601String()
                  : combineDateTime.toUtc().toIso8601String(),
              'merchantId': widget.merchantInfo['id'],
              "userLatitude": party.collectionType == "DINE_IN" &&
                      party.venueProduct != null
                  ? party.venueProduct!.outletProductInformation["outlet"]
                      ["latitude"]
                  : party.collectionType == 'DELIVERY'
                      ? party.deliveryAddress!.latitude
                      : positionProvider.userLatitude,
              "userLongitude": party.collectionType == "DINE_IN" &&
                      party.venueProduct != null
                  ? party.venueProduct!.outletProductInformation["outlet"]
                      ["longitude"]
                  : party.collectionType == 'DELIVERY'
                      ? party.deliveryAddress!.longitude
                      : positionProvider.userLongitude,
              'productType': widget.productType
            },
            fetchPolicy: FetchPolicy.noCache),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            print('API has Exception');
          }

          if (result.isLoading) {
            return LoadingController();
          }

          if (result.data != null) {
            outlets = result.data!['GetMerchantOutletsByMerchantId'];

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0.0),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0, vertical: 30.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                LayoutBuilder(builder: (context, constraints) {
                                  var imageDynamicHeight =
                                      constraints.maxWidth * 0.4;

                                  // print('select-outlet-widget');
                                  // print(widget.merchantInfo['photos'][0]);
                                  print(
                                      'width:  ${constraints.maxWidth} :: ${imageDynamicHeight} :: ${constraints.maxWidth * 0.4}  ');

                                  return Container(
                                      width: constraints.maxWidth,
                                      height: imageDynamicHeight,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: widget.merchantInfo['photos']
                                                        .length ==
                                                    0 ||
                                                widget.merchantInfo['photos'] ==
                                                    null
                                            ? DefaultImageHelper
                                                .defaultImageWithSize(
                                                constraints.maxWidth,
                                                imageDynamicHeight,
                                              )
                                            : CachedImage(
                                                width: constraints.maxWidth,
                                                height: imageDynamicHeight,
                                                imageUrl: widget
                                                    .merchantInfo['photos'][0]),
                                      ));
                                }),
                                SizedBox(height: 8.0),
                                Text(
                                  widget.merchantInfo['name'],
                                  style: Theme.of(context).textTheme.button,
                                ),
                                SizedBox(height: 8.0),
                              ])),
                      SizedBox(height: 10.0),
                      outlets.length > 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    "PlanAParty.SelectLocation",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ).tr(),
                                  SizedBox(height: 10.0),
                                  Wrap(
                                    children:
                                        List.generate(outlets.length, (index) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 10.0),
                                        child: InkWell(
                                          onTap: () {
                                            widget.onPressed(outlets[index]);
                                          },
                                          splashColor: Colors.grey,
                                          child: Row(children: <Widget>[
                                            Container(
                                                width: 60.0,
                                                height: 60.0,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade200,
                                                      offset: Offset(0, 1),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      SvgPicture.asset(
                                                          'assets/images/location.svg',
                                                          width: 24.0,
                                                          height: 24.0),
                                                      SizedBox(height: 4.0),
                                                      outlets[index][
                                                                  'distance'] !=
                                                              null
                                                          ? Text(
                                                              "${StringHelper.formatAddress(outlets[index]['distance'])} km",
                                                              style: Theme
                                                                      .of(
                                                                          context)
                                                                  .textTheme
                                                                  .subtitle2!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                              .grey[
                                                                          400]),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis)
                                                          : Container(
                                                              width: 0,
                                                              height: 0)
                                                    ])),
                                            SizedBox(width: 12.0),
                                            Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      outlets[index]['name'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    SizedBox(height: 8.0),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Icon(Icons.star,
                                                                size: 12.0,
                                                                color: Color(
                                                                    0xFFF4B920)),
                                                            SizedBox(
                                                                width: 4.0),
                                                            Text(
                                                              '${outlets[index]['reviewScore'].toStringAsFixed(1)}',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .subtitle2!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Color(
                                                                        0xFFF4B920),
                                                                  ),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(width: 8.0),
                                                        Container(
                                                            width: 120,
                                                            child: Text(
                                                                outlets[index][
                                                                    'location'],
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .subtitle2!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors.grey[
                                                                            400],
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Row(children: [
                                                      _buildPriceIndicator(
                                                          context,
                                                          outlets[index]
                                                              ['priceRange']),
                                                      Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Text(
                                                              " •  ",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .subtitle2!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                            ),
                                                            Icon(
                                                              Icons.people,
                                                              size: 12.0,
                                                            ),
                                                            Text(
                                                                " ${outlets[index]['maxPax'].toString()} pax ",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .subtitle2!
                                                                    .copyWith(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ))
                                                          ]),
                                                    ]),
                                                  ]),
                                            )
                                          ]),
                                        ),
                                      );
                                    }),
                                  ),
                                ])
                          : Container(width: 0, height: 0)
                    ]),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  String _buildAmenityList(List<dynamic> amenities) {
    String amenityStr = "";
    for (var i = 0; i < amenities.length; i++) {
      if (i != amenities.length - 1) {
        amenityStr += amenities[i]['amenity']['name'] + " • ";
      } else {
        amenityStr += amenities[i]['amenity']['name'];
      }
    }
    return amenityStr;
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
      widgets.add(
        Text(
          priceStr,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      );
    }
    if (priceStr.length < 4) {
      for (int j = 0; j < 4 - priceStr.length; j++) {
        greyPriceStr += "\$";
      }
      if (greyPriceStr != "") {
        widgets.add(
          Text(
            greyPriceStr,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
          ),
        );
      }
    }

    return Row(children: widgets);
  }
}
