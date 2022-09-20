import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MerchantOutletAmenities extends StatelessWidget {
  MerchantOutletAmenities(this.amenitiesList);

  final List amenitiesList;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "ViewMerchantOutlet.Amenities",
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: Colors.black),
      ).tr(),
      SizedBox(
        height: 5,
      ),
      Wrap(
          spacing: 5,
          children: List.generate(
              amenitiesList.length,
              (index) => Chip(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  backgroundColor: Colors.grey[200],
                  label: Text(amenitiesList[index].toString(),
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          )))))
    ]));
  }
}
