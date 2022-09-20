import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';

class PlanAPartyStepsWidget extends StatelessWidget {
  const PlanAPartyStepsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width / 3.5,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 4.0,
                      )
                    ]),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("PlanAParty.Step1",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.black))
                          .tr(),
                      SizedBox(height: 12.0),
                      SvgPicture.asset('assets/images/icon-space.svg')
                    ])),
            Container(
                width: MediaQuery.of(context).size.width / 3.5,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 4.0,
                      )
                    ]),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("PlanAParty.Step2",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: Colors.black))
                              .tr(),
                          SizedBox(height: 12.0),
                          SvgPicture.asset('assets/images/icon-food-service.svg')
                        ]))),
            Container(
                width: MediaQuery.of(context).size.width / 3.5,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 4.0,
                      )
                    ]),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("PlanAParty.Step3",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: Colors.black))
                              .tr(),
                          SizedBox(height: 12.0),
                          SvgPicture.asset('assets/images/icon-garlands.svg')
                        ]))),
          ]),
    );
  }
}
