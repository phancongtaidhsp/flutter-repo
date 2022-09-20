import 'package:flutter/material.dart';
import 'package:gem_consumer_app/models/Outlet.dart';

class OutletInfo extends StatelessWidget {
  const OutletInfo({Key? key, required this.outletData, required this.outlet})
      : super(key: key);
  final Outlet outletData;
  final Map<String, dynamic> outlet;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(outletData.name!,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(color: Colors.black)),
            SizedBox(height: 16.0),
            Row(children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  outlet['priceRange'] != null
                      ? _buildPriceIndicator(context, outlet['priceRange'])
                      : Container(width: 0.0, height: 0.0),
                  Text(outlet['priceRange'] != null ? " • " : "",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 12)),
                  Icon(
                    Icons.people,
                    size: 12.0,
                  ),
                  outlet['maxPax'] == null
                      ? const SizedBox(
                          width: 0,
                        )
                      : Text(" ${outlet['maxPax'].toString()} pax",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w400))
                ],
              ),
              // Text(" • ${distance.toStringAsFixed(1)} km",
              //     style: Theme.of(context)
              //         .textTheme
              //         .subtitle2!
              //         .copyWith(
              //             fontSize: 12, fontWeight: FontWeight.w400))
            ]),
            SizedBox(height: 4.0),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceIndicator(BuildContext context, String priceIndicator) {
    List<Widget> widgets = [];
    String priceStr = "";
    String greyPriceStr = "";
    int price =
        priceIndicator != null ? int.parse(priceIndicator.toString()) : 0;

    for (int i = 0; i < price; i++) {
      priceStr += "\$";
    }
    if (priceStr != "") {
      widgets.add(Text(priceStr,
          style:
              Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 12)));
    }
    if (priceStr.length < 4) {
      for (int j = 0; j < 4 - priceStr.length; j++) {
        greyPriceStr += "\$";
      }
      if (greyPriceStr != "") {
        widgets.add(Text(greyPriceStr,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontSize: 12, color: Colors.grey)));
      }
    }

    return Row(children: widgets);
  }
}
