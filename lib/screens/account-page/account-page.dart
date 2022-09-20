import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gem_consumer_app/configuration.dart';
import 'package:gem_consumer_app/environment.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/account-page/widgets/custom-icon-button.dart';
import 'package:gem_consumer_app/screens/account-page/widgets/zendesk-chat-page.dart';
import 'package:gem_consumer_app/screens/help-center/help-center-home-page.dart';
import 'package:gem_consumer_app/screens/home/home.dart';
import 'package:gem_consumer_app/screens/login/login.dart';
import 'package:gem_consumer_app/screens/login/login.gql.dart';
import 'package:gem_consumer_app/screens/order-page/my_order_page.dart';
import 'package:gem_consumer_app/screens/user-address-page/user-address-home-page.dart';
import 'package:gem_consumer_app/screens/profile/gql/profile.gql.dart';
import 'package:gem_consumer_app/screens/profile/profile_page.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_birthday_popup.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zendesk2/zendesk2.dart';
import '../../configuration.dart';
import '../../providers/auth.dart';
import '../../screens/account-page/widgets/custom-icon-button.dart';
import '../../screens/account-page/widgets/zendesk-chat-page.dart';
import '../../screens/home/home.dart';
import '../../screens/login/login.dart';
import '../../screens/order-page/my_order_page.dart';
import '../../screens/user-address-page/user-address-home-page.dart';
import '../../screens/profile/gql/profile.gql.dart';
import '../../screens/profile/profile_page.dart';
import '../../screens/profile/widgets/profile_birthday_popup.dart';
import '../../helpers/ui_theme.dart';

class AccountPage extends StatelessWidget {
  static String routeName = '/account-page';
  static late Auth auth;
  static late PlanAParty party;
  final z = Zendesk.instance;

  @override
  Widget build(BuildContext context) {
    auth = context.read<Auth>();
    party = context.read<PlanAParty>();
    List<dynamic> allList = [
      {
        "icon": "assets/images/account-page/my-profile.svg",
        "text": "AccountPage.Profile",
        "function": null
      },
      {
        "icon": "assets/images/account-page/my-addresses.svg",
        "text": "AccountPage.Address",
        "function": () {
          Navigator.pushNamed(context, UserAddressHomePage.routeName);
        }
      },
      {
        "icon": "assets/images/account-page/my-orders.svg",
        "text": "AccountPage.Order",
        "function": () {
          Navigator.pushNamed(context, MyOrderPage.routeName);
        }
      },
      {
        "icon": "assets/images/account-page/gemspot-support.svg",
        "text": "AccountPage.GemSpotSupport",
        "function": () {
          chat(context);
        }
      },
      {
        "icon": "assets/images/account-page/help-center.svg",
        "text": "AccountPage.HelpCenter",
        "function": () {
          Navigator.pushNamed(context, HelpCenterHomePage.routeName);
        }
      },
      {
        "icon": "assets/images/account-page/log-out.svg",
        "text": "AccountPage.LogOut",
        "function": () async {
          await auth.logout(context);
          Navigator.pushNamedAndRemoveUntil(
              context, Home.routeName, (route) => false);
        }
      }
    ];
    List<dynamic> listLogin = [
      {
        "icon": "assets/images/account-page/my-profile.svg",
        "text": "AccountPage.Login",
        "function": () {
          Navigator.pushNamedAndRemoveUntil(
              context, Login.routeName, (route) => false);
        }
      },
      {
        "icon": "assets/images/account-page/gemspot-support.svg",
        "text": "AccountPage.GemSpotSupport",
        "function": () {
          chat(context);
        }
      },
      {
        "icon": "assets/images/account-page/help-center.svg",
        "text": "AccountPage.HelpCenter",
        "function": null
      },
      {
        "icon": "assets/images/account-page/settings.svg",
        "text": "AccountPage.Settings",
        "function": null
      }
    ];
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
              child: GridView.builder(
                padding: EdgeInsets.all(5.0),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: auth.currentUser != null &&
                        auth.currentUser.isAuthenticated!
                    ? allList.length
                    : listLogin.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) {
                  return _buildGridItem(
                      context,
                      auth.currentUser != null &&
                              auth.currentUser.isAuthenticated!
                          ? allList[index]
                          : listLogin[index]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(context, dynamic item) {
    if (item['text'] == "AccountPage.Profile") {
      return Query(
        options: QueryOptions(
            document: gql(ProfileGQL.GET_USER_INFO),
            variables: {'userId': auth.currentUser.id},
            optimisticResult: QueryResult.optimistic(),
            fetchPolicy: FetchPolicy.networkOnly),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null && result.data!['currentUser'] != null) {
            auth.setUserInfo(
                result.data!['currentUser']['displayName'] ?? '',
                result.data!['currentUser']['email'] ?? '',
                result.data!['currentUser']['phone'] ?? '');
          }

          return CustomIconButton("assets/images/account-page/my-profile.svg",
              "AccountPage.Profile", () {
            if (result.data != null) {
              if (result.data!['currentUser']['dateOfBirth'] != null) {
                Navigator.pushNamed(context, ProfilePage.routeName);
              } else {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => Dialog(
                    child: ProfileBirthdayPopUp(),
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(24),
                  ),
                );
              }
            }
          });
        },
      );
    }

    if (item['text'] == "AccountPage.LogOut") {
      return Mutation(
        options: MutationOptions(
            document: gql(LoginGQL.LOGOUT),
            update: (GraphQLDataProxy cache, QueryResult? result) async {
              await auth.logout(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, Home.routeName, (route) => false);
            },
            onCompleted: (dynamic resultData) {
              print('success');
              party.resetParty();
            },
            onError: (dynamic error) {
              print(error);
            }),
        builder: (
          RunMutation runMutation,
          QueryResult? result,
        ) {
          return CustomIconButton(
              "assets/images/account-page/log-out.svg",
              "AccountPage.LogOut",
              () => runMutation({
                    'userId': "${auth.currentUser.id}",
                    'deviceToken': "${auth.firebaseToken}",
                  }));
        },
      );
    }

    return CustomIconButton(item['icon'], item['text'], item['function']);
  }

  void chat(BuildContext context) async {
    final userName = auth.currentUser.name ?? '';
    await z.initChatSDK(
        Configuration.KEY_ZENDESK_KEY, Configuration.KEY_APP_ID);

    Zendesk2Chat zChat = Zendesk2Chat.instance;

    String subName = Environment.isProductEnvironment ? '' : '[TESTING] ';

    await zChat.setVisitorInfo(
      name: '$subName$userName',
      email: auth.currentUser.email ?? '',
      phoneNumber: auth.currentUser.phone ?? '',
      tags: ['app', 'zendesk2_plugin'],
    );

    await Zendesk2Chat.instance.startChatProviders(autoConnect: false);

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ZendeskChatPage()));
  }
}
