import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/product_tag_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class PartyProductInfoWidget extends StatelessWidget {
  PartyProductInfoWidget(this.product, this.isSeasonal, this.isSSTEnabled);

  final Map<String, dynamic> product;
  final bool isSeasonal;
  final bool isSSTEnabled;

  @override
  Widget build(BuildContext context) {
    var currentPrice = product['currentPrice'] ?? 0.0;

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                      "RM ${StringHelper.formatCurrency((currentPrice + (isSSTEnabled ? currentPrice * 0.06 : 0)))} ",
                  style: Theme.of(context).textTheme.headline2!.copyWith(
                      fontWeight: FontWeight.w400, color: primaryColor)),
              product['originalPrice'] > currentPrice
                  ? TextSpan(
                      text:
                          " RM ${StringHelper.formatCurrency((product['originalPrice'] + (isSSTEnabled ? product['originalPrice'] * 0.06 : 0)))} ",
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontFamily: 'Arial Rounded MT Bold',
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ))
                  : TextSpan(text: ""),
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
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 12))
                : Container(
                    width: 0,
                    height: 0,
                  ),
            product['description'] != null
                ? SizedBox(height: 20.0)
                : Container(width: 0.0, height: 0.0),
            product['description'] != null
                ? Text(product['description'],
                    style: Theme.of(context).textTheme.bodyText1)
                : Container(width: 0.0, height: 0.0),
          ],
        ),
      ),
    );
  }
}
