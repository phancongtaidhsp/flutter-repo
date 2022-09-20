import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/api-client.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/firebase_remote_config_helper.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/account-page/account-page.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/pop-up-dialog-add-to-basket-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/pop-up-dialog-service-information-widget.dart';
import 'package:gem_consumer_app/screens/home/widgets/home-tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/login/new_member_page.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-popup-name-and-demand.dart';
import 'package:gem_consumer_app/screens/profile/gql/profile.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/pop-up-error-message-widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/AddOn.dart';
import '../../models/UserCartItem.dart';
import '../../providers/add-to-cart-items.dart';
import '../../providers/auth.dart';
import '../../providers/firebase_remote_config_helper.dart';
import '../../providers/notification-provider.dart';
import '../../providers/plan-a-party.dart';
import '../../screens/account-page/account-page.dart';
import '../../screens/celebration/widgets/pop-up-dialog-add-to-basket-widget.dart';
import '../../screens/celebration/widgets/pop-up-dialog-service-information-widget.dart';
import '../../screens/home/widgets/home-tab.dart';
import '../../screens/login/login.dart';
import '../../screens/login/login.gql.dart';
import '../../screens/notification/notification-page.dart';
import '../../screens/party/plan_a_party_homepage.dart';
import '../../screens/party/widgets/party-login-popup-widget.dart';
import '../../screens/review-basket/gql/basket.gql.dart';
import '../../widgets/fab-bottom-app-bar-item.dart';
import '../../widgets/loading_controller.dart';
import '../user-address-page/widgets/pop-up-set-location-service.dart';

class Home extends StatefulWidget {
  static String routeName = '/home';
  const Home({Key? key, this.selectedPage}) : super();
  final int? selectedPage;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  List<Widget> tabPages = [];
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late String deviceToken;
  AndroidDeviceInfo? androidDeviceInfo;
  IosDeviceInfo? iOSDeviceInfo;
  late Auth auth;
  bool isCheckUserInfo = true;
  bool isFirstTime = true;
  late PlanAParty party;
  late AddToCartItems userCart;
  var _locationPermissionPending = true;

  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  var _checkUserCart = true;

  checkServiceEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("serviceEnabled");
        return;
      }
    }
  }

  Future<void> checkPermissionGranted() async {
    await checkServiceEnabled();
    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => Dialog(
            child: PopUpSetLocationService(),
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(24),
          ),
        ).then((value) {
          if (value == PermissionStatus.granted) {
            setState(() {});
          }
        });
        return;
      } else {
        setState(() {
          _locationPermissionPending = false;
        });
      }
    } else {
      setState(() {
        _locationPermissionPending = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          onAppResumed();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _clearNotificationBadge() async {
    FlutterAppBadger.removeBadge();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('badgeCounter', 0);
  }

  Future<void> onAppResumed() async {
    await checkPermissionGranted();
    _clearNotificationBadge();
    var uid = auth.currentUser.id;
    if (uid != null) {
      var notificationCounter = await APIClient.getUnreadNotifications(uid);
      if (notificationCounter != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .setNotification();
      }
    }
  }

  Future<void> _checkUserCartDb(BuildContext context) async {
    /** This portion of code was running every time on build method. */
    setState(() {
      _checkUserCart = true;
    });
    auth = Provider.of<Auth>(context, listen: false);
    party = Provider.of<PlanAParty>(context, listen: false);
    userCart = Provider.of<AddToCartItems>(context, listen: false);

    var result;
    if (auth.currentUser.id != null) {
      result = await APIClient.checkUserCurrentCart(auth.currentUser.id!);
    }

    if (result != null &&  result.data != null) {
      if (result.data!['CartItems'] != null &&
          result.data!['CartItems'].length > 0) {
        dataMassaging(result.data!['CartItems']);
      }
    }
    setState(() {
      _checkUserCart = false;
    });
    /** build method is called  */
  }

  @override
  void initState() {
    super.initState();
    print('most important init method');
    WidgetsBinding.instance?.addObserver(this);
    Future.delayed(Duration.zero, () async {
      await checkPermissionGranted();
      await _clearNotificationBadge();
      var uid = auth.currentUser.id;
      if (uid != null) {
        var notificationCounter = await APIClient.getUnreadNotifications(uid);
        if (notificationCounter != null) {
          Provider.of<NotificationProvider>(context, listen: false)
              .setNotification();
        }
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setInt('badgeCounter', 0);
      await _checkUserCartDb(context);
    });
    versionCheck();

    Future.delayed(Duration.zero, () async {
      if (widget.selectedPage == 4) {
        goToParty();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    Loader.hide();
    super.dispose();
  }

  void _firebaseCloudMessagingListeners(RunMutation runMutation) {
    if (Platform.isIOS) _iOSPermission();
    _firebaseMessaging.getToken().then((token) async {
      deviceToken = token!;
      auth.setFirebaseDeviceToken(token);
      print('pushtoken: $deviceToken');
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        androidDeviceInfo = await deviceInfo.androidInfo;
      } else if (Platform.isIOS) {
        iOSDeviceInfo = await deviceInfo.iosInfo;
      }

      if ((androidDeviceInfo != null || iOSDeviceInfo != null) &&
          (auth.currentUser.id != null)) {
        runMutation({
          "deviceInfo": {
            "userId": auth.currentUser.id,
            "deviceToken": deviceToken,
            "phoneModel": Platform.isAndroid
                ? androidDeviceInfo!.model
                : iOSDeviceInfo!.model,
            "os": Platform.isAndroid ? 'ANDROID' : 'IOS',
            "additionalInfo": {}
          }
        });
      }

      // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        print('getInitialMessage data:');
        if (message != null) {
          _notificationHandler(message, true, isResumed: false);
        }
      });

      // onMessage: When the app is open and it receives a push notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("onMessage data:");

        _notificationHandler(message, false);
      });

      // replacement for onResume: When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('onMessageOpenedApp data:');
        _notificationHandler(message, true);
      });
    });
  }

  Future<void> _notificationHandler(RemoteMessage? data, bool isLaunch,
      {bool isResumed = true}) async {
    if (data != null &&
        data.notification != null &&
        data.notification!.body!.isNotEmpty &&
        data.notification!.title!.isNotEmpty) {
      Map<String, dynamic> value = Map<String, dynamic>.from(data.data);
      if (isLaunch) {
        Timer(Duration(milliseconds: 500), () {
          Navigator.popUntil(context, ModalRoute.withName('/home'));
          _selectedIndex = 2;
          auth.setSelectedIndex(2);
        });
      }
      await Provider.of<NotificationProvider>(context, listen: false)
          .setNotification();

      print(data.notification);
      print(value);
      print(isLaunch);
      print(isResumed);
    }
  }

  Future<void> _iOSPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  void versionCheck() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    String currentBuild = info.buildNumber;
    String newBuild =
        FirebaseRemoteConfigHelper.loadConfig('gemspot_consumer_build_number');
    print('@version $currentBuild, $newBuild');
    if (int.parse(currentBuild) < int.parse(newBuild)) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => Dialog(
              child: PopUpLoginWidget(
                  title: "General.NewVersionTitle",
                  content: "General.NewVersionContent",
                  buttonKey: "Button.Okay",
                  continueFunction: () {
                    // FIXME: update gemspot ios app id
                    LaunchReview.launch(
                        androidAppId: "com.mnc.gem", iOSAppId: "1338665484");
                  }),
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(24)));
    }
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<Auth>(context, listen: false);
    party = Provider.of<PlanAParty>(context, listen: false);
    userCart = Provider.of<AddToCartItems>(context, listen: false);

    tabPages = [
      HomeTab(
        goToPage: goToParty,
        goToPackage: goToPackages,
      ),
      HomeTab(
        goToPage: goToParty,
        goToPackage: goToPackages,
      ),
      Center(
          child: NotificationPage(
        goToPage: goToParty,
        goToPackage: goToPackages,
      )),
      Center(child: AccountPage()),
      Center(
        child: PlanAPartyHomePage(
          selectedPage: widget.selectedPage,
        ),
      )
    ];
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: _locationPermissionPending
          ? Scaffold(
              body: SafeArea(
                child: LoadingController(),
              ),
            )
          : _checkUserCart
              ? Scaffold(
                  body: SafeArea(
                    child: LoadingController(),
                  ),
                )
              : Scaffold(
                  resizeToAvoidBottomInset: false,
                  bottomNavigationBar: _menu(context),
                  body: isCheckUserInfo && auth.currentUser.id != null
                      ? Query(
                          options: QueryOptions(
                              document: gql(ProfileGQL.GET_USER_INFO),
                              variables: {'userId': auth.currentUser.id},
                              optimisticResult: QueryResult.optimistic(),
                              fetchPolicy: FetchPolicy.networkOnly),
                          builder: (QueryResult result,
                              {VoidCallback? refetch, FetchMore? fetchMore}) {
                            if (result.isLoading) {
                              print('loading');
                              return Scaffold(body: LoadingController());
                            }
                            if (result.data != null) {
                              isCheckUserInfo = false;
                              if (result.data!['currentUser'] == null) {
                                WidgetsBinding.instance!
                                    .addPostFrameCallback((timeStamp) async {
                                  if (!auth.isOpeningNewMemberPage) {
                                    showLoadingOverlay(context);
                                    await Future.delayed(
                                        Duration(milliseconds: 1500));
                                    Loader.hide();
                                    auth.isOpeningNewMemberPage = true;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NewMember(
                                                auth.currentUser.phone!
                                                    .substring(0, 2),
                                                auth.currentUser.phone!
                                                    .substring(
                                                        2,
                                                        auth.currentUser.phone!
                                                            .length),
                                                email: auth.currentUser.email,
                                              )),
                                    );
                                  }
                                });
                              } else {
                                auth.setUserInfo(
                                    result.data!['currentUser']['displayName'],
                                    result.data!['currentUser']['email'],
                                    result.data!['currentUser']['phone']);
                              }
                            }

                            return _buildHomePage();
                          })
                      : _buildHomePage(),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = tabPages.length - 1;
                        auth.setSelectedIndex(_selectedIndex);
                        print('@selectedindexxxxx $_selectedIndex');
                      });
                    }, // Switch tabs
                    child: SvgPicture.asset(
                      'assets/images/icon-gem-black.svg',
                      semanticsLabel: 'gemspot logo',
                      height: 28,
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                ),
    );
  }

  Future<bool> onHandleBackButton() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
        auth.setSelectedIndex(0);
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Widget _buildHomePage() {
    return WillPopScope(
      onWillPop: onHandleBackButton,
      child: Mutation(
          options: MutationOptions(
            document: gql(LoginGQL.SET_DEVICE_INFO),
            onCompleted: (dynamic resultData) {
              if (resultData != null) {
                print(resultData);
              }
            },
          ),
          builder: (
            RunMutation? runMutation,
            QueryResult? result,
          ) {
            if (isFirstTime) {
              _firebaseCloudMessagingListeners(runMutation!);
              isFirstTime = false;
            }
            return Consumer<Auth>(builder: (context, item, child) {
              return tabPages[item.selectedIndex];
            });
          }),
    );
  }

  void _selectedTab(int index) {
    setState(() {
      _selectedIndex = index;
      auth.setSelectedIndex(index);
      if (index == 1) {
        if (auth.currentUser.isAuthenticated!) {
          if (party.checkAnyItem() || userCart.checkAnyItem()) {
            showDialog(
                context: context,
                builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(10),
                    child: Mutation(
                      options: MutationOptions(
                        document: gql(BasketGQL.CLEAR_USER_CART_ITEM),
                        onCompleted: (dynamic resultData) {
                          if (resultData != null) {
                            if (resultData["clearUserCartItem"]["status"] ==
                                    "SUCCESS" ||
                                resultData["clearUserCartItem"]["status"] ==
                                    "NOT_EXISTS_IN_DATABASE") {
                              party.resetParty();
                              userCart.clearCartItems();
                              Navigator.pop(context);
                              popUpServiceDialog();
                            } else {
                              Navigator.pop(context);
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => Dialog(
                                  child: PopUpErrorMessageWidget(),
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.all(24),
                                ),
                              );
                            }
                          }
                        },
                        onError: (dynamic resultData) {
                          print("FAIL: $resultData");
                        },
                      ),
                      builder: (
                        RunMutation? runMutation,
                        QueryResult? result,
                      ) {
                        if (result!.isLoading) {
                          return LoadingController();
                        }
                        return PopUpDialogAddToBasketWidget(
                            title: "Celebration.DiscardBasket",
                            content: "Celebration.DiscardBasketContent",
                            continueFunction: () {
                              runMutation!({"userId": auth.currentUser.id});
                            });
                      },
                    )));
          } else {
            popUpServiceDialog();
          }
        } else {
          popUpLoginDialog();
        }
      }
    });
  }

  void goToParty() {
    setState(() {
      _selectedIndex = 4;
      auth.setSelectedIndex(4);
    });
  }

  void goToPackages() {
    setState(() {
      _selectedIndex = 1;
      auth.setSelectedIndex(1);
      if (auth.currentUser.isAuthenticated!) {
        if (party.checkAnyItem() || userCart.checkAnyItem()) {
          showDialog(
              context: context,
              builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(10),
                  child: Mutation(
                    options: MutationOptions(
                      document: gql(BasketGQL.CLEAR_USER_CART_ITEM),
                      onCompleted: (dynamic resultData) {
                        if (resultData != null) {
                          if (resultData["clearUserCartItem"]["status"] ==
                                  "SUCCESS" ||
                              resultData["clearUserCartItem"]["status"] ==
                                  "NOT_EXISTS_IN_DATABASE") {
                            party.resetParty();
                            userCart.clearCartItems();
                            Navigator.pop(context);
                            popUpServiceDialog();
                          } else {
                            Navigator.pop(context);
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => Dialog(
                                child: PopUpErrorMessageWidget(),
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.all(24),
                              ),
                            );
                          }
                        }
                      },
                      onError: (dynamic resultData) {
                        print("FAIL: $resultData");
                      },
                    ),
                    builder: (
                      RunMutation? runMutation,
                      QueryResult? result,
                    ) {
                      if (result!.isLoading) {
                        return LoadingController();
                      }
                      return PopUpDialogAddToBasketWidget(
                          title: "Celebration.DiscardBasket",
                          content: "Celebration.DiscardBasketContent",
                          continueFunction: () {
                            runMutation!({"userId": auth.currentUser.id});
                          });
                    },
                  )));
        } else {
          popUpServiceDialog();
        }
      } else {
        popUpLoginDialog();
      }
    });
  }

  Widget _menu(ctx) {
    return Consumer<Auth>(builder: (context, item, child) {
      return FABBottomAppBar(
        centerItemText: 'General.Plan'.tr(),
        color: Colors.grey,
        selectedColor: Colors.black,
        onTabSelected: _selectedTab,
        notchedShape: CircularNotchedRectangle(),
        selectedIndex: item.selectedIndex,
        items: [
          FABBottomAppBarItem(
              svgFileName: 'icon-home', text: 'General.Home'.tr()),
          FABBottomAppBarItem(
              svgFileName: 'icon-offer', text: 'General.Packages'.tr()),
          FABBottomAppBarItem(
              svgFileName: 'icon-alarm', text: 'General.Notifications'.tr()),
          FABBottomAppBarItem(
              svgFileName: 'icon-account', text: 'General.Account'.tr()),
        ],
      );
    });
  }

  void dataMassaging(List<dynamic> queryDataList) {
    party.resetParty();
    userCart.clearCartItems();

    print('data massaging called');
    if (queryDataList.length > 0) {
      queryDataList.forEach((item) {
        if (item != null) {
          double totalAddOnPrice = 0.00;
          List<AddOn> addOnList = [];
          if (item['cartItemDetails'] != null &&
              item['cartItemDetails'].length > 0) {
            item['cartItemDetails'].forEach((addon) {
              AddOn tempAddOn = AddOn(
                  addOnOptionsId: addon['productAddOnOptionId'],
                  addOnPriceWhenAdded:
                      double.parse(addon['addOnPriceWhenAdded'].toString()),
                  cartItemId: addon['id'],
                  name: addon['productAddonOption']['name'],
                  addOnTitle: addon['productAddonOption']['productAddon']
                      ['name']);

              addOnList.add(tempAddOn);
              totalAddOnPrice += addon['addOnPriceWhenAdded'];
            });
          }
          double finalPrice =
              item["productOutlet"]["product"]["currentPrice"].toDouble() +
                  totalAddOnPrice;
          var lat = item["latitude"] ?? 0.0;
          var lng = item["longitude"] ?? 0.0;
          UserCartItem cartItem = UserCartItem(
              id: item["id"],
              outletProductInformation: item["productOutlet"],
              preOrderId: item["preOrderId"],
              priceWhenAdded: double.parse(item["priceWhenAdded"].toString()),
              serviceType: item["collectionType"],
              finalPrice: finalPrice,
              serviceDate: DateFormat("d MMM")
                  .format(DateTime.parse(item["serviceDateTime"]).toLocal()),
              serviceTime: DateFormat.jm()
                  .format(DateTime.parse(item["serviceDateTime"]).toLocal()),
              quantity: item["quantity"],
              currentDeliveryAddress: item["currentDeliveryAddress"],
              specialInstructions: item["remarks"],
              isDeliveredToVenue: item["isDeliveredToVenue"],
              addOns: addOnList,
              latitude: double.parse(lat.toString()),
              longitude: double.parse(lng.toString()),
              //merchantSST: item["merchantSST"], //CHECK
              isMerchantDelivery: item["productOutlet"]["product"]
                  ["isMerchantDelivery"],
              distance: item["distance"] != null
                  ? item['distance'].toDouble()
                  : null);

          if (cartItem.outletProductInformation["product"]["productType"] ==
              "ROOM") {
            party.setVenueProduct(cartItem);
          }
          if (cartItem.outletProductInformation["product"]["productType"] ==
              "FOOD") {
            party.addFBProduct(cartItem);
          }
          if (cartItem.outletProductInformation["product"]["productType"] ==
              "GIFT") {
            party.addDecorationProduct(cartItem);
          }
          if (cartItem.outletProductInformation["product"]["productType"] ==
              "BUNDLE") {
            userCart.addToCart(cartItem);
          }
        }
      });
    }
  }

  void popUpServiceDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: PopUpDialogServiceInformationWidget(),
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(24),
      ),
    );
  }

  void popUpLoginDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
            child: PopUpLoginWidget(
                title: "AccountPage.Login",
                content: "AccountPage.LoginToProceed",
                continueFunction: () {
                  Navigator.pushReplacementNamed(context, Login.routeName);
                }),
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(24)));
  }
}
