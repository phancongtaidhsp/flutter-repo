import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import '../../order-page/my_order_page.dart';

class DialogCheckoutFail extends StatelessWidget {
  DialogCheckoutFail(this.message);
  final String message;
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                    child: Text(
                  'Basket.CheckoutFail'.tr(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Arial Rounded MT Bold',
                      fontWeight: FontWeight.w400),
                ))
              ]),
              SizedBox(
                height: 25,
              ),
              Text(
                'Basket.ReviewAgain'.tr(),
                textAlign: TextAlign.left,
                style: textTheme.bodyText2!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              Text(
                'Reason: ${message}',
                textAlign: TextAlign.left,
                style: textTheme.bodyText2!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              SizedBox(
                height: 25,
              ),
              SubmitButton(
                text: 'Button.Okay'.tr(),
                textColor: Colors.black,
                backgroundColor: primaryColor,
                onPressed: () {
                  if (message.substring(0, 13) == "ORDER CREATED") {
                    Navigator.pushNamed(context, MyOrderPage.routeName);
                  } else {
                    Navigator.pop(context);
                  }
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
