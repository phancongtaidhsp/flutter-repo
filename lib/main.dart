import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gem_consumer_app/environment.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/providers/scroll_party_provider.dart';
import 'package:gem_consumer_app/providers/notification-provider.dart';
import 'package:gem_consumer_app/providers/user-position-provider.dart';
import 'package:gem_consumer_app/screens/help-center/help-center-home-page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import '../providers/add-to-cart-items.dart';
import '../providers/firebase_remote_config_helper.dart';
import '../providers/plan-a-party.dart';
import '../screens/account-page/account-page.dart';
import '../screens/celebration/view-celebration/view_celebration_page.dart';
import '../screens/celebration/celebration_homepage.dart';
import '../screens/login/login.dart';
import '../providers/auth.dart';
import '../screens/home/home.dart';
import '../screens/login/sign_in_with_mobile_page.dart';
import '../screens/merchant-outlet/view_merchant_outlet_page.dart';
import '../screens/notification/notification-page.dart';
import '../screens/onboarding/onboarding-page.dart';
import '../screens/order-page/my_order_page.dart';
import '../screens/order-page/order_detail_page.dart';
import '../screens/order-page/order_review_page.dart';
import '../screens/party/plan_a_party_address_list_page.dart';
import '../screens/party/plan_a_party_delivery_detail_page.dart';
import '../screens/party/plan_a_party_homepage.dart';
import '../screens/party/plan_a_party_reselect_delivery_address_page.dart';
import '../screens/party/plan_a_party_room_details_page.dart';
import '../screens/party/plan_a_party_product_details_page.dart';
import '../screens/party/plan_a_party_product_list_page.dart';
import '../screens/party/plan_a_party_landing_page.dart';
import '../screens/profile/profile_page.dart';
import '../screens/profile/widgets/profile_add_or_edit_occasion.dart';
import '../screens/review-basket/review_basket_page.dart';
import '../screens/review-basket/update_item_page.dart';
import '../screens/search/search_result_page.dart';
import '../screens/user-address-page/user-address-home-page.dart';

import '../splash.dart';
import '../values/color-helper.dart';

