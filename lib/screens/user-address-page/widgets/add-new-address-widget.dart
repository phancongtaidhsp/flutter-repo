import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:location/location.dart';
import 'package:gem_consumer_app/screens/user-address-page/add-new-address-page.dart';
import 'package:gem_consumer_app/screens/user-address-page/widgets/pop-up-set-location-service.dart';

class AddNewAddressWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    checkServiceEnabled() async {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          print("serviceEnabled");
          return;
        }
      }
    }

    checkPermissionGranted() async {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddNewAddressPage()));
      }
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          print(_permissionGranted);
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => Dialog(
              child: PopUpSetLocationService(),
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(24),
            ),
          );
          return;
        }
      }
    }

    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
        padding: EdgeInsets.all(15),
        child: GestureDetector(
            onTap: () {
              checkServiceEnabled();
              checkPermissionGranted();
            },
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  size: 26,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("UserAddressPage.AddNewAddress",
                        style: textTheme.subtitle2!
                            .copyWith(fontWeight: FontWeight.normal))
                    .tr(),
              ],
            )));
  }
}
