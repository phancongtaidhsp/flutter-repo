import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/pop-up-dialog-add-to-basket-widget.dart';
import 'package:gem_consumer_app/screens/home/home.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_landing_page.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_product_list_page.dart';
import 'package:provider/provider.dart';

class EventInfoAppBar extends StatefulWidget {
  const EventInfoAppBar({@required this.cancel, @required this.routeName});
  final Function? cancel;
  final String? routeName;

  @override
  _EventInfoAppBarState createState() => _EventInfoAppBarState();
}

class _EventInfoAppBarState extends State<EventInfoAppBar> {
  String eventCriteriaStr = "";
  Map<String, dynamic>? selectedEventCriteria;
  late PlanAParty party;
  final dateFormat = DateFormat('dd MMM yyyy');
  String convertTimeTemp(TimeOfDay timeOfDay) {
    final now = new DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  void initState() {
    // party = context.read<PlanAParty>();
    // eventCriteriaStr = party.pax != null
    //     ? "${dateFormat.format(party.date!)} • ${party.time} • ${party.pax} pax"
    //     : "${dateFormat.format(party.date!)} • ${party.time}";
    party = context.read<PlanAParty>();
    var date = DateTime(DateTime.now().year, DateTime.now().month, 31,
        DateTime.now().hour, DateTime.now().minute);
    if (party.date == null) {
      // const TimeOfDay dateTime = TimeOfDay(hour: 15, minute: 0); // 3:00pm

      eventCriteriaStr = party.pax != null
          ? "${dateFormat.format(date)} • ${'00:00'} • ${party.pax} pax"
          : "${dateFormat.format(date)} • ${'00:00'}";
    } else {
      eventCriteriaStr = party.pax != null
          ? "${dateFormat.format(party.date!)} • ${party.time} • ${party.pax} pax"
          : "${dateFormat.format(party.date!)} • ${party.time}";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 36.0,
                width: 36.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset: Offset(0, 1.5))
                    ]),
                child: IconButton(
                    icon: SvgPicture.asset('assets/images/icon-back.svg'),
                    iconSize: 36.0,
                    onPressed: () {
                      if (party.planCurrentStep! == 0) {
                        if (widget.routeName ==
                            PlanAPartyProductListPage.routeName) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                                context, Home.routeName, (route) => false);
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.all(10),
                                  child: PopUpDialogAddToBasketWidget(
                                      title: "PlanAParty.ExitPlanAPartyTitle",
                                      content:
                                          "PlanAParty.ExitPlanAPartyContent",
                                      continueFunction: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            Home.routeName,
                                            (route) => false);
                                      })));
                        }
                      } else if (party.planCurrentStep! > 0) {
                        if (party.demands![party.planCurrentStep!] == "F&B") {
                          if (widget.routeName ==
                              PlanAPartyLandingPage.routeName) {
                            Navigator.popUntil(
                                context,
                                ModalRoute.withName(
                                    PlanAPartyLandingPage.routeName));
                          } else {
                            Navigator.pop(context);
                          }

                          print("F&B back");
                        } else if (party.demands![party.planCurrentStep!] ==
                            "DECORATION") {
                          if (widget.routeName ==
                              PlanAPartyLandingPage.routeName) {
                            Navigator.popUntil(
                                context,
                                ModalRoute.withName(
                                    PlanAPartyLandingPage.routeName));
                          } else {
                            Navigator.pop(context);
                          }
                        }
                        if (widget.routeName ==
                            PlanAPartyLandingPage.routeName) {
                          party.setCurrentStep(party.planCurrentStep! - 1);
                        }
                      }
                    })),
            Flexible(
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(23.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 0.5,
                                blurRadius: 3,
                                offset: Offset(0, 2))
                          ]),
                      child: Stack(children: [
                        Center(
                          child: buildAppBar(),
                        ),
                      ]),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 6.0),
        child: Column(children: <Widget>[
          Text(party.name ?? 'NONAME',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w700, color: Colors.black)),
          Text(
            eventCriteriaStr,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          )
        ]));
  }
}
