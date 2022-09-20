import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:provider/provider.dart';

class PaxSelectionControllerWidget extends StatefulWidget {
  @override
  _PaxSelectionControllerWidgetState createState() =>
      _PaxSelectionControllerWidgetState();
}

class _PaxSelectionControllerWidgetState
    extends State<PaxSelectionControllerWidget> {
  late FilterProvider filterProvider;
  late PlanAParty event;
  late int tempPaxQuantity;

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    event = context.read<PlanAParty>();
    tempPaxQuantity = filterProvider.maxPax;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Search.SelectPax",
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.w400))
                .tr(),
            Spacer(),
            Container(
              height: 36.0,
              width: 36.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 1)),
                  ]),
              child: IconButton(
                  icon: Icon(
                    Icons.close,
                  ),
                  iconSize: 18.0,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            )
          ],
        ),
        Container(
            height: 150,
            width: 355,
            child: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 36.0,
                      width: 36.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1)),
                          ]),
                      child: IconButton(
                          icon: SvgPicture.asset('assets/images/minus.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            if (tempPaxQuantity > 1) {
                              setState(() {
                                tempPaxQuantity--;
                              });
                            }
                          })),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    "${tempPaxQuantity.toString()}",
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Container(
                      height: 36.0,
                      width: 36.0,
                      decoration: BoxDecoration(
                          color: Colors.orange[300],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: Offset(0, 1)),
                          ]),
                      child: IconButton(
                          icon: SvgPicture.asset('assets/images/plus.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            setState(() {
                              tempPaxQuantity++;
                            });
                          })),
                ],
              ),
            )),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24.0),
                primary: Color.fromRGBO(0, 0, 0, 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0))),
            onPressed: () {
              filterProvider.maxPax = tempPaxQuantity;
              Navigator.pop(context);
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Button.Apply',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: Colors.white))
                      .tr()
                ]))
      ],
    );
  }
}
