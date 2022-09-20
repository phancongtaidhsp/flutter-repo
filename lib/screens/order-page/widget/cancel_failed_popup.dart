import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/screens/order-page/order_detail_page.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class CancelFailedPopUp extends StatelessWidget {
  final bool isCancelSuccess;
  final String orderId;

  const CancelFailedPopUp(
      {required this.isCancelSuccess, required this.orderId});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Text(
                    'Button.CancelFail'.tr(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Arial Rounded MT Bold',
                        fontWeight: FontWeight.w400),
                  )),
                ],
              ),
              SizedBox(height: 15),
              Text(
                "Button.CancelFailContent".tr(),
                style: textTheme.bodyText2!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 30,
              ),
              SubmitButton(
                text: 'Button.Okay'.tr(),
                textColor: Colors.black,
                backgroundColor: primaryColor,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderDetailPage(
                                orderId: orderId,
                              )));
                },
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
