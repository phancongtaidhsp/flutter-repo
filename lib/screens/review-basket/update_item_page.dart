import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/amenities-list-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/celebration-app-bar.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/celebration-details-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/package-list-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/variation-list-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/view_merchant_outlet_page.dart';
import 'package:gem_consumer_app/screens/party/widgets/quantity-error-message-widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import '../../screens/review-basket/review_basket_page.dart';
import '../../widgets/loading_controller.dart';
import '../../widgets/product-carousel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'gql/basket.gql.dart';
import 'package:gem_consumer_app/helpers/geo-helper.dart';

class UpdateItemPage extends StatefulWidget {
  const UpdateItemPage({Key? key}) : super(key: key);
  static String routeName = '/update-item';

  @override
  _UpdateItemPageState createState() => _UpdateItemPageState();
}

class _UpdateItemPageState extends State<UpdateItemPage> {
  late UpdateItemPageArguments args;

  double merchantSST = 0.0;

  TextEditingController _specialInstructionsTextcontroller =
      TextEditingController();
  int quantity = 1;
  bool minimumQuantity = false;
  bool maximumQuantity = false;
  static late Auth auth;
  AddToCartItems? userCart;
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

  Position? position;
  UserAddress? currentUserLocation;
  UserAddress? deliveryLocation;
  List selectedAddOn = [];
  List multipleSelectedAddOn = [];
  List singleSelectedAddOn = [];
  double selectedAddOnTotalPrice = 0.00;

  bool isFetchCartDataTheFirstTime = true;

