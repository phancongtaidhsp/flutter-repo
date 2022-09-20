import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/configuration.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/amenities-list-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/celebration-app-bar.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/package-list-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/celebration-details-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/pop-up-dialog-add-to-basket-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/variation-list-widget.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/view_merchant_outlet_page.dart';
import 'package:gem_consumer_app/screens/party/widgets/quantity-error-message-widget.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:gem_consumer_app/screens/review-basket/gql/basket.gql.dart';
import 'package:gem_consumer_app/screens/review-basket/review_basket_page.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:gem_consumer_app/widgets/pop-up-error-message-widget.dart';
import 'package:gem_consumer_app/widgets/product-carousel.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../widgets/location_not_found.dart';

class ViewCelebrationPage extends StatefulWidget {
  static String routeName = '/view-celebration';
  ViewCelebrationPage({this.celebrationItem});
  final UserCartItem? celebrationItem;

  @override
  _ViewCelebrationPageState createState() => _ViewCelebrationPageState();
}

class _ViewCelebrationPageState extends State<ViewCelebrationPage> {
  late Auth auth;
  bool isLoggedIn = false;
  TextEditingController _specialInstructionsTextcontroller =
      TextEditingController();
  int quantity = 1;
  bool minimumQuantity = false;
  bool maximumQuantity = false;
  late AddToCartItems userCart;
  late PlanAParty party;
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

  List<String> _selectedCollectionType = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Position? position;
  UserAddress? currentUserLocation;
  UserAddress? deliveryLocation;
  List selectedAddOn = [];
  List multipleSelectedAddOn = [];
  List singleSelectedAddOn = [];
  double selectedAddOnTotalPrice = 0.00;

