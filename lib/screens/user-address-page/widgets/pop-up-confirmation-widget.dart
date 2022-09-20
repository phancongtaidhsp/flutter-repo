import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/screens/user-address-page/gql/address.gql.dart';
import 'package:gem_consumer_app/screens/user-address-page/user-address-home-page.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PopUpConfirmation extends StatelessWidget {
  PopUpConfirmation(this.addressId);

  final String addressId;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
        color: Colors.transparent,
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Text("UserAddressPage.DeleteAddress",
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .copyWith(fontWeight: FontWeight.normal))
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
            SizedBox(
              height: 25,
            ),
            Text(
              "UserAddressPage.ConfirmationDescription",
               style: textTheme.bodyText2!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
              textAlign: TextAlign.left,
            ).tr(),
            SizedBox(
              height: 24,
            ),
            Mutation(
                options: MutationOptions(
                  document: gql(AddressGQL.DELETE_USER_ADDRESS),
                  onCompleted: (dynamic resultData) {
                    Navigator.pushNamedAndRemoveUntil(
                        context,
                        UserAddressHomePage.routeName,
                        ModalRoute.withName('/home'));
                  },
                ),
                builder: (
                  RunMutation runMutation,
                  QueryResult? result,
                ) {
                  return SubmitButton(
                      text: "Button.Yes",
                      textColor: Colors.black,
                      backgroundColor: primaryColor,
                      onPressed: () {
                        runMutation({"id": "$addressId"});
                      });
                }),
            SizedBox(
              height: 5,
            ),
            SubmitButton(
                text: "Button.No",
                textColor: Colors.white,
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),
        ));
  }
}
