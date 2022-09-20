import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PartyRoomAmenitiesWidget extends StatelessWidget {
  PartyRoomAmenitiesWidget(this.amenitiesList);
  final List<String> amenitiesList;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          width: size.width,
          padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PlanAParty.Amenities",
                style: Theme.of(context).textTheme.button,
              ).tr(),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width,
                  child: Wrap(
                      spacing: 7,
                      direction: Axis.horizontal,
                      children: List.generate(
                        amenitiesList.length,
                        (index) => Chip(
                          backgroundColor: Colors.grey[200],
                          label: Text(
                            amenitiesList.elementAt(index),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12),
                          ),
                        ),
                      )))
            ],
          ),
        ));
  }
}
