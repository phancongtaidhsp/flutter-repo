import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PriceIndicatorSelection extends StatefulWidget {
  PriceIndicatorSelection(this.tempPriceIndicatorList);
  final List<int> tempPriceIndicatorList;

  @override
  _PriceIndicatorSelectionState createState() =>
      _PriceIndicatorSelectionState();
}

class _PriceIndicatorSelectionState extends State<PriceIndicatorSelection> {
  List<int> priceIndicatorList = [1, 2, 3, 4];
  String priceSymbol = '\$';

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Search.Price",
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontWeight: FontWeight.w700))
                .tr(),
            SizedBox(
              height: 10,
            ),
            Wrap(
                spacing: 7,
                direction: Axis.horizontal,
                children: List.generate(
                    priceIndicatorList.length,
                    (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              if (widget.tempPriceIndicatorList.contains(
                                  priceIndicatorList.elementAt(index))) {
                                widget.tempPriceIndicatorList.remove(
                                    priceIndicatorList.elementAt(index));
                              } else {
                                widget.tempPriceIndicatorList
                                    .add(priceIndicatorList.elementAt(index));
                              }
                            });
                          },
                          child: Chip(
                            backgroundColor: widget.tempPriceIndicatorList
                                    .contains(
                                        priceIndicatorList.elementAt(index))
                                ? Color.fromRGBO(253, 196, 0, 1)
                                : Colors.grey[200],
                            label: Container(
                                width: 50,
                                height: 30,
                                child: Center(
                                    child: Text(
                                  priceSymbol *
                                      priceIndicatorList.elementAt(index),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(fontWeight: FontWeight.normal),
                                ))),
                          ),
                        ))),
          ],
        ));
  }
}
