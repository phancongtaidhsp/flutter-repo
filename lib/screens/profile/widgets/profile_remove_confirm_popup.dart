import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/screens/profile/gql/profile.gql.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileRemoveConfirmPopUp extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileRemoveConfirmPopUp(this.userData);

  @override
  Widget build(BuildContext context) {
    String date = '. . .';

    if (userData != null) {
      var formatString = "yyyy-MM-ddThh:mm:ssZ";
      if (userData['date'] != null) {
        DateTime format1 = new DateFormat(formatString).parse(userData['date']);
        date = DateFormat("EEEE, dd MMM yyyy").format(format1);
      }
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                    height: 36.0,
                    width: 36.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1.75,
                              blurRadius: 1,
                              offset: Offset(0, 1)),
                        ]),
                    child: IconButton(
                        icon: SvgPicture.asset('assets/images/icon-close.svg'),
                        iconSize: 36.0,
                        onPressed: () {
                          Navigator.pop(context);
                        })),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Profile.RemoveConfirm'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.w400),
              ),
              SvgPicture.asset(
                'assets/images/logo_clean.svg',
                width: 140,
                height: 140,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.headline3!.copyWith(
                    fontWeight: FontWeight.w400, color: Colors.grey[600]),
              ),
              Text(
                userData['name'],
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontWeight: FontWeight.w400, fontSize: 12),
              ),
              SizedBox(
                height: 40,
              ),
              Mutation(
                  options: MutationOptions(
                    document: gql(ProfileGQL.DELETE_SPECIAL_DAY),
                    onCompleted: (dynamic resultData) {
                      Navigator.pop(context, true);
                    },
                    onError: (dynamic resultData) {
                      print(resultData);
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult? result) {
                    return SubmitButton(
                      text: 'Button.Yes'.tr(),
                      backgroundColor: Colors.black,
                      rippleColor: Colors.white,
                      isUppercase: true,
                      onPressed: () {
                        runMutation({
                          "id": userData['id'],
                        });
                      },
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Center(
                        child: Text("Button.No".tr().toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Arial Rounded MT Bold',
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center),
                      )),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)))),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
