import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:gem_consumer_app/screens/celebration/widgets/pop-up-dialog-widget.dart';
import 'package:provider/provider.dart';

class AddToCartWidget extends StatefulWidget {
  AddToCartWidget({required this.validateInputs});
  final Function validateInputs;

  @override
  _AddToCartWidgetState createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        flex: 1,
        child: Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, -2.0), //(x,y)
                blurRadius: 4.0,
              )
            ]),
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    primary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0))),
                onPressed: () => widget.validateInputs(),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // Consumer<AddToCartTotal>(builder: (context, cart, child) {
                      //   return Text('RM ${cart.totalPrice.toStringAsFixed(2)}',
                      //       textAlign: TextAlign.center,
                      //       style: Theme.of(context).textTheme.button);
                      // }),
                      Text('Button.AddToBasket',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.button)
                          .tr()
                    ]))),
      )
    ]);
  }
}
