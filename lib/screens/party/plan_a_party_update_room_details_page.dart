import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/pop-up-error-message-widget.dart';
import '../../models/UserCartItem.dart';
import '../../providers/add-to-cart-items.dart';
import '../../providers/auth.dart';
import '../../providers/plan-a-party.dart';
import '../../screens/party/plan_a_party_landing_page.dart';
import '../../screens/party/widgets/party-room-details-page-widgets/party-room-amenities-widget.dart';
import '../../screens/party/widgets/party-room-details-page-widgets/party-room-booking-widget.dart';
import '../../screens/party/widgets/party-room-details-page-widgets/party-room-info-widget.dart';
import '../../screens/party/widgets/party-room-details-page-widgets/party-room-special-instructions-widget.dart';
import '../../screens/party/widgets/quantity-error-message-widget.dart';
import '../../screens/party/widgets/update-error-message-widget.dart';
import '../../screens/product/product.gql.dart';
import '../../screens/review-basket/gql/basket.gql.dart';
import '../../widgets/loading_controller.dart';
import '../../widgets/product-carousel.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'edit-party/widgets/dialog-widget.dart';

class PlanAPartyUpdateRoomDetailsPage extends StatefulWidget {
  final UserCartItem selectedProduct;

  PlanAPartyUpdateRoomDetailsPage(this.selectedProduct);

  @override
  _PlanAPartyUpdateRoomDetailsPageState createState() =>
      _PlanAPartyUpdateRoomDetailsPageState();
}

