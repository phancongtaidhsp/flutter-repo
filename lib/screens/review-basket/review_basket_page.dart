import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_landing_page.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import '../../widgets/loading_controller.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import "package:collection/collection.dart";
import 'package:easy_localization/easy_localization.dart';
import '../../models/AddOn.dart';
import '../../models/UserCartItem.dart';
import '../../providers/add-to-cart-items.dart';
import '../../providers/auth.dart';
import '../../providers/plan-a-party.dart';
import '../../screens/review-basket/gql/basket.gql.dart';
import '../../screens/review-basket/widgets/check-out-widget.dart';
import '../../screens/review-basket/widgets/term-and-condition.dart';
import '../../screens/review-basket/widgets/view-basket-info/cart-item-widget.dart';
import '../../screens/review-basket/widgets/view-basket-info/service-info-widget.dart';
import '../../screens/review-basket/widgets/view-basket-info/subtotal-price-info.widget.dart';
import '../../screens/review-basket/widgets/view-basket-info/total-price-info.widget.dart';

class ReviewBasketPage extends StatefulWidget {
  static String routeName = '/review-basket';
  @override
  _ReviewBasketPageState createState() => _ReviewBasketPageState();
}

class _ReviewBasketPageState extends State<ReviewBasketPage> {
  late AddToCartItems userCart;
  late PlanAParty party;
  late Auth auth;
  String? preOrderId;
  String? orderName;
  String? deliveryAddress;
  bool checkCartOnlyCelebration = false;
  double merchantSST = 0.0;
  bool _loadingUserCart = true;
  double totalDeliveryFee = 0.00;

  @override
  void initState() {
    userCart = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    auth = context.read<Auth>();

    _clearAndRestItems();
    super.initState();
  }

