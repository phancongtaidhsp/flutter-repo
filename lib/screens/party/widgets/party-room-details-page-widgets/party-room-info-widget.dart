import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/product_tag_widget.dart';

class PartyRoomInfoWidget extends StatelessWidget {
  PartyRoomInfoWidget(this.product, this.isSeasonal, this.isSSTEnabled);

  final Map<String, dynamic> product;
  final bool isSeasonal;
  final bool isSSTEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // TODO Need to check with real condition
                  isSeasonal
                      ? ProductTagWidget(
                          text: 'Product.Seasonal'.tr(),
                          textColor: Colors.black,
                          iconPath: 'assets/images/icon_seasonal.svg',
                          backgroundColor: primaryColor,
                        )
                      : Container(),
                  SizedBox(height: isSeasonal ? 20.0 : 0),
                  RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text:
                            'RM ${StringHelper.formatCurrency((product['currentPrice'] + (isSSTEnabled ? product['currentPrice'] * 0.06 : 0)))}',
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                            fontWeight: FontWeight.w400, color: primaryColor)),
                    TextSpan(
                        text: 'PlanAParty.Deposit'
                            .tr(namedArgs: {'symbol1': "(", 'symbol2': ")"}),
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .copyWith(fontWeight: FontWeight.normal)),
                  ])),
                  SizedBox(height: 10.0),
                  Text(product['title'],
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.w400)),
                  SizedBox(height: 4.0),
                  product['subTitle'] != null
                      ? Text(product['subTitle'],
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 12))
                      : Container(
                          height: 0,
                          width: 0,
                        ),
                  product['description'] != null
                      ? SizedBox(height: 20.0)
                      : Container(width: 0.0, height: 0.0),
                  product['description'] != null
                      ? Text(product['description'],
                          style: Theme.of(context).textTheme.bodyText1)
                      : Container(width: 0.0, height: 0.0),
                ])));
  }
}
