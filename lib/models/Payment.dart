import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Payment {
  final String mp_amount;
  final String mp_username = dotenv.env['RAZER_USERNAME'].toString();
  final String mp_password = dotenv.env['RAZER_PASSWORD'].toString();
  final String mp_merchant_ID = dotenv.env['RAZER_MERCHANT_ID'].toString();
  final String mp_app_name = dotenv.env['RAZER_APP_NAME'].toString();
  final String mp_verification_key =
      dotenv.env['RAZER_VERIFICATION_KEY'].toString();
  final String mp_order_ID;
  final String mp_currency = dotenv.env['RAZER_CURRENCY'].toString();
  final String mp_country = dotenv.env['RAZER_COUNTRY'].toString();
  final String mp_channel = dotenv.env['RAZER_CHANNEL'].toString();
  final String mp_bill_description;
  final String mp_bill_name;
  final String mp_bill_email;
  final String mp_bill_mobile;
  final bool mp_sandbox_mode =
          dotenv.env['RAZER_SANDBOX_MODE'].toString() == "true" ? true : false,
      mp_dev_mode =
          dotenv.env['RAZER_DEV_MODE'].toString() == "true" ? true : false;

  Payment({
    required this.mp_amount,
    required this.mp_order_ID,
    required this.mp_bill_description,
    required this.mp_bill_name,
    required this.mp_bill_email,
    required this.mp_bill_mobile,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mp_amount'] = this.mp_amount;
    data['mp_username'] = this.mp_username;
    data['mp_password'] = this.mp_password;
    data['mp_merchant_ID'] = this.mp_merchant_ID;
    data['mp_app_name'] = this.mp_app_name;
    data['mp_verification_key'] = this.mp_verification_key;
    data['mp_order_ID'] = this.mp_order_ID;
    data['mp_currency'] = this.mp_currency;
    data['mp_country'] = this.mp_country;
    data['mp_channel'] = this.mp_channel;
    data['mp_bill_description'] = this.mp_bill_description;
    data['mp_bill_name'] = this.mp_bill_name;
    data['mp_bill_email'] = this.mp_bill_email;
    data['mp_bill_mobile'] = this.mp_bill_mobile;
    data['mp_sandbox_mode'] = this.mp_sandbox_mode;
    data['mp_dev_mode'] = this.mp_dev_mode;
    return data;
  }
}
