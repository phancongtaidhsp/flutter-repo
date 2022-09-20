import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MerchantOutletDescriptions extends StatelessWidget {
  MerchantOutletDescriptions(this.description);
  final String description;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ViewMerchantOutlet.Description",
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: Colors.black),
          ).tr(),
          SizedBox(
            height: 10,
          ),
          Container(
            width: size.width * 0.866,
            child:
                Text(description, style: Theme.of(context).textTheme.bodyText1),
          ),
        ],
      ),
    );
  }
}
