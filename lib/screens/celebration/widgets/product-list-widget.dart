import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/screens/celebration/view-celebration/view_celebration_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:provider/provider.dart';

class ProductListWidget extends StatelessWidget {
  ProductListWidget(this.dataMap, this.selectedServiceType, this.selectedDate,
      this.selectedTime, this.pax,
      {this.selectedAddress});

  final Map dataMap;
  final String selectedServiceType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int pax;
  final UserAddress? selectedAddress;

  @override
  Widget build(BuildContext context) {
    print('product-list-widget');
    return dataMap.length <= 0
        ? Center(
            child: Container(
              child: Text(
                "CelebrationHome.EmptyProduct",
                style: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(fontWeight: FontWeight.normal),
              ).tr(),
            ),
          )
        : Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 26,
            ),
            height: MediaQuery.of(context).size.height,
            child: DefaultTabController(
              length: dataMap.keys.length,
              child: Scaffold(
                backgroundColor: Colors.white,
                primary: false,
                appBar: TabBar(
                  labelStyle: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(fontWeight: FontWeight.normal),
                  unselectedLabelStyle: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontSize: 14),
                  isScrollable: true,
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  indicatorWeight: 4,
                  indicatorColor: primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: List.generate(
                    dataMap.keys.length,
                    (index) => Text(
                      dataMap.keys.toList()[index].toString().toUpperCase(),
                    ),
                  ),
                ),
                body: Container(
                  margin: EdgeInsets.only(top: 30, right: 26),
                  child: TabBarView(
                    children: List.generate(
                        dataMap.keys.length,
                        (index) => _productList(context,
                            dataMap[dataMap.keys.toList()[index].toString()])),
                  ),
                ),
              ),
            ),
          );
  }

  ListView _productList(BuildContext context, List dataList) {
    final Map<String, String> allCollectionType = {
      "DINE_IN": "CollectionType.DINE_IN".tr(),
      "DELIVERY": "CollectionType.DELIVERY".tr(),
      "PICKUP": "CollectionType.PICKUP".tr(),
    };

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: dataList.length,
        itemBuilder: (BuildContext context, int index) {
          Map types = groupBy(dataList[index]["collectionTypes"], (obj) {
            obj = obj as Map?;
            if (obj != null) {
              return obj['type'];
            }
          });

          List<String> productOutletCollectionTypes = [];
          types.keys.toList().forEach((element) {
            productOutletCollectionTypes.add(allCollectionType[element] ?? '');
          });

          String collectTypeText = productOutletCollectionTypes.join(" / ");

          //PreOrder Time
          String saleText = "";
          if (dataList[index]['product']['advancePurchaseDuration'] != null) {
            int saleDuration =
                dataList[index]['product']['advancePurchaseDuration'];
            String saleUnit = dataList[index]['product']['advancePurchaseUnit'];
            saleText = saleDuration.toString() + " " + saleUnit.toLowerCase();

            if (saleDuration > 1) {
              saleText += "s";
            }
          }

          // Seasonal Checking
          bool isSeasonal = !dataList[index]['isAlwaysAvailable'];
          bool isAvailable = dataList[index]["available"];
          //bool isProductSelected = false;

          // if (isSeasonal) {
          //   isAvailable = false;
          //   List seasonalHours = dataList[index]['menuItemBusinessHours'];
          //   seasonalHours.forEach((element) {
          //     if (element != null) {
          //       if (isNowBetweenDateRange(element)) {
          //         isAvailable = true;
          //       }
          //     }
          //   });
          // } else {
          //   isAvailable = true;
          // }

          return Consumer<AddToCartItems>(builder: (context, cart, child) {
            return GestureDetector(
                onTap: () {
                  if (dataList[index]['availableQuantity'] > 0 && isAvailable) {
                    Navigator.pushNamed(context, ViewCelebrationPage.routeName,
                        arguments: ViewCelebrationPageArguments(
                            dataList[index]['id'],
                            this.selectedServiceType,
                            this.selectedDate,
                            this.selectedTime,
                            this.pax,
                            selectedAddress: this.selectedAddress));
                  }
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LayoutBuilder(builder: (context, constraints) {
                        return Container(
                            width: constraints.maxWidth,
                            height: constraints.maxWidth * 0.4,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: dataList[index]["product"]
                                                      ['smallThumbNail'] ==
                                                  "" ||
                                              dataList[index]["product"]
                                                      ['smallThumbNail'] ==
                                                  null
                                          ? DefaultImageHelper
                                              .defaultImageWithSize(
                                              constraints.maxWidth,
                                              constraints.maxWidth * 0.4,
                                            )
                                          : CachedImage(
                                              imageUrl: dataList[index]
                                                  ["product"]['smallThumbNail'],
                                              width: constraints.maxWidth,
                                              height:
                                                  constraints.maxWidth * 0.4,
                                            ),
                                    ),
                                    dataList[index]['availableQuantity'] <= 0 ||
                                            !isAvailable
                                        ? Container(
                                            width: constraints.maxWidth,
                                            height: constraints.maxWidth * 0.4,
                                            child: SvgPicture.asset(
                                              'assets/images/grey-overlay.svg',
                                              fit: BoxFit.cover,
                                            ))
                                        : Container(
                                            width: 0,
                                            height: 0,
                                          ),
                                    dataList[index]['availableQuantity'] <= 0 ||
                                            !isAvailable
                                        ? Positioned.fill(
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                        "Product.NotAvailable",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline3!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .white))
                                                    .tr()))
                                        : Container(
                                            width: 0,
                                            height: 0,
                                          ),
                                    dataList[index]["product"]['isNew']
                                        ? Positioned(
                                            top: 10,
                                            right: 12,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              child: Text(
                                                'Product.New'.tr(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Arial',
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 0,
                                            width: 0,
                                          ),
                                    Positioned(
                                      top: 12,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          saleText.length > 0
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6),
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/icon-sale.svg',
                                                        color: grayTextColor,
                                                        width: 14,
                                                        height: 14,
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
                                                                FontWeight.w400,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Arial'),
                                                      )
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(12),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          12))),
                                                )
                                              : Container(),
                                          SizedBox(
                                            height: saleText.length > 0 ? 6 : 0,
                                          ),
                                          isSeasonal
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6),
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/images/icon_seasonal.svg',
                                                        color: grayTextColor,
                                                        width: 12,
                                                        height: 12,
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(
                                                        'Product.Seasonal'.tr(),
                                                        style: TextStyle(
                                                            color:
                                                                grayTextColor,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Arial'),
                                                      )
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(12),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          12))),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  ],
                                )));
                      }),
                      SizedBox(height: 8.0),
                      Text(
                        dataList[index]["product"]['title'],
                        style: Theme.of(context).textTheme.button,
                      ),
                      dataList[index]['outlet']['name'] == null
                          ? Text("Product.MerchantName",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: Colors.grey[400],
                                  )).tr()
                          : Text(dataList[index]['outlet']['name'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: Colors.grey[400],
                                  )),
                      SizedBox(height: 4.0),
                      RichText(
                          text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text:
                                "RM ${StringHelper.formatCurrency((dataList[index]['product']['currentPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['currentPrice'] * 0.06 : 0)))} ",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w400)),
                        dataList[index]['product']['originalPrice'] >
                                dataList[index]['product']['currentPrice']
                            ? TextSpan(
                                text:
                                    "RM ${StringHelper.formatCurrency((dataList[index]['product']['originalPrice'] + (dataList[index]['outlet']['isSSTEnabled'] ? dataList[index]['product']['originalPrice'] * 0.06 : 0)))}",
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontFamily: 'Arial Rounded MT Bold',
                                  color: Colors.grey,
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
                                    fontSize: 12, fontWeight: FontWeight.w400)),
                        TextSpan(
                            text: " • $collectTypeText",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w400))
                      ])),
                      SizedBox(height: 20.0),
                    ]));
          });
        });
  }
}
