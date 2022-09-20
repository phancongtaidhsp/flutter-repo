import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class SelectedOutletWidget extends StatefulWidget {
  SelectedOutletWidget(this.outletDataMap);
  final Map outletDataMap;
  @override
  _SelectedOutletWidgetState createState() => _SelectedOutletWidgetState();
}

class _SelectedOutletWidgetState extends State<SelectedOutletWidget> {
  @override
  Widget build(BuildContext context) {
    print('selected-outlet-widget');
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth,
                          height: constraints.maxWidth * 0.4,
                          child: widget.outletDataMap['thumbNail'] == null ||
                                  widget.outletDataMap['thumbNail'] == ''
                              ? DefaultImageHelper.defaultImageWithSize(
                                  constraints.maxWidth,
                                  constraints.maxWidth * 0.4,
                                )
                              : CachedImage(
                                  imageUrl: widget.outletDataMap['thumbNail'],
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth * 0.4,
                                ),
                        );
                      }),
                    ],
                  ))),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.outletDataMap['name'],
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ],
          ),
          widget.outletDataMap['amenities'] == null ||
                  widget.outletDataMap['amenities'].length == 0
              ? Container(width: 0.0, height: 0.0)
              : Text(_buildAmenityList(widget.outletDataMap['amenities']),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.grey[400],
                      )),
          SizedBox(height: 4.0),
          Row(children: [
            _buildPriceIndicator(context, widget.outletDataMap['priceRange']),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(" •  ",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 12)),
                Icon(
                  Icons.people,
                  size: 12.0,
                ),
                Text(" ${widget.outletDataMap['maxPax'].toString()} pax ",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w400))
              ],
            ),
            // locationListWithDistance[index]
            //             ['distance'] !=
            //         null
            //     ? Text(
            //         " •  ${locationListWithDistance[index]['distance'].toStringAsFixed(1)} km",
            //         style: Theme.of(context)
            //             .textTheme
            //             .subtitle2
            //             .copyWith(
            //                 fontSize: 12,
            //                 fontWeight:
            //                     FontWeight
            //                         .w400))
            //     : Container(width: 0, height: 0)
          ]),
          SizedBox(height: 20.0),
        ]);
  }

  String _buildAmenityList(List<dynamic> amenities) {
    String amenityStr = "";
    for (var i = 0; i < amenities.length; i++) {
      if (i != amenities.length - 1) {
        amenityStr += amenities[i]['amenity']['name'] + " • ";
      } else {
        amenityStr += amenities[i]['amenity']['name'];
      }
    }
    return amenityStr;
  }

  Widget _buildPriceIndicator(BuildContext context, String priceIndicator) {
    List<Widget> widgets = [];
    String priceStr = "";
    String greyPriceStr = "";
    int price = int.tryParse(priceIndicator.toString()) ?? 0;

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
