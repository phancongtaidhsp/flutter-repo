import 'dart:async';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-popup-name-and-demand.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/dialog-checkout-fail.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../UI/Buttons/primary_button.dart';
import '../../environment.dart';
import '../../providers/auth.dart';
import '../../screens/login/login.gql.dart';

class OtpVerification extends StatefulWidget {
  final String dialCode;
  final String phoneNumber;
  final String otp;
  final String? email;
  final String? provider;
  final String? userAccountId;
  OtpVerification(this.dialCode, this.phoneNumber, this.otp,
      {this.email, this.provider, this.userAccountId});

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  var displayNumber;
  late Auth authProvider;
  late PlanAParty party;
  bool isFirstUser = false;
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(235, 236, 237, 1),
    borderRadius: BorderRadius.circular(100),
  );
  final BoxDecoration pinFillDecoration = BoxDecoration(
    color: const Color.fromRGBO(253, 196, 0, 1),
    borderRadius: BorderRadius.circular(100),
  );
  static const _timerDuration = 30;
  StreamController _timerStream = StreamController<int>();
  int? timerCounter;
  Timer? _resendCodeTimer;

  @override
  void initState() {
    authProvider = context.read<Auth>();
    // FIXME: for dev testing purpose
    if (!Environment.isProductEnvironment) {
      _pinPutController.text = widget.otp;
    }
    party = context.read<PlanAParty>();
    activeCounter();

    super.initState();
  }

  @override
  dispose() {
    _timerStream.close();
    _resendCodeTimer?.cancel();
    Loader.hide();
    super.dispose();
  }

  activeCounter() {
    _resendCodeTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timerDuration - timer.tick > 0)
        _timerStream.sink.add(_timerDuration - timer.tick);
      else {
        _timerStream.sink.add(0);
        _resendCodeTimer?.cancel();
      }
    });
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  Future<void> putTokenIntoBox(
      BuildContext context, String at, String rt) async {
    var box = await Hive.openBox('tokens');
    box.put('at', at);
    box.put('rt', rt);

    await authProvider.login(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    displayNumber = widget.phoneNumber;
    for (int i = 2; i < widget.phoneNumber.length - 3; i++) {
      displayNumber = replaceCharAt(displayNumber, i, "*");
    }
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              SizedBox(height: size.height * 0.2),
              Container(
                width: size.width * 0.87,
                alignment: Alignment.center,
                child: Text(
                  'OtpVerification.Title',
                  style: textTheme.headline1!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ).tr(),
              ),
              SizedBox(height: size.height * 0.015),
              Container(
                child: Text(
                  '${widget.dialCode} $displayNumber',
                  style: textTheme.subtitle1!.copyWith(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: size.width * 0.84,
                alignment: Alignment.center,
                child: PinPut(
                  eachFieldWidth: 45,
                  eachFieldHeight: 45,
                  withCursor: true,
                  fieldsCount: 6,
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  submittedFieldDecoration: pinFillDecoration,
                  selectedFieldDecoration: pinPutDecoration,
                  followingFieldDecoration: pinPutDecoration,
                  pinAnimationType: PinAnimationType.scale,
                  textStyle:
                      const TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.025),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'OtpVerification.DidntReceiveIt',
                      textAlign: TextAlign.left,
                      style: textTheme.subtitle1,
                    ).tr(),
                    StreamBuilder(
                      stream: _timerStream.stream,
                      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                        return Mutation(
                          options: MutationOptions(
                            document: gql(LoginGQL.MOBILE_SIGNIN),
                            onCompleted: (dynamic resultData) {},
                          ),
                          builder: (
                            RunMutation runMutation,
                            QueryResult? result,
                          ) {
                            return TextButton(
                              child: snapshot.data == 0
                                  ? Text(
                                      "OtpVerification.SendOtp",
                                      textAlign: TextAlign.left,
                                      style: textTheme.subtitle1!.copyWith(
                                          decoration: TextDecoration.underline,
                                          color: Colors.black),
                                    ).tr()
                                  : Text(
                                      'OtpVerification.Retry',
                                      textAlign: TextAlign.left,
                                      style: textTheme.subtitle1!.copyWith(
                                          decoration: TextDecoration.underline,
                                          color: Colors.black),
                                    ).tr(namedArgs: {
                                      'countdown': snapshot.hasData
                                          ? snapshot.data.toString()
                                          : '30'
                                    }),
                              onPressed: snapshot.data == 0
                                  ? () => {
                                        runMutation({
                                          'phoneNumber':
                                              "${widget.dialCode}${widget.phoneNumber}",
                                          'email': widget.email,
                                          'provider': widget.provider
                                        }),
                                        _timerStream.sink.add(30),
                                        activeCounter(),
                                        _pinPutController.clear()
                                      }
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.258),
              Mutation(
                options: MutationOptions(
                    document: gql(LoginGQL.MOBILE_VERIFY),
                    onCompleted: (dynamic resultData) async {
                      Loader.hide();
                      if (resultData != null &&
                          resultData['phoneSignInVerifyCode'] != null) {
                        await putTokenIntoBox(
                            context,
                            resultData['phoneSignInVerifyCode']['a'],
                            resultData['phoneSignInVerifyCode']['r']);
                        if (party.featuredVenueOutletId != null) {
                          popUpPartyServiceDialog();
                        }
                      }
                    },
                    onError: (dynamic error) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => Dialog(
                                child: DialogFail(
                                  message: 'OtpVerification.Error',
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
                      action: () {
                        showLoadingOverlay(context);
                        runMutation({
                          'phoneNumber':
                              "${widget.dialCode}${widget.phoneNumber}",
                          'token': "${_pinPutController.text}",
                          'userAccountId': widget.userAccountId,
                          'provider': widget.provider
                        });
                      },
                      btnText: 'OtpVerification.Verify');
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void popUpPartyServiceDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: PopUpNameAndDemand(),
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(24),
      ),
    );
  }
}
