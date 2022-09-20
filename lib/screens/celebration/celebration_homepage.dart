import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/providers/user-position-provider.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/celebration-fixed-header.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/product-list-widget.dart';

class CelebrationHomePage extends StatefulWidget {
  static String routeName = '/celebration-home';

  @override
  _CelebrationHomePageState createState() => _CelebrationHomePageState();
}

class _CelebrationHomePageState extends State<CelebrationHomePage> {
  //late AddToCartItems userCart;
  late PlanAParty party;
  late Auth auth;
  late geo.Position position;
  late UserPositionProvider positionProvider;
  Location location = new Location();

  checkPermissionGranted() async {
    await location.hasPermission().then((value) {
      if (value == PermissionStatus.granted) {
        print("Permission granted");
        getCurrentLocation();
      } else if (value == PermissionStatus.denied) {
        print("Permission denied");
      } else if (value == PermissionStatus.deniedForever) {
        print("Permission deniedForever");
      } else if (value == PermissionStatus.grantedLimited) {
        print("Permission granted limited");
      }
      print("return Value  $value");
      return value;
    });
  }

  @override
  void initState() {
    //userCart = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    //userCart.addListener(_listener);
    auth = context.read<Auth>();
    positionProvider = context.read<UserPositionProvider>();
    checkPermissionGranted();
    super.initState();
  }

  @override
  void dispose() {
    //userCart.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('celebration home page');
    final args = ModalRoute.of(context)!.settings.arguments
        as CelebrationHomePageArguments;
    var combineDateTime = new DateTime(
        args.selectedDate.year,
        args.selectedDate.month,
        args.selectedDate.day,
        args.selectedTime.hour,
        args.selectedTime.minute);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: CelebrationHeaderSliverFixedHeaderDelegate(
                      minHeight: 140.0,
                      maxHeight: 300.0,
                      child: Container(
                          height: 42,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 0.0),
                            child: Text("CelebrationHome.Featured",
                                    style:
                                        Theme.of(context).textTheme.headline3)
                                .tr(),
                          )),
                    ))
              ];
            },
            body: Query(
                options: QueryOptions(
                    document: gql(
                        ProductGQL.GET_FEATURED_CELEBRATION_PRODUCT_OUTLETS),
                    variables: {
                      'selectedServiceType': args.selectedServiceType,
                      'selectedDate': combineDateTime.toUtc().toIso8601String(),
                      'pax': args.pax,
                      'userLatitude': args.selectedServiceType == "DELIVERY"
                          ? args.selectedAddress!.latitude
                          : null,
                      'userLongitude': args.selectedServiceType == "DELIVERY"
                          ? args.selectedAddress!.longitude
                          : null,
                    },
                    fetchPolicy: FetchPolicy.cacheAndNetwork),
                builder: (QueryResult? result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result!.isLoading) {
                    return LoadingController();
                  }

                  if (result.data != null) {
                    List productOutletList =
                        result.data!["GetFeaturedCelebrationProductOutlets"];
                    productOutletList.removeWhere(
                        (p) => p["product"]["isRecommended"] == false);

                    Map<String, dynamic> productsData = {};
                    productOutletList.forEach((productOutlet) {
                      productOutlet["product"]["productCategories"]
                          .forEach((categories) {
                        if (categories['category']['name'] != null) {
                          if (productsData[categories['category']['name']] ==
                              null) {
                            productsData[categories['category']['name']] = [];
                          }
                          productsData[categories['category']['name']].add({
                            ...productOutlet,
                            'outletId': productOutlet['outlet']['id']
                          });
                        }
                      });
                    });

                    return productsData.length > 0
                        ? Column(children: <Widget>[
                            Flexible(
                              child: ProductListWidget(
                                  productsData,
                                  args.selectedServiceType,
                                  args.selectedDate,
                                  args.selectedTime,
                                  args.pax,
                                  selectedAddress: args.selectedAddress),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.068),
                            // userCart.checkAnyItem()
                            //     ? ReviewBasketWidget(
                            //         price: userCart.calculateTotalPrice(),
                            //         itemCount:
                            //             userCart.calculateCartItemsQuantity(),
                            //         reviewBasket: () {
                            //           Navigator.pushNamed(
                            //               context, ReviewBasketPage.routeName);
                            //         })
                            //     : Container(width: 0, height: 0)
                          ])
                        : Center(
                            child: Container(
                              child: Text(
                                "CelebrationHome.EmptyProduct",
                                style: Theme.of(context)
                                    .textTheme
                                    .button!
                                    .copyWith(fontWeight: FontWeight.normal),
                              ).tr(),
                            ),
                          );
                  }
                  return Center(
                    child: Container(
                      child: Text(
                        "CelebrationHome.EmptyProduct",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(fontWeight: FontWeight.normal),
                      ).tr(),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  getCurrentLocation() async {
    position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best);
    positionProvider.setUserPosition(position);
  }
}

class CelebrationHomePageArguments {
  final String selectedServiceType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int pax;
  final UserAddress? selectedAddress;

  CelebrationHomePageArguments(
      this.selectedServiceType, this.selectedDate, this.selectedTime, this.pax,
      {required this.selectedAddress});
}
