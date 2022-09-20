import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';

class MerchantOutletDirections extends StatelessWidget {
  MerchantOutletDirections(this.directions, this.distance);
  final dynamic distance;
  final String directions;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("ViewMerchantOutlet.Directions",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Colors.black))
                  .tr(),
              Spacer(),
              Text(
                  distance is String
                      ? "- km • RM - • "
                      : "${StringHelper.formatCurrency(distance)} km",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontSize: 12))
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "$directions", //"${merchantData["address1"]}, ${merchantData["address2"]}, ${merchantData["state"]}, ${merchantData["postalCode"]}, ${merchantData["city"]}",
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
