import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:app_settings/app_settings.dart';
import 'package:location/location.dart';

class PopUpSetLocationService extends StatefulWidget {
  @override
  State<PopUpSetLocationService> createState() =>
      _PopUpSetLocationServiceState();
}

class _PopUpSetLocationServiceState extends State<PopUpSetLocationService>
    with WidgetsBindingObserver {
  Location location = new Location();
  late bool _serviceEnabled;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  checkPermissionGranted() async {
    _permissionGranted = await location.hasPermission().then((value) {
      if (value == PermissionStatus.granted) {
        print("Permission granted");
      } else if (value == PermissionStatus.denied) {
        print("Permission denied");
      } else if (value == PermissionStatus.deniedForever) {
        print("Permission deniedForever");
      } else if (value == PermissionStatus.grantedLimited) {
        print("Permission granted limited");
      }
      print("return Value  $value");
      return value;
    });
  }

  checkServiceEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("serviceEnabled : $_serviceEnabled");
        return;
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    checkPermissionGranted();
    checkServiceEnabled();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("resume check change");
      _permissionGranted = await location.hasPermission().then((value) {
        if (value == PermissionStatus.granted) {
          print("Permission granted");
          setState(() {
            _permissionGranted = value;
          });
          Navigator.pop(context, value);
        } else if (value == PermissionStatus.denied) {
          setState(() {
            _permissionGranted = value;
          });
        } else if (value == PermissionStatus.deniedForever) {
          print("Permission deniedForever");
          setState(() {
            _permissionGranted = value;
          });
        } else if (value == PermissionStatus.grantedLimited) {
          print("Permission granted limited");
          setState(() {
            _permissionGranted = value;
          });
          Navigator.pop(context, value);
        }
        print("return Value  $value");
        return value;
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  Text("UserAddressPage.SetLocation",
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(fontWeight: FontWeight.normal))
                      .tr(),
                  //Spacer(),
                  // Container(
                  //     height: 36.0,
                  //     width: 36.0,
                  //     decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         shape: BoxShape.circle,
                  //         boxShadow: [
                  //           BoxShadow(
                  //               color: Colors.grey.withOpacity(0.4),
                  //               spreadRadius: 0.5,
                  //               blurRadius: 2,
                  //               offset: Offset(0, 1.5))
                  //         ]),
                  //     child: IconButton(
                  //         icon:
                  //             SvgPicture.asset('assets/images/icon-close.svg'),
                  //         iconSize: 36.0,
                  //         onPressed: () {
                  //           Navigator.pop(context);
                  //         }))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "UserAddressPage.Description",
                style: textTheme.bodyText2!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                textAlign: TextAlign.left,
              ).tr(),
              SizedBox(
                height: 12,
              ),
              Text(
                "UserAddressPage.PleaseTurnOnPermission",
                style: textTheme.bodyText2!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                textAlign: TextAlign.left,
              ).tr(),
              SizedBox(
                height: 32,
              ),
              SubmitButton(
                  text: "UserAddressPage.TurnOnLocationSerivce",
                  textColor: Colors.black,
                  backgroundColor: primaryColor,
                  onPressed: () {
                    AppSettings.openAppSettings(asAnotherTask: true);
                    //Navigator.pop(context);
                  })
            ]),
          ),
        ));
  }

  // void _updateStatus(PermissionStatus status) {
  //   if (status != _status) {
  //     // check status has changed
  //     setState(() {
  //       _status = status; // update
  //     });
  //   } else {
  //     if (status != PermissionStatus.granted) {
  //       PermissionHandler().requestPermissions(
  //           [PermissionGroup.locationWhenInUse]).then(_onStatusRequested);
  //     }
  //   }
  // }
}

// void _askPermission() {
//   PermissionHandler().requestPermissions(
//       [PermissionGroup.locationWhenInUse]).then(_onStatusRequested);
// }

// void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statuses) {
//   final status = statuses[PermissionGroup.locationWhenInUse];
//   if (status != PermissionStatus.granted) {
//     // On iOS if "deny" is pressed, open App Settings
//     PermissionHandler().openAppSettings();
//   } else {
//     _updateStatus(status);
//   }
// }
