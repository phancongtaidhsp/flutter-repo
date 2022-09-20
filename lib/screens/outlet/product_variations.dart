import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/models/Product.dart';

import '../../models/AddOnWithOptions.dart';
import 'product_option_checkbox_form_field.dart';

class ProductVariations extends StatefulWidget {
  ProductVariations({required this.isEnableSST, required this.product});

  //final List<AddOn> addonList; //Product Outlet List
  //final List<Map<String, dynamic>> productAddonOptions;
  final bool isEnableSST;
  final Product product;

  @override
  _ProductVariationsState createState() => _ProductVariationsState();
}

class _ProductVariationsState extends State<ProductVariations> {
  //  List<Widget> addonListWidgets = [];
  @override
  Widget build(BuildContext context) {
    log(widget.product.addOnWithOptions.toString());
    // print(widget.addonList.length.toString());
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.product.addOnWithOptions!.length, // Product List
        itemBuilder: (context, index) {
          return _buildVariationList(
            context,
            widget.product.addOnWithOptions![index],
            widget.product,
            widget.isEnableSST,
          );
        });
  }
}

Widget _buildVariationList(
  BuildContext context,
  AddOnWithOptions addOnWithOptions,
  Product product,
  bool isSSTEnable,
) {
  List<Map<String, dynamic>> addonList = addOnWithOptions.addOnOptions;
  print(addonList);

  List<Widget> addonListWidgets = [];

  // final Map<String, dynamic> addonOptions = addOn;
  // addonOptions.sort((a, b) => a['order'].compareTo(b['order']));
  addonListWidgets.add(
    Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(product.title,
                        style: Theme.of(context).textTheme.button),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  addOnWithOptions.isRequired
                      ? Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0)),
                              color: Theme.of(context).primaryColor),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Text('Validation.Required',
                                    style: Theme.of(context).textTheme.caption)
                                .tr(),
                          ),
                        )
                      : Container(width: 0.0, height: 0.0)
                ]),
            SizedBox(height: 4.0),
            Text(addOnWithOptions.name,
                style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 20.0),
            ProductOptionCheckboxFormField(
              validatorTextKey: 'Required',
              options: addonList,
              minimumSelectItem: addOnWithOptions.minimumSelectItem,
              maximumSelectItem: addOnWithOptions.maximumSelectItem,
              productId: product.id,
              addonId: addOnWithOptions.id,
              isEnableSST: isSSTEnable,
            )
          ],
        ),
      ),
    ),
  );
  addonListWidgets.add(SizedBox(height: 10.0));

  return addonListWidgets.length > 0
      ? Column(children: addonListWidgets)
      : Container(width: 0.0, height: 0.0);
}

String _numberToWords(int number) {
  if (number == 0) return "zero";

  if (number < 0) return "Minus " + _numberToWords(number.abs());

  String words = "";

  if (number > 0) {
    if (words != "") words += "and ";

    List unitsMap = [
      "zero",
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine",
      "ten",
      "eleven",
      "twelve",
      "thirteen",
      "fourteen",
      "fifteen",
      "sixteen",
      "seventeen",
      "eighteen",
      "nineteen"
    ];
    List tensMap = [
      "zero",
      "ten",
      "twenty",
      "thirty",
      "forty",
      "fifty",
      "sixty",
      "seventy",
      "eighty",
      "ninety"
    ];

    if (number < 20)
      words += unitsMap[number];
    else {
      words += tensMap[(number / 10).floor()];
      if ((number % 10) > 0) words += "-" + unitsMap[number % 10];
    }
  }

  return words;
}