  @override
  void initState() {
    userCart = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    auth = context.read<Auth>();
    if (auth.currentUser.isAuthenticated!) {
      isLoggedIn = true;
    }
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final args = ModalRoute.of(context)!.settings.arguments
        as ViewCelebrationPageArguments;
    _selectedCollectionType.add(args.selectedServiceType);
    _selectedDate = args.selectedDate;
    _selectedTime = args.selectedTime;
    if (args.selectedAddress != null) {
      deliveryLocation = args.selectedAddress!;
    }

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
                final productOutletData = result.data!['ProductOutlet'];

                UserCartItem item = UserCartItem(
                    outletProductInformation: productOutletData, addOns: []);
                // Seasonal Checking
                bool isSeasonal = !productOutletData['isAlwaysAvailable'];

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
                                                item,
                                                checkBoxesFunction:
                                                    _setSelectedVariationMultiple,
                                                radioFunction:
                                                    _setSelectedVariation,
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
                                document: gql(BasketGQL.ADD_TO_CART),
                                onCompleted: (dynamic resultData) {
                                  if (resultData != null) {
                                    if (resultData["createUserCart"]
                                            ["status"] ==
                                        "SUCCESS") {
                                      Navigator.pop(context);
                                      userCart.addToCart(item);
                                      Navigator.pushNamed(
                                          context, ReviewBasketPage.routeName);
                                    }
                                  }
                                },
                              ),
                              builder: (
                                RunMutation? runMutation,
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
                                                offset:
                                                    Offset(0.0, -2.0), //(x,y)
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
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  result!.isNotLoading) {
                                                if (userCart.checkAnyItem()) {
                                                  _showConfirmationDialog();
                                                } else {
                                                  var combineDateTime =
                                                      new DateTime(
                                                          _selectedDate!.year,
                                                          _selectedDate!.month,
                                                          _selectedDate!.day,
                                                          _selectedTime!.hour,
                                                          _selectedTime!
                                                              .minute);
                                                  item.quantity = quantity;
                                                  item.specialInstructions =
                                                      _specialInstructionsTextcontroller
                                                          .text;
                                                  item.priceWhenAdded = double
                                                      .parse(productOutletData[
                                                                  "product"]
                                                              ["currentPrice"]
                                                          .toString());
                                                  item.finalPrice = double.parse(
                                                          productOutletData[
                                                                      "product"]
                                                                  [
                                                                  "currentPrice"]
                                                              .toString()) +
                                                      selectedAddOnTotalPrice;
                                                  item.isOutletSSTEnabled =
                                                      productOutletData[
                                                              "outlet"]
                                                          ["isSSTEnabled"];

                                                  runMutation!({
                                                    "createCartItemInput": {
                                                      "userId":
                                                          auth.currentUser.id,
                                                      "productOutletId":
                                                          item.outletProductInformation[
                                                              "id"],
                                                      "quantity": item.quantity,
                                                      "currentDeliveryAddress":
                                                          _selectedCollectionType[
                                                                      0] ==
                                                                  "DELIVERY"
                                                              ? deliveryLocation!
                                                                  .address1
                                                              : null,
                                                      "latitude":
                                                          _selectedCollectionType[
                                                                      0] ==
                                                                  "DELIVERY"
                                                              ? deliveryLocation!
                                                                  .latitude
                                                              : null,
                                                      "longitude":
                                                          _selectedCollectionType[
                                                                      0] ==
                                                                  "DELIVERY"
                                                              ? deliveryLocation!
                                                                  .longitude
                                                              : null,
                                                      "remarks": item
                                                          .specialInstructions,
                                                      "priceWhenAdded":
                                                          item.outletProductInformation[
                                                                  "product"]
                                                              ["currentPrice"],
                                                      "collectionType":
                                                          _selectedCollectionType[
                                                              0],
                                                      "serviceDateTime":
                                                          combineDateTime
                                                              .toUtc()
                                                              .toIso8601String(),
                                                      "isDeliveredToVenue":
                                                          false,
                                                      "addons":
                                                          selectedAddOn.length >
                                                                  0
                                                              ? selectedAddOn
                                                              : null,
                                                      "numberOfPax": args.pax,
                                                      "orderName": item
                                                              .outletProductInformation[
                                                          "product"]["title"]
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
    });
  }

  void _showConfirmationDialog() {
    //if (userCartItems.itemList.length > 0) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: Mutation(
              options: MutationOptions(
                document: gql(BasketGQL.CLEAR_USER_CART_ITEM),
                onCompleted: (dynamic resultData) {
                  if (resultData != null) {
                    if (resultData["clearUserCartItem"]["status"] ==
                            "SUCCESS" ||
                        resultData["clearUserCartItem"]["status"] ==
                            "NOT_EXISTS_IN_DATABASE") {
                      party.resetParty();
                      userCart.clearCartItems();
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => Dialog(
                          child: PopUpErrorMessageWidget(),
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.all(24),
                        ),
                      );
                    }
                  }
                },
                onError: (dynamic resultData) {
                  print(resultData);
                },
              ),
              builder: (
                RunMutation? runMutation,
                QueryResult? result,
              ) {
                return PopUpDialogAddToBasketWidget(
                    title: "Celebration.DiscardBasket",
                    content: "Celebration.DiscardBasketContent",
                    continueFunction: () {
                      runMutation!({"userId": auth.currentUser.id});
                    });
              },
            )
            //                     PopUpDialogAddToBasketWidget(
            // title: "Celebration.DiscardBasket",
            // content: "Celebration.DiscardBasketContent",
            // continueFunction: () {
            //   Navigator.pop(context);
            //   //_validateInputs(runMutation);
            // })
            ));
    //} else {
    //  _validateInputs(runMutation);
    //}
  }

  getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    var addresses = await Geocoder.google(Configuration.ANDROID_API_KEY)
        .findAddressesFromCoordinates(
            Coordinates(position?.latitude, position?.longitude));
    if (addresses.isEmpty) {
      errorDialog(
        errorMessage: 'We are unable to get your current address. Try later.',
        okButtonAction: () {},
        context: context,
        okButtonText: 'OK',
      );
      return;
    }

    if (addresses.length > 0) {
      var useAddress = addresses[0];

      setState(() {
        currentUserLocation = UserAddress(
            id: '000',
            name: 'UserAddressPage.CurrentLocation'.tr(),
            address1: useAddress.featureName,
            address2: '',
            postalCode: useAddress.postalCode,
            city: useAddress.subAdminArea ?? useAddress.locality,
            state: useAddress.adminArea,
            longitude: position?.longitude ?? 0.0,
            latitude: position?.latitude ?? 0.0);
      });
    }
  }
}

class ViewCelebrationPageArguments {
  final String productOutletId;
  final String selectedServiceType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int pax;
  final UserAddress? selectedAddress;

  ViewCelebrationPageArguments(this.productOutletId, this.selectedServiceType,
      this.selectedDate, this.selectedTime, this.pax,
      {this.selectedAddress});
}
