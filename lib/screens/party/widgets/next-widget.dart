import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:provider/provider.dart';

class NextWidget extends StatefulWidget {
  NextWidget({required this.validateInputs, required this.lastStep});
  final Function validateInputs;
  final bool lastStep;

  @override
  _NextWidgetState createState() => _NextWidgetState();
}

class _NextWidgetState extends State<NextWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
              primary: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0))),
          onPressed: () {
            widget.validateInputs();
          },
          child: Consumer<PlanAParty>(builder: (context, party, child) {
            return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: party.checkAnyItem()
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: <Widget>[
                  party.checkAnyItem()
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8.0),
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(party.countCartItem().toString(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button!
                                          .copyWith(color: Colors.white))),
                              party.checkAnyItem()
                                  ? SizedBox(width: 8.0)
                                  : Container(width: 0.0, height: 0.0),
                              Text(
                                  'RM ${StringHelper.formatCurrency(party.calculatedTotalCartItemPrice())}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.button)
                            ])
                      : Container(width: 0.0, height: 0.0),
                  Text(
                      widget.lastStep
                          ? 'Button.ViewBasket'.tr().toUpperCase()
                          : 'Button.Next'.tr().toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.button)
                ]);
          }),
        ));
  }
}
