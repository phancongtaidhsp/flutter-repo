import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/UI/Buttons/primary_button.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_landing_page.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_product_list_page.dart';
import 'package:gem_consumer_app/screens/party/widgets/chip-form.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:provider/provider.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class PopUpDateTime extends StatefulWidget {
  @override
  _PopUpDateTimeState createState() => _PopUpDateTimeState();
}

class _PopUpDateTimeState extends State<PopUpDateTime> {
  late PlanAParty party;
  // DateTime? _dateSelected;
  // TimeOfDay? _timeSelected;
  DateTime? _dateSelected;

  TimeOfDay? _timeSelected;

  bool isNumberOfPAXInvalid = false;
  int numberOfPAX = 0;
  bool isTouchedDate = false;
  bool isTouchedTime = false;
  TextEditingController _controller = TextEditingController();

  /*
          : CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now().add(Duration(minutes: 1)),
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime.now().add(const Duration(days: 60)), */
  Future<void> _showIOSDateTimePicker(BuildContext ctx,
      {required bool timeOnly}) async {
    DateTime? privateDate = DateTime.now();
    if (timeOnly) {
      final now = DateTime.now();
      if (_timeSelected == null) {
        privateDate = DateTime.now();
      } else {
        privateDate = DateTime(now.year, now.month, now.day,
            _timeSelected!.hour, _timeSelected!.minute);
      }
    } else {
      privateDate = _dateSelected;
    }
    await showIOSDatePicker(
        timeOnly: timeOnly,
        context: ctx,
        minimumYear: DateTime.now().year,
        // initialDateTime: DateTime.now().add(Duration(minutes: 1)),
        initialDateTime: privateDate == null ? DateTime.now() : privateDate,
        minimumDate: DateTime.now(),
        maximumDate: DateTime.now().add(const Duration(days: 60)),
        onDateTimeChanged: (val) {
          if (!timeOnly) {
            setState(() {
              _dateSelected = val;
            });
          } else {
            setState(() {
              _timeSelected = TimeOfDay.fromDateTime(val);
              print(_timeSelected);
            });
          }
        });
  }

