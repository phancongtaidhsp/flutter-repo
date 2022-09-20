import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/screens/login/login.gql.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:io' show Platform;
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../environment.dart';
import '../../providers/auth.dart';
import '../../screens/home/home.dart';
import '../../screens/login/sign_in_with_mobile_page.dart';
import '../../values/color-helper.dart';

class Login extends StatefulWidget {
  static String routeName = '/login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoggedIn = false;
  bool _isAvailableFuture = false;

  Map? _userObj;
  Map? _appleInfo;
  String? id;
  late Auth authProvider;
  String? provider;

  @override
  void initState() {
    authProvider = context.read<Auth>();
    signIn();
    _checkAppleLogin();
    super.initState();
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  void signIn() async {
    var box = await Hive.openBox('tokens');
    if (box.get('at') != null && box.get('rt') != null) {
      await authProvider.login(context);
    }
  }

  Future<bool> _checkAppleLogin() async {
    _isAvailableFuture = await SignInWithApple.isAvailable();
    print(_isAvailableFuture);
    return _isAvailableFuture;
  }

  @override
  Widget build(BuildContext context) {
    bool _isIOS = false;
    if (Platform.isIOS) {
      _isIOS = true;
    }

    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Container(
          height: size.height,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login-bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: FutureBuilder<bool>(
            future: _checkAppleLogin(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ClipRRect(
                  child: Container(
                    child: Mutation(
                        options: MutationOptions(
                            document: gql(LoginGQL.LOGIN_SOCIAL_USER),
                            onCompleted: (dynamic resultData) async {
                              Loader.hide();
                              if (resultData != null) {
                                if (resultData != null &&
                                    resultData['socialSignIn'] != null) {
                                  await putTokenIntoBox(
                                      context,
                                      resultData['socialSignIn']['a'],
                                      resultData['socialSignIn']['r']);
                                }
                              }
                            },
                            onError: (dynamic error) {
                              print(error);
                            }),
                        builder: (
                          RunMutation runLoginSocialMutation,
                          QueryResult? loginSocialResult,
                        ) {
                          return Mutation(
                              options: MutationOptions(
                                  document:
                                      gql(LoginGQL.CHECK_SOCIAL_USER_EXISTED),
                                  onCompleted: (dynamic resultData) {
                                    Loader.hide();
                                    if (resultData != null) {
                                      if (resultData['checkExistSocialUser']
                                              ['status'] ==
                                          'ACCOUNT_NOT_EXISTED') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignInWithMobile(
                                                      email: _userObj != null
                                                          ? _userObj!['email']
                                                          : '',
                                                      provider: provider,
                                                      accountId:
                                                          _userObj != null
                                                              ? _userObj!['id']
                                                              : '',
                                                    )));
                                      } else {
                                        showLoadingOverlay(context);
                                        runLoginSocialMutation({
                                          'userAccountId': _userObj != null
                                              ? _userObj!['id']
                                              : '',
                                          'provider': provider,
                                        });
                                      }
                                    }
                                  },
                                  onError: (dynamic error) {
                                    print(error);
                                  }),
                              builder: (
                                RunMutation runMutation,
                                QueryResult? result,
                              ) {
                                return Column(
                                  children: [
                                    SizedBox(height: size.height * 0.2),
                                    Spacer(),
                                    SizedBox(height: size.height * 0.075),
                                    _renderButton(context, "Login.MobileSignIn",
                                        () {
                                      Navigator.of(context).pushNamed(
                                          SignInWithMobile.routeName);
                                    }, isPrimaryColor: true),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.005),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.79,
                                      child: new RichText(
                                        text: new TextSpan(
                                          children: [
                                            new TextSpan(
                                              text:
                                                  'By signing up you agree to our ',
                                              style: textTheme.subtitle2!
                                                  .copyWith(
                                                      fontSize: 11,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            ),
                                            new TextSpan(
                                              text: 'Terms and Conditions',
                                              style: textTheme.subtitle2!
                                                  .copyWith(
                                                      fontSize: 11,
                                                      color: Colors.black,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontWeight:
                                                          FontWeight.normal),
                                              recognizer:
                                                  new TapGestureRecognizer()
                                                    ..onTap = () {
                                                      launch(
                                                          'https://www.mygemspot.com/terms-and-conditions/');
                                                    },
                                            ),
                                            new TextSpan(
                                              text: ' and ',
                                              style: textTheme.subtitle2!
                                                  .copyWith(
                                                      fontSize: 11,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            ),
                                            new TextSpan(
                                              text: 'Privacy Policy',
                                              style: textTheme.subtitle2!
                                                  .copyWith(
                                                      fontSize: 11,
                                                      color: Colors.black,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontWeight:
                                                          FontWeight.normal),
                                              recognizer:
                                                  new TapGestureRecognizer()
                                                    ..onTap = () {
                                                      launch(
                                                          'https://www.mygemspot.com/privacy-policy/');
                                                    },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.012),
                                    // _renderButton(
                                    //   context,
                                    //   "Login.FacebookSignIn",
                                    //   () async {
                                    //     FacebookAuth.instance.login(
                                    //         permissions: [
                                    //           "public_profile",
                                    //           "email"
                                    //         ]).then((value) {
                                    //       FacebookAuth.instance
                                    //           .getUserData()
                                    //           .then((userData) {
                                    //         if (value.accessToken != null) {
                                    //           print(value.status);
                                    //           provider = 'FACEBOOK';
                                    //           _userObj = userData;
                                    //           showLoadingOverlay(context);
                                    //           runMutation({
                                    //             'userAccountId': "${userData['id']}",
                                    //             'provider': provider,
                                    //           });
                                    //         }
                                    //       });
                                    //     });
                                    //   },
                                    // ),
                                    // SizedBox(height: size.height * 0.012),
                                    // Visibility(
                                    //   visible: _isIOS && _isAvailableFuture,
                                    //   child: _renderButton(
                                    //       context, "Login.AppleSignIn",
                                    //       () async {
                                    //     final credential = await SignInWithApple
                                    //         .getAppleIDCredential(
                                    //       scopes: [
                                    //         AppleIDAuthorizationScopes.email,
                                    //         AppleIDAuthorizationScopes.fullName,
                                    //       ],
                                    //     );
                                    //     //check user details
                                    //     print(credential.email);
                                    //     print(credential.givenName);
                                    //     print(credential.identityToken);
                                    //     print(credential.familyName);
                                    //     print(credential.state);
                                    //     print(credential.userIdentifier);
                                    //     if (credential.identityToken != null) {
                                    //       _appleInfo = JwtDecoder.tryDecode(credential.identityToken!);
                                    //       provider = 'APPLE';
                                    //       showLoadingOverlay(context);
                                    //       _userObj = {
                                    //         "email": _appleInfo!['email']!,
                                    //         "id": credential.userIdentifier,
                                    //       };
                                    //       runMutation({
                                    //         'userAccountId': credential.userIdentifier,
                                    //         'provider': provider,
                                    //       });
                                    //     }
                                    //     // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                                    //     // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                                    //   }),
                                    // ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(
                                            context, Home.routeName);
                                      },
                                      child: Text(
                                        "Login.Later",
                                        textAlign: TextAlign.center,
                                        style: textTheme.subtitle1,
                                      ).tr(),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      Environment.appVersion,
                                      textAlign: TextAlign.center,
                                      style: textTheme.subtitle2!.copyWith(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(height: 10)
                                  ],
                                );
                              });
                        }),
                  ),
                );
              } else {
                return LoadingController();
              }
            },
          )),
    );
  }

  SizedBox _renderButton(
      BuildContext context, String buttonText, Function buttonFunction,
      {bool isPrimaryColor = false, String? icon}) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.87,
        child: ElevatedButton(
            onPressed: () => buttonFunction(),
            child: Stack(
              children: [
                icon != null
                    ? Positioned(
                        left: MediaQuery.of(context).size.width * 0.11,
                        child: Image.asset(
                          icon,
                          width: 16,
                        ),
                      )
                    : Container(width: 0.0, height: 0.0),
                SizedBox(width: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.87,
                  child: Text(
                    buttonText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.button,
                  ).tr(),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 17),
                primary: !isPrimaryColor
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: primaryColor, width: 2.5),
                    borderRadius: BorderRadius.circular(25.0)))));
  }

  Future<void> putTokenIntoBox(
      BuildContext context, String at, String rt) async {
    var box = await Hive.openBox('tokens');
    box.put('at', at);
    box.put('rt', rt);

    await authProvider.login(context);
  }
}
