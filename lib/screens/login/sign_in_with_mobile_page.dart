import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/dialog-checkout-fail.dart';
import '../../UI/Buttons/primary_button.dart';
import '../../screens/login/otp_verification_page.dart';
import '../../screens/login/widgets/dial-code-sheet-widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../screens/login/login.gql.dart';
import 'dart:convert';

class SignInWithMobile extends StatefulWidget {
  static String routeName = '/signInWithMobile';

  final String? provider;
  final String? email;
  final String? accountId;

  SignInWithMobile({this.provider, this.email, this.accountId});

  @override
  _SignInWithMobileState createState() => _SignInWithMobileState();
}

class _SignInWithMobileState extends State<SignInWithMobile> {
  final _phoneNumberController = TextEditingController();
  bool _validate = false;
  void _phoneNumber(String newText) {
    setState(() {
      phoneNumber = newText;
    });
  }

  //temporary data
  String countryFlag = "🇲🇾";
  String dialCode = "+60";
  String phoneNumber = '';

  @override
  void dispose() {
    _phoneNumberController.dispose();
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            height: size.height,
            width: double.infinity,
            margin: EdgeInsets.only(
              left: size.width * 0.0666,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.0213),
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
                      icon: SvgPicture.asset('assets/images/icon-back.svg'),
                      iconSize: 36.0,
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ),
                SizedBox(height: size.height * 0.213),
                Container(
                  width: size.width * 0.867,
                  child: Text(
                    'SignInWithMobile.Title',
                    style: textTheme.headline1!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ).tr(),
                ),
                SizedBox(height: size.height * 0.031),
                Container(
                  height: size.height * 0.0554,
                  width: size.width * 0.8666,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    color: Color.fromRGBO(245, 245, 245, 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: size.width * 0.07),
                      Container(
                        child: Text(
                          '$countryFlag',
                          //'🇲🇾',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyText1!.copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      DialCodeSheet(),
                      Container(
                        height: size.height * 1,
                        alignment: Alignment.center,
                        child: Text(
                          '$dialCode',
                          //'+60',
                          style: textTheme.button,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(
                          height: size.height * 1,
                          alignment: Alignment.center,
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: _phoneNumberController,
                            onChanged: (newText) {
                              _phoneNumber(newText);
                              setState(() {
                                _phoneNumberController.text.isEmpty
                                    ? _validate = false
                                    : _validate = true;
                              });
                            },
                            textAlign: TextAlign.start,
                            keyboardType:
                                TextInputType.numberWithOptions(signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: textTheme.button,
                            decoration: InputDecoration(
                              isDense:
                                  true, // this will remove the default content padding
                              // now you can customize it here or add padding widget
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),

                              border: InputBorder.none,
                              hintText: '123456789',
                              hintStyle: textTheme.button!.copyWith(
                                color: Colors.grey,
                              ),

                              //  TextStyle(
                              //   color: Colors.grey,
                              //   fontFamily: 'Arial Rounded MT Bold',
                              //   fontSize: 14,
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Mutation(
                  options: MutationOptions(
                      document: gql(LoginGQL.MOBILE_SIGNIN),
                      onCompleted: (dynamic resultData) {
                        // FIXME: for dev testing purpose, remove for prod
                        Loader.hide();
                        if (resultData != null) {
                          var result =
                              jsonDecode(resultData['phoneSignIn']['status']);

                          String verificationId = '';
                          if (widget.provider == null) {
                            verificationId =
                                result['phoneSignIn']['verificationId'];
                          } else {
                            verificationId =
                                result['firstSocialSignIn']['verificationId'];
                          }

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtpVerification(
                                      "$dialCode",
                                      "$phoneNumber",
                                      "$verificationId",
                                      provider: widget.provider,
                                      email: widget.email,
                                      userAccountId: widget.accountId)));
                        }
                      },
                      onError: (error) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => Dialog(
                                  child: DialogFail(
                                    message: 'Login.LoginFailFrequent',
                                  ),
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.all(24),
                                ));
                      }),
                  builder: (
                    RunMutation runMutation,
                    QueryResult? result,
                  ) {
                    return PrimaryButton(
                        action: _validate
                            ? () {
                                showLoadingOverlay(context);
                                if (phoneNumber.startsWith('0')) {
                                  phoneNumber = phoneNumber.substring(
                                      1, phoneNumber.length);
                                }
                                runMutation({
                                  'phoneNumber': "$dialCode$phoneNumber",
                                  'email': widget.email,
                                  'provider': widget.provider,
                                  'userAccountId': widget.accountId,
                                });
                              }
                            : () {},
                        btnText: 'SignInWithMobile.Next');
                  },
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
