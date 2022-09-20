import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-room-details-page-widgets/party-room-amenities-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-room-details-page-widgets/party-room-booking-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-room-details-page-widgets/party-room-info-widget.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/product-carousel.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../widgets/loading_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductRoomDetail extends StatelessWidget {
  const ProductRoomDetail({
    Key? key,
    required this.productOutletId,
  }) : super(key: key);

  final String productOutletId;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
          body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Query(
              options: QueryOptions(
                  document: gql(ProductGQL.GET_PRODUCT_OUTLET_BY_ID),
                  variables: {'id': productOutletId},
                  fetchPolicy: FetchPolicy.networkOnly),
              builder: (QueryResult result,
                  {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.isLoading) {
                  return LoadingController();
                }
                if (result.data != null &&
                    result.data!['ProductOutlet'] != null) {
                  var productOutletData = result.data!['ProductOutlet'];

                  List<String> amenitiesList = [];
                  if (productOutletData['product']["productAmenities"].length >
                      0) {
                    productOutletData['product']["productAmenities"]
                        .forEach((element) {
                      amenitiesList.add(element["amenity"]["name"]);
                    });
                  }
                  bool isSeasonal = !productOutletData['isAlwaysAvailable'];
                  bool isSSTEnabled =
                      productOutletData['outlet']['isSSTEnabled'];
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Stack(
                            children: <Widget>[
                              Column(children: <Widget>[
                                Container(
                                    color: Colors.grey[200],
                                    child: Column(children: <Widget>[
                                      ProductPhotoCarousel(
                                          productOutletData['product']["id"],
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3)
                                    ])),
                                Container(
                                  color: Colors.grey[200],
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PartyRoomInfoWidget(
                                        productOutletData['product'],
                                        isSeasonal,
                                        isSSTEnabled,
                                      ),
                                      PartyRoomBookingWidget(
                                          productOutletData['product'],
                                          isSSTEnabled),
                                      amenitiesList.length > 0
                                          ? PartyRoomAmenitiesWidget(
                                              amenitiesList)
                                          : Container(
                                              height: 0,
                                              width: 0,
                                            ),
                                      SizedBox(height: 10.0),
                                    ],
                                  ),
                                ),
                              ]),
                              Positioned(
                                top: size.height * 0.0246,
                                left: size.width * 0.85,
                                child: Container(
                                  height: 36.0,
                                  width: 36.0,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                    ),
                                    iconSize: 18.0,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            height: 36.0,
                            width: 56.0,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 250, 249, 249),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1)),
                                ]),
                            child: IconButton(
                                icon: SvgPicture.asset(
                                    'assets/images/icon-back.svg'),
                                iconSize: 36.0,
                                onPressed: () {
                                  Navigator.pop(context);
                                })),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 50),
                              Text(
                                "General.LoadingError",
                                style: Theme.of(context).textTheme.button,
                              ).tr()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      )),
    );
  }
}
