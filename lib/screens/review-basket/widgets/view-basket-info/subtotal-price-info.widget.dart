import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:provider/provider.dart';
import 'package:gem_consumer_app/helpers/geo-helper.dart';

class SubTotalPriceInfoWidget extends StatelessWidget {
  SubTotalPriceInfoWidget({Key? key, required this.userCartItems})
      : super(key: key);

  final List<UserCartItem> userCartItems;
  @override
  Widget build(BuildContext context) {
    AddToCartItems userCart;
    PlanAParty party;
    userCart = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    double totalDeliveryFee = 0.00;
    double serviceCharge = 0; 
    bool isServiceChargeEnable = false;
    dynamic serviceChargeRate = 0;

    var venueItem = userCartItems.where((element) => element.outletProductInformation['product']['productType'] == "ROOM").toList();
    var foodItem = userCartItems.where((element) => element.outletProductInformation['product']['productType'] == "FOOD").toList();

    if(venueItem.isNotEmpty && foodItem.isNotEmpty && venueItem[0].outletProductInformation["outletId"] == foodItem[0].outletProductInformation["outletId"]) {
      isServiceChargeEnable = true;
      serviceCharge = party.calculateServiceCharge();
      var dineInCollectionType =(foodItem[0].outletProductInformation["outlet"]["collectionTypes"] as List).firstWhere((element) => element["type"] == "DINE_IN", orElse: () => null);
      if (dineInCollectionType != null) serviceChargeRate = dineInCollectionType["serviceChargeRate"];
    }

    if (userCartItems[0].serviceType == "DELIVERY") {
      var deliveryCollectionType = (userCartItems[0]
              .outletProductInformation["outlet"]['collectionTypes'] as List)
          .firstWhere((element) => element['type'] == 'DELIVERY');

      if (deliveryCollectionType['firstNthKM'] != null &&
          deliveryCollectionType['firstNthKMDeliveryFee'] != null &&
          deliveryCollectionType['deliveryFeePerKM'] != null &&
          userCartItems[0].distance != null) {
        print("OUTLET REQUIRED DELIVERY FEE");
        final double distanceInKm =
            double.parse(userCartItems[0].distance!.toStringAsFixed(2));
        int firstNthKM = deliveryCollectionType[
            'firstNthKM']; // distance = 10 km , firstNthKM =5 , firstNthKMDeliveryFee =1 , deliveryFeePerKM = 2,
        double firstNthKMDeliveryFee =
            deliveryCollectionType['firstNthKMDeliveryFee'].toDouble();
        double deliveryFeePerKM =
            deliveryCollectionType['deliveryFeePerKM'].toDouble();

        double calculateDeliveryFee() {
          if (firstNthKM >= distanceInKm) {
            return double.parse((firstNthKMDeliveryFee).toStringAsFixed(2));
          }
          double subDistance = (distanceInKm - firstNthKM);
          double deliveryFee =
              (firstNthKMDeliveryFee) + (subDistance.ceil() * deliveryFeePerKM);
          return double.parse(deliveryFee.toStringAsFixed(2));
        }

        totalDeliveryFee = calculateDeliveryFee();
        userCart.addTheOutletDeliveryFeeNoListener(totalDeliveryFee);
        userCart.outletsDeliveryFee.add({
          "outletId": userCartItems[0].outletProductInformation["outlet"]["id"],
          "deliveryFee": totalDeliveryFee
        });
      }
    }

    return Container(
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
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ).tr(),
              Spacer(),
              Text(
                "${StringHelper.formatCurrency((userCartItems.map((m) => double.parse(m.isOutletSSTEnabled ? ((m.finalPrice! * 1.06) * m.quantity!).toString() : ((m.finalPrice!) * m.quantity!).toString())).reduce((a, b) => a + b)))}",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          isServiceChargeEnable ? Row(
            children: [
              Text(
                "Basket.ServiceCharge",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.black),
              ).tr(namedArgs: {"rate": StringHelper.formatCurrency(serviceChargeRate)}),
              Spacer(),
              Text(
                "${StringHelper.formatCurrency(serviceCharge)}",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.black),
              ),
            ],
          ) : Container(),
          isServiceChargeEnable ? SizedBox(
            height: 10,
          ) : Container(),
          Row(
            children: [
              Text(
                "Basket.DeliveryFee",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.black),
              ).tr(),
              Spacer(),
              Text(
                "${StringHelper.formatCurrency(totalDeliveryFee)}", //"${productList.map((m) => double.parse(m.price.toString())).reduce((a, b) => a + b).toStringAsFixed(2)}",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.black),
              ),
            ],
          ),
          // SizedBox(
          //   height: 10,
          // ),
          // Row(
          //   children: [
          //     Text(
          //       "Basket.VoucherDiscount",
          //       style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),
          //     ).tr(),
          //     Spacer(),
          //     Text(
          //       "0.00", //"${(productMap[productMap.keys.elementAt(index)].map((m) => double.parse(m.price.toString())).reduce((a, b) => a + b)).toStringAsFixed(2)}",
          //       style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
