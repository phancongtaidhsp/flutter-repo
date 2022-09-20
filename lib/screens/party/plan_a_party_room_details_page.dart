import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-room-details-page-widgets/party-room-amenities-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-room-details-page-widgets/party-room-booking-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-room-details-page-widgets/party-room-info-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-room-details-page-widgets/party-room-special-instructions-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/quantity-error-message-widget.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:gem_consumer_app/screens/review-basket/gql/basket.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:gem_consumer_app/widgets/product-carousel.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';

class PlanAPartyRoomDetailsPage extends StatefulWidget {
  static String routeName = '/plan-a-party-place-details';

  @override
  _PlanAPartyRoomDetailsPageState createState() =>
      _PlanAPartyRoomDetailsPageState();
}

class _PlanAPartyRoomDetailsPageState extends State<PlanAPartyRoomDetailsPage> {
  bool minimumQuantity = false;
  bool maximumQuantity = false;
  late Map<String, dynamic> product;
  int quantity = 1;
  var queryBuilderRunningCounter = 0;
  TextEditingController _controller = TextEditingController();
  Auth? auth;
  AddToCartItems? basket;
  PlanAParty? party;

  @override
  void initState() {
    basket = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final args = ModalRoute.of(context)!.settings.arguments
        as PlanAPartyRoomDetailsPageArguments;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
          body: SafeArea(
        child: Query(
            options: QueryOptions(
                variables: {'id': args.productOutletId},
                document: gql(ProductGQL.GET_PRODUCT_OUTLET_BY_ID),
                fetchPolicy: FetchPolicy.cacheAndNetwork),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return LoadingController();
              }

              if (result.data != null &&
                  result.data!['ProductOutlet'] != null) {
                Map<String, dynamic> productOutletData =
                    result.data!['ProductOutlet'];
                product = result.data!['ProductOutlet']['product'];

                int availableQuantity = productOutletData["numberOfRoom"];

                List<String> amenitiesList = [];
                if (productOutletData["product"]["productAmenities"].length >
                    0) {
                  productOutletData["product"]["productAmenities"]
                      .forEach((element) {
                    amenitiesList.add(element["amenity"]["name"]);
                  });
                }
                bool isSeasonal = !productOutletData['isAlwaysAvailable'];
                bool isSSTEnabled = productOutletData['outlet']['isSSTEnabled'];
                queryBuilderRunningCounter++;
                UserCartItem item = UserCartItem(
                    outletProductInformation: productOutletData, addOns: []);
                return Container(
                    color: Colors.white,
                    child: Column(children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Stack(
                            children: <Widget>[
                              Column(children: <Widget>[
                                Container(
                                    color: Colors.grey[200],
                                    child: Column(children: <Widget>[
                                      ProductPhotoCarousel(product["id"],
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
                                            product,
                                            isSeasonal,
                                            isSSTEnabled,
                                          ),
                                          PartyRoomBookingWidget(
                                              product, isSSTEnabled),
                                          amenitiesList.length > 0
                                              ? PartyRoomAmenitiesWidget(
                                                  amenitiesList)
                                              : Container(
                                                  height: 0,
                                                  width: 0,
                                                ),
                                          SizedBox(height: 10.0),
                                          Container(
                                              width: size.width,
                                              padding: EdgeInsets.all(25),
                                              color: Colors.white,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    PartyRoomSpecialInstructionsWidget(
                                                        _controller),
                                                    Container(
                                                      width: size.width,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            height: 36.0,
                                                            width: 36.0,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          1,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              1)),
                                                                ]),
                                                            child: IconButton(
                                                                icon: SvgPicture
                                                                    .asset(
                                                                        'assets/images/minus.svg'),
                                                                iconSize: 36.0,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    if (quantity ==
                                                                        1) {
                                                                      minimumQuantity =
                                                                          true;
                                                                      maximumQuantity =
                                                                          false;
                                                                    } else {
                                                                      minimumQuantity =
                                                                          false;
                                                                      maximumQuantity =
                                                                          false;
                                                                      quantity--;
                                                                    }
                                                                  });
                                                                }),
                                                          ),
                                                          Container(
                                                            width: size.width *
                                                                0.266,
                                                            child: Center(
                                                                child: Text(
                                                              "$quantity",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline2,
                                                            )),
                                                          ),
                                                          Container(
                                                            height: 36.0,
                                                            width: 36.0,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                        .orange[
                                                                    300],
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3),
                                                                      spreadRadius:
                                                                          2,
                                                                      blurRadius:
                                                                          2,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              1)),
                                                                ]),
                                                            child: IconButton(
                                                                icon: SvgPicture
                                                                    .asset(
                                                                        'assets/images/plus.svg'),
                                                                iconSize: 36.0,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    if ((quantity +
                                                                            1) <=
                                                                        availableQuantity) {
                                                                      maximumQuantity =
                                                                          false;
                                                                      minimumQuantity =
                                                                          false;
                                                                      quantity++;
                                                                    } else {
                                                                      maximumQuantity =
                                                                          true;
                                                                      minimumQuantity =
                                                                          false;
                                                                    }
                                                                  });
                                                                }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    QuantityErrorMessageWidget(
                                                        maximumQuantity,
                                                        minimumQuantity,
                                                        availableQuantity)
                                                  ])),
                                        ]))
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
                                          }))),
                            ],
                          ),
                        ),
                      ),
                      Row(children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, -2.0), //(x,y)
                                      blurRadius: 4.0,
                                    )
                                  ]),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.0, vertical: 16.0),
                              child: Mutation(
                                  options: MutationOptions(
                                      document: gql(BasketGQL.ADD_TO_CART),
                                      onCompleted: (dynamic resultData) {
                                        print(resultData);
                                        if (resultData["createUserCart"]
                                                ["status"] ==
                                            "SUCCESS") {
                                          party!.setVenueProduct(item);
                                          Navigator.pop(context);
                                        } else {
                                          print("FAILED ADD TO CART");
                                          print(resultData);
                                        }
                                      },
                                      onError: (dynamic error) {
                                        print(error);
                                      }),
                                  builder: (
                                    RunMutation runMutation,
                                    QueryResult? result,
                                  ) {
                                    return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            primary:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.0))),
                                        onPressed: () {
                                          if (result!.isNotLoading) {
                                            var combineDateTime = new DateTime(
                                              party!.date!.year,
                                              party!.date!.month,
                                              party!.date!.day,
                                              party!.timeOfDay!.hour,
                                              party!.timeOfDay!.minute,
                                            );
                                            item.quantity = quantity;
                                            item.specialInstructions =
                                                _controller.text;
                                            item.priceWhenAdded = double.parse(
                                                product['currentPrice']
                                                    .toString());
                                            item.finalPrice = double.parse(
                                                product['currentPrice']
                                                    .toString());
                                            item.isOutletSSTEnabled =
                                                productOutletData['outlet']
                                                    ['isSSTEnabled'];

                                            try {
                                              runMutation({
                                                "createCartItemInput": {
                                                  "userId":
                                                      auth!.currentUser.id,
                                                  "productOutletId":
                                                      item.outletProductInformation[
                                                          "id"],
                                                  "quantity": item.quantity,
                                                  "remarks":
                                                      item.specialInstructions,
                                                  "priceWhenAdded":
                                                      double.parse(product[
                                                              'currentPrice']
                                                          .toString()),
                                                  "collectionType":
                                                      party!.collectionType,
                                                  "serviceDateTime":
                                                      combineDateTime
                                                          .toUtc()
                                                          .toIso8601String(),
                                                  "isDeliveredToVenue": false,
                                                  "numberOfPax": party!.pax,
                                                  "orderName": party!.name
                                                }
                                              });
                                            } catch (e) {
                                              print(e.toString());
                                              print(
                                                  'EXCEPTION IN runMutation line 436 ');
                                            }

                                            print("Clicked");
                                          }
                                        },
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                  'RM ${StringHelper.formatCurrency((quantity * (product["currentPrice"] + (isSSTEnabled ? product["currentPrice"] * 0.06 : 0))))}',
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .button),
                                              Text('Button.AddToBasket',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .button)
                                                  .tr()
                                            ]));
                                  })),
                        )
                      ]),
                    ]));
              } else {
                return SafeArea(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 55.0),
                                    child: Column(children: [
                                      Text("Product.ProductNotFound",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2)
                                          .tr(),
                                      SizedBox(height: 20.0),
                                    ]))),
                            Row(children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 16.0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            primary:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.0))),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('General.Back',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .button)
                                            .tr())),
                              )
                            ])
                          ],
                        )));
              }
            }),
      )),
    );
  }
}

class PlanAPartyRoomDetailsPageArguments {
  final String productId;
  final String productOutletId;

  PlanAPartyRoomDetailsPageArguments(this.productId, this.productOutletId);
}
