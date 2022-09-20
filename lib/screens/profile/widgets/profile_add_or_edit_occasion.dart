import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth.dart';
import '../../../screens/party/widgets/chip-form.dart';
import '../../../screens/profile/gql/profile.gql.dart';
import '../../../screens/profile/widgets/profile_remove_confirm_popup.dart';
import '../../../values/color-helper.dart';
import '../../../widgets/dropdown/custom_dropdown.dart';
import '../../../widgets/submit-button.dart';

class ProfileAddOrEditOccasion extends StatefulWidget {
  static String routeName = '/add-or-edit-occasion';

  final Map<String, dynamic>? data;

  const ProfileAddOrEditOccasion({this.data});

  @override
  _ProfileAddOrEditOccasionState createState() =>
      _ProfileAddOrEditOccasionState();
}

class _ProfileAddOrEditOccasionState extends State<ProfileAddOrEditOccasion> {
  TextEditingController _controller = TextEditingController();
  DateTime? _dateSelected;
  bool _isBackPressedOrTouchedOutSide = false, _isDropDownOpened = false;
  bool isDateSelected = false;
  String reminderSelected = 'Profile.1DayBefore'.tr();
  List<String> listReminder = [
    'Profile.1DayBefore'.tr(),
    'Profile.1WeekBefore'.tr(),
    'Profile.1MonthBefore'.tr()
  ];
  Map<String, dynamic>? userData;
  static late Auth auth;
  final _formKey = GlobalKey<FormState>();

