import 'package:flutter/material.dart';
import 'package:gem_consumer_app/api-client.dart';
import 'package:gem_consumer_app/providers/user-position-provider.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-event-category-outlet-listing-widget.dart';
import 'package:gem_consumer_app/widgets/banner-carousel.dart';
import 'package:gem_consumer_app/widgets/pop-up-error-message-widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/scroll_party_provider.dart';
//import '../user-address-page/widgets/pop-up-set-location-service.dart';
import 'widgets/party-login-popup-widget.dart';
import '../../providers/add-to-cart-items.dart';
import '../../providers/auth.dart';
import '../../providers/plan-a-party.dart';
import '../../screens/celebration/widgets/pop-up-dialog-add-to-basket-widget.dart';
import '../../screens/login/login.dart';

import '../../screens/party/widgets/party-popup-name-and-demand.dart';
import '../../screens/party/widgets/plan-a-party-steps.widget.dart';
import '../../screens/review-basket/gql/basket.gql.dart';
import '../../widgets/loading_controller.dart';
import 'package:geolocator/geolocator.dart' as geo;

class PlanAPartyHomePage extends StatefulWidget {
  static String routeName = '/plan-a-party-home';
  const PlanAPartyHomePage({
    Key? key,
    this.selectedPage,
  });
  final int? selectedPage;
  @override
  _PlanAPartyHomePageState createState() => _PlanAPartyHomePageState();
}

class _PlanAPartyHomePageState extends State<PlanAPartyHomePage> {
  late AddToCartItems userCartItems;
  late PlanAParty party;
  late Auth auth;
  late UserPositionProvider positionProvider;
  Position? position;
  bool isLoggedIn = false;
  bool isPositionAvailable = false;
  final ScrollController _controller = ScrollController();
  var _categoriesLoading = true;
  List<dynamic> eventCategories = [];
  var _loadingBelowListView = false;
  var _selectedEventCategoryId = '';
  var _selectedEventCategoryName = '';
  var hasNext = false;
  Location location = new Location();

