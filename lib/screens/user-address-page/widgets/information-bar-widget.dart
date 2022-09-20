import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/screens/user-address-page/reselect-address-page.dart';

class InformationBarWidget extends StatelessWidget {
  InformationBarWidget(this.userSelectedAddress);
  final UserAddress userSelectedAddress;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
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
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: SvgPicture.asset("assets/images/location.svg")),
              SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("UserAddressPage.Address",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.button!.copyWith(
                              fontSize: 12, fontWeight: FontWeight.bold))
                      .tr(),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.48,
                      child: Text(
                        "${userSelectedAddress.address1}",
                        style: Theme.of(context).textTheme.bodyText1,
                      ))
                ],
              ),
              Spacer(),
              Center(
                child: IconButton(
                    icon: Icon(
                      Icons.mode_edit,
                      color: primaryColor,
                    ),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ReselectAddressPage(userSelectedAddress)));
                    }),
              ),
            ]));
  }
}