  @override
  void initState() {
    userCart = context.read<AddToCartItems>();
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    args =
        ModalRoute.of(context)!.settings.arguments as UpdateItemPageArguments;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
          body: SafeArea(
        child: Query(
            options: QueryOptions(
                variables: {'id': args.userCartItemId},
                document: gql(BasketGQL.GET_USER_CART_ITEM_BY_ID),
                fetchPolicy: FetchPolicy.networkOnly),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return LoadingController();
              }
              if (result.data != null &&
                  result.data!['GetCartItemsById'] != null) {
                final productOutletData =
                    result.data!['GetCartItemsById']['productOutlet'];
                // Seasonal Checking
                bool isSeasonal = !productOutletData['isAlwaysAvailable'];

                if (isFetchCartDataTheFirstTime) {
                  dataMassaging(result.data!['GetCartItemsById']);

                  _specialInstructionsTextcontroller.text =
                      userCart!.celebrationItem!.specialInstructions!;
                  quantity = userCart!.celebrationItem!.quantity!;

                  isFetchCartDataTheFirstTime = false;
                }

                return Form(
                    autovalidateMode: _autovalidate,
                    key: _formKey,
                    child: Container(
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
                                        productOutletData['product']['id'],
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
                                        CelebrationDetailsWidget(
                                            productOutletData, isSeasonal),
                                        SizedBox(height: 10.0),
                                        productOutletData['product']
                                                        ['productBundles'] !=
                                                    null &&
                                                productOutletData['product']
                                                            ['productBundles']
                                                        .length >
                                                    0
                                            ? VariationListWidget(
                                                productOutletData['product']
                                                    ['productBundles'],
                                                userCart!.celebrationItem!,
                                                checkBoxesFunction:
                                                    _setSelectedVariationMultiple,
                                                radioFunction:
                                                    _setSelectedVariation,
                                                // selectedItem:
                                                //     userCart!.celebrationItem !=
                                                //             null
                                                //         ? userCart!
                                                //             .celebrationItem!
                                                //             .addOns
                                                //         : null,
                                                isEnableSST:
                                                    productOutletData['outlet']
                                                        ['isSSTEnabled'],
                                              )
                                            : Container(
                                                width: 0.0, height: 0.0),
                                        productOutletData['product']
                                                        ['productBundles'] !=
                                                    null &&
                                                productOutletData['product']
                                                            ['productBundles']
                                                        .length >
                                                    0
                                            ? PackageListWidget(
                                                productOutletData['product']
                                                    ['productBundles'])
                                            : Container(
                                                width: 0.0, height: 0.0),
                                        productOutletData['outlet'] != null &&
                                                productOutletData['outlet']
                                                        ['amenities'] !=
                                                    null &&
                                                productOutletData['outlet']
                                                            ['amenities']
                                                        .length >
                                                    0
                                            ? AmenitiesListWidget(
                                                productOutletData['outlet']
                                                    ['amenities'])
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
                                                              _specialInstructionsTextcontroller,
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
                                                                  .asset(quantity ==
                                                                          0
                                                                      ? 'assets/images/bin.svg'
                                                                      : 'assets/images/minus.svg'),
                                                              iconSize: 36.0,
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (quantity ==
                                                                      0) {
                                                                    //minimumQuantity = true;
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
                                                                      productOutletData[
                                                                          "availableQuantity"]) {
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
                                                      productOutletData[
                                                          "availableQuantity"])
                                                ]))
                                      ]))
                            ]),
                            Positioned(
                                top: MediaQuery.of(context).size.height * 0.265,
                                right: 20,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      primary: Colors.white),
                                  onPressed: () {
                                    Navigator.pushNamed(context,
                                        ViewMerchantOutletPage.routeName,
                                        arguments:
                                            ViewMerchantOutletPageArguments(
                                                productOutletData['outlet']
                                                    ['id']));
                                  },
                                  child: SvgPicture.asset(
                                      'assets/images/icon-info.svg',
                                      width: 10,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.055),
                                )),
                            Positioned(top: 20.0, child: CelebrationAppBar()),
                          ]))),
                          Mutation(
                              options: MutationOptions(
                                document: gql(quantity == 0
                                    ? BasketGQL.DELETE_CART_ITEM
                                    : BasketGQL.UPDATE_CART_ITEM),
                                onCompleted: (dynamic resultData) {
                                  print("UPDATE RESULT $resultData");
                                  if (resultData != null) {
                                    if (quantity == 0) {
                                      if (resultData["deleteCartItem"]
                                              ["status"] ==
                                          "SUCCESS") {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            ReviewBasketPage.routeName,
                                            ModalRoute.withName(
                                                '/celebration-home'));
                                        //userCart!.clearCartItems();
                                      }
                                    } else {
                                      if (resultData["updateUserCartItems"]
                                              ["status"] ==
                                          "SUCCESS") {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            ReviewBasketPage.routeName,
                                            ModalRoute.withName(
                                                '/celebration-home'));
                                      }
                                    }
                                  }
                                },
                              ),
                              builder: (
                                RunMutation runMutation,
                                QueryResult? result,
                              ) {
                                return Row(children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset: Offset(0.0, -2.0),
                                                //(x,y)
                                                blurRadius: 4.0,
                                              )
                                            ]),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25.0, vertical: 16.0),
                                        child: ElevatedButton(
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
                                              if (quantity == 0) {
                                                runMutation({
                                                  "productOutletId": userCart!
                                                          .celebrationItem!
                                                          .outletProductInformation[
                                                      "id"],
                                                  "userId": auth.currentUser.id
                                                });
                                              } else {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  runMutation({
                                                    "UpdateCartItemInput": {
                                                      "id": userCart!
                                                          .celebrationItem!.id,
                                                      "quantity": quantity,
                                                      "remarks":
                                                          _specialInstructionsTextcontroller
                                                              .text,
                                                      "addons":
                                                          selectedAddOn.length >
                                                                  0
                                                              ? selectedAddOn
                                                              : null,
                                                    }
                                                  });
                                                }
                                              }
                                            },
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  // Consumer<AddToCartTotal>(
                                                  //     builder: (context, cart,
                                                  //         child) {
                                                  //   return Text(
                                                  //       'RM ${StringHelper.formatCurrency(((productOutletData['product']['currentPrice'] + (selectedAddOnTotalPrice) + (productOutletData['outlet']['isSSTEnabled'] ? (productOutletData['product']['currentPrice'] + selectedAddOnTotalPrice) * 0.06 : 0)) * quantity))}',
                                                  //       textAlign:
                                                  //           TextAlign.center,
                                                  //       style: Theme.of(context)
                                                  //           .textTheme
                                                  //           .button);
                                                  // }),
                                                  Text(
                                                          quantity == 0
                                                              ? 'Button.Remove'
                                                              : 'Button.Update',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .button)
                                                      .tr()
                                                ]))),
                                  )
                                ]);
                                // AddToCartWidget(
                                //   validateInputs: () {
                                //     _showConfirmationDialog(runMutation);
                                //   },
                                // );
                              }),
                        ])));
              }
              return SafeArea(
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 75.0),
                          child: Text("Product.ProductNotFound",
                                  style: Theme.of(context).textTheme.headline2)
                              .tr())));
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

  void dataMassaging(dynamic item) {
    List<String> tempOutletIds = [];

    if (item != null) {
      double totalAddOnPrice = 0.00;
      List<AddOn> addOnList = [];
      if (item['cartItemDetails'] != null &&
          item['cartItemDetails'].length > 0) {
        item['cartItemDetails'].forEach((addon) {
          print("Add On : ${addon['productAddonOption']['name']}");
          AddOn tempAddOn = AddOn(
              addOnOptionsId: addon['productAddonOptionId'],
              addOnPriceWhenAdded:
                  double.parse(addon['addOnPriceWhenAdded'].toString()),
              cartItemId: addon['id'],
              name: addon['productAddonOption']['name'],
              addOnTitle: addon['productAddonOption']['productAddon']['name'],
              addonId: addon['productAddonOption']['productAddon']['id']);

          addOnList.add(tempAddOn);
          totalAddOnPrice += addon['addOnPriceWhenAdded'];
        });
      }

      double priceWhenAdded = double.parse(item["priceWhenAdded"]);
      bool isSSTEnabled = item["productOutlet"]['outlet']['isSSTEnabled'];
      merchantSST = isSSTEnabled
          ? double.parse(
              ((priceWhenAdded + totalAddOnPrice) * 0.06).toStringAsFixed(2))
          : 0.00;

      //User Cart Item Instantiation
      UserCartItem userCartItem = UserCartItem(
          id: item["id"],
          outletProductInformation: item["productOutlet"],
          preOrderId: item["preOrderId"],
          priceWhenAdded: priceWhenAdded,
          serviceType: item["collectionType"],
          merchantSST: merchantSST,
          addOns: addOnList,
          finalPrice:
              double.parse((priceWhenAdded + totalAddOnPrice).toString()),
          serviceDate: DateFormat("d MMM")
              .format(DateTime.parse(item["serviceDateTime"]).toLocal()),
          serviceTime: DateFormat.jm()
              .format(DateTime.parse(item["serviceDateTime"]).toLocal()),
          quantity: item["quantity"],
          currentDeliveryAddress: item["currentDeliveryAddress"],
          specialInstructions: item["remarks"],
          isDeliveredToVenue: item["isDeliveredToVenue"],
          latitude: item["latitude"],
          longitude: item["longitude"],
          isMerchantDelivery: item["productOutlet"]["product"]
              ["isMerchantDelivery"],
          distance:
              item["distance"] != null ? item['distance'].toDouble() : null);

      if (userCartItem.serviceType == "DELIVERY") {
        print("p1 ");
        if (!tempOutletIds
            .contains(userCartItem.outletProductInformation["outlet"]["id"])) {
          var deliveryCollectionType =
              (userCartItem.outletProductInformation["outlet"]
                      ['collectionTypes'] as List)
                  .firstWhere((element) => element['type'] == 'DELIVERY');

          if (deliveryCollectionType['firstNthKM'] != null &&
              deliveryCollectionType['firstNthKMDeliveryFee'] != null &&
              deliveryCollectionType['deliveryFeePerKM'] != null &&
              userCartItem.distance != null) {
            print("OUTLET REQUIRED DELIVERY FEE");
            final double distanceInKm =
                double.parse(item['distance'].toStringAsFixed(2));
            int firstNthKM = deliveryCollectionType[
                'firstNthKM']; // distance = 10 km , firstNthKM =5 , firstNthKMDeliveryFee =1 , deliveryFeePerKM = 2,
            double firstNthKMDeliveryFee =
                deliveryCollectionType['firstNthKMDeliveryFee'].toDouble();
            double deliveryFeePerKM =
                deliveryCollectionType['deliveryFeePerKM'].toDouble();

            double calculateDeliveryFee() {
              if (firstNthKM >= distanceInKm) {
                return double.parse(firstNthKMDeliveryFee.toStringAsFixed(2));
              }
              double subDistance = (distanceInKm - firstNthKM);
              double deliveryFee = (firstNthKMDeliveryFee) +
                  (subDistance.ceil() * deliveryFeePerKM);
              return double.parse(deliveryFee.toStringAsFixed(2));
            }

            userCart!.addTheOutletDeliveryFee(calculateDeliveryFee());
            tempOutletIds
                .add(userCartItem.outletProductInformation["outlet"]["id"]);
          }
        }
      }

      if (userCartItem.outletProductInformation["product"]["productType"] ==
          "BUNDLE") {
        userCart!.celebrationItem = userCartItem;
      }
    }
  }
}

class UpdateItemPageArguments {
  final String userCartItemId;

  UpdateItemPageArguments(this.userCartItemId);
}