  Future<void> _showIOSDateTimePicker(BuildContext ctx,
      {required bool timeOnly}) async {
    await showIOSDatePicker(
      context: ctx,
      timeOnly: timeOnly,
      minimumYear: DateTime.now().year,
      minimumDate: DateTime.now(),
      initialDateTime: _dateSelected == null ? DateTime.now() : _dateSelected!,
      maximumDate: DateTime(2100),
      // maximumDate:
      //     DateTime.now().add(const Duration(days: 60)),
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
    userData = widget.data;
    if (userData != null) {
      var formatString = "yyyy-MM-ddTHH:mm:ss.mmmZ";
      _dateSelected =
          new DateFormat(formatString).parse(userData!['date'], true).toLocal();
      _controller.text = userData!['name'];

      if (userData!['reminderInterval'] != null) {
        reminderSelected =
            listReminder[convertReminderTime(userData!['reminderInterval'])];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: _removeFocus,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size(size.width, 60),
          child: _buildAppBar(),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                'Profile.AddASpecialOccasion'.tr(),
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[900]),
              ),
              SizedBox(
                height: 20,
              ),
              _buildTextFieldNameSpecialDay(),
              SizedBox(
                height: 20,
              ),
              _buildDatePicker(),
              SizedBox(
                height: 2,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
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
                height: 30,
              ),
              Text(
                'Profile.Reminder'.tr(),
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[900]),
              ),
              AwesomeDropDown(
                dropDownList: listReminder,
                numOfListItemToShow: listReminder.length,
                isBackPressedOrTouchedOutSide: _isBackPressedOrTouchedOutSide,
                elevation: 2,
                selectedItem: reminderSelected,
                onDropDownItemClick: (selectedItem) {
                  reminderSelected = selectedItem;
                },
                dropStateChanged: (isOpened) {
                  _isDropDownOpened = isOpened;
                  if (!isOpened) {
                    _isBackPressedOrTouchedOutSide = false;
                  }
                },
                dropDownListTextStyle: TextStyle(
                  fontFamily: 'Arial Rounded MT Bold',
                  color: grayTextColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                selectedItemTextStyle: TextStyle(
                  fontFamily: 'Arial Rounded MT Bold',
                  color: grayTextColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                dropDownBGColor: lightPrimaryColor,
                dropDownIcon: SvgPicture.asset(
                  'assets/images/dropdown-button.svg',
                  color: grayTextColor,
                  width: 8,
                  height: 8,
                ),
              ),
              Spacer(),
              userData == null
                  ? Mutation(
                      options: MutationOptions(
                        document: gql(ProfileGQL.ADD_SPECIAL_DAY),
                        onCompleted: (dynamic resultData) {
                          Navigator.pop(context, true);
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
                          text: 'Button.Add',
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                          isUppercase: true,
                          onPressed: () {
                            _removeFocus();
                            _formKey.currentState!.validate();

                            if (_dateSelected == null) {
                              setState(() {
                                isDateSelected = true;
                              });
                            } else {
                              setState(() {
                                isDateSelected = false;
                              });

                              if (_formKey.currentState!.validate()) {
                                String date =
                                    _dateSelected!.toUtc().toIso8601String();
                                runMutation({
                                  "createSpecialDay": {
                                    "userId": auth.currentUser.id,
                                    "name": _controller.text,
                                    "date": date,
                                    "reminderInterval": getDayFromReminderTime(
                                        reminderSelected),
                                    "reminderIntervalUnit": "DAY"
                                  }
                                });
                              }
                            }
                          },
                        );
                      })
                  : _buildBottomEditOccasion(),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getDayFromReminderTime(String reminderTime) {
    int index = listReminder.indexOf(reminderTime);
    switch (index) {
      case 2:
        return 30;
      case 1:
        return 7;
      default:
        return 1;
    }
  }

  int convertReminderTime(int reminderInterval) {
    switch (reminderInterval) {
      case 30:
        return 2;
      case 7:
        return 1;
      default:
        return 0;
    }
  }

  void _removeFocus() {
    if (_isDropDownOpened) {
      setState(() {
        _isBackPressedOrTouchedOutSide = true;
      });
    }
  }

  Widget _buildBottomEditOccasion() {
    return Column(
      children: [
        Mutation(
            options: MutationOptions(
              document: gql(ProfileGQL.ADD_SPECIAL_DAY),
              onCompleted: (dynamic resultData) {
                Navigator.pop(context, true);
              },
              onError: (dynamic resultData) {
                print(resultData);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return SubmitButton(
                text: 'Button.Update'.tr(),
                backgroundColor: Colors.black,
                rippleColor: Colors.white,
                isUppercase: true,
                onPressed: () {
                  _removeFocus();
                  _formKey.currentState!.validate();

                  if (_dateSelected == null) {
                    setState(() {
                      isDateSelected = true;
                    });
                  } else {
                    setState(() {
                      isDateSelected = false;

                      if (_formKey.currentState!.validate()) {
                        String date = _dateSelected!.toUtc().toIso8601String();
                        runMutation({
                          "createSpecialDay": {
                            "id": userData!['id'],
                            "userId": auth.currentUser.id,
                            "name": _controller.text,
                            "date": date,
                            "reminderInterval":
                                getDayFromReminderTime(reminderSelected),
                            "reminderIntervalUnit": "DAY"
                          }
                        });
                      }
                    });
                  }
                },
              );
            }),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: () {
              showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) => Dialog(
                  child: ProfileRemoveConfirmPopUp(userData!),
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(24),
                ),
              ).then((value) {
                if (value != null && value) {
                  Navigator.pop(context, true);
                }
              });
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Center(
                  child: Text("Button.Remove".tr().toUpperCase(),
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
          height: 20,
        )
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
        onTap: () {
          _removeFocus();
          if (Platform.isAndroid) {
            showDatePicker(
                context: context,
                initialDate:
                    _dateSelected == null ? DateTime.now() : _dateSelected!,
                firstDate: DateTime.now().subtract(Duration(seconds: 30)),
                lastDate: DateTime(2100),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.dark(),
                    child: child ??
                        SizedBox(
                          width: 0,
                        ),
                  );
                }).then((DateTime? value) {
              if (value != null) {
                setState(() {
                  _dateSelected = value;
                });
              }
            });
          } else {
            _showIOSDateTimePicker(context, timeOnly: false);
          }
        },
        child: ChipForm(
            text: _dateSelected != null
                ? DateFormat('dd MMM, yyyy').format(_dateSelected!)
                : 'PlanAParty.HintDatePicker'.tr()));
  }

  Widget _buildTextFieldNameSpecialDay() {
    return Form(
      key: _formKey,
      child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          controller: _controller,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Validation.Required'.tr();
            }
            return null;
          },
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            errorStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: Colors.red, fontSize: 10, fontWeight: FontWeight.normal),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(23.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(23.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(23.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            labelText: tr('Profile.NameSpecialDay'),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: Theme.of(context).textTheme.bodyText1,
            suffixIconConstraints: BoxConstraints(
              minWidth: 31,
              minHeight: 31,
            ),
          ),
          keyboardType: TextInputType.text),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.grey[200],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: 36,
              height: 36,
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
                    _removeFocus();
                    Navigator.pop(context);
                  })),
          Text(
            'Profile.SpecialOccasions'.tr(),
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          Container(
            width: 36,
            height: 36,
          )
        ],
      ),
    );
  }
}
