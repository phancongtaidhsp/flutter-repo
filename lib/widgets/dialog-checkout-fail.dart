import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class DialogFail extends StatelessWidget {
  DialogFail({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
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
                height: 25,
              ),
              Text(
                message.tr(),
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 25,
              ),
              SubmitButton(
                text: 'Button.Okay'.tr(),
                textColor: Colors.black,
                backgroundColor: primaryColor,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
