import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/option_checkbox_form_field.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/option_radio_form_field.dart';

class VariationListWidget extends StatefulWidget {
  VariationListWidget(this.list, this.selectedItem,
      {required this.radioFunction,
      required this.checkBoxesFunction,
      required this.isEnableSST});

  final List<dynamic> list; //Product Outlet List
  final Function radioFunction; // Function
  final Function checkBoxesFunction; // Function
  final UserCartItem selectedItem;
  final bool isEnableSST;

  @override
  _VariationListWidgetState createState() => _VariationListWidgetState();
}

class _VariationListWidgetState extends State<VariationListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.list.length, // Product List
        itemBuilder: (context, index) {
          return _buildVariationList(
              context,
              widget.list[index], // Current Product Information
              widget.radioFunction,
              widget.checkBoxesFunction,
              widget.isEnableSST,
              widget.selectedItem);
        });
  }
}

Widget _buildVariationList(
    BuildContext context,
    Map<String, dynamic> productOutlet,
    Function radioFunction,
    Function checkBoxesFunction,
    bool isSSTEnable,
    UserCartItem selectedItem) {
  List<Widget> addonList = [];
  if (productOutlet['product']['productAddons'] != null &&
      productOutlet['product']['productAddons'].length > 0) {
    List addons = productOutlet['product']['productAddons'];
    if (addons.length > 0) {
      addons.forEach((addOn) {
        String requireText = '';
        if(addOn['isRequired']) {
          if(addOn['isMultiselect']) {
            requireText = 'Product.Pick'.tr(namedArgs: {
              'number': addOn['minimumSelectItem'].toString()});
          } else {
            requireText = 'Product.SingleSelection'.tr();
          }
        } else {
          requireText = 'Product.PickNoRequire'.tr();
        }

        if(addOn['isMultiselect']) {
          requireText += 'Product.MaximumSelected'.tr(
              namedArgs: {
                'number': addOn['maximumSelectItem'].toString()
              }
          );
        }

        final List addonOptions = (addOn['productAddonOptions'] as List);
        addonOptions.sort((a,b) => a['order'].compareTo(b['order']));

        addonList.add(Container(
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
                              child: Text(productOutlet['product']['title'],
                                  style: Theme.of(context).textTheme.button),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            addOn['isRequired']
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.0)),
                                        color: Theme.of(context).primaryColor),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        child: Text('Validation.Required',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption)
                                            .tr()))
                                : Container(width: 0.0, height: 0.0)
                          ]),
                      SizedBox(height: 4.0),
                      Text(addOn["name"],
                          style: Theme.of(context).textTheme.subtitle1),
                      SizedBox(height: 4.0),
                      Text(requireText, style: Theme.of(context).textTheme.bodyText1,),
                      SizedBox(height: 4.0),
                      addOn['isMultiselect']
                          ? OptionCheckboxFormField(
                              selectedItem: selectedItem,
                              validatorTextKey: 'Required',
                              options: addonOptions,
                              minimumSelectItem: addOn['minimumSelectItem'],
                              maximumSelectItem: addOn['maximumSelectItem'],
                              productId: productOutlet['product']['id'],
                              addonId: addOn['id'],
                              isEnableSST: isSSTEnable,
                              checkBoxesFunction: checkBoxesFunction)
                          : OptionRadioFormField(
                              selectedItem: selectedItem,
                              validatorTextKey: 'Required',
                              options: addonOptions,
                              minimumSelectItem: addOn['minimumSelectItem'],
                              productId: productOutlet['product']['id'],
                              addonId: addOn['id'],
                              isEnableSST: isSSTEnable,
                              selectedRadio: radioFunction)
                    ]))));
        addonList.add(SizedBox(height: 10.0));
      });
    }
  }

  return addonList.length > 0
      ? Column(children: addonList)
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
