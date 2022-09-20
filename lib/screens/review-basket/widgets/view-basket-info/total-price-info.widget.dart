import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/firebase_remote_config_helper.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:provider/provider.dart';
import 'package:gem_consumer_app/helpers/geo-helper.dart';

class TotalPriceInfoWidget extends StatefulWidget {
  TotalPriceInfoWidget({Key? key, required this.cartItems, required this.serviceCharge}) : super(key: key);
  final List<UserCartItem> cartItems;
  final double serviceCharge;

  @override
  State<TotalPriceInfoWidget> createState() => _TotalPriceInfoWidgetState();
}

class _TotalPriceInfoWidgetState extends State<TotalPriceInfoWidget> {
  String sst = FirebaseRemoteConfigHelper.loadConfig('gemspot_sst_rate');
  var totalItemsPrice = 0.00;
  var totalPrice = 0.00;
  double totalDeliveryFee = 0.0;
  double distance = 0.0;
  late AddToCartItems basket;
  var _loadingTotalPriceInfo = false;
  double calculateDeliveryFee(int firstNthKM, double distance,
      double firstNthKMDeliveryFee, double deliveryFeePerKM) {
    if (firstNthKM >= distance) {
      return double.parse(firstNthKMDeliveryFee.toStringAsFixed(2));
    }
    double subDistance = (distance - firstNthKM);
    double deliveryFee = (firstNthKMDeliveryFee) +
        (subDistance.ceil() * deliveryFeePerKM);
    return double.parse(deliveryFee.toStringAsFixed(2));
  }

  void _arrangeBasketValues() {
    List<String> tempOutletIds = [];
    if (widget.cartItems != null && widget.cartItems.length > 0) {
      widget.cartItems.forEach((cartItem) {
        totalItemsPrice += cartItem.isOutletSSTEnabled
            ? ((cartItem.finalPrice! * 1.06) * cartItem.quantity!)
            : ((cartItem.finalPrice!) * cartItem.quantity!);
        if (cartItem.serviceType == "DELIVERY" && cartItem.distance != null) {
          if (!tempOutletIds
              .contains(cartItem.outletProductInformation["outlet"]["id"])) {
            distance = double.parse(cartItem.distance!.toStringAsFixed(2));

            var deliveryCollectionType =
                (cartItem.outletProductInformation["outlet"]['collectionTypes']
                        as List)
                    .firstWhere((element) => element['type'] == 'DELIVERY');
            totalDeliveryFee += calculateDeliveryFee(
                deliveryCollectionType['firstNthKM'],
                distance,
                deliveryCollectionType['firstNthKMDeliveryFee'].toDouble(),
                deliveryCollectionType['deliveryFeePerKM'].toDouble());
            tempOutletIds
                .add(cartItem.outletProductInformation["outlet"]["id"]);
          }
        }
      });
    }
    totalPrice = (totalItemsPrice + totalDeliveryFee + widget.serviceCharge);
    totalPrice += totalPrice * double.parse(sst);
    basket.setDeliveryFee(totalDeliveryFee);
    print("totalDeliveryFee totalDeliveryFee: $totalDeliveryFee");
    basket.setDistance(distance);
    print("distance distance: $distance");
    basket.setTaxAmount(
        ((totalItemsPrice + totalDeliveryFee) * double.parse(sst)));
    basket.setFinalTotal(totalPrice);
    basket.setServiceCharge(widget.serviceCharge);
    setState(() {
      _loadingTotalPriceInfo = false;
    });
    totalItemsPrice += widget.serviceCharge;
  }

  @override
  void initState() {
    basket = context.read<AddToCartItems>();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _arrangeBasketValues();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loadingTotalPriceInfo
        ? LoadingController()
        : widget.cartItems.length > 0
            ? Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                            width: 1,
                            style: BorderStyle.solid,
                            color: Color.fromRGBO(228, 229, 229, 1)),
                      )),
                      child: Row(
                        children: [
                          Text(
                            "Basket.Total",
                            style:
                                Theme.of(context).textTheme.headline3!.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                          ).tr(),
                          Spacer(),
                          Text(
                            "RM ${StringHelper.formatCurrency(totalPrice)}",
                            style:
                                Theme.of(context).textTheme.headline3!.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                            width: 1,
                            style: BorderStyle.solid,
                            color: Color.fromRGBO(228, 229, 229, 1)),
                      )),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Basket.Subtotal",
                                style: Theme.of(context).textTheme.bodyText1,
                              ).tr(),
                              Spacer(),
                              Text(
                                "${StringHelper.formatCurrency(totalItemsPrice)}",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          // Remove Service Tax
                          // Row(
                          //   children: [
                          //     Text(
                          //       "Basket.ServiceTax",
                          //       style: Theme.of(context).textTheme.bodyText1,
                          //     ).tr(),
                          //     Spacer(),
                          //     Text(
                          //       "${StringHelper.formatCurrency(((totalItemsPrice + totalDeliveryFee) * double.parse(sst)))}",
                          //       style: Theme.of(context).textTheme.bodyText1,
                          //     ),
                          //   ],
                          // ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                "Basket.DeliveryFee",
                                style: Theme.of(context).textTheme.bodyText1,
                              ).tr(),
                              Spacer(),
                              Text(
                                "${StringHelper.formatCurrency(totalDeliveryFee)}",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                          //NOTE:FURTHER MIGHT NEED
                          // SizedBox(
                          //   height: 5,
                          // ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       "Basket.GemCredits",
                          //       style: Theme.of(context)
                          //           .textTheme
                          //           .bodyText1
                          //           .copyWith(color: Color.fromRGBO(244, 185, 32, 1)),
                          //     ).tr(),
                          //     Spacer(),
                          //     Text(
                          //       "0.00",
                          //       style: Theme.of(context)
                          //           .textTheme
                          //           .bodyText1
                          //           .copyWith(color: Color.fromRGBO(244, 185, 32, 1)),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container(width: 0.0, height: 0.0);
  }
}