class _PlanAPartyUpdateRoomDetailsPageState
    extends State<PlanAPartyUpdateRoomDetailsPage> {
  bool minimumQuantity = false;
  bool maximumQuantity = false;
  late int quantity;
  Map<String, dynamic>? product;
  TextEditingController _controller = TextEditingController();
  late Auth auth;
  late AddToCartItems basket;
  late PlanAParty party;

  @override
  void initState() {
    basket = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    auth = context.read<Auth>();
    quantity = widget.selectedProduct.quantity!;
    if (widget.selectedProduct.specialInstructions != null) {
      _controller.text = widget.selectedProduct.specialInstructions!;
    }

    super.initState();
  }

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
        child: Query(
            options: QueryOptions(
                variables: {
                  'id': widget.selectedProduct.outletProductInformation["id"]
                },
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

                // Seasonal Checking
                bool isSeasonal = !productOutletData['isAlwaysAvailable'];
                bool isSSTEnabled = productOutletData['outlet']['isSSTEnabled'];

                return Container(
                    color: Colors.grey[200],
                    child: Column(children: <Widget>[
                      Expanded(
                          child: SingleChildScrollView(
                              child: Stack(children: <Widget>[
                        Column(children: <Widget>[
                          Container(
                              color: Colors.grey[200],
                              child: Column(children: <Widget>[
                                ProductPhotoCarousel(
                                    widget.selectedProduct
                                            .outletProductInformation["product"]
                                        ["id"]!,
                                    height: MediaQuery.of(context).size.height *
                                        0.3)
                              ])),
                          Container(
                              color: Colors.grey[200],
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PartyRoomInfoWidget(
                                        product!, isSeasonal, isSSTEnabled),
                                    PartyRoomBookingWidget(
                                        product!, isSSTEnabled),
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
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 36.0,
                                                      width: 36.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.3),
                                                                spreadRadius: 1,
                                                                blurRadius: 1,
                                                                offset: Offset(
                                                                    0, 1)),
                                                          ]),
                                                      child: IconButton(
                                                          icon: SvgPicture.asset(
                                                              'assets/images/minus.svg'),
                                                          iconSize: 36.0,
                                                          onPressed: () {
                                                            setState(() {
                                                              if (quantity <=
                                                                  1) {
                                                                if (quantity !=
                                                                    0) {
                                                                  quantity--;
                                                                  if (quantity ==
                                                                      0) {
                                                                    minimumQuantity =
                                                                        true;
                                                                    maximumQuantity =
                                                                        false;
                                                                  }
                                                                }
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
                                                      width: size.width * 0.266,
                                                      child: Center(
                                                          child: Text(
                                                        "$quantity",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      )),
                                                    ),
                                                    Container(
                                                      height: 36.0,
                                                      width: 36.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .orange[300],
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.3),
                                                                spreadRadius: 2,
                                                                blurRadius: 2,
                                                                offset: Offset(
                                                                    0, 1)),
                                                          ]),
                                                      child: IconButton(
                                                          icon: SvgPicture.asset(
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
                                              UpdateErrorMessageWidget(
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
                      ]))),
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
                              child: quantity != 0
                                  ? Mutation(
                                      options: MutationOptions(
                                          document: gql(BasketGQL.ADD_TO_CART),
                                          onCompleted: (dynamic resultData) {
                                            if (resultData != null) {
                                              if (resultData["createUserCart"]
                                                      ["status"] ==
                                                  "SUCCESS") {
                                                party.setVenueProduct(
                                                    widget.selectedProduct);
                                                Navigator.pop(context);
                                              } else {
                                                print(
                                                    "FAILED UPDATE CART ITEM");
                                                print(resultData);
                                              }
                                            } else {
                                              print(
                                                  "RESULT DATA FROM API IS NULL");
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
                                                primary: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0))),
                                            onPressed: () {
                                              print("Clicked");
                                              //CHECK: READ FROM DATABASE AND FORM USERCARTITEM
                                              var combineDateTime =
                                                  new DateTime(
                                                party.date!.year,
                                                party.date!.month,
                                                party.date!.day,
                                                party.timeOfDay!.hour,
                                                party.timeOfDay!.minute,
                                              );
                                              print(combineDateTime);
                                              widget.selectedProduct
                                                      .specialInstructions =
                                                  _controller.text;
                                              widget.selectedProduct.quantity =
                                                  quantity;
                                              String collectionType =
                                                  party.collectionType!;

                                              runMutation({
                                                "createCartItemInput": {
                                                  "userId": auth.currentUser.id,
                                                  "productOutletId": widget
                                                          .selectedProduct
                                                          .outletProductInformation[
                                                      "id"],
                                                  "quantity": widget
                                                      .selectedProduct.quantity,
                                                  "remarks": widget
                                                      .selectedProduct
                                                      .specialInstructions,
                                                  "priceWhenAdded": widget
                                                      .selectedProduct
                                                      .priceWhenAdded,
                                                  "collectionType":
                                                      collectionType,
                                                  "serviceDateTime":
                                                      combineDateTime
                                                          .toUtc()
                                                          .toIso8601String(),
                                                  "isDeliveredToVenue": false,
                                                  "numberOfPax": party.pax,
                                                  "orderName": party.name
                                                }
                                              });
                                            },
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(
                                                      'RM ${StringHelper.formatCurrency((quantity * (product!["currentPrice"] + (isSSTEnabled ? product!["currentPrice"] * 0.06 : 0))))}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .button),
                                                  Text('Button.Update',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .button)
                                                      .tr()
                                                ]));
                                      })
                                  : Mutation(
                                      options: MutationOptions(
                                        document:
                                            gql(BasketGQL.CLEAR_USER_CART_ITEM),
                                        onCompleted: (dynamic resultData) {
                                          if (resultData["clearUserCartItem"]
                                                      ["status"] ==
                                                  "SUCCESS" ||
                                              resultData["clearUserCartItem"]
                                                      ["status"] ==
                                                  "NOT_EXISTS_IN_DATABASE") {
                                            party.clearPartyItems();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            Navigator.popUntil(
                                                context,
                                                ModalRoute.withName(
                                                    PlanAPartyLandingPage
                                                        .routeName));
                                          } else {
                                            Navigator.pop(context);
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => Dialog(
                                                child:
                                                    PopUpErrorMessageWidget(),
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    EdgeInsets.all(24),
                                              ),
                                            );
                                          }
                                        },
                                        onError: (dynamic resultData) {
                                          print("FAIL");
                                          print(resultData);
                                        },
                                      ),
                                      builder: (
                                        RunMutation runMutation,
                                        QueryResult? result,
                                      ) {
                                        return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16),
                                                primary: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0))),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      insetPadding:
                                                          EdgeInsets.all(10),
                                                      child: DialogWidget(
                                                          title:
                                                              "EditAParty.RemoveVenueTitle",
                                                          content:
                                                              "EditAParty.RemoveVenueProduct",
                                                          continueButtonText:
                                                              "Button.Yes",
                                                          continueFunction: () {
                                                            runMutation({
                                                              "userId": auth
                                                                  .currentUser
                                                                  .id
                                                            });
                                                          },
                                                          cancelButtonText:
                                                              "Button.No",
                                                          cancelFunction: () {
                                                            Navigator.pop(
                                                                context);
                                                          })));
                                            },
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(
                                                      'RM ${StringHelper.formatCurrency((quantity * product!["currentPrice"]))}', //'RM ${cart.totalPrice.toStringAsFixed(2)}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .button),
                                                  Text('Button.Update',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .button)
                                                      .tr()
                                                ]));
                                      },
                                    )),
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