import './api-client.dart';
import 'package:hive/hive.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('onBackgroundMessage::called');
  // when application is in background and platform is android
  // SharedPreferences will not work and throws error
  // we user SharedPreferencesAndroid to store information

  if (Platform.isAndroid) SharedPreferencesAndroid.registerWith();
  final preferences = await SharedPreferences.getInstance();
  var notificationCounter = preferences.getInt('notificationCounter') ?? 0;
  notificationCounter = notificationCounter + 1;
  preferences.setInt('notificationCounter', notificationCounter);

  var badgeCounter = preferences.getInt('badgeCounter') ?? 0;
  badgeCounter = badgeCounter + 1;
  preferences.setInt('badgeCounter', badgeCounter);
  FlutterAppBadger.updateBadgeCount(badgeCounter);
  print(
      'background message ${message.notification!.body} ${preferences.getInt('notificationCounter')}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await dotenv.load(fileName: Environment.filename);
  await initHiveForFlutter();
  await Hive.openBox('searchHistory');

  print('onBackgroundMessage::1');

  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: lightBack,
      statusBarIconBrightness: Brightness.light));
  var firebaseRemoteConfigHelper = FirebaseRemoteConfigHelper();
  // if (Platform.isIOS) {
  //   Timer(const Duration(milliseconds: 1000), () {
  //     firebaseRemoteConfigHelper.initializedConfig();
  //   });
  // } else {
  firebaseRemoteConfigHelper.initializedConfig();
  //}
  Provider.debugCheckInvalidValueType = null;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      EasyLocalization(
          supportedLocales: [Locale('en', 'US')],
          path: 'assets/i18n',
          fallbackLocale: Locale('en', 'US'),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => Auth()),
              ChangeNotifierProvider(create: (context) => AddToCartItems()),
              ChangeNotifierProvider(create: (context) => PlanAParty()),
              ChangeNotifierProvider(create: (context) => FilterProvider()),
              ChangeNotifierProvider(
                create: (context) => UserPositionProvider(),
              ),
              ChangeNotifierProvider(
                create: (context) => ScrollPartyProvider(),
              ),
              ChangeNotifierProvider(
                create: (context) => NotificationProvider(),
              ),
            ],
            child: MyApp(),
          )),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: APIClient.client,
      child: MaterialApp(
          builder: (context, child) {
            // Obtain the current media query information.
            final mediaQueryData = MediaQuery.of(context);
            // Take the textScaleFactor from system and make
            // sure that it's no less than 1.0, but no more
            // than 1.5.
            final num constrainedTextScaleFactor =
                mediaQueryData.textScaleFactor.clamp(1.0, 1.0);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                  textScaleFactor: constrainedTextScaleFactor as double?),
              child: child!,
            );
          },
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'GemSpot',
          theme: ThemeData(
            primarySwatch: _createMaterialColor(Color(0xFFFDC400)),
            textTheme: TextTheme(
                headline1: TextStyle(
                    fontFamily: 'Arial Rounded MT Bold',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
                headline2: TextStyle(
                  fontFamily: 'Arial Rounded MT Bold',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                headline3: TextStyle(
                  fontFamily: 'Arial Rounded MT Bold',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                button: TextStyle(
                    fontFamily: 'Arial Rounded MT Bold',
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
                subtitle1: TextStyle(
                  fontFamily: 'Arial Rounded MT Bold',
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                subtitle2: TextStyle(
                  fontFamily: 'Arial Rounded MT Bold',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                bodyText2: TextStyle(
                  fontFamily: 'Arial',
                  color: Colors.white,
                  fontSize: 12,
                ),
                bodyText1: TextStyle(
                  fontFamily: 'Arial',
                  color: Colors.grey,
                  fontSize: 12,
                ),
                caption: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 10,
                )),
            brightness: Brightness.light,
          ),
          // themeMode: ThemeMode.system,
          // darkTheme: ThemeData(
          //   brightness: Brightness.dark,
          // ),
          initialRoute: Splash.routeName,
          routes: {
            Splash.routeName: (ctx) => Splash(),
            Home.routeName: (ctx) => Home(),
            Login.routeName: (ctx) => Login(),
            CelebrationHomePage.routeName: (ctx) => CelebrationHomePage(),
            ViewCelebrationPage.routeName: (ctx) => ViewCelebrationPage(),
            SignInWithMobile.routeName: (ctx) => SignInWithMobile(),
            ReviewBasketPage.routeName: (ctx) => ReviewBasketPage(),
            UpdateItemPage.routeName: (ctx) => UpdateItemPage(),
            SearchResultPage.routeName: (ctx) => SearchResultPage(),
            ViewMerchantOutletPage.routeName: (ctx) => ViewMerchantOutletPage(),
            PlanAPartyHomePage.routeName: (ctx) => PlanAPartyHomePage(),
            AccountPage.routeName: (ctx) => AccountPage(),
            PlanAPartyProductListPage.routeName: (ctx) =>
                PlanAPartyProductListPage(),
            OnboardingPage.routeName: (ctx) => OnboardingPage(),
            UserAddressHomePage.routeName: (ctx) => UserAddressHomePage(),
            PlanAPartyLandingPage.routeName: (ctx) => PlanAPartyLandingPage(),
            PlanAPartyProductDetailsPage.routeName: (ctx) =>
                PlanAPartyProductDetailsPage(),
            PlanAPartyRoomDetailsPage.routeName: (ctx) =>
                PlanAPartyRoomDetailsPage(),
            PlanAPartyAddressListPage.routeName: (ctx) =>
                PlanAPartyAddressListPage(),
            ProfilePage.routeName: (ctx) => ProfilePage(),
            NotificationPage.routeName: (ctx) => NotificationPage(
                  goToPage: () {},
                  goToPackage: () {},
                ),
            ProfileAddOrEditOccasion.routeName: (ctx) =>
                ProfileAddOrEditOccasion(),
            MyOrderPage.routeName: (ctx) => MyOrderPage(),
            OrderDetailPage.routeName: (ctx) => OrderDetailPage(
                  orderId: '0',
                ),
            OrderReviewPage.routeName: (ctx) => OrderReviewPage(orderId: '0'),
            PlanAPartyDeliveryDetailPage.routeName: (ctx) =>
                PlanAPartyDeliveryDetailPage(
                    userSelectedAddress: UserAddress(
                        id: 'id',
                        name: 'name',
                        address1: 'address1',
                        state: 'state',
                        city: 'city',
                        postalCode: '1',
                        longitude: 0.0,
                        latitude: 0.0)),
            PlanAPartyReselectDeliveryAddressPage.routeName: (ctx) =>
                PlanAPartyReselectDeliveryAddressPage(
                  userSelectedAddress: UserAddress(
                    id: 'id',
                    name: 'name',
                    address1: 'address1',
                    state: 'state',
                    city: 'city',
                    postalCode: '1',
                    longitude: 0.0,
                    latitude: 0.0,
                  ),
                  refreshLocationOnMap: () {},
                ),
            HelpCenterHomePage.routeName: (ctx) => HelpCenterHomePage()
          }),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}
