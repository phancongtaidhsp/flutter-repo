import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/variation-list-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-product-details-page-widgets/party-product-info-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/quantity-error-message-widget.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:gem_consumer_app/screens/review-basket/gql/basket.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:gem_consumer_app/widgets/product-carousel.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import '../../providers/add-to-cart-items.dart';
import '../../providers/auth.dart';
import '../../providers/plan-a-party.dart';
import '../../screens/celebration/widgets/variation-list-widget.dart';
import '../../screens/party/widgets/party-product-details-page-widgets/party-product-info-widget.dart';
import '../../screens/party/widgets/quantity-error-message-widget.dart';
import '../../screens/product/product.gql.dart';
import '../../screens/review-basket/gql/basket.gql.dart';
import '../../widgets/loading_controller.dart';
import '../../widgets/product-carousel.dart';

class PlanAPartyProductDetailsPage extends StatefulWidget {
  static String routeName = '/plan-a-party-product-details';
  @override
  _PlanAPartyProductDetailsPageState createState() =>
      _PlanAPartyProductDetailsPageState();
}

class _PlanAPartyProductDetailsPageState
    extends State<PlanAPartyProductDetailsPage> {
  bool minimumQuantity = false;
  bool maximumQuantity = false;
  late Map<String, dynamic> product;
  int quantity = 1;

  TextEditingController _controller = TextEditingController();

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'totalPrice': 0.00,
    'productAddons': [],
    'productAddonOptions': [],
    'collectionType': "",
    'selectedDate': "",
    'selectedTime': ""
  };
  List selectedAddOn = [];
  List multipleSelectedAddOn = [];
  List singleSelectedAddOn = [];
  double selectedAddOnTotalPrice = 0.00;
  late Auth auth;
  late AddToCartItems basket;
  late PlanAParty party;

  late UserCartItem item;

  @override
  void initState() {
    basket = context.read<AddToCartItems>();
    auth = context.read<Auth>();
    party = context.read<PlanAParty>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final args = ModalRoute.of(context)!.settings.arguments
        as PlanAPartyProductDetailsPageArguments;
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
                int availableQuantity = productOutletData["availableQuantity"];
                bool isSeasonal = !productOutletData['isAlwaysAvailable'];
                bool isSSTEnabled = productOutletData['outlet']['isSSTEnabled'];
                item = UserCartItem(
                    outletProductInformation: productOutletData, addOns: []);
                return Form(
                    autovalidateMode: _autovalidate,
                    key: _formKey,
                    child: Container(
                        color: Colors.white,
                        child: Column(children: <Widget>[
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Stack(children: <Widget>[
                            Column(children: <Widget>[
                              Container(
                                  color: Colors.grey[200],
                                  child: Column(children: <Widget>[
                                    ProductPhotoCarousel(product['id'],
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3)
                                  ])),
                              Container(
                                  color: Colors.grey[200],
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PartyProductInfoWidget(
                                          product,
                                          isSeasonal,
                                          isSSTEnabled,
                                        ),
                                        product['productAddons'] != null &&
                                                product['productAddons']
                                                        .length >
                                                    0
                                            ? VariationListWidget(
                                                [
                                                    result
                                                        .data!['ProductOutlet']
                                                  ], // In Plan A Party product, only 1
                                                item,
                                                checkBoxesFunction:
                                                    _setSelectedVariationMultiple,
                                                radioFunction:
                                                    _setSelectedVariation,
                                                isEnableSST: isSSTEnabled)
                                            : Container(
                                                width: 0.0, height: 0.0),
                                        // product['productBundles'] != null &&
                                        //         product['productBundles']
                                        //                 .length >
                                        //             0
                                        //     ? PackageListWidget(
                                        //         product['productBundles'])
                                        //     : Container(
                                        //         width: 0.0, height: 0.0),
                                        SizedBox(height: 10.0),
                                        Container(
                                            width: size.width,
                                            padding: EdgeInsets.all(25),
                                            color: Colors.white,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Product.SpecialInstructions",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .button,
                                                  ).tr(),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          top: 20.0),
                                                      width: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width,
                                                      child: TextFormField(
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .sentences,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .subtitle2!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                          controller:
                                                              _controller,
                                                          onChanged:
                                                              (value) async {},
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            filled: true,
                                                            fillColor: Colors
                                                                .grey[200],
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            15,
                                                                        horizontal:
                                                                            16),
                                                            border:
                                                                OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            23.0),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                    )),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            23.0),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                    )),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            23.0),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                    )),
                                                            hintText:
                                                                "Special Instructions",
                                                            hintStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1!
                                                                .copyWith(
                                                                    fontSize:
                                                                        14),
                                                            floatingLabelBehavior:
                                                                FloatingLabelBehavior
                                                                    .never,
                                                          ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .text)),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
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
                                                                  .orange[300],
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
                                  child: Mutation(
                                      options: MutationOptions(
                                          document: gql(BasketGQL.ADD_TO_CART),
                                          onCompleted: (dynamic resultData) {
                                            if (resultData["createUserCart"]
                                                    ["status"] ==
                                                "SUCCESS") {
                                              if (item.outletProductInformation[
                                                          "product"]
                                                      ["productType"] ==
                                                  "FOOD") {
                                                party.addFBProduct(item);
                                                print(
                                                    "FOOD ADDED INTO PROVIDER ");
                                              }
                                              if (item.outletProductInformation[
                                                          "product"]
                                                      ["productType"] ==
                                                  "GIFT") {
                                                party
                                                    .addDecorationProduct(item);
                                                print(
                                                    "GIFT ADDED INTO PROVIDER ");
                                              }
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
                                                primary: Theme.of(context)
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0))),
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  result!.isNotLoading) {
                                                String? collectionType =
                                                    party.collectionType;
                                                String deliveryAddress = "";
                                                double latitude = 0;
                                                double longitude = 0;
                                                if (collectionType ==
                                                    "DELIVERY") {
                                                  deliveryAddress =
                                                      "${party.deliveryAddress!.address1}, ${party.deliveryAddress!.city}, ${party.deliveryAddress!.postalCode}, ${party.deliveryAddress!.state}";
                                                  latitude = party
                                                      .deliveryAddress!
                                                      .latitude;
                                                  longitude = party
                                                      .deliveryAddress!
                                                      .longitude;
                                                }
                                                //If the "FOOD" and "GIFT" is not from same outlet of "ROOM" product, service type will be "DELIVERY"
                                                if (collectionType ==
                                                        "DINE_IN" &&
                                                    party.venueProduct !=
                                                        null) {
                                                  if (party.venueProduct!
                                                              .outletProductInformation[
                                                          "outlet"]["id"] !=
                                                      item.outletProductInformation[
                                                          "outlet"]["id"]) {
                                                    collectionType = "DELIVERY";
                                                    deliveryAddress =
                                                        "${party.venueProduct!.outletProductInformation["outlet"]["address1"]}, ${party.venueProduct!.outletProductInformation["outlet"]["city"]}, ${party.venueProduct!.outletProductInformation["outlet"]["postalCode"]}, ${party.venueProduct!.outletProductInformation["outlet"]["state"]}";
                                                    latitude = party
                                                            .venueProduct!
                                                            .outletProductInformation[
                                                        "outlet"]["latitude"];
                                                    longitude = party
                                                            .venueProduct!
                                                            .outletProductInformation[
                                                        "outlet"]["longitude"];
                                                  }
                                                }
                                                var combineDateTime =
                                                    new DateTime(
                                                  party.date!.year,
                                                  party.date!.month,
                                                  party.date!.day,
                                                  party.timeOfDay!.hour,
                                                  party.timeOfDay!.minute,
                                                );

                                                item.quantity = quantity;
                                                item.specialInstructions =
                                                    _controller.text;
                                                item.priceWhenAdded =
                                                    double.parse(
                                                        product['currentPrice']
                                                            .toString());
                                                item.finalPrice = double.parse(
                                                        product['currentPrice']
                                                            .toString()) +
                                                    selectedAddOnTotalPrice;
                                                item.isOutletSSTEnabled =
                                                    productOutletData['outlet']
                                                        ['isSSTEnabled'];
                                                if (selectedAddOn.length > 0) {
                                                  selectedAddOn
                                                      .forEach((element) {
                                                    // selectedAddOnTotalPrice +=
                                                    //     double.parse(
                                                    //         element["price"]
                                                    //             .toString());
                                                    AddOn tempAddon = AddOn(
                                                        addonId:
                                                            element["addonId"],
                                                        addOnOptionsId:
                                                            element["id"],
                                                        addOnPriceWhenAdded:
                                                            double.parse(element[
                                                                    "price"]
                                                                .toString()));
                                                    item.addOns.add(tempAddon);
                                                  });
                                                }

                                                try {
                                                  runMutation({
                                                    "createCartItemInput": {
                                                      "userId":
                                                          auth.currentUser.id,
                                                      "productOutletId":
                                                          item.outletProductInformation[
                                                              "id"],
                                                      "quantity": item.quantity,
                                                      "remarks": item
                                                          .specialInstructions,
                                                      "priceWhenAdded":
                                                          item.priceWhenAdded,
                                                      "collectionType":
                                                          collectionType,
                                                      "serviceDateTime": (party
                                                                  .demands!
                                                                  .contains(
                                                                      "VENUE") &&
                                                              collectionType ==
                                                                  "DELIVERY")
                                                          ? combineDateTime
                                                              .subtract(
                                                                  Duration(
                                                                      hours: 1))
                                                              .toUtc()
                                                              .toIso8601String()
                                                          : combineDateTime
                                                              .toUtc()
                                                              .toIso8601String(),
                                                      "isDeliveredToVenue": (party
                                                                  .demands!
                                                                  .contains(
                                                                      "VENUE") &&
                                                              collectionType ==
                                                                  "DELIVERY")
                                                          ? true
                                                          : false,
                                                      "currentDeliveryAddress":
                                                          collectionType ==
                                                                  "DELIVERY"
                                                              ? deliveryAddress
                                                              : null,
                                                      "latitude":
                                                          collectionType ==
                                                                  "DELIVERY"
                                                              ? latitude
                                                              : null,
                                                      "longitude":
                                                          collectionType ==
                                                                  "DELIVERY"
                                                              ? longitude
                                                              : null,
                                                      "addons":
                                                          selectedAddOn.length >
                                                                  0
                                                              ? selectedAddOn
                                                              : null,
                                                      "numberOfPax":
                                                          party.pax ?? 0,
                                                      "orderName": party.name
                                                    }
                                                  });
                                                } catch (e) {
                                                  print(e.toString());
                                                }
                                                print("Clicked");
                                              }
                                            },
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(
                                                      'RM ${StringHelper.formatCurrency(((productOutletData['product']['currentPrice'] + (selectedAddOnTotalPrice) + (productOutletData['outlet']['isSSTEnabled'] ? (productOutletData['product']['currentPrice'] + selectedAddOnTotalPrice) * 0.06 : 0)) * quantity))}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .button),
                                                  Text('Button.AddToBasket',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .button)
                                                      .tr()
                                                ]));
                                      })),
                            )
                          ]),
                        ])));
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

  void _setSelectedVariation(String selectedVariation, String productId,
      String addonId, dynamic price) {
    if (selectedVariation != null) {
      if (_formData['productAddons'].length > 0) {
        int index = _formData['productAddons']
            .indexWhere((data) => (data['addonId'] == addonId));
        if (index >= 0) {
          _formData['productAddons'].elementAt(index)['id'] = selectedVariation;
          _formData['productAddons'].elementAt(index)['price'] =
              double.parse(price.toString());
          _formData['productAddons'].elementAt(index)['addonId'] = addonId;
        } else {
          _formData['productAddons'].add({
            'id': selectedVariation,
            'price': double.parse(price.toString()),
            'addonId': addonId
          });
        }
      } else {
        _formData['productAddons'].add({
          'id': selectedVariation,
          'price': double.parse(price.toString()),
          'addonId': addonId
        });
      }
      singleSelectedAddOn = _formData['productAddons'];
    } else {
      singleSelectedAddOn
          .removeWhere((element) => element['addonId'] == addonId);
    }

    setState(() {
      selectedAddOnTotalPrice = 0.00;
      selectedAddOn.clear();
      selectedAddOn = singleSelectedAddOn + multipleSelectedAddOn;
      selectedAddOn.forEach((element) {
        selectedAddOnTotalPrice += double.parse(element["price"].toString());
      });
    });
  }

  void _setSelectedVariationMultiple(
      List selectedOptions,
      List selectedOptionList,
      String productId,
      String addonId,
      bool isMultiple) {
    _formData['productAddonOptions'] = selectedOptionList;

    setState(() {
      selectedAddOnTotalPrice = 0.00;

      multipleSelectedAddOn
          .removeWhere((element) => element['addonId'] == addonId);
      multipleSelectedAddOn.addAll(selectedOptionList);

      selectedAddOn = singleSelectedAddOn + multipleSelectedAddOn;

      selectedAddOn.forEach((element) {
        selectedAddOnTotalPrice += double.parse(element["price"].toString());
      });
      print("addon: $selectedAddOn");
      print("addon: ${selectedAddOn.length}");
    });
  }
}

class PlanAPartyProductDetailsPageArguments {
  final String productOutletId;

  PlanAPartyProductDetailsPageArguments(this.productOutletId);
}
