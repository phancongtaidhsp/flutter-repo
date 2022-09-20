import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ReviewBasketWidget extends StatefulWidget {
  ReviewBasketWidget(
      {required this.price,
      required this.itemCount,
      required this.reviewBasket});

  final double price;
  final int itemCount;
  final Function reviewBasket;

  @override
  _ReviewBasketWidgetState createState() => _ReviewBasketWidgetState();
}

class _ReviewBasketWidgetState extends State<ReviewBasketWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.12,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            offset: Offset(0.0, -2.0), //(x,y)
            blurRadius: 4.0,
          )
        ]),
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('RM ${widget.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.button),
                    Text('Basket.Items',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w400))
                        .tr(namedArgs: {"count": widget.itemCount.toString()})
                  ]),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24.0),
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0))),
                  onPressed: () => widget.reviewBasket(),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('Button.Review',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.button)
                            .tr()
                      ]))
            ]));
  }
}
