import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-type-and-address.dart';
import 'package:gem_consumer_app/screens/user-address-page/widgets/pop-up-set-location-service.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-popup-date-time.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class PopUpNameAndDemand extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PopUpNameAndDemand();
}

class _PopUpNameAndDemand extends State<PopUpNameAndDemand> {
  late PlanAParty party;
  TextEditingController _nameEventController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<DemandCheckBox> demandCheckBoxList = [
    DemandCheckBox(
        title: 'PlanAParty.DemandVenue'.tr(), value: 'VENUE', checked: true),
    DemandCheckBox(
        title: 'PlanAParty.DemandF&B'.tr(), value: 'F&B', checked: true),
    DemandCheckBox(
        title: 'PlanAParty.DemandDecoration'.tr(),
        value: "DECORATION",
        checked: true)
  ];
  List<String> selectedDemandList = ["VENUE", "F&B", "DECORATION"];

  @override
  void initState() {
    party = context.read<PlanAParty>();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => party.setEventDemands(selectedDemandList));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    // Location location = new Location();
    // bool _serviceEnabled;
    // PermissionStatus _permissionGranted = PermissionStatus.denied;

    // checkPermissionGranted() async {
    //   _permissionGranted = await location.hasPermission().then((value) {
    //     if (value == PermissionStatus.granted) {
    //       print("Permission granted");
    //     } else if (value == PermissionStatus.denied) {
    //       print("Permission denied");
    //     } else if (value == PermissionStatus.deniedForever) {
    //       print("Permission deniedForever");
    //     } else if (value == PermissionStatus.grantedLimited) {
    //       print("Permission granted limited");
    //     }
    //     print("return Value  $value");
    //     return value;
    //   });
    //   setState(() {});
    // }

    // checkServiceEnabled() async {
    //   _serviceEnabled = await location.serviceEnabled();
    //   if (!_serviceEnabled) {
    //     _serviceEnabled = await location.requestService();
    //     if (!_serviceEnabled) {
    //       print("serviceEnabled");
    //       return;
    //     }
    //   }
    // }

    //checkServiceEnabled();
    //checkPermissionGranted();

    return Material(
      color: Colors.transparent,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      "PlanAParty.NameYourEvent".tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Arial Rounded MT Bold',
                          fontWeight: FontWeight.w400),
                    ),
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
                            icon: SvgPicture.asset(
                                'assets/images/icon-close.svg'),
                            iconSize: 36.0,
                            onPressed: () {
                              Navigator.pop(context);
                            }))
                  ],
                ),
                SizedBox(height: 15),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _nameEventController,
                  style: textTheme.button!.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 22),
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
                    labelText: 'PlanAParty.HintEventName'.tr(),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Validation.Required'.tr();
                    }
                    if (value.length < 5) {
                      return 'Validation.LimitCharacterRequired'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "PlanAParty.WhatYouNeed".tr(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Arial Rounded MT Bold',
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 10),
                party.featuredVenueOutletId != null
                    ? Text(
                        'Validation.VenueRequired',
                        style: TextStyle(color: Colors.red),
                      ).tr()
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                ...demandCheckBoxList
                    .map((item) => ListTile(
                          onTap: () => onDemandCheckBoxClick(item),
                          contentPadding: EdgeInsets.all(0),
                          visualDensity: VisualDensity(vertical: -4),
                          leading: Checkbox(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3)),
                            activeColor: lightPrimaryColor,
                            value: item.checked,
                            onChanged: (value) => onDemandCheckBoxClick(item),
                          ),
                          title: Transform.translate(
                            offset: Offset(-16, 0),
                            child: Text(
                              item.title,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Arial Rounded MT Bold',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                          ),
                        ))
                    .toList(),
                selectedDemandList.length == 0
                    ? Text(
                        'Validation.Required',
                        style: TextStyle(color: Colors.red),
                      ).tr()
                    : Container(width: 0.0, height: 0.0),
                SizedBox(height: 30),
                SubmitButton(
                  text: 'SignInWithMobile.Next',
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                  rippleColor: Colors.white,
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        selectedDemandList.length > 0) {
                      party.setEventName(_nameEventController.text);
                      party.setEventDemands(selectedDemandList);
                      party.arrangeDemandsOrder();
                      if (selectedDemandList.contains('VENUE')) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => Dialog(
                                  child: PopUpDateTime(),
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.all(24),
                                ));
                      } else {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => Dialog(
                                  child: PopUpTypeAndAddress(),
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.all(24),
                                ));
                      }
                    }
                    // checkPermissionGranted();

                    // if (_permissionGranted != PermissionStatus.granted) {
                    //   showDialog(
                    //     barrierDismissible: false,
                    //     context: context,
                    //     builder: (context) => Dialog(
                    //       child: PopUpSetLocationService(),
                    //       backgroundColor: Colors.transparent,
                    //       insetPadding: EdgeInsets.all(24),
                    //     ),
                    //   ).then((value) {
                    //     setState(() {
                    //       _permissionGranted = value;
                    //     });
                    //   });
                    // } else if (_permissionGranted == PermissionStatus.granted) {
                    //   if (_formKey.currentState!.validate() &&
                    //       selectedDemandList.length > 0) {
                    //     party.setEventName(_nameEventController.text);
                    //     party.setEventDemands(selectedDemandList);
                    //     party.arrangeDemandsOrder();
                    //     if (selectedDemandList.contains('VENUE')) {
                    //       showDialog(
                    //           barrierDismissible: false,
                    //           context: context,
                    //           builder: (context) => Dialog(
                    //                 child: PopUpDateTime(),
                    //                 backgroundColor: Colors.transparent,
                    //                 insetPadding: EdgeInsets.all(24),
                    //               ));
                    //     } else {
                    //       showDialog(
                    //           barrierDismissible: false,
                    //           context: context,
                    //           builder: (context) => Dialog(
                    //                 child: PopUpTypeAndAddress(),
                    //                 backgroundColor: Colors.transparent,
                    //                 insetPadding: EdgeInsets.all(24),
                    //               ));
                    //     }
                    //   }
                    // }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDemandCheckBoxClick(DemandCheckBox demandCheckBox) {
    setState(() {
      if (party.featuredVenueOutletId != null) {
        if (demandCheckBox.value != "VENUE") {
          demandCheckBox.checked = !demandCheckBox.checked;
          if (demandCheckBox.checked) {
            selectedDemandList.add(demandCheckBox.value);
          } else {
            selectedDemandList.remove(demandCheckBox.value);
          }
        }
      } else {
        demandCheckBox.checked = !demandCheckBox.checked;
        if (demandCheckBox.checked) {
          selectedDemandList.add(demandCheckBox.value);
        } else {
          selectedDemandList.remove(demandCheckBox.value);
        }
      }
    });
  }
}

class DemandCheckBox {
  String title;
  String value;
  bool checked;

  DemandCheckBox(
      {required this.title, this.checked = false, required this.value});
}