  Future<void> _planParty() async {
    if (isLoggedIn) {
      if (party.checkAnyItem() || userCartItems.checkAnyItem()) {
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
                          userCartItems.clearCartItems();

                          Navigator.pop(context);
                          popUpNameAndDemandDialog();
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
                    RunMutation runMutation,
                    QueryResult? result,
                  ) {
                    if (result!.isLoading) {
                      return LoadingController();
                    }
                    return PopUpDialogAddToBasketWidget(
                        title: "Celebration.DiscardBasket",
                        content: "Celebration.DiscardBasketContent",
                        continueFunction: () {
                          runMutation({"userId": auth.currentUser.id});
                        });
                  },
                )));
      } else {
        party.resetParty();
        popUpNameAndDemandDialog();
      }
    } else {
      popUpLoginDialog();
    }
  }

  List<dynamic> merchantOutletList = [];
  @override
  void initState() {
    userCartItems = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    auth = context.read<Auth>();
    if (auth.currentUser.isAuthenticated!) {
      isLoggedIn = true;
    }
    Future.delayed(Duration.zero, () async {
      await _checkPositionAvailable();
      Provider.of<ScrollPartyProvider>(context, listen: false).resetScroller();
      eventCategories = await APIClient.getEventCategories();
      if (eventCategories.length > 0) {
        var eventCategoryIdParam = eventCategories[0]['id'];
        _selectedEventCategoryId = eventCategoryIdParam;
        print(_selectedEventCategoryId);
        print('_selectedEventCategoryId');

        _selectedEventCategoryName = eventCategories[0]['name'];
        var returnDataMap = await APIClient.getCategoryOutlets(
          positionProvider.userLatitude,
          positionProvider.userLongitude,
          eventCategoryIdParam,
          0,
        );
        merchantOutletList = returnDataMap['merchantOutletList'];
        hasNext = returnDataMap['hasNext'];
      }
      setState(() {
        _categoriesLoading = false;
      });
      if (widget.selectedPage == 4) {
        _planParty();
      }
    });

    //checkPermissionGranted();
    positionProvider = context.read<UserPositionProvider>();
    _controller.addListener(_onScroll);
    super.initState();
  }

  Future<bool> _checkPositionAvailable() async {
    isPositionAvailable = await getCurrentLocation();

    return isPositionAvailable;
  }

  void scrollDownForLoader() {
    //print('scroldown called');
    _controller.jumpTo(
      _controller.offset + 250,
    );
  }

  Future<void> outletForCategory({
    required String categoryId,
    required String categoryName,
    required int pageNumber,
  }) async {
    _selectedEventCategoryId = categoryId;
    _selectedEventCategoryName = categoryName;
    if (pageNumber == 0) {
      merchantOutletList = [];
      Provider.of<ScrollPartyProvider>(context, listen: false).resetScroller();
    }
    var returnDataMap = await APIClient.getCategoryOutlets(
      positionProvider.userLatitude,
      positionProvider.userLongitude,
      categoryId,
      pageNumber,
    );
    var merchantOutletListNew = returnDataMap['merchantOutletList'];
    merchantOutletList = [...merchantOutletList, ...merchantOutletListNew];
    hasNext = returnDataMap['hasNext'];
    Provider.of<ScrollPartyProvider>(context, listen: false).updateBlock();
    //  setState(() {});
  }

  Future<void> _onScroll() async {
    if (!_controller.hasClients) {
      return;
    }
    var maxScrollExtent = _controller.position.maxScrollExtent - 50;

    if ((_controller.offset >= maxScrollExtent &&
            !_controller.position.outOfRange) &&
        _categoriesLoading == false &&
        _loadingBelowListView == false) {
      setState(() {
        _loadingBelowListView = true;
      });

      Provider.of<ScrollPartyProvider>(context, listen: false).updateScroller();
      SharedPreferences preferences = await SharedPreferences.getInstance();

      if (hasNext == false) {
        setState(() {
          _loadingBelowListView = false;
        });
        return;
      }

      await outletForCategory(
        categoryId: _selectedEventCategoryId,
        categoryName: _selectedEventCategoryName,
        pageNumber: Provider.of<ScrollPartyProvider>(context, listen: false)
            .scrollerCounter,
      );
      // await Future.delayed(
      //   const Duration(
      //     seconds: 10,
      //   ),
      // );
      setState(() {
        _loadingBelowListView = false;
      });
    } else {
      // print(
      //     'attached:::2  :: ${Provider.of<ScrollPartyProvider>(context, listen: false).scrollerCounter} ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          controller: _controller,
          child: Column(
            children: [
              BannerCarousel(
                'BOOKING',
                height: MediaQuery.of(context).size.width * 0.6,
                isBottomCurve: true,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.32,
                  width: MediaQuery.of(context).size.width,
                  color: Color.fromRGBO(255, 213, 107, 1),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.only(top: 64.0, left: 25.0),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'PlanAPartyHome.Title',
                                    style: TextStyle(
                                      fontFamily: 'Arial Rounded MT Bold',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32,
                                    ),
                                    textAlign: TextAlign.left,
                                  ).tr(),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'PlanAPartyHome.SubTitle',
                                    style: TextStyle(
                                      fontFamily: 'Arial Rounded MT Light',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.left,
                                  ).tr(),
                                ])),
                        Spacer(),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 24,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(24),
                                  topLeft: Radius.circular(24)),
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              PlanAPartyStepsWidget(),
              Container(
                color: Colors.white,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              primary: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0))),
                          onPressed: () {
                            _planParty();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text('Button.StartPlanning',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.button)
                                  .tr(),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Text("PlanAParty.EventCategoryTitle",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .copyWith(fontWeight: FontWeight.w400))
                            .tr(),
                        SizedBox(height: 20.0),
                        _categoriesLoading
                            ? LoadingController()
                            : eventCategories.length > 0
                                ? Consumer<ScrollPartyProvider>(
                                    builder: (context, scrollProvider, _) {
                                      // print(
                                      //     'INSIDE PROVIDER:: ${scrollProvider.scrollerCounter} :: ${_selectedEventCategoryId} ::  ${_selectedEventCategoryName} :: ${scrollProvider.scrollerCounter}');
                                      return PartyEventCategoryOutletListingWidget(
                                        eventCategories,
                                        merchantOutletList,
                                        outletForCategory,
                                        _selectedEventCategoryName,
                                        _selectedEventCategoryId,
                                      );
                                    },
                                  )
                                : SizedBox(width: 0.0, height: 0.0),
                        _loadingBelowListView
                            ? LoadingController()
                            : SizedBox(width: 0.0, height: 0.0),
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void popUpNameAndDemandDialog() {
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

  Future<bool> getCurrentLocation() async {
    try {
      position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.low);
      print(position);
      positionProvider.setUserPosition(position!);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
