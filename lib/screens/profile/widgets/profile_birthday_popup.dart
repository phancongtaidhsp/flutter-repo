import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/screens/party/widgets/chip-form.dart';
import 'package:gem_consumer_app/screens/profile/gql/profile.gql.dart';
import 'package:gem_consumer_app/screens/profile/profile_page.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class ProfileBirthdayPopUp extends StatefulWidget {
  @override
  _ProfileBirthdayPopUpState createState() => _ProfileBirthdayPopUpState();
}

class _ProfileBirthdayPopUpState extends State<ProfileBirthdayPopUp> {
  DateTime? _dateSelected;
  bool isDateSelected = false;
  static late Auth auth;

  Future<void> _showIOSDateTimePicker(BuildContext ctx,
      {required bool timeOnly}) async {
    await showIOSDatePicker(
      context: context,
      timeOnly: timeOnly,
      initialDateTime: _dateSelected == null ? DateTime.now() : _dateSelected!,
      minimumDate: DateTime(1900),
      maximumDate: DateTime.now(),
      onDateTimeChanged: (val) {
        if (!timeOnly) {
          setState(() {
            _dateSelected = val;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    auth = context.read<Auth>();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(16), topLeft: Radius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                            Navigator.pop(context);
                          })),
                  Spacer(),
                  Mutation(
                      options: MutationOptions(
                        document: gql(ProfileGQL.UPDATE_USER_INFO),
                        onCompleted: (dynamic resultData) {
                          Navigator.pop(context, true);
                          Navigator.pushNamed(context, ProfilePage.routeName);
                        },
                        onError: (dynamic resultData) {
                          print(resultData);
                        },
                      ),
                      builder: (
                        RunMutation runMutation,
                        QueryResult? result,
                      ) {
                        return SubmitButton(
                          text: 'Button.Next'.tr(),
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                          rippleColor: Colors.grey,
                          width: 100,
                          height: 40,
                          textSize: 12,
                          verticalTextPadding: 14,
                          isUppercase: true,
                          onPressed: () {
                            if (_dateSelected != null) {
                              String date =
                                  _dateSelected!.toUtc().toIso8601String();

                              setState(() {
                                isDateSelected = false;
                              });

                              runMutation({
                                "updateProfile": {
                                  "userId": auth.currentUser.id,
                                  "dateOfBirth": date,
                                }
                              });
                            } else {
                              setState(() {
                                isDateSelected = true;
                              });
                            }
                          },
                        );
                      }),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Profile.WhenIsYourBirthday'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 24,
              ),
              InkWell(
                  onTap: () async {
                    if (Platform.isAndroid) {
                      showDatePicker(
                          context: context,
                          initialDate: _dateSelected == null
                              ? DateTime.now()
                              : _dateSelected!,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark(),
                              child: child ??
                                  SizedBox(
                                    width: 0,
                                  ),
                            );
                          }).then((value) {
                        setState(() {
                          _dateSelected = value;
                        });
                      });
                    } else {
                      await _showIOSDateTimePicker(context, timeOnly: false);
                    }
                  },
                  child: ChipForm(
                      text: _dateSelected != null
                          ? DateFormat('dd MMM, yyyy').format(_dateSelected!)
                          : 'PlanAParty.HintDatePicker'.tr())),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 4),
                child: Visibility(
                  visible: isDateSelected,
                  child: Text(
                    'Validation.Required',
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.normal),
                  ).tr(),
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
