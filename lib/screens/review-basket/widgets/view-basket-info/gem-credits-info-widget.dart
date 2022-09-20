import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class GemCreditsInfoWidget extends StatelessWidget {
  const GemCreditsInfoWidget({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            "Basket.GemCredits",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline3!.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ).tr(),
          SizedBox(
            height: 4,
          ),
          Text("Basket.GemCreditsRefund",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyText1)
              .tr(),
          SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Text(
                "RM 0.00",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline3!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
