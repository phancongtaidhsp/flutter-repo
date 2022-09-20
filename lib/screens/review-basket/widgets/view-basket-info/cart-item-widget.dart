import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/review-basket/update_item_page.dart';
import 'package:gem_consumer_app/screens/review-basket/widgets/view-basket-info/display-addon-widget.dart';
import 'package:gem_consumer_app/widgets/special_instruction.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    Key? key,
    required this.userCartItem,
    required this.index,
    required this.innerIndex,
  }) : super(key: key);

  final UserCartItem? userCartItem;
  final int index;
  final int innerIndex;

  @override
  Widget build(BuildContext context) {
    var addOnMap;
    if (userCartItem!.addOns.length > 0) {
      addOnMap = groupBy(userCartItem!.addOns, (AddOn obj) {
        return obj.addonId;
      });
    }

    // Seasonal Checking
    bool isSeasonal = userCartItem != null
        ? !userCartItem!.outletProductInformation['isAlwaysAvailable']
        : false;
    bool isAvailable;

    if (isSeasonal) {
      isAvailable = false;

      List seasonalHours =
          userCartItem!.outletProductInformation['menuItemBusinessHours'];
      seasonalHours.forEach((element) {
        if (element != null) {
          if (isNowBetweenDateRange(element, context)) {
            isAvailable = true;
          }
        }
      });
    } else {
      isAvailable = true;
    }

    bool isProductActive = userCartItem!.outletProductInformation['status'] ==
            'APPROVED' &&
        userCartItem!.outletProductInformation["product"]["status"] ==
            'APPROVED' &&
        userCartItem!.outletProductInformation["outlet"]['status'] == 'ACTIVE';

    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: GestureDetector(
          onTap: () {
            if (userCartItem!.outletProductInformation['product']
                    ['productType'] ==
                'BUNDLE') {
              Navigator.pushNamed(context, UpdateItemPage.routeName,
                  arguments: UpdateItemPageArguments(
                    userCartItem!.id!,
                  ));
            }
          },
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 25,
                      width: 29,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          "${(userCartItem!.quantity!.toString())}x",
                          style: Theme.of(context).textTheme.button!.copyWith(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8.5,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Text(
                          userCartItem!.outletProductInformation["product"]
                              ["title"],
                          style: Theme.of(context).textTheme.button!.copyWith(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: userCartItem!.outletProductInformation["product"]
                                  ["productType"] ==
                              "ROOM"
                          ? Text(
                              "Basket.Deposit",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ).tr(namedArgs: {
                              'price': StringHelper.formatCurrency(
                                  (userCartItem!.isOutletSSTEnabled
                                      ? ((userCartItem!.finalPrice! * 1.06) *
                                          userCartItem!.quantity!)
                                      : ((userCartItem!.finalPrice!) *
                                          userCartItem!.quantity!))),
                              'symbol1': "(",
                              'symbol2': ")"
                            })
                          : Text(
                              StringHelper.formatCurrency(
                                  (userCartItem!.isOutletSSTEnabled
                                      ? ((userCartItem!.finalPrice! * 1.06) *
                                          userCartItem!.quantity!)
                                      : ((userCartItem!.finalPrice!) *
                                          userCartItem!.quantity!))),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                    ),
                  ],
                ),
                // productMap[productMap.keys.elementAt(index)][innerIndex].quantity >
                //         productMap[productMap.keys.elementAt(index)][innerIndex]
                //             .limitQuantity
                //     ? Container(
                //         padding: EdgeInsets.only(
                //           top: 10,
                //         ),
                //         child: Row(children: <Widget>[
                //           Icon(Icons.error_rounded,
                //               color: Color.fromRGBO(237, 53, 86, 1)),
                //           SizedBox(width: 5),
                //           Expanded(
                //               child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: <Widget>[
                //                 Text("Product.ExceedQuantity",
                //                         style: Theme.of(context)
                //                             .textTheme
                //                             .bodyText1
                //                             .copyWith(
                //                                 color:
                //                                     Color.fromRGBO(237, 53, 86, 1)))
                //                     .tr(),
                //                 Text("Product.AvailableQuantity",
                //                         style: Theme.of(context)
                //                             .textTheme
                //                             .bodyText1
                //                             .copyWith(
                //                                 color:
                //                                     Color.fromRGBO(237, 53, 86, 1)))
                //                     .tr(namedArgs: {
                //                   'number':
                //                       productMap[productMap.keys.elementAt(index)]
                //                               [innerIndex]
                //                           .limitQuantity
                //                           .toString()
                //                 })
                //               ]))
                //         ]))
                //     : Container(width: 0.0, height: 0.0),

                SizedBox(
                  height: 6,
                ),

                SizedBox(
                  height: 6,
                ),
                addOnMap != null && addOnMap.length > 0
                    ? DisplayAddonWidget(addOnMap)
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                userCartItem!.specialInstructions == null ||
                        userCartItem!.specialInstructions == ''
                    ? const SizedBox(
                        width: 0,
                      )
                    : Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: SpecialInstruction(
                            specialInstructionText:
                                userCartItem!.specialInstructions!),
                      ),
                (!isAvailable || !isProductActive)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.exclamationCircle,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text('Product.UnavailableSelected'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                      color: Colors.redAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal))
                        ],
                      )
                    : Container()
              ])),
    );
  }

  bool isNowBetweenDateRange(Map data, BuildContext context) {
    AddToCartItems cart = context.read<AddToCartItems>();
    bool isAvailable;
    DateTime now = DateTime.now();
    var formatString = "yyyy-MM-ddThh:mm:ssZ";

    // Date range
    if (data['endDate'] == null || data['startDate'] == null) {
      isAvailable = true;
    } else {
      DateTime endDate =
          new DateFormat(formatString).parse(data['endDate'], true).toLocal();
      DateTime startDate =
          new DateFormat(formatString).parse(data['startDate'], true).toLocal();
      isAvailable = now.isAfter(startDate) && now.isBefore(endDate);
    }

    // if now is not between date range, return false immediately
    if (isAvailable == false) {
      return false;
    }

    // if not, continue checking with day
    // Day
    if (data['day'] == null) {
      isAvailable = true;
    } else {
      String todayText = DateFormat('EE').format(DateTime.now()).toUpperCase();
      String dayText = data['day'];

      isAvailable = todayText == dayText;
    }

    // if today is not the same with day, return false immediately
    if (isAvailable == false) {
      return false;
    }

    // if not, continue checking with time
    // Time Range
    if (data['startTime'] == null || data['endTime'] == null) {
      isAvailable = true;
    } else {
      var startTimeList = data['startTime'].split(':');
      var endTimeList = data['endTime'].split(':');

      DateTime startTime = new DateTime(now.year, now.month, now.day,
          int.parse(startTimeList[0]), int.parse(startTimeList[1]));
      DateTime endTime = new DateTime(now.year, now.month, now.day,
          int.parse(endTimeList[0]), int.parse(endTimeList[1]));

      isAvailable = now.isAfter(startTime) && now.isBefore(endTime);
    }
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => cart.setIsAvailable(isAvailable));

    return isAvailable;
  }
}
