import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/package-list-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/variation-list-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-product-details-page-widgets/party-product-info-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/update-error-message-widget.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:gem_consumer_app/screens/review-basket/gql/basket.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:gem_consumer_app/widgets/product-carousel.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class PlanAPartyUpdateProductDetailsPage extends StatefulWidget {
  PlanAPartyUpdateProductDetailsPage(this.selectedProduct);
  final UserCartItem selectedProduct;
  @override
  _PlanAPartyUpdateProductDetailsPageState createState() =>
      _PlanAPartyUpdateProductDetailsPageState();
}

class _PlanAPartyUpdateProductDetailsPageState
    extends State<PlanAPartyUpdateProductDetailsPage> {
  bool minimumQuantity = false;
  bool maximumQuantity = false;
  int? quantity;
  Map<String, dynamic>? product;
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
  @override
  void initState() {
    basket = context.read<AddToCartItems>();
    auth = context.read<Auth>();
    party = context.read<PlanAParty>();
    quantity = widget.selectedProduct.quantity;
    if (widget.selectedProduct.specialInstructions != null) {
      _controller.text = widget.selectedProduct.specialInstructions!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Update Product Page");
    print("111 ${widget.selectedProduct}");
    print("222 ${widget.selectedProduct.addOns}");
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

                int availableQuantity = productOutletData["availableQuantity"];

                List<String> amenitiesList = [];
                if (productOutletData["outlet"]["amenities"].length > 0) {
                  productOutletData["outlet"]["amenities"].forEach((element) {
                    amenitiesList.add(element["amenity"]["name"]);
                  });
                }

                // Seasonal Checking
                bool isSeasonal = productOutletData['isAlwaysAvailable'];
                bool isSSTEnabled = productOutletData['outlet']['isSSTEnabled'];
                return Form(
                    autovalidateMode: _autovalidate,
                    key: _formKey,
                    child: Container(
                        color: Colors.grey[200],
                        child: Column(children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              child: Stack(
                                children: <Widget>[
                                  Column(children: <Widget>[
                                    Container(
                                      color: Colors.grey[200],
                                      child: Column(
                                        children: <Widget>[
                                          ProductPhotoCarousel(
                                              widget.selectedProduct
                                                      .outletProductInformation[
                                                  "product"]["id"],
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3)
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: Colors.grey[200],
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PartyProductInfoWidget(
                                            product!,
                                            isSeasonal,
                                            isSSTEnabled,
                                          ),
                                          product!['productAddons'] != null &&
                                                  product!['productAddons']
                                                          .length >
                                                      0
                                              ? VariationListWidget([
                                                  result.data!['ProductOutlet']
                                                ], widget.selectedProduct,
                                                  checkBoxesFunction:
                                                      _setSelectedVariationMultiple,
                                                  radioFunction:
                                                      _setSelectedVariation,
                                                  isEnableSST: isSSTEnabled)
                                              : Container(
                                                  width: 0.0, height: 0.0),
                                          product!['productBundles'].length > 0
                                              ? PackageListWidget(
                                                  product!['productBundles'])
                                              : Container(
                                                  width: 0.0, height: 0.0),
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 20.0),
                                                        width:
                                                            MediaQuery.of(
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
                                                                  EdgeInsets.symmetric(
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
                                                                    if (quantity! <=
                                                                        1) {
                                                                      if (quantity !=
                                                                          0) {
                                                                        quantity =
                                                                            quantity! -
                                                                                1;
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
                                                                      quantity =
                                                                          quantity! -
                                                                              1;
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
                                                                    if ((quantity! +
                                                                            1) <=
                                                                        availableQuantity) {
                                                                      maximumQuantity =
                                                                          false;
                                                                      minimumQuantity =
                                                                          false;
                                                                      quantity =
                                                                          quantity! +
                                                                              1;
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
                                    child: quantity != 0
                                        ? Mutation(
                                            options: MutationOptions(
                                                document:
                                                    gql(BasketGQL.ADD_TO_CART),
                                                onCompleted:
                                                    (dynamic resultData) {
                                                  if (resultData != null) {
                                                    if (resultData[
                                                                "createUserCart"]
                                                            ["status"] ==
                                                        "SUCCESS") {
                                                      party.updateItem(widget
                                                          .selectedProduct);
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 16),
                                                      primary: Theme.of(context)
                                                          .primaryColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25.0))),
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      widget.selectedProduct
                                                              .specialInstructions =
                                                          _controller.text;
                                                      widget.selectedProduct
                                                          .quantity = quantity;

                                                      String collectionType =
                                                          party.collectionType!;
                                                      //If the "FOOD" and "GIFT" is not from same outlet of "ROOM" product, service type will be "DELIVERY"
                                                      if (collectionType ==
                                                              "DINE_IN" &&
                                                          party.venueProduct !=
                                                              null) {
                                                        if (party.venueProduct!
                                                                        .outletProductInformation[
                                                                    "outlet"]
                                                                ["id"] !=
                                                            widget.selectedProduct
                                                                    .outletProductInformation[
                                                                "outlet"]["id"]) {
                                                          collectionType =
                                                              "DELIVERY";
                                                        }
                                                      }

                                                      if (selectedAddOn.length >
                                                          0) {
                                                        widget.selectedProduct
                                                            .addOns
                                                            .clear();
                                                        double totalAddOnPrice =
                                                            0.00;
                                                        selectedAddOn
                                                            .forEach((element) {
                                                          totalAddOnPrice +=
                                                              double.parse(element[
                                                                      "price"]
                                                                  .toString());
                                                          AddOn tempAddon = AddOn(
                                                              addonId: element[
                                                                  "addonId"],
                                                              addOnOptionsId:
                                                                  element["id"],
                                                              addOnPriceWhenAdded:
                                                                  double.parse(element[
                                                                          "price"]
                                                                      .toString()));
                                                          widget.selectedProduct
                                                              .addOns
                                                              .add(tempAddon);
                                                        });
                                                        double priceWhenAdded =
                                                            double.parse(widget
                                                                .selectedProduct
                                                                .priceWhenAdded
                                                                .toString());
                                                        widget.selectedProduct
                                                                .finalPrice =
                                                            double.parse(
                                                                (priceWhenAdded +
                                                                        totalAddOnPrice)
                                                                    .toString());
                                                      } else {
                                                        widget.selectedProduct
                                                            .addOns
                                                            .clear();
                                                        double priceWhenAdded =
                                                            double.parse(widget
                                                                .selectedProduct
                                                                .priceWhenAdded
                                                                .toString());
                                                        widget.selectedProduct
                                                                .finalPrice =
                                                            double.parse(
                                                                (priceWhenAdded)
                                                                    .toString());
                                                      }
                                                      runMutation({
                                                        "createCartItemInput": {
                                                          "userId": auth
                                                              .currentUser.id,
                                                          "productOutletId": widget
                                                              .selectedProduct
                                                              .outletProductInformation["id"],
                                                          "quantity": widget
                                                              .selectedProduct
                                                              .quantity,
                                                          "remarks": widget
                                                              .selectedProduct
                                                              .specialInstructions,
                                                          "priceWhenAdded": widget
                                                              .selectedProduct
                                                              .priceWhenAdded,
                                                          "collectionType":
                                                              collectionType,
                                                          "addons": selectedAddOn
                                                                      .length >
                                                                  0
                                                              ? selectedAddOn
                                                              : null,
                                                          "numberOfPax":
                                                              party.pax ?? 0,
                                                          "orderName":
                                                              party.name,
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                            'RM ${StringHelper.formatCurrency(((productOutletData['product']['currentPrice'] + (selectedAddOnTotalPrice) + (productOutletData['outlet']['isSSTEnabled'] ? (productOutletData['product']['currentPrice'] + selectedAddOnTotalPrice) * 0.06 : 0)) * quantity))}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .button),
                                                        Text('Button.Update',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .button)
                                                            .tr()
                                                      ]));
                                            })
                                        : Mutation(
                                            options: MutationOptions(
                                              document: gql(
                                                  BasketGQL.DELETE_CART_ITEM),
                                              onCompleted:
                                                  (dynamic resultData) {
                                                if (resultData != null) {
                                                  if (resultData[
                                                              "deleteCartItem"]
                                                          ["status"] ==
                                                      "SUCCESS") {
                                                    print(
                                                        "SUCCESSFULLY Delete User Cart Items");
                                                    if (widget.selectedProduct
                                                                    .outletProductInformation[
                                                                "product"]
                                                            ["productType"] ==
                                                        "GIFT") {
                                                      if (party
                                                              .decorationProducts!
                                                              .length >
                                                          0) {
                                                        party.removeItem(
                                                            widget.selectedProduct
                                                                        .outletProductInformation[
                                                                    "product"]
                                                                ["id"],
                                                            widget.selectedProduct
                                                                        .outletProductInformation[
                                                                    "product"][
                                                                "productType"]);
                                                      }
                                                    }
                                                    if (widget.selectedProduct
                                                                    .outletProductInformation[
                                                                "product"]
                                                            ["productType"] ==
                                                        "FOOD") {
                                                      if (party.fbProducts!
                                                              .length >
                                                          0) {
                                                        party.removeItem(
                                                            widget.selectedProduct
                                                                        .outletProductInformation[
                                                                    "product"]
                                                                ["id"],
                                                            widget.selectedProduct
                                                                        .outletProductInformation[
                                                                    "product"][
                                                                "productType"]);
                                                        print(
                                                            "FINAL CHECK :${party.fbProducts!.length}");
                                                      }
                                                    }
                                                  } else {
                                                    print(
                                                        "FAILED DELETE CART ITEM");
                                                    print(resultData);
                                                  }
                                                } else {
                                                  print(
                                                      "RESULT DATA FROM API IS NULL");
                                                }
                                                Navigator.of(context).pop();
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 16),
                                                      primary: Theme.of(context)
                                                          .primaryColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25.0))),
                                                  onPressed: () {
                                                    runMutation({
                                                      "productOutletId": widget
                                                              .selectedProduct
                                                              .outletProductInformation[
                                                          "id"],
                                                      "userId":
                                                          auth.currentUser.id
                                                    });
                                                  },
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        Text(
                                                            'RM ${StringHelper.formatCurrency(((productOutletData['product']['currentPrice'] + (selectedAddOnTotalPrice) + (productOutletData['outlet']['isSSTEnabled'] ? (productOutletData['product']['currentPrice'] + selectedAddOnTotalPrice) * 0.06 : 0)) * quantity))}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .button),
                                                        Text('Button.Update',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .button)
                                                            .tr()
                                                      ]));
                                            },
                                          )))
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