  _clearAndRestItems() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userCart.outletsDeliveryFee != null) {
        userCart.clearOutletsDeliveryFee();
      }
      if (userCart.totalDeliveryFee > 0.00) {
        userCart.resetTotalDeliveryFee();
      }

      setState(() {
        _loadingUserCart = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _loadingUserCart
        ? Scaffold(body: LoadingController())
        : Query(
            options: QueryOptions(
                document: gql(BasketGQL.GET_USER_CART_ITEMS),
                variables: {'userId': auth.currentUser.id},
                fetchPolicy: FetchPolicy.noCache),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return Scaffold(body: LoadingController());
              }
              if (result.data != null) {
                party.clearPartyItemsNoListner();
                userCart.clearCartItemsNoListner();
                if (party.demands != null) {
                  party.setCurrentStepNoListener(party.demands!.length - 1);
                }
                if (result.data!['CartItems'] != null &&
                    result.data!['CartItems'].length > 0) {
                  List<UserCartItem> cartItems =
                      dataMassaging(result.data!['CartItems']);
                  return AnnotatedRegion(
                    value: SystemUiOverlayStyle(
                        statusBarBrightness: Brightness.light,
                        statusBarColor: lightBack,
                        statusBarIconBrightness: Brightness.light),
                    child: Scaffold(
                      bottomSheet: Container(
                        height: 90, //
                        child: (checkCartOnlyCelebration
                                ? userCart.checkAnyItem()
                                : party.checkAnyItem())
                            ? CheckOutWidget(
                                price: checkCartOnlyCelebration
                                    ? userCart.calculateTotalPrice() +
                                        totalDeliveryFee
                                    : party.calculatedTotalCartItemPrice() +
                                        totalDeliveryFee,
                                serviceCharge: checkCartOnlyCelebration
                                    ? null
                                    : party.calculateServiceCharge(),
                                itemCount: checkCartOnlyCelebration
                                    ? userCart.calculateCartItemsQuantity()
                                    : party.countCartItem(),
                                preOrderId: preOrderId!,
                                orderName: orderName!,
                                deliveryFee: totalDeliveryFee,
                              )
                            : Container(width: 0.0, height: 0.0),
                      ),
                      body: SafeArea(
                        child: SingleChildScrollView(
                          child: Container(
                            // height: double.infinity, // <-----
                            //color: Colors.red,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: size.height * 0.073,
                                  width: MediaQuery.of(context).size.width,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 25.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 2,
                                            offset: Offset(0, 1)),
                                      ]),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 36.0,
                                        width: 36.0,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(0, 1)),
                                            ]),
                                        child: IconButton(
                                            icon: SvgPicture.asset(
                                                'assets/images/icon-back.svg'),
                                            iconSize: 36.0,
                                            onPressed: () {
                                              if (checkCartOnlyCelebration) {
                                                Navigator.pop(context);
                                              } else {
                                                Navigator.popUntil(
                                                    context,
                                                    ModalRoute.withName(
                                                        PlanAPartyLandingPage
                                                            .routeName));
                                              }
                                            }),
                                      ),
                                      Text("Button.ViewBasket",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400))
                                          .tr(),
                                      checkCartOnlyCelebration
                                          ? Container(
                                              width: 0,
                                              height: 0,
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                party.setCurrentStep(0);
                                                Navigator.pushNamed(
                                                        context,
                                                        PlanAPartyLandingPage
                                                            .routeName)
                                                    .then(((value) {
                                                  setState(() {
                                                    party.setCurrentStep(
                                                        party.demands!.length -
                                                            1);
                                                  });
                                                }));
                                              },
                                              child: Text("General.Edit",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                      textAlign:
                                                          TextAlign.center)
                                                  .tr(),
                                            )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    top: 5,
                                  ),
                                  //height: size.height * 0.718,
                                  width: MediaQuery.of(context).size.width,
                                  child: _basketList(context, cartItems),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
              return NodataInBasket(size: size);
            },
          );
  }

  Widget _basketList(
    BuildContext context,
    List<UserCartItem> dataList,
  ) {
    Map<String, List<UserCartItem>> userCartItemMap =
        groupBy(dataList, (UserCartItem item) {
      return item.outletProductInformation["outlet"]["id"];
    });

    Map iconPath = {
      "DINE_IN": "assets/images/service-type/dine-in-icon.png",
      "DELIVERY": "assets/images/service-type/delivery.png",
      "PICKUP": "assets/images/service-type/delivery.png"
    };
    Map collectionType = {
      "DINE_IN": "Dine In",
      "PICKUP": "Pick Up",
      "DELIVERY": "Delivery"
    };
    List<String> displayOrder = ["DINE_IN", "PICKUP", "DELIVERY"];
    List<String> userSelectedServices = [];
    Map<String, List<UserCartItem>> newMap = {};
    if (userCartItemMap.isNotEmpty) {
      displayOrder.forEach((type) {
        for (UserCartItem item in dataList) {
          if (item.serviceType == type) {
            userSelectedServices.add(type);
            break;
          }
        }
      });
    }

    for (var z = 0; z < userSelectedServices.length; z++) {
      for (var i = 0; i < userCartItemMap.length; i++) {
        if (userCartItemMap[userCartItemMap.keys.elementAt(i)]!.every(
            (element) => element.serviceType == userSelectedServices[z])) {
          if (userSelectedServices[z] == "DELIVERY") {
            deliveryAddress =
                userCartItemMap[userCartItemMap.keys.elementAt(i)]![0]
                    .currentDeliveryAddress;
          }
          newMap.putIfAbsent(userCartItemMap.keys.elementAt(i),
              () => userCartItemMap[userCartItemMap.keys.elementAt(i)]!);
        }
      }
    }
    userCartItemMap = newMap;

    return Column(children: [
      Container(
        // color: Colors.yellow,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          children: List.generate(userCartItemMap.length, (index) {
            print(userCartItemMap[userCartItemMap.keys.elementAt(index)]![0]
                .specialInstructions);

            print('usercartitem map');
            return Column(
              children: [
                ServiceInfoWidget(
                    userCartItems:
                        userCartItemMap[userCartItemMap.keys.elementAt(index)]!,
                    iconPath: iconPath[userCartItemMap[
                            userCartItemMap.keys.elementAt(index)]![0]
                        .serviceType],
                    serviceDateAndTimeInfo:
                        "${collectionType[userCartItemMap[userCartItemMap.keys.elementAt(index)]![0].serviceType]}, ${userCartItemMap[userCartItemMap.keys.elementAt(index)]![0].serviceDate}, ${userCartItemMap[userCartItemMap.keys.elementAt(index)]![0].serviceTime}"),
                Column(
                  children: List.generate(
                      userCartItemMap[userCartItemMap.keys.elementAt(index)]!
                          .length,
                      (_index) => CartItemWidget(
                          userCartItem: userCartItemMap[
                              userCartItemMap.keys.elementAt(index)]![_index],
                          index: index,
                          innerIndex: _index)),
                ),
                Divider(
                  thickness: 1,
                ),
                InkWell(
                  onTap: () {
                    List termList = userCartItemMap[
                            userCartItemMap.keys.elementAt(index)]![0]
                        .outletProductInformation['outlet']['collectionTypes']
                        .where((element) =>
                            element['type'] ==
                            userCartItemMap[
                                    userCartItemMap.keys.elementAt(index)]![0]
                                .serviceType)
                        .toList();

                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (ctx) => Container(
                        child: TermAndCondition((termList.length > 0 &&
                                termList[0]['terms'] != null)
                            ? termList[0]['terms']
                            : ''),
                        height: MediaQuery.of(context).size.height * 0.9,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "General.TermAndCondition".tr(),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
                // AddVoucherWidget(),
                SubTotalPriceInfoWidget(
                    userCartItems: userCartItemMap[
                        userCartItemMap.keys.elementAt(index)]!),
              ],
            );
          }),
        ),
      ),
      SizedBox(height: 10.0),
      TotalPriceInfoWidget(
          cartItems: dataList, serviceCharge: party.calculateServiceCharge()),
      SizedBox(height: 10),
      userSelectedServices.contains("DELIVERY")
          ? Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: EdgeInsets.only(
                top: 15,
                left: 20,
                right: 20,
                bottom: 35,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 4.0,
                    )
                  ]),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: SvgPicture.asset("assets/images/location.svg")),
                    SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Basket.DeliveryAddress",
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .button!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold))
                            .tr(),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.48,
                            child: Text(
                              "$deliveryAddress",
                              style: Theme.of(context).textTheme.bodyText1,
                            ))
                      ],
                    ),
                  ]))
          : Container(
              width: 0,
              height: 0,
            ),
      SizedBox(height: 100),
    ]);
  }

  List<UserCartItem> dataMassaging(List<dynamic> cartItemList) {
    List<UserCartItem> userCartItems = [];
    List<String> tempOutletIds = [];
    if (cartItemList.length > 0) {
      userCart.resetTotalDeliveryFee();
      totalDeliveryFee = 0;
      cartItemList.forEach((item) {
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
                  addOnTitle: addon['productAddonOption']['productAddon']
                      ['name'],
                  addonId: addon['productAddonOption']['productAddon']['id']);

              addOnList.add(tempAddOn);
              totalAddOnPrice += addon['addOnPriceWhenAdded'];
            });
          }
          preOrderId = item["preOrderId"];
          orderName = item["orderName"];
          double priceWhenAdded =
              double.parse(item["priceWhenAdded"].toString());
          bool isSSTEnabled = item["productOutlet"]['outlet']['isSSTEnabled'];
          merchantSST = isSSTEnabled
              ? double.parse(((priceWhenAdded + totalAddOnPrice) * 0.06)
                  .toStringAsFixed(2))
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
              latitude:
                  item["latitude"] != null ? item["latitude"].toDouble() : null,
              longitude: item["longitude"] != null
                  ? item["longitude"].toDouble()
                  : null,
              isOutletSSTEnabled: item["productOutlet"]["outlet"]
                  ["isSSTEnabled"],
              isMerchantDelivery: item["productOutlet"]["product"]
                  ["isMerchantDelivery"],
              distance: item["distance"] != null
                  ? item['distance'].toDouble()
                  : null);

          if (userCartItem.serviceType == "DELIVERY") {
            print("p1 ");
            if (!tempOutletIds.contains(
                userCartItem.outletProductInformation["outlet"]["id"])) {
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
                    double.parse(userCartItem.distance!.toStringAsFixed(2));
                int firstNthKM = deliveryCollectionType['firstNthKM'];
                double firstNthKMDeliveryFee =
                    deliveryCollectionType['firstNthKMDeliveryFee'].toDouble();
                double deliveryFeePerKM =
                    deliveryCollectionType['deliveryFeePerKM'].toDouble();

                double calculateDeliveryFee() {
                  if (firstNthKM >= distanceInKm) {
                    return double.parse(
                        firstNthKMDeliveryFee.toStringAsFixed(2));
                  }
                  double subDistance = (distanceInKm - firstNthKM);
                  double deliveryFee = (firstNthKMDeliveryFee) +
                      (subDistance.ceil() * deliveryFeePerKM);
                  return double.parse(deliveryFee.toStringAsFixed(2));
                }

                totalDeliveryFee += calculateDeliveryFee();
                userCart
                    .addTheOutletDeliveryFeeNoListener(calculateDeliveryFee());
                tempOutletIds
                    .add(userCartItem.outletProductInformation["outlet"]["id"]);
              }
            }
          }

          userCartItems.add(userCartItem);
          if (userCartItem.outletProductInformation["product"]["productType"] ==
              "ROOM") {
            party.setVenueProductNoListener(userCartItem);
          }

          if (userCartItem.outletProductInformation["product"]["productType"] ==
              "FOOD") {
            party.addFBProductNoListener(userCartItem);
          }

          if (userCartItem.outletProductInformation["product"]["productType"] ==
              "GIFT") {
            party.addDecorationProductNoListener(userCartItem);
          }

          if (userCartItem.outletProductInformation["product"]["productType"] ==
              "BUNDLE") {
            checkCartOnlyCelebration = true;
            userCart.celebrationItem = userCartItem;
          }
        }
      });
      if (party.venueProduct != null &&
          party.fbProducts != null &&
          party.fbProducts!.length > 0 &&
          party.fbProducts![0].outletProductInformation["outlet"]["id"] ==
              party.venueProduct!.outletProductInformation["outlet"]["id"]) {
        party.setCurrentVenueAnyFB(true);
      }

      if (party.venueProduct != null &&
          party.decorationProducts != null &&
          party.decorationProducts!.length > 0 &&
          party.decorationProducts![0].outletProductInformation["outlet"]
                  ["id"] ==
              party.venueProduct!.outletProductInformation["outlet"]["id"]) {
        party.setCurrentVenueAnyDeco(true);
      }
    }

    return userCartItems;
  }
}

class NodataInBasket extends StatelessWidget {
  const NodataInBasket({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(children: <Widget>[
      Column(children: <Widget>[
        Container(
          height: size.height * 0.073,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 1)),
          ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 36.0,
                width: 36.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1)),
                    ]),
                child: IconButton(
                    icon: SvgPicture.asset('assets/images/icon-back.svg'),
                    iconSize: 36.0,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Text("Button.ViewBasket",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontWeight: FontWeight.w400))
                  .tr(),
              Container(
                width: 40,
                height: 0,
              )
            ],
          ),
        ),
        Container(
          child: Center(
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                  child: Text("Basket.EmptyMessage",
                          style: Theme.of(context).textTheme.headline2)
                      .tr())),
        )
      ])
    ])));
  }
}
