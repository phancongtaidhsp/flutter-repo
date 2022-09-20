import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:provider/provider.dart';

class RecommendedButtonWidget extends StatefulWidget {
  @override
  _RecommendedButtonWidgetState createState() =>
      _RecommendedButtonWidgetState();
}

class _RecommendedButtonWidgetState extends State<RecommendedButtonWidget> {
  late FilterProvider filterProvider;

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if (filterProvider.isRecommended() == false) {
            filterProvider.recommended = true;
          } else {
            filterProvider.recommended = false;
          }
        },
        child: Center(
            child: Row(
          children: [
            Text("Search.Recommended",
                    style: TextStyle(
                      fontFamily: 'Arial Rounded MT Bold',
                      color: filterProvider.isRecommended() == true
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center)
                .tr(),
          ],
        )),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            primary: filterProvider.isRecommended() == true
                ? Color.fromRGBO(0, 0, 0, 1)
                : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }
}
