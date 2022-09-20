import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_product_details_page.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_room_details_page.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_update_product_details_page.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_update_room_details_page.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:provider/provider.dart';
import '../../../providers/plan-a-party.dart';
import '../../../screens/party/plan_a_party_product_details_page.dart';
import '../../../screens/party/plan_a_party_room_details_page.dart';
import '../../../screens/party/plan_a_party_update_product_details_page.dart';
import '../../../screens/party/plan_a_party_update_room_details_page.dart';
import '../../../values/color-helper.dart';

class PartyProductListWidget extends StatefulWidget {
  PartyProductListWidget(this.dataMap, this.productType,
      {this.isSelectOne = false});
  final Map dataMap;
  final String productType;
  final bool isSelectOne;

  @override
  State<PartyProductListWidget> createState() => _PartyProductListWidgetState();
}

class _PartyProductListWidgetState extends State<PartyProductListWidget>
    with TickerProviderStateMixin {
  final Map<String, String> allCollectionType = {
    "DINE_IN": "Dine In",
    "DELIVERY": "Delivery",
    "PICKUP": "Pick Up"
  };
  late TabController _tabController;
  var indexSelected = 0;

  @override
  void initState() {
    // _adjustheight();
    if (widget.productType == "ROOM" &&
        widget.dataMap.keys.contains("Selected")) {
      widget.dataMap.removeWhere((key, value) => key != "Selected");
    }

    _tabController = TabController(
      initialIndex: indexSelected,
      length: widget.dataMap.keys.length, //widget.dataMap.keys.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('party-product-list-widget');
    if (widget.productType == "ROOM" &&
        widget.dataMap.keys.contains("Selected")) {
      widget.dataMap.removeWhere((key, value) => key != "Selected");
    }

    if (_tabController.length != widget.dataMap.keys.length) {
      _tabController = TabController(
        length: widget.dataMap.keys.length, //widget.dataMap.keys.length,
        vsync: this,
      );
    }
    double topSpacing = widget.productType == "ROOM" ? 8 : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  indexSelected = index;
                  _tabController.animateTo(index);
                });
              },
              labelStyle: Theme.of(context)
                  .textTheme
                  .button!
                  .copyWith(fontWeight: FontWeight.normal),
              unselectedLabelStyle:
                  Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14),
              isScrollable: true,
              labelPadding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              indicatorWeight: 4,
              indicatorColor: primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: List.generate(
                widget.dataMap.keys.length,
                (index) => Text(
                  widget.dataMap.keys.toList()[index].toString().toUpperCase(),
                ),
              ),
            ),
            IndexedStack(
              index: indexSelected,
              children: List.generate(widget.dataMap.keys.length, (index) {
                return indexSelected == index
                    ? Container(
                        margin: EdgeInsets.only(
                          bottom: 100,
                          top: topSpacing,
                        ),
                        child: _productList(
                            widget.dataMap[
                                widget.dataMap.keys.toList()[index].toString()],
                            allCollectionType,
                            context),
                      )
                    : Container(
                        width: 0,
                      );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _productList(
      List<dynamic> dataList, Map allCollectionType, BuildContext context) {
    // var imageHeightForGrid =
    //     ((MediaQuery.of(context).size.width / 2) - 10) * 0.4;
    // print('$imageHeightForGrid imageHeightForGrid');

    return widget.isSelectOne
        ? ListView.builder(
            // FOR ROOM
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: dataList.length,
            itemBuilder: (BuildContext context, int index) {
              // Seasonal Checking
              // print('ListView.builder ::: itembuilder ::: ${dataList.length}');
              bool isSeasonal = !dataList[index]['isAlwaysAvailable'];
              bool isAvailable = dataList[index]['available'];
              bool isProductSelected = false;

              // Product Collection Type Text
              Map types = groupBy(dataList[index]["collectionTypes"], (obj) {
                obj as Map;
                return obj['type'];
              });
              String collectTypeText = "";
              types.keys.toList().forEach((element) {
                collectTypeText += allCollectionType[element] + " / ";
              });

              if (collectTypeText.length > 0) {
                collectTypeText =
                    collectTypeText.substring(0, collectTypeText.length - 2);
              }

              // Sales Text
              String saleText = "";
              if (dataList[index]["product"]['advancePurchaseDuration'] !=
                  null) {
                int saleDuration =
                    dataList[index]["product"]['advancePurchaseDuration'];
                String saleUnit =
                    dataList[index]["product"]['advancePurchaseUnit'];
                saleText =
                    saleDuration.toString() + " " + saleUnit.toLowerCase();

                if (saleDuration > 1) {
                  saleText += "s";
                }
              }
              // this is for product ID
              String productOutletId = dataList[index]['id'];
              String productType = dataList[index]['product']['productType'];
              return Consumer<PlanAParty>(builder: (context, party, child) {
                if (productType == "ROOM") {
                  if (party.venueProduct != null &&
                      party.venueProduct!.outletProductInformation['id'] ==
                          productOutletId) {
                    isProductSelected = true;
                  }
                }

                ////print(dataList[index]['product']['thumbNail']);

                return GestureDetector(
                    onTap: () {
                      if (dataList[index]['numberOfRoom'] > 0 && isAvailable) {
                        isProductSelected
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PlanAPartyUpdateRoomDetailsPage(
                                            party.venueProduct!)))
                            : Navigator.pushNamed(
                                context, PlanAPartyRoomDetailsPage.routeName,
                                arguments: PlanAPartyRoomDetailsPageArguments(
                                    dataList[index]['product']['id'],
                                    dataList[index]['id']));
                      }
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          dataList[index]['numberOfRoom'] > 0 && isAvailable
                              ? LayoutBuilder(builder: (context, constraints) {
                                  var imageDynamicHeight =
                                      constraints.maxWidth * 0.4;
                                  return Container(
                                      width: constraints.maxWidth,
                                      height: imageDynamicHeight,
                                      decoration: isProductSelected
                                          ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  width: 4.0,
                                                  color: Theme.of(context)
                                                      .primaryColor))
                                          : BoxDecoration(),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: constraints.maxWidth,
                                                height: imageDynamicHeight,
                                                child: dataList[index]
                                                                    ['product'][
                                                                'smallThumbNail'] ==
                                                            "" ||
                                                        dataList[index]
                                                                    ['product'][
                                                                'smallThumbNail'] ==
                                                            null
                                                    ? DefaultImageHelper
                                                        .defaultImageWithSize(
                                                        constraints.maxWidth,
                                                        imageDynamicHeight,
                                                      )
                                                    : CachedImage(
                                                        imageUrl: dataList[
                                                                    index]
                                                                ['product']
                                                            ['smallThumbNail'],
                                                        width: constraints
                                                            .maxWidth,
                                                        height:
                                                            imageDynamicHeight,
                                                      ),
                                              ),
                                              dataList[index]['product']
                                                      ['isNew']
                                                  ? Positioned(
                                                      top: 10,
                                                      right: 12,
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12))),
                                                        child: Text(
                                                          'Product.New'.tr(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'Arial',
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              Positioned(
                                                top: 12,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    saleText.length > 0
                                                        ? Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        6),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/icon-sale.svg',
                                                                  color:
                                                                      grayTextColor,
                                                                  width: 12,
                                                                  height: 12,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  saleText,
                                                                  style: TextStyle(
                                                                      color:
                                                                          grayTextColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          'Arial'),
                                                                )
                                                              ],
                                                            ),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    primaryColor,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            12),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            12))),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      height:
                                                          saleText.length > 0
                                                              ? 6
                                                              : 0,
                                                    ),
                                                    isSeasonal
                                                        ? Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        6),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/icon_seasonal.svg',
                                                                  color:
                                                                      grayTextColor,
                                                                  width: 12,
                                                                  height: 12,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'Product.Seasonal'
                                                                      .tr(),
                                                                  style: TextStyle(
                                                                      color:
                                                                          grayTextColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          'Arial'),
                                                                )
                                                              ],
                                                            ),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    primaryColor,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            12),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            12))),
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                              ),
                                              isProductSelected
                                                  ? Positioned(
                                                      bottom: 12,
                                                      right: 12,
                                                      child: Container(
                                                          height: 24,
                                                          width: 24,
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
                                                          child: Center(
                                                              child: Text(
                                                            party.venueProduct!
                                                                .quantity
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Arial Rounded MT Bold',
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ))),
                                                    )
                                                  : Container(
                                                      width: 0.0, height: 0.0),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: isProductSelected
                                                    ? BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            width: 4.0,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor))
                                                    : BoxDecoration(),
                                              )
                                            ],
                                          )));
                                })
                              : LayoutBuilder(builder: (context, constraints) {
                                  var imageDynamicHeight =
                                      constraints.maxWidth * 0.4;
                                  return Container(
                                    width: constraints.maxWidth,
                                    height: imageDynamicHeight,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: imageDynamicHeight,
                                            width: constraints.maxWidth,
                                            child: dataList[index]['product'][
                                                            'smallThumbNail'] ==
                                                        "" ||
                                                    dataList[index]['product'][
                                                            'smallThumbNail'] ==
                                                        null
                                                ? DefaultImageHelper
                                                    .defaultImageWithSize(
                                                    constraints.maxWidth,
                                                    imageDynamicHeight,
                                                  )
                                                : CachedImage(
                                                    imageUrl: dataList[index]
                                                            ['product']
                                                        ['smallThumbNail'],
                                                    width: constraints.maxWidth,
                                                    height: imageDynamicHeight,
                                                  ),
                                          ),
                                          Container(
                                              height: imageDynamicHeight,
                                              width: constraints.maxWidth,
                                              child: SvgPicture.asset(
                                                'assets/images/grey-overlay.svg',
                                                fit: BoxFit.cover,
                                              )),
                                          Positioned.fill(
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                          "Product.NotAvailable",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline3!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .white))
                                                      .tr()))
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          SizedBox(height: 8.0),
                          Text(
                            dataList[index]['product']['title'],
                            style: Theme.of(context).textTheme.button,
                          ),
                          SizedBox(height: 4.0),
                          widget.productType == "ROOM"
                              ? RichText(
                                  text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          "RM ${StringHelper.formatCurrency((dataList[index]['product']['originalPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['originalPrice'] * 0.06 : 0)))}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400)),
                                  TextSpan(
                                      text:
                                          " • ${dataList[index]['product']['pax'] == null ? 10 : dataList[index]['product']['pax']} pax",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400)),
                                  collectTypeText != ""
                                      ? TextSpan(
                                          text: " • $collectTypeText",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400))
                                      : TextSpan(text: "")
                                ]))
                              : RichText(
                                  text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          "RM ${StringHelper.formatCurrency((dataList[index]['product']['currentPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['currentPrice'] * 0.06 : 0)))} ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400)),
                                  dataList[index]['product']['originalPrice'] >
                                          dataList[index]['product']
                                              ['currentPrice']
                                      ? TextSpan(
                                          text:
                                              "RM ${StringHelper.formatCurrency((dataList[index]['product']['originalPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['originalPrice'] * 0.06 : 0)))}",
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontFamily: 'Arial Rounded MT Bold',
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                          ))
                                      : TextSpan(text: ""),
                                  TextSpan(
                                      text:
                                          " • ${dataList[index]['product']['pax'] == null ? 10 : dataList[index]['product']['pax']} pax",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400)),
                                  collectTypeText != ""
                                      ? TextSpan(
                                          text: " • $collectTypeText",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400))
                                      : TextSpan(text: "")
                                ])),
                          SizedBox(height: 20.0),
                        ]));
              });
            })
        : GridView.builder(
            // FOR FOOD AND DECO
            shrinkWrap: true,
            cacheExtent: 999999,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dataList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.95,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 10.0,
                mainAxisExtent: 190,
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              // Product Collection Type Text

              Map types = groupBy(dataList[index]["collectionTypes"], (obj) {
                obj as Map;
                return obj['type'];
              });
              String collectTypeText = "";
              types.keys.toList().forEach((element) {
                collectTypeText += allCollectionType[element] + " / ";
              });
              if (collectTypeText.isNotEmpty) {
                collectTypeText =
                    collectTypeText.substring(0, collectTypeText.length - 2);
              }

              // Sales Text
              String saleText = "";
              if (dataList[index]["product"]['advancePurchaseDuration'] !=
                  null) {
                int saleDuration =
                    dataList[index]["product"]['advancePurchaseDuration'];
                String saleUnit =
                    dataList[index]["product"]['advancePurchaseUnit'];
                saleText =
                    saleDuration.toString() + " " + saleUnit.toLowerCase();

                if (saleDuration > 1) {
                  saleText += "s";
                }
              }
              UserCartItem product = UserCartItem(
                  outletProductInformation: dataList[index], addOns: []);

              String productOutletId = dataList[index]['id'];
              String productType = dataList[index]['product']['productType'];

              // Seasonal Checking
              bool isSeasonal = !dataList[index]['isAlwaysAvailable'];
              bool isAvailable = dataList[index]['available'];
              bool isProductSelected = false;

              return Consumer<PlanAParty>(builder: (context, party, child) {
                int selectedProductQuantity = 0;

                if (productType == "FOOD") {
                  List fbProductList = party.fbProducts!
                      .where((product) =>
                          product.outletProductInformation["id"] ==
                          productOutletId)
                      .toList();
                  if (fbProductList.length > 0) {
                    isProductSelected = true;
                    product = fbProductList[0];
                    selectedProductQuantity = fbProductList[0].quantity;
                  }
                }
                if (productType == "GIFT") {
                  List decorationProductList = party.decorationProducts!
                      .where((product) =>
                          product.outletProductInformation["id"] ==
                          productOutletId)
                      .toList();
                  if (decorationProductList.isNotEmpty) {
                    isProductSelected = true;
                    product = decorationProductList[0];
                    selectedProductQuantity = decorationProductList[0].quantity;
                  }
                }
                var title = dataList[index]['product']['title'] as String;
                // if (title.length > 200) {
                //   title = title.substring(0, 200) + '...';
                // }
                if (index == 1) {
                  dataList[index]['product']['smallThumbNail'] = '';
                }
                //(dataList[index]['product']['thumbNail']
                // print(dataList[index]['product']['thumbNail']);
                // print('image ingridview builder $isAvailable');

                return GestureDetector(
                    onTap: () {
                      if (dataList[index]['availableQuantity'] > 0 &&
                          isAvailable) {
                        if (isProductSelected) {
                          // print("Before this $product");
                          // print("Before this 2 ${product.addOns}");
                        }
                        isProductSelected
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PlanAPartyUpdateProductDetailsPage(
                                            product)))
                            : Navigator.pushNamed(
                                context, PlanAPartyProductDetailsPage.routeName,
                                arguments:
                                    PlanAPartyProductDetailsPageArguments(
                                        dataList[index]['id']));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        height: 400,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              dataList[index]['availableQuantity'] > 0 &&
                                      isAvailable
                                  ? LayoutBuilder(
                                      builder: (context, constraints) {
                                      var imageDynamicHeight =
                                          constraints.maxWidth * 0.667;

                                      return SizedBox(
                                        width: constraints.maxWidth,
                                        height: imageDynamicHeight,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Stack(
                                            children: [
                                              dataList[index]['product'][
                                                              'smallThumbNail'] ==
                                                          "" ||
                                                      dataList[index]['product']
                                                              [
                                                              'smallThumbNail'] ==
                                                          null
                                                  ? DefaultImageHelper
                                                      .defaultImageWithSize(
                                                          constraints.maxWidth,
                                                          imageDynamicHeight)
                                                  : CachedImage(
                                                      width:
                                                          constraints.maxWidth,
                                                      height:
                                                          imageDynamicHeight,
                                                      imageUrl: dataList[index]
                                                              ['product']
                                                          ['smallThumbNail']),
                                              dataList[index]['product']
                                                      ['isNew']
                                                  ? Positioned(
                                                      top: 10,
                                                      right: 12,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            12))),
                                                        child: Text(
                                                          'Product.New'.tr(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'Arial',
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              Positioned(
                                                top: 12,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    saleText.length > 0
                                                        ? Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        6),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/icon-sale.svg',
                                                                  color:
                                                                      grayTextColor,
                                                                  width: 12,
                                                                  height: 12,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  saleText,
                                                                  style: TextStyle(
                                                                      color:
                                                                          grayTextColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          'Arial'),
                                                                )
                                                              ],
                                                            ),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    primaryColor,
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            12),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            12))),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      height:
                                                          saleText.length > 0
                                                              ? 6
                                                              : 0,
                                                    ),
                                                    isSeasonal
                                                        ? Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        6),
                                                            child: Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/icon_seasonal.svg',
                                                                  color:
                                                                      grayTextColor,
                                                                  width: 12,
                                                                  height: 12,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'Product.Seasonal'
                                                                      .tr(),
                                                                  style: TextStyle(
                                                                      color:
                                                                          grayTextColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12,
                                                                      fontFamily:
                                                                          'Arial'),
                                                                )
                                                              ],
                                                            ),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    primaryColor,
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topRight: Radius
                                                                        .circular(
                                                                            12),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            12))),
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                              ),
                                              isProductSelected
                                                  ? Positioned(
                                                      bottom: 12,
                                                      right: 12,
                                                      child: Container(
                                                          height: 24,
                                                          width: 24,
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
                                                                        const Offset(
                                                                            0,
                                                                            1)),
                                                              ]),
                                                          child: Center(
                                                              child: Text(
                                                            selectedProductQuantity
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Arial Rounded MT Bold',
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ))),
                                                    )
                                                  : Container(
                                                      width: 0.0, height: 0.0),
                                              LayoutBuilder(builder:
                                                  (context, constraints) {
                                                var imageDynamicHeight =
                                                    constraints.maxWidth *
                                                        0.667;

                                                return Container(
                                                  height: imageDynamicHeight,
                                                  decoration: isProductSelected
                                                      ? BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                              width: 4.0,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor))
                                                      : BoxDecoration(),
                                                );
                                              })
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                      var imageDynamicHeight =
                                          constraints.maxWidth * 0.667;

                                      return SizedBox(
                                          width: constraints.maxWidth,
                                          height: constraints.maxWidth * 0.667,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Stack(children: [
                                                dataList[index]['product'][
                                                                'smallThumbNail'] ==
                                                            "" ||
                                                        dataList[index]
                                                                    ['product'][
                                                                'smallThumbNail'] ==
                                                            null
                                                    ? DefaultImageHelper
                                                        .defaultImageWithSize(
                                                        constraints.maxWidth,
                                                        imageDynamicHeight,
                                                      )
                                                    : CachedImage(
                                                        width: constraints
                                                            .maxWidth,
                                                        height:
                                                            imageDynamicHeight,
                                                        imageUrl: dataList[
                                                                    index]
                                                                ['product']
                                                            ['smallThumbNail']),
                                                Container(
                                                    decoration: BoxDecoration(
                                                      // color: primaryColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topRight:
                                                            Radius.circular(12),
                                                        bottomRight:
                                                            Radius.circular(12),
                                                      ),
                                                    ),
                                                    width: constraints.maxWidth,
                                                    height: imageDynamicHeight,
                                                    child: SvgPicture.asset(
                                                      'assets/images/grey-overlay.svg',
                                                      fit: BoxFit.cover,
                                                    )),
                                                Positioned.fill(
                                                    child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                                "Product.NotAvailable",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headline3!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .white))
                                                            .tr()))
                                              ])));
                                    }),
                              const SizedBox(height: 8.0),
                              Text(
                                  dataList[index]['product']['pax'] != null
                                      ? "${dataList[index]['product']['pax']} Pax | $title"
                                      : title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(fontWeight: FontWeight.normal),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4.0),
                              Expanded(
                                child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: widget.productType == "ROOM"
                                        ? TextSpan(children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    "RM ${StringHelper.formatCurrency((dataList[index]['product']['originalPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['originalPrice'] * 0.06 : 0)))}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                          ])
                                        : TextSpan(children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    "RM ${StringHelper.formatCurrency((dataList[index]['product']['currentPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['currentPrice'] * 0.06 : 0)))} ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                            dataList[index]['product']
                                                        ['originalPrice'] >
                                                    dataList[index]['product']
                                                        ['currentPrice']
                                                ? TextSpan(
                                                    text:
                                                        "RM ${StringHelper.formatCurrency((dataList[index]['product']['originalPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['originalPrice'] * 0.06 : 0)))}",
                                                    style: const TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontFamily:
                                                          'Arial Rounded MT Bold',
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                    ))
                                                : const TextSpan(text: "")
                                          ])),
                              ),
                            ]),
                      ),
                    ));
              });
            });
  }
}
