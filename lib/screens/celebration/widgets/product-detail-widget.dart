import 'package:flutter/material.dart';

class ProductDetailsWidget extends StatelessWidget {
  ProductDetailsWidget(this.productData);

  final Map<String, dynamic> productData;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0))),
        child: Row(children: <Widget>[
          Flexible(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
            child: productData['product']['description'] != null ||
                    productData['quantity'] != null ||
                    productData['product']['title'] != null
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    productData['product']['description'] != "" && productData['product']['description'] != null
                        ? Text(productData['product']['description'],
                            style: Theme.of(context).textTheme.bodyText1)
                        : Container(width: 0.0, height: 0.0),
                    SizedBox(height: 10.0),
                    Text('${productData['quantity']}x | ${productData['product']['title']}',
                        style: Theme.of(context).textTheme.button)
                  ])
                : Container(width: 0.0, height: 0.0),
          ))
        ]));
  }
}
