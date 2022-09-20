import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/api-client.dart';
import 'package:gem_consumer_app/models/Outlet.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/pop-up-dialog-add-to-basket-widget.dart';
import 'package:gem_consumer_app/screens/login/login.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/view_merchant_outlet_page.dart';
import 'package:gem_consumer_app/screens/merchant-outlet/widgets/merchant-outlet-app-bar-widget.dart';
import 'package:gem_consumer_app/screens/outlet/outlet_and_product_carousel.dart';
import 'package:gem_consumer_app/screens/outlet/outlet_info.dart';
import 'package:gem_consumer_app/screens/outlet/product_list.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-login-popup-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-popup-name-and-demand.dart';
import 'package:gem_consumer_app/screens/review-basket/gql/basket.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:gem_consumer_app/widgets/pop-up-error-message-widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class OutletScreen extends StatefulWidget {
  const OutletScreen({Key? key, required this.outletId}) : super(key: key);
  final String outletId;
  @override
  State<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends State<OutletScreen>
    with SingleTickerProviderStateMixin {
  late PlanAParty party;
  late Auth auth;
  late AddToCartItems userCart;
  var _apiLoadingData = true;
  late Outlet outletData;
  Map<String, dynamic> outlet = {};
  late TabController _tabController;
  var indexSelected = 0;
  var tabsMap = [];
  var productFood = [];
  var productRoom = [];
  var productDecoration = [];
  var tabCounter = 0;
  var dataList = [];
  var _errorInApi = false;
  Future<void> _getData() async {
    var response = await APIClient.getOutletInformation(widget.outletId);
    print(response);
    print('response');
    if (response != null) {
      var outletProductCollection =
          response['GetAllProductOutletsByOutlet'] as List;
      var mapData = outletProductCollection.first;
      outlet = mapData['outlet'] as Map<String, dynamic>;
      List<String> photos = [];
      var outletPhotos = outlet['photos'] as List;
      outletPhotos.forEach((element) {
        photos.add(element);
      });

      outletData = Outlet(
        id: outlet['id'],
        name: outlet['name'],
        thumbNail: outlet['thumbNail'],
        photos: photos,
        merchantId: outlet['merchantId'],
        email: outlet['email'],
        countryId: outlet['countryId'],
        address1: outlet['address1'],
        address2: outlet['address2'],
        state: outlet['state'],
        city: outlet['city'],
        postalCode: outlet['postalCode'],
        location: outlet['location'],
        maxPax: outlet['maxPax'],
        introduction: outlet['introduction'],
        latitude: outlet['latitude'],
        longitude: outlet['longitude'],
        maxDeliveryKM: outlet['maxDeliveryKM'],
        deliveryFeePerKM: outlet['deliveryFeePerKM'],
        firstNthKM: outlet['firstNthKM'],
        firstNthKMDeliveryFee: outlet['firstNthKMDeliveryFee'],
        remark: outlet['remark'],
        commissionType: outlet['commissionType'],
        commissionRate: outlet['commissionRate'],
      );
      outletProductCollection.forEach((element) {
        if (element['product']['productType'] == 'FOOD') {
          productFood.add(element);
        }
        if (element['product']['productType'] == 'ROOM') {
          productRoom.add(element);
        }
        if (element['product']['productType'] == 'GIFT') {
          productDecoration.add(element);
        }
      });
    } else {
      setState(() {
        _errorInApi = true;
        _apiLoadingData = false;
      });
      return;
    }

    if (productRoom.isNotEmpty) {
      tabsMap.add('Venue');
      dataList.add(productRoom);
      tabCounter++;
    }
    if (productFood.isNotEmpty) {
      tabsMap.add('Food');
      dataList.add(productFood);
      tabCounter++;
    }
    if (productDecoration.isNotEmpty) {
      tabsMap.add('Decoration');
      dataList.add(productDecoration);
      tabCounter++;
    }

    _tabController = TabController(
      initialIndex: indexSelected,
      length: tabCounter,
      vsync: this,
    );

    setState(() {
      _apiLoadingData = false;
    });
  }

  @override
  void initState() {
    auth = context.read<Auth>();
    userCart = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: lightBack,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        bottomSheet: _apiLoadingData || _errorInApi
            ? const SizedBox(
                width: 0,
              )
            : _buildBottomSheetButton(),
        body: SafeArea(
          child: _apiLoadingData
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(
                        height: 20,
                      ),
                      Text('Loading outlet'),
                    ],
                  ),
                )
              : _errorInApi
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //CircularProgressIndicator(),

                          Text(
                            'General.OutletLoadingError'.tr(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            label: Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            icon: Icon(Icons.arrow_back),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Stack(
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Column(
                                      children: [
                                        OutletAndProductCarousel(
                                          merchantOutletPhotos:
                                              outletData.photos!,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                        ),
                                        OutletInfo(
                                            outletData: outletData,
                                            outlet: outlet),
                                      ],
                                    ),
                                    _infoButton(context),
                                  ],
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 0.0),
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TabBar(
                                          controller: _tabController,
                                          onTap: (index) {
                                            setState(() {
                                              indexSelected = index;
                                              _tabController.animateTo(index);
                                            });
                                          },
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .button!
                                              .copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                          unselectedLabelStyle:
                                              Theme.of(context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(fontSize: 14),
                                          isScrollable: true,
                                          labelPadding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 6.0),
                                          indicatorWeight: 4,
                                          indicatorColor: primaryColor,
                                          indicatorSize:
                                              TabBarIndicatorSize.label,
                                          tabs: List.generate(
                                            tabCounter,
                                            (index) => Text(
                                              tabsMap[index]
                                                  .toString()
                                                  .toUpperCase(),
                                            ),
                                          ),
                                        ),
                                        IndexedStack(
                                          index: indexSelected,
                                          children: List.generate(tabCounter,
                                              (index) {
                                            return indexSelected == index
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 100,
                                                    ),
                                                    child: ProductList(
                                                      dataList: dataList[index],
                                                      outletName:
                                                          outletData.name!,
                                                      outlet: outlet,
                                                      roomSelected:
                                                          indexSelected == 0 &&
                                                              productRoom
                                                                  .isNotEmpty,
                                                    ),
                                                  )
                                                : Container(
                                                    width: 0,
                                                  );
                                          }),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(top: 12.0, child: MerchantOutletAppBar()),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _infoButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.265,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: CircleBorder(), primary: Colors.white),
        onPressed: () {
          Navigator.pushNamed(
            context,
            ViewMerchantOutletPage.routeName,
            arguments: ViewMerchantOutletPageArguments(
              outletData.id,
            ),
          );
        },
        child: SvgPicture.asset('assets/images/icon-info.svg',
            width: 10, height: MediaQuery.of(context).size.height * 0.055),
      ),
    );
  }

  Widget _buildBottomSheetButton() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          offset: Offset(0.0, -2.0), //(x,y)
          blurRadius: 4.0,
        )
      ]),
      width: MediaQuery.of(context).size.width * 1,
      alignment: Alignment.bottomCenter,
      height: 70,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 5,
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
            primary: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
          ),
          onPressed: () async {
            party.setFeaturedVenueOutletId(outletData.id);
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
                                  party.setFeaturedVenueOutletId(outletData.id);
                                  popUpPartyServiceDialog();
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
                popUpPartyServiceDialog();
              }
            } else {
              popUpLoginDialog();
            }
          },
          child: Text('Button.StartPlanningAParty'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.button),
        ),
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
