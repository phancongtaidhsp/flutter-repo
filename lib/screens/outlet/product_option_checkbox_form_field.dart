import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/screens/outlet/variation_icon.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class ProductOptionCheckboxFormField extends StatefulWidget {
  final String? validatorTextKey;
  final String? productId;
  final String? addonId;
  final List<dynamic> options;
  final int maximumSelectItem;
  final int minimumSelectItem;
  final bool isEnableSST;

  const ProductOptionCheckboxFormField(
      {Key? key,
      required this.options,
      required this.maximumSelectItem,
      required this.minimumSelectItem,
      this.productId,
      this.validatorTextKey,
      required this.isEnableSST,
      this.addonId})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ProductOptionCheckboxFormField> {
  bool isSelectOverMaximumNumber = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Container>.generate(
        widget.options.length,
        (int index) {
          return Container(
            // color: Colors.red,
            height: 30,
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const VariationIcon(),
                Expanded(
                  child: Text(widget.options[index]['name'],
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      )),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  '+${StringHelper.formatCurrency((widget.options[index]['price'] + (widget.isEnableSST ? widget.options[index]['price'] * 0.06 : 0)))}',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
