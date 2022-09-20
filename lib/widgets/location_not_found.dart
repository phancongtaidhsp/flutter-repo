import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/UI/Buttons/primary_button.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

Future<void> errorDialog({
  required BuildContext context,
  required String errorMessage,
  required String okButtonText,
  required Function okButtonAction,
}) async {
  var height = 280.0;

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: Builder(builder: (_) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 240,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: primaryColor,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.error,
                          color: Colors.black,
                          size: 32,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorMessage, //   'General.PhonePasswordIncorrect'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 38,
                    child: PrimaryButton(
                      btnText: okButtonText, // 'Withdraw.Continue'.tr(),
                      action: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          }),
        );
      });
}
