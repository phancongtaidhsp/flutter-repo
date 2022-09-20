import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/UI/Buttons/primary_button.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

extension DarkMode on BuildContext {
  /// is dark mode currently enabled?
  bool isDarkMode() {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => SpinKitFadingCircle(
            color: primaryColor,
            size: 42.0,
          ));
}

Future<void> showIOSDatePicker({
  required BuildContext context,
  required bool timeOnly,
  required Function onDateTimeChanged,
  required DateTime initialDateTime,
  required DateTime minimumDate,
  required DateTime maximumDate,
  int? minimumYear,
}) async {
  var _timeSelected = false;

  // if(timeOnly){
  //                 _timeSelected = TimeOfDay.fromDateTime(val);

  // }
  await showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(24),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            )),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 200,
              child: timeOnly
                  ? CupertinoDatePicker(
                      mode: timeOnly
                          ? CupertinoDatePickerMode.time
                          : CupertinoDatePickerMode.date,
                      initialDateTime: initialDateTime,
                      // minimumDate: minimumDate,
                      onDateTimeChanged: (val) {
                        _timeSelected = true;
                        onDateTimeChanged(val);
                      })
                  : minimumYear == null
                      ? CupertinoDatePicker(
                          mode: timeOnly
                              ? CupertinoDatePickerMode.time
                              : CupertinoDatePickerMode.date,
                          initialDateTime: initialDateTime.add(const Duration(
                            seconds: 30,
                          )),
                          minimumDate: minimumDate,
                          maximumDate: maximumDate,
                          onDateTimeChanged: (val) {
                            _timeSelected = true;
                            onDateTimeChanged(val);
                          })
                      : CupertinoDatePicker(
                          minimumYear: minimumYear,
                          mode: timeOnly
                              ? CupertinoDatePickerMode.time
                              : CupertinoDatePickerMode.date,
                          initialDateTime: initialDateTime.add(const Duration(
                            seconds: 30,
                          )),
                          minimumDate: minimumDate,
                          maximumDate: maximumDate,
                          onDateTimeChanged: (val) {
                            _timeSelected = true;
                            onDateTimeChanged(val);
                          }),
            ),
            const SizedBox(
              height: 15,
            ),
            // Close the modal
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: PrimaryButton(
                btnText: 'OK',
                action: () => Navigator.of(context).pop(),
                // child: const Text('OK'),
                // onPressed: () => Navigator.of(ctx).pop(),
              ),
            )
          ],
        ),
      ),
    ),
  );
  if (!_timeSelected) {
    onDateTimeChanged(initialDateTime);
  }
}

void showLoadingOverlay(BuildContext context) {
  Loader.show(context,
      progressIndicator: SpinKitFadingCircle(
        color: primaryColor,
        size: 42.0,
      ),
      overlayColor: Colors.transparent);
}

Widget buildAppBar(String text, BuildContext context) {
  return AppBar(
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
                  Navigator.pop(context);
                })),
        Text(
          text.tr(),
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
