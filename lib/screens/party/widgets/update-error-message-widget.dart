import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UpdateErrorMessageWidget extends StatelessWidget {
  UpdateErrorMessageWidget(
      this.maximumQuantity, this.minimumQuantity, this.availableQuantity);
  final int availableQuantity;
  final bool maximumQuantity;
  final bool minimumQuantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: [
            maximumQuantity
                ? Row(children: <Widget>[
                    Icon(Icons.error_rounded,
                        color: Color.fromRGBO(237, 53, 86, 1)),
                    SizedBox(width: 5),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Text("Product.ExceedQuantity",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          color:
                                              Color.fromRGBO(237, 53, 86, 1)))
                              .tr(),
                          Text("Product.AvailableQuantity",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          color:
                                              Color.fromRGBO(237, 53, 86, 1)))
                              .tr(namedArgs: {
                            'number': availableQuantity.toString()
                          })
                        ]))
                  ])
                : Container(width: 0.0, height: 0.0),
            maximumQuantity
                ? SizedBox(height: 10)
                : Container(width: 0.0, height: 0.0),
            minimumQuantity
                ? Row(children: <Widget>[
                    Icon(Icons.error_rounded,
                        color: Color.fromRGBO(237, 53, 86, 1)),
                    SizedBox(width: 5),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Text("Product.Remove",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          color:
                                              Color.fromRGBO(237, 53, 86, 1)))
                              .tr(),
                        ]))
                  ])
                : Container(width: 0.0, height: 0.0),
            minimumQuantity
                ? SizedBox(height: 10)
                : Container(width: 0.0, height: 0.0)
          ],
        ));
  }
}
