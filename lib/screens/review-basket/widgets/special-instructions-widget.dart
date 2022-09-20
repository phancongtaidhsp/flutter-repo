import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/models/Product.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:easy_localization/easy_localization.dart';

import '../gql/basket.gql.dart';

class SpecialInstructions extends StatefulWidget {
  SpecialInstructions(this.productId);
  final String productId;

  @override
  _SpecialInstructionsState createState() => _SpecialInstructionsState();
}

class _SpecialInstructionsState extends State<SpecialInstructions> {
  late AddToCartItems basket;
  TextEditingController _controller = TextEditingController();
  late int productIndex;
  late Product product;
  int maxQuantity = 99;

  @override
  void initState() {
    super.initState();
    basket = context.read<AddToCartItems>();
  }

  textListener(String text) {
    _controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product.SpecialInstructions",
            style: Theme.of(context).textTheme.button,
          ).tr(),
          Container(
              padding: EdgeInsets.only(top: 20.0),
              width: MediaQuery.of(context).size.width,
              child: Consumer<AddToCartItems>(
                builder: (context, item, child) {
                  return TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _controller,
                      onChanged: (e) {
                        setState(() {
                          setState(() {
                            product.specialInstructions = e;
                            //basket.updateItem(productIndex, product);
                          });
                        });
                      },
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        labelText: tr('Product.SpecialInstructionsPlaceholder'),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: Theme.of(context).textTheme.bodyText1,
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 31,
                          minHeight: 31,
                        ),
                      ),
                      keyboardType: TextInputType.text);
                },
              )),
          SizedBox(
            height: 40,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 36.0,
                  width: 36.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1)),
                      ]),
                ),
                SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 30,
                ),
                Container(
                  height: 36.0,
                  width: 36.0,
                  decoration: BoxDecoration(
                      color: Colors.orange[300],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(0, 1)),
                      ]),
                  child:
                      Consumer<AddToCartItems>(builder: (context, item, child) {
                    return IconButton(
                        icon: SvgPicture.asset('assets/images/plus.svg'),
                        iconSize: 36.0,
                        onPressed: () {
                          if ((product.quantity! + 1) < maxQuantity) {
                            setState(() {
                              product.quantity = product.quantity! + 1;
                              //basket.updateItem(productIndex, product);
                            });
                          }
                        });
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
