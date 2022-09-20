import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:provider/provider.dart';

class FilterButtonWidget extends StatefulWidget {
  FilterButtonWidget({required this.function});
  final Function function;

  @override
  _FilterButtonWidgetState createState() => _FilterButtonWidgetState();
}

class _FilterButtonWidgetState extends State<FilterButtonWidget> {
  late FilterProvider advancedFilterProvider;

  @override
  void initState() {
    advancedFilterProvider = context.read<FilterProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => widget.function(),
        child: Center(
          child: Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20,
                color: advancedFilterProvider.isAnyAdvancedFilterSelected()
                    ? Colors.white
                    : Colors.black,
              ),
              SizedBox(width: 4),
              Text("Search.Filter",
                      style: TextStyle(
                        fontFamily: 'Arial Rounded MT Bold',
                        color:
                            advancedFilterProvider.isAnyAdvancedFilterSelected()
                                ? Colors.white
                                : Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center)
                  .tr(),
            ],
          ),
        ),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            primary: advancedFilterProvider.isAnyAdvancedFilterSelected()
                ? Color.fromRGBO(0, 0, 0, 1)
                : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }
}
