import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class PartyRoomBookingWidget extends StatelessWidget {
  PartyRoomBookingWidget(this.product, this.isSSTEnabled);
  final Map<String, dynamic> product;
  final bool isSSTEnabled;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          width: size.width,
          padding: EdgeInsets.all(25),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PlanAParty.Booking",
                style: Theme.of(context).textTheme.button,
              ).tr(),
              SizedBox(
                height: 16,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text("PlanAParty.BookingPrice".tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: grayTextColor)),
                          SizedBox(
                            width: 5,
                          ),
                          Tooltip(
                              preferBelow: true,
                              triggerMode: TooltipTriggerMode.tap,
                              message: "PlanAParty.BookingPriceTooltip".tr(),
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 18,
                              )),
                          Spacer(),
                          Text(
                              'RM ${StringHelper.formatCurrency((product['originalPrice'] + (isSSTEnabled ? product['originalPrice'] * 0.06 : 0)))}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black54))
                        ]),
                        SizedBox(
                          height: 8,
                        ),
                        (product['minimumSpend'] != null &&
                                product['minimumSpend'] > 0)
                            ? Row(
                                children: [
                                  Text("PlanAParty.MinimumSpend".tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              color: grayTextColor)),
                                  Spacer(),
                                  Text(
                                      'RM ${StringHelper.formatCurrency(product['minimumSpend'])}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black54))
                                ],
                              )
                            : Container()
                      ]))
            ],
          ),
        ));
  }
}
