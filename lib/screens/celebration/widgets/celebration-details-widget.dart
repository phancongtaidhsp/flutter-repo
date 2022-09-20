import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/product_tag_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class CelebrationDetailsWidget extends StatelessWidget {
  CelebrationDetailsWidget(this.productData, this.isSeasonal);

  final Map<String, dynamic> productData;
  final bool isSeasonal;

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
                  isSeasonal
                      ? ProductTagWidget(
                          text: 'Product.Seasonal'.tr(),
                          textColor: Colors.black,
                          iconPath: 'assets/images/icon_seasonal.svg',
                          backgroundColor: primaryColor,
                        )
                      : Container(width: 0, height: 0),
                  SizedBox(height: isSeasonal ? 20.0 : 0),
                  RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text:
                            "RM ${StringHelper.formatCurrency((productData['product']['currentPrice'] + (productData['outlet']['isSSTEnabled'] ? productData['product']['currentPrice'] * 0.06 : 0)))} ",
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                            fontWeight: FontWeight.w400, color: primaryColor)),
                    productData['product']['originalPrice'] >
                            productData['product']['currentPrice']
                        ? TextSpan(
                            text:
                                "RM ${StringHelper.formatCurrency((productData['product']['originalPrice'] + (productData['outlet']['isSSTEnabled'] ? productData['product']['originalPrice'] * 0.06 : 0)))} ",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontFamily: 'Arial Rounded MT Bold',
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ))
                        : TextSpan(text: ""),
                  ])),
                  productData['outlet'] != null
                      ? SizedBox(height: 20.0)
                      : Container(width: 0.0, height: 0.0),
                  productData['outlet'] != null &&
                          productData['outlet']['name'] != null
                      ? Text(productData['outlet']['name'],
                          style: Theme.of(context).textTheme.subtitle1)
                      : Container(width: 0.0, height: 0.0),
                  SizedBox(height: 4.0),
                  Text(productData['product']['title'],
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.w400)),
                  productData['product']['pax'] != null
                      ? SizedBox(height: 4.0)
                      : Container(width: 0.0, height: 0.0),
                  productData['product']['pax'] != null
                      ? Text('${productData['product']['pax'] ?? 0} Pax',
                          style: Theme.of(context).textTheme.bodyText1)
                      : Container(width: 0.0, height: 0.0),
                  productData['product']['description'] != null
                      ? SizedBox(height: 20.0)
                      : Container(width: 0.0, height: 0.0),
                  productData['product']['description'] != null
                      ? Text(productData['product']['description'],
                          style: Theme.of(context).textTheme.bodyText1)
                      : Container(width: 0.0, height: 0.0),
                ])));
  }
}
