import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-filter-widgets/pax-selection-controller-widget.dart';
import 'package:provider/provider.dart';

class PartyPaxSelectionWidget extends StatefulWidget {
  @override
  _PartyPaxSelectionWidgetState createState() =>
      _PartyPaxSelectionWidgetState();
}

class _PartyPaxSelectionWidgetState extends State<PartyPaxSelectionWidget> {
  late FilterProvider filterProvider;
  late PlanAParty event;
  late int tempPaxQuantity;

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    event = context.read<PlanAParty>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ElevatedButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0, 0), //(x,y)
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: PaxSelectionControllerWidget()),
                  ),
                ),
              ],
            ),
          );
        },
        child: Center(
            child: Row(
          children: [
            Text("Search.SelectPax",
                    style: TextStyle(
                      fontFamily: 'Arial Rounded MT Bold',
                      color: filterProvider.maxPax != event.pax
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
            primary: filterProvider.maxPax != event.pax
                ? Color.fromRGBO(0, 0, 0, 1)
                : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }
}