  @override
  void initState() {
    party = context.read<PlanAParty>();
    _controller.text = "0";
    if (party.name != null && party.date != null && party.time != null) {
      _timeSelected = party.timeOfDay;
      _dateSelected = party.date!;
      _controller.text = party.pax.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16), topLeft: Radius.circular(16))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  party.name != null
                      ? Text(
                          party.name!,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w700),
                        )
                      : Container(width: 0, height: 0),
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
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1)),
                          ]),
                      child: IconButton(
                          icon:
                              SvgPicture.asset('assets/images/icon-close.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            Navigator.pop(context);
                          }))
                ],
              ),
              SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PlanAParty.Date'.tr(),
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 20,
                              fontFamily: 'Arial Rounded MT Bold',
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                            onTap: () async {
                              if (Platform.isAndroid) {
                                showDatePicker(
                                    context: context,
                                    initialDate: _dateSelected == null
                                        ? DateTime.now()
                                        : _dateSelected!,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 60)),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child ??
                                            SizedBox(
                                              width: 0,
                                            ),
                                      );
                                    }).then((value) {
                                  setState(() {
                                    _dateSelected = value!;
                                  });
                                });
                              }
                              //return;
                              if (Platform.isIOS) {
                                await _showIOSDateTimePicker(context,
                                    timeOnly: false);

                                //showDialog(context: context, builder: builder)

                              }
                            },
                            child: ChipForm(
                                text: _dateSelected != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_dateSelected!)
                                    : 'PlanAParty.HintDatePicker'.tr())),
                        SizedBox(height: 4),
                        isTouchedDate && (_dateSelected == null)
                            ? Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Validation.Required',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontFamily: 'Arial Rounded MT Bold'),
                                ).tr(),
                              )
                            : Container(width: 0.0, height: 0.0),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PlanAParty.Time'.tr(),
                          style: TextStyle(
                              color: grayTextColor,
                              fontSize: 20,
                              fontFamily: 'Arial Rounded MT Bold',
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                            onTap: () async {
                              if (Platform.isAndroid) {
                                showTimePicker(
                                    context: context,
                                    initialTime: _timeSelected != null
                                        ? _timeSelected!
                                        : TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child ??
                                            SizedBox(
                                              width: 0,
                                            ),
                                      );
                                    }).then((value) {
                                  setState(() {
                                    _timeSelected = value;
                                  });
                                });
                              } else {
                                await _showIOSDateTimePicker(context,
                                    timeOnly: true);
                              }
                            },
                            child: ChipForm(
                                text: _timeSelected != null
                                    ? convertTime(_timeSelected!)
                                    : 'PlanAParty.HintTimePicker'.tr())),
                        SizedBox(height: 4),
                        isTouchedTime && _timeSelected == null
                            ? Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Validation.Required',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontFamily: 'Arial Rounded MT Bold'),
                                ).tr(),
                              )
                            : Container(width: 0.0, height: 0.0),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              party.demands!.contains("VENUE")
                  ? Text(
                      'PlanAParty.NumberPAX'.tr(),
                      style: TextStyle(
                          color: Colors.grey[900],
                          fontSize: 20,
                          fontFamily: 'Arial Rounded MT Bold',
                          fontWeight: FontWeight.w400),
                    )
                  : Container(width: 0.0, height: 0.0),
              party.demands!.contains("VENUE")
                  ? SizedBox(height: 10)
                  : Container(width: 0.0, height: 0.0),
              party.demands!.contains("VENUE")
                  ? _buildNumberPAX(
                      controller: _controller,
                      minusFunction: () {
                        setState(() {
                          try {
                            numberOfPAX = int.parse(_controller.text);
                            if (_controller.text == "") {
                              numberOfPAX = 0;
                            }
                            numberOfPAX--;
                            if (numberOfPAX < 0) {
                              numberOfPAX = 0;
                            }
                            _controller.text = numberOfPAX.toString();
                            _controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: _controller.text.length));
                            isNumberOfPAXInvalid = false;
                          } catch (error) {
                            isNumberOfPAXInvalid = true;
                          }
                        });
                      },
                      plusFunction: () {
                        setState(() {
                          try {
                            numberOfPAX = int.parse(_controller.text);
                            if (_controller.text == "") {
                              numberOfPAX = 0;
                            }
                            numberOfPAX++;
                            _controller.text = numberOfPAX.toString();
                            _controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: _controller.text.length));
                            isNumberOfPAXInvalid = false;
                          } catch (error) {
                            isNumberOfPAXInvalid = true;
                          }
                        });
                      })
                  : Container(width: 0.0, height: 0.0),
              SizedBox(height: 6),
              isNumberOfPAXInvalid
                  ? Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Validation.InvalidNumber',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Arial Rounded MT Bold'),
                      ).tr(),
                    )
                  : Container(width: 0.0, height: 0.0),
              SizedBox(height: 30),
              SubmitButton(
                text: party.demands!.contains("VENUE")
                    ? 'PlanAParty.ExploreVenue'
                    : 'PlanAParty.ExploreMerchant',
                isUppercase: true,
                rippleColor: Colors.white,
                textColor: Colors.white,
                backgroundColor: Colors.black,
                onPressed: () {
                  if (_timeSelected == null) {
                    isTouchedTime = true;
                  }

                  if (_dateSelected == null) {
                    isTouchedDate = true;
                  }

                  if (party.demands!.contains("VENUE")) {
                    if (_controller.text.isNotEmpty) {
                      numberOfPAX = int.parse(_controller.text);
                      isNumberOfPAXInvalid = !(numberOfPAX > 0);
                    } else {
                      isNumberOfPAXInvalid = true;
                    }
                  }

                  setState(() {
                    if ((party.demands!.contains("VENUE")
                            ? !isNumberOfPAXInvalid
                            : true) &&
                        _dateSelected != null &&
                        _timeSelected != null) {
                      party.setEventDate(_dateSelected!);
                      party.setEventTime(_timeSelected!);
                      if (party.demands!.contains("VENUE")) {
                        party.setEventPax(numberOfPAX);
                        party.setEventCollectionType("DINE_IN");
                      }
                      if (party.featuredVenueOutletId != null) {
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            PlanAPartyProductListPage.routeName,
                            ModalRoute.withName('/home'),
                            arguments: PlanAPartyProductListPageArguments(
                                party.featuredVenueOutletId!));
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          PlanAPartyLandingPage.routeName,
                          ModalRoute.withName('/home'),
                        );
                      }
                    } else {
                      print('invalid');
                    }
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPAX(
      {required TextEditingController controller,
      required Function minusFunction,
      required Function plusFunction}) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23.0), color: lightPrimaryColor),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: Material(
              shape: CircleBorder(),
              color: Colors.white,
              child: InkWell(
                onTap: () => minusFunction(),
                customBorder: CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: SvgPicture.asset(
                    'assets/images/minus.svg',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grayTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arial Rounded MT Bold',
              ),
              onTap: () {
                controller.clear();
              },
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
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
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Material(
              shape: CircleBorder(),
              color: Colors.white,
              child: InkWell(
                onTap: () => plusFunction(),
                customBorder: CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      'assets/images/plus.svg',
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String convertTime(TimeOfDay timeOfDay) {
    final now = new DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }
}
