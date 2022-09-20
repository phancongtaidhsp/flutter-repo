import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gem_consumer_app/helpers/group-by-nested-array-properties-helper.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:status_change/status_change.dart';
import '../../providers/auth.dart';
import '../../providers/plan-a-party.dart';
import '../../screens/party/plan_a_party_landing_page.dart';
import '../../screens/party/widgets/next-widget.dart';
import '../../screens/product/product.gql.dart';
import '../../screens/review-basket/review_basket_page.dart';
import '../../widgets/loading_controller.dart';
import 'widgets/event-info-header-app-bar.dart';
import '../../values/color-helper.dart';
import 'widgets/party-confirmation-popup-widget.dart';
import 'widgets/party-merchant-outlet-details-widget.dart';
import 'widgets/party-product-list-widget.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PlanAPartyProductListPage extends StatefulWidget {
  static String routeName = '/plan-a-party-product-list';

  @override
  _PlanAPartyProductListPageState createState() =>
      _PlanAPartyProductListPageState();
}

class _PlanAPartyProductListPageState extends State<PlanAPartyProductListPage> {
  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;
  Position? position;
  bool checkAnyVenue = false;
  bool checkAnyFood = false;
  bool checkAnyDeco = false;
  bool hasSelectedVenue = false;
  bool hasSelectedFood = false;
  bool hasSelectedDeco = false;
  Map<String, String> _processesMap = {
    'VENUE': 'PlanAParty.Venue'.tr(),
    'F&B': 'PlanAParty.F&B'.tr(),
    'DECORATION': 'PlanAParty.Decoration'.tr()
  };
  final _processesTitle = [];
  String? merchantOutletId;
  late Auth auth;
  late FilterProvider filterProvider;

  Color getColor(int index) {
    final party = Provider.of<PlanAParty>(context, listen: false);

    if (index > party.planCurrentStep!) {
      return Colors.grey.withOpacity(0.5);
    } else {
      return primaryColor;
    }
  }

  @override
  void initState() {
    //Duration(milliseconds: 400);
    getCurrentLocation();
    filterProvider = context.read<FilterProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as PlanAPartyProductListPageArguments;
    merchantOutletId = args.merchantOutletId;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Consumer<PlanAParty>(
        builder: (context, party, _) {
          var combineDateTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            DateTime.now().hour,
            DateTime.now().minute,
          );
          if (party.date != null) {
            combineDateTime = DateTime(
                party.date!.year,
                party.date!.month,
                party.date!.day,
                party.timeOfDay!.hour,
                party.timeOfDay!.minute);
          }

          var serviceTypeAPIInput;
          serviceTypeAPIInput = party.collectionType;
          if (party.demands!.contains("VENUE") && party.venueProduct != null) {
            if (party.venueProduct!.outletProductInformation['outlet']['id'] !=
                merchantOutletId) {
              serviceTypeAPIInput = "DELIVERY";
            }
          }

          bool lastStep = false;

          if (party.planCurrentStep! == (party.demands!.length - 1)) {
            if (party.demands![party.planCurrentStep!] == "DECORATION" &&
                party.currentVenueAnyDeco == true) {
              lastStep = true;
            } else if (party.demands![party.planCurrentStep!] == "F&B" &&
                party.currentVenueAnyFB == true) {
              lastStep = true;
            }
          }

          return Scaffold(
            bottomSheet: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    offset: Offset(0.0, -2.0), //(x,y)
                    blurRadius: 4.0,
                  )
                ]),
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: NextWidget(
                  lastStep: lastStep,
                  validateInputs: _validateInputs,
                )),
            body: SafeArea(
              child: ListView(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 14, bottom: 10),
                      child: EventInfoAppBar(
                        cancel: cancel,
                        routeName: PlanAPartyProductListPage.routeName,
                      )),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Query(
                      options: QueryOptions(
                          variables: {
                            'outletId': merchantOutletId,
                            'selectedServiceType': serviceTypeAPIInput,
                            'selectedDate':
                                combineDateTime.toUtc().toIso8601String(),
                            'pax': party.pax
                          },
                          document:
                              gql(ProductGQL.GET_PRODUCT_OUTLETS_BY_OUTLET),
                          fetchPolicy: FetchPolicy.noCache),
                      builder: (QueryResult result,
                          {VoidCallback? refetch, FetchMore? fetchMore}) {
                        if (result.isLoading) {
                          return LoadingController();
                        }
                        if (result.data != null) {
                          List<dynamic> mappedVenueList = [];
                          List<dynamic> mappedFoodList = [];
                          List<dynamic> mappedGiftList = [];
                          List<dynamic> selectedRoomList = [];
                          List<dynamic> selectedFoodList = [];
                          List<dynamic> selectedGiftList = [];
                          var mapParameters = {
                            'outletId': merchantOutletId,
                            'selectedServiceType': serviceTypeAPIInput,
                            'selectedDate':
                                combineDateTime.toUtc().toIso8601String(),
                            'pax': party.pax
                          };
                          print(mapParameters);
                          final productOutletsData =
                              result.data!['GetProductOutletsByOutlet'] as List;
                          if (productOutletsData.isNotEmpty) {
                            final venueList = productOutletsData
                                .where((item) =>
                                    item['product']['productType'] == 'ROOM')
                                .toList();
                            final foodList = productOutletsData
                                .where((item) =>
                                    item['product']['productType'] == 'FOOD')
                                .toList();
                            final giftList = productOutletsData
                                .where((item) =>
                                    item['product']['productType'] == 'GIFT')
                                .toList();
                            checkAnyVenue = venueList.length > 0 ? true : false;
                            checkAnyFood = foodList.length > 0 ? true : false;
                            checkAnyDeco = giftList.length > 0 ? true : false;

                            if (party.venueProduct != null &&
                                party.venueProduct!
                                            .outletProductInformation['outlet']
                                        ["id"] ==
                                    productOutletsData[0]["outlet"]["id"] &&
                                checkAnyFood) {
                              party.setCurrentVenueAnyFB(true);
                            }

                            if (party.venueProduct != null &&
                                party.venueProduct!
                                            .outletProductInformation['outlet']
                                        ["id"] ==
                                    productOutletsData[0]["outlet"]["id"] &&
                                checkAnyDeco) {
                              party.setCurrentVenueAnyDeco(true);
                            }

                            //Venue Category
                            if (checkAnyVenue) {
                              List<dynamic> outletRoomCategoryList =
                                  sortCategories(
                                      productOutletsData[0]['outlet']
                                          ['productCategories'],
                                      "ROOM");
                              // outletRoomCategoryList.sort(
                              //     (a, b) => a['order'].compareTo(b['order']));
                              //print("CCCCC $outletRoomCategoryList");

                              outletRoomCategoryList.forEach((cat) {
                                venueList.forEach((item) {
                                  item['productCategories'].forEach((itemCat) {
                                    if (cat['id'] ==
                                            itemCat['category']['id'] &&
                                        !mappedVenueList.contains(item)) {
                                      mappedVenueList.add(item);
                                    }
                                  });
                                });
                              });
                            }
                            // Food and Beverage Category
                            if (checkAnyFood) {
                              List<dynamic> outletFoodCategoryList =
                                  sortCategories(
                                      productOutletsData[0]['outlet']
                                          ['productCategories'],
                                      "FOOD");
                              // outletFoodCategoryList.sort(
                              //     (a, b) => a['order'].compareTo(b['order']));
                              outletFoodCategoryList.forEach((cat) {
                                foodList.forEach((item) {
                                  item['productCategories'].forEach((itemCat) {
                                    if (cat['id'] ==
                                            itemCat['category']['id'] &&
                                        !mappedFoodList.contains(item)) {
                                      mappedFoodList.add(item);
                                    }
                                  });
                                });
                              });
                            }
                            // Decoration Category
                            if (checkAnyDeco) {
                              List<dynamic> outletGiftCategoryList =
                                  sortCategories(
                                      productOutletsData[0]['outlet']
                                          ['productCategories'],
                                      "GIFT");

                              outletGiftCategoryList.forEach((cat) {
                                giftList.forEach((item) {
                                  item['productCategories'].forEach((itemCat) {
                                    if (cat['id'] ==
                                            itemCat['category']['id'] &&
                                        !mappedGiftList.contains(item)) {
                                      mappedGiftList.add(item);
                                    }
                                  });
                                });
                              });
                            }
                            Map roomsData = Map();
                            Map foodsData = Map();
                            Map giftsData = Map();
                            _processesTitle.clear();
                            party.demands!.forEach((element) {
                              _processesTitle.add(_processesMap[element]);
                            });

                            if (party.venueProduct != null) {
                              if (party.venueProduct!.outletProductInformation[
                                          'product'] !=
                                      null &&
                                  party.venueProduct!.outletProductInformation[
                                          'outlet']['id'] ==
                                      merchantOutletId) {
                                selectedRoomList.clear();
                                var productId = party.venueProduct!
                                    .outletProductInformation['product']['id'];

                                var prod1 = mappedVenueList.where((d) {
                                  return d['product']['id'] == productId;
                                }).toList();
                                selectedRoomList.add(prod1[0]);
                              }
                            }
                            if (party.fbProducts!.length > 0) {
                              selectedFoodList.clear();
                              party.fbProducts!.forEach((foodProduct) {
                                var prod2 = mappedFoodList
                                    .where((d) =>
                                        d['id'] ==
                                        foodProduct
                                            .outletProductInformation["id"])
                                    .toList();
                                if (prod2.isNotEmpty) {
                                  selectedFoodList.add(prod2[0]);
                                }
                              });
                            }
                            if (party.decorationProducts!.length > 0) {
                              selectedGiftList.clear();
                              party.decorationProducts!
                                  .forEach((decorationProduct) {
                                var prod3 = mappedGiftList
                                    .where((d) =>
                                        d['id'] ==
                                        decorationProduct
                                            .outletProductInformation["id"])
                                    .toList();

                                if (prod3.isNotEmpty) {
                                  selectedGiftList.add(prod3[0]);
                                }
                              });
                            }

                            roomsData = generateTabs(
                                GroupByArray.groupByArray(
                                    mappedVenueList,
                                    sortCategories(
                                        productOutletsData[0]['outlet']
                                            ['productCategories'],
                                        "ROOM")),
                                selectedList: selectedRoomList);
                            foodsData = generateTabs(
                                GroupByArray.groupByArray(
                                    mappedFoodList,
                                    sortCategories(
                                        productOutletsData[0]['outlet']
                                            ['productCategories'],
                                        "FOOD")),
                                selectedList: selectedFoodList);
                            giftsData = generateTabs(
                                GroupByArray.groupByArray(
                                    mappedGiftList,
                                    sortCategories(
                                        productOutletsData[0]['outlet']
                                            ['productCategories'],
                                        "GIFT")),
                                selectedList: selectedGiftList);
                            return Column(
                              children: [
                                party.demands!.length > 1
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.grey[100],
                                        height: 70,
                                        child: StatusChange.tileBuilder(
                                          theme: StatusChangeThemeData(
                                            direction: Axis.horizontal,
                                            connectorTheme: ConnectorThemeData(
                                                space: 1.0, thickness: 1.0),
                                          ),
                                          builder:
                                              StatusChangeTileBuilder.connected(
                                            itemWidth: (_) =>
                                                MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                _processesTitle.length,
                                            nameWidgetBuilder:
                                                (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0),
                                                child: InkResponse(
                                                  child: Text(
                                                    _processesTitle[index],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2!
                                                        .copyWith(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color:
                                                                grayTextColor),
                                                  ),
                                                ),
                                              );
                                            },
                                            indicatorWidgetBuilder: (_, index) {
                                              return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (party.demands!
                                                          .contains("VENUE")) {
                                                        if (party
                                                                .venueProduct !=
                                                            null) {
                                                          onTapped(index);
                                                        }
                                                      } else {
                                                        onTapped(index);
                                                      }
                                                    });
                                                  },
                                                  child: _buildIcon(index,
                                                      party.planCurrentStep!));
                                            },
                                            lineWidgetBuilder: (index) {
                                              return SolidLineConnector(
                                                color: getColor(index),
                                                space: 2.5,
                                                thickness: 8,
                                              );
                                            },
                                            itemCount: _processesTitle.length,
                                          ),
                                        ),
                                      )
                                    : Container(width: 0.0, height: 0.0),
                                Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: _buildContent(
                                      productOutletsData[0]['outlet'],
                                      roomsData,
                                      foodsData,
                                      giftsData),
                                )
                              ],
                            );
                          }
                        }
                        return Container(width: 0.0, height: 0.0);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  continued() {
    filterProvider.clearAdvancedFilterAndSmartFilter();
    final party = Provider.of<PlanAParty>(context, listen: false);
    // ignore: unnecessary_statements
    if (party.planCurrentStep! < (party.demands!.length - 1)) {
      if (party.demands![party.planCurrentStep!] == "VENUE" &&
          party.featuredVenueOutletId != null) {
        Navigator.pushReplacementNamed(
            context, PlanAPartyLandingPage.routeName);
      }
      setState(() => party.setCurrentStep(party.planCurrentStep! + 1));

      if (party.demands![party.planCurrentStep!] == "F&B" &&
          checkAnyFood == false) {
        Navigator.popUntil(
            context, ModalRoute.withName(PlanAPartyLandingPage.routeName));
        if (party.demands![party.planCurrentStep! - 1] != "VENUE" &&
            !party.currentVenueAnyFB) {
          setState(() => party.setCurrentStep(party.planCurrentStep! - 1));
        }
      }
      if (party.demands![party.planCurrentStep!] == "DECORATION" &&
          checkAnyDeco == false) {
        Navigator.popUntil(
            context, ModalRoute.withName(PlanAPartyLandingPage.routeName));
        if (party.demands![party.planCurrentStep! - 1] != "VENUE" &&
            !party.currentVenueAnyFB) {
          setState(() => party.setCurrentStep(party.planCurrentStep! - 1));
        }
      }
    } else {
      if (party.demands![party.planCurrentStep!] == "DECORATION" &&
          party.currentVenueAnyDeco == true) {
        Navigator.pushNamed(context, ReviewBasketPage.routeName);
      } else if (party.demands![party.planCurrentStep!] == "F&B" &&
          party.currentVenueAnyFB == true) {
        Navigator.pushNamed(context, ReviewBasketPage.routeName);
      } else {
        Navigator.popUntil(
            context, ModalRoute.withName(PlanAPartyLandingPage.routeName));
      }
    }
  }

  cancel() {
    final party = Provider.of<PlanAParty>(context, listen: false);

    // ignore: unnecessary_statements
    if (party.planCurrentStep! > 0) {
      setState(() => party.setCurrentStep(party.planCurrentStep! - 1));
    }
  }

  List<dynamic> sortCategories(dynamic data, String productType) {
    List<dynamic> result = [];
    result = data
        .where((item) => item['category']['productType'] == productType)
        .map((item) => {
              "id": item['category']['id'],
              "name": item['category']['name'],
              "order": item['order']
            })
        .toList();
    //print("Sort Categories Result: $result");
    return result;
  }

  Map<String, List<dynamic>> generateTabs(
    Map<String, List<dynamic>> mappedData, {
    List<dynamic>? selectedList,
  }) {
    Map<String, List<dynamic>> newList = {};
    // print("long data ");
    // print("MAPPED DATA IN GENERATE TABS $mappedData");

    // print("SELECTED LIST IN GENERATE TABS $selectedList");
    if (selectedList != null) {
      // print(1);
      if (selectedList.length > 0) {
        // print("List. ${selectedList.length}");
        // print("Check item $selectedList");
        // print(2);
        newList.putIfAbsent('Selected', () => selectedList);
      }
    }
    if (mappedData.length > 0) {
      //print("The Key Length ${mappedData.length}");
      mappedData.keys.forEach((item) {
        // print("ITEMMMM $item");
        if (item != "Selected") {
          newList.putIfAbsent(item, () {
            return mappedData[item]!;
          });
        }
      });
    }

    if (newList.keys.contains("Selected")) {
      if (newList["Selected"]!.isEmpty) {
        newList.remove("Selected");
      }
    }
    // print("IN THE END NEW LIST $newList");
    return newList;
  }

  Widget _buildIcon(int index, int currentStep) {
    if (index <= currentStep) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 12.0,
        ),
      );
    } else {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3)),
      );
    }
  }

  dynamic _buildContent(
    Map<String, dynamic> outletData,
    Map roomData,
    Map foodData,
    Map giftData,
  ) {
    final party = Provider.of<PlanAParty>(context, listen: false);
    final double distance = outletData['distance'] != null
        ? outletData['distance'].toDouble()
        : null;
    final double averageReview = outletData['averageReview'];
    var combineDateTime = new DateTime(party.date!.year, party.date!.month,
        party.date!.day, party.timeOfDay!.hour, party.timeOfDay!.minute);
    if (party.planCurrentStep != -1) {
      switch (party.demands![party.planCurrentStep!]) {
        case "VENUE":
          if (party.demands!.contains("VENUE")) {
            if (party.venueProduct != null) {
              print("VEBUE");
              return Query(
                options: QueryOptions(
                    variables: {
                      'outletId': party.venueProduct!
                          .outletProductInformation['outlet']["id"],
                      'selectedServiceType': party.collectionType,
                      'selectedDate': combineDateTime.toUtc().toIso8601String(),
                      'pax': party.pax
                    },
                    document: gql(ProductGQL.GET_PRODUCT_OUTLETS_BY_OUTLET),
                    fetchPolicy: FetchPolicy.noCache),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.isLoading) {
                    return LoadingController();
                  }
                  if (result.data != null) {
                    List<dynamic> mappedVenueList = [];
                    final selectedVenueProduct =
                        result.data!['GetProductOutletsByOutlet'];
                    final venueList = selectedVenueProduct
                        .where(
                            (item) => item['product']['productType'] == 'ROOM')
                        .toList();

                    List<dynamic> outletRoomCategoryList = sortCategories(
                        selectedVenueProduct[0]['outlet']['productCategories'],
                        "ROOM");
                    outletRoomCategoryList
                        .sort((a, b) => a['order'].compareTo(b['order']));
                    venueList.forEach((item) {
                      outletRoomCategoryList.forEach((cat) {
                        item['productCategories'].forEach((itemCat) {
                          if (cat['id'] == itemCat['category']['id']) {
                            mappedVenueList.add(item);
                          }
                        });
                      });
                    });
                    Map selectedVenueData = Map();
                    List<dynamic> selectedRoomList = [];
                    if (party.venueProduct != null) {
                      var prod1 = mappedVenueList.where((d) {
                        print(
                            '${d['product']['id']} == ${party.venueProduct!.id}');
                        return d['product']['id'] ==
                            party.venueProduct!
                                .outletProductInformation['product']['id'];
                      }).toList();

                      selectedRoomList.add(prod1[0]);
                    }
                    selectedVenueData = generateTabs(
                        groupBy(
                            mappedVenueList,
                            (obj) => obj['productCategories'][0]['category']
                                    ['name']
                                .trim()),
                        selectedList: selectedRoomList);
                    return Column(
                      children: [
                        PartyMerchantOutletDetailsWidget(
                            selectedVenueProduct[0]["outlet"],
                            distance,
                            averageReview),
                        PartyProductListWidget(
                          selectedVenueData,
                          "ROOM",
                          isSelectOne: true,
                        )
                      ],
                    );
                  }
                  return Container(width: 0.0, height: 0.0);
                },
              );
            }
          }
          return roomData.length > 0
              ? Column(
                  children: [
                    PartyMerchantOutletDetailsWidget(
                        outletData, distance, averageReview),
                    PartyProductListWidget(
                      roomData,
                      "ROOM",
                      isSelectOne: true,
                    )
                  ],
                )
              : Container(
                  height: 350,
                  child: Center(
                      child: Text(
                    "CelebrationHome.EmptyProduct",
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(fontWeight: FontWeight.normal),
                  ).tr()),
                );
        case "F&B":
          print("F&B");
          if (party.fbProducts != null && party.fbProducts!.length > 0) {}
          // if (party.demands!.contains("VENUE")) {
          //   if (party.venueProduct != null && party.currentVenueAnyFB) {
          //     return Query(
          //       options: QueryOptions(
          //           variables: {
          //             'outletId': party.venueProduct!
          //                 .outletProductInformation['outlet']["id"],
          //             'selectedServiceType': party.collectionType,
          //             'selectedDate':
          //                 party.date!.toIso8601String().substring(0, 10),
          //             'pax': party.pax
          //           },
          //           document: gql(ProductGQL.GET_PRODUCT_OUTLETS_BY_OUTLET),
          //           fetchPolicy: FetchPolicy.cacheAndNetwork),
          //       builder: (QueryResult result,
          //           {VoidCallback? refetch, FetchMore? fetchMore}) {
          //         if (result.isLoading) {
          //           return LoadingController();
          //         }
          //         if (result.data != null) {
          //           List<dynamic> mappedFoodList = [];
          //           final productList =
          //               result.data!['GetProductOutletsByOutlet'];
          //           final foodList = productList
          //               .where(
          //                   (item) => item['product']['productType'] == 'FOOD')
          //               .toList();
          //           List<dynamic> outletFoodCategoryList = sortCategories(
          //               productList[0]['outlet']['productCategories'], "FOOD");
          //           outletFoodCategoryList
          //               .sort((a, b) => a['order'].compareTo(b['order']));
          //           foodList.forEach((item) {
          //             outletFoodCategoryList.forEach((cat) {
          //               item['productCategories'].forEach((itemCat) {
          //                 if (cat['id'] == itemCat['category']['id']) {
          //                   mappedFoodList.add(item);
          //                 }
          //               });
          //             });
          //           });
          //           Map productData = Map();
          //           List<dynamic> selectedFoodList = [];
          //           if (party.fbProducts != null &&
          //               party.fbProducts!.length > 0) {
          //             party.fbProducts!.forEach((p) {
          //               var prod1 = mappedFoodList.where((d) {
          //                 return d['product']['id'] ==
          //                     p.outletProductInformation['product']['id'];
          //               }).toList();
          //               if (prod1.length > 0) {
          //                 selectedFoodList.add(prod1[0]);
          //               }
          //             });
          //           }
          //           productData = generateTabs(
          //               groupBy(
          //                   mappedFoodList,
          //                   (obj) => obj['productCategories'][0]['category']
          //                           ['name']
          //                       .trim()),
          //               selectedList: selectedFoodList);
          //           return Column(
          //             children: [
          //               PartyMerchantOutletDetailsWidget(
          //                   productData[0]["outlet"], distance, averageReview),
          //               PartyProductListWidget(
          //                 productData,
          //                 "FOOD",
          //               )
          //             ],
          //           );
          //         }
          //         return Container(width: 0.0, height: 0.0);
          //       },
          //     );
          //   }
          // }
          return foodData.length > 0
              ? Column(
                  children: [
                    PartyMerchantOutletDetailsWidget(
                        outletData, distance, averageReview),
                    PartyProductListWidget(
                      foodData,
                      "FOOD",
                    )
                  ],
                )
              : Container(
                  height: 350,
                  child: Center(
                      child: Text(
                    "CelebrationHome.EmptyProduct",
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(fontWeight: FontWeight.normal),
                  ).tr()),
                );

        case "DECORATION":
          // if (party.demands!.contains("VENUE")) {
          //   if (party.venueProduct != null && party.currentVenueAnyDeco) {
          //     return Query(
          //       options: QueryOptions(
          //           variables: {
          //             'outletId': party.venueProduct!
          //                 .outletProductInformation['outlet']["id"],
          //             'selectedServiceType': party.collectionType,
          //             'selectedDate':
          //                 party.date!.toIso8601String().substring(0, 10),
          //             'pax': party.pax
          //           },
          //           document: gql(ProductGQL.GET_PRODUCT_OUTLETS_BY_OUTLET),
          //           fetchPolicy: FetchPolicy.cacheAndNetwork),
          //       builder: (QueryResult result,
          //           {VoidCallback? refetch, FetchMore? fetchMore}) {
          //         if (result.isLoading) {
          //           return LoadingController();
          //         }
          //         if (result.data != null) {
          //           List<dynamic> mappedGiftList = [];
          //           final productList =
          //               result.data!['GetProductOutletsByOutlet'];
          //           final giftList = productList
          //               .where(
          //                   (item) => item['product']['productType'] == 'GIFT')
          //               .toList();

          //           List<dynamic> outletGiftCategoryList = sortCategories(
          //               productList[0]['outlet']['productCategories'], "GIFT");
          //           outletGiftCategoryList
          //               .sort((a, b) => a['order'].compareTo(b['order']));
          //           giftList.forEach((item) {
          //             outletGiftCategoryList.forEach((cat) {
          //               item['productCategories'].forEach((itemCat) {
          //                 if (cat['id'] == itemCat['category']['id']) {
          //                   mappedGiftList.add(item);
          //                 }
          //               });
          //             });
          //           });
          //           Map productData = Map();
          //           List<dynamic> selectedGiftList = [];
          //           if (party.decorationProducts != null &&
          //               party.decorationProducts!.length > 0) {
          //             party.decorationProducts!.forEach((p) {
          //               var prod1 = mappedGiftList.where((d) {
          //                 return d['product']['id'] ==
          //                     p.outletProductInformation['product']['id'];
          //               }).toList();
          //               if (prod1.length > 0) {
          //                 selectedGiftList.add(prod1[0]);
          //               }
          //             });
          //           }
          //           productData = generateTabs(
          //               groupBy(
          //                   mappedGiftList,
          //                   (obj) => obj['productCategories'][0]['category']
          //                           ['name']
          //                       .trim()),
          //               selectedList: selectedGiftList);
          //           return Column(
          //             children: [
          //               PartyMerchantOutletDetailsWidget(
          //                   productData[0]["outlet"], distance, averageReview),
          //               PartyProductListWidget(
          //                 productData,
          //                 "GIFT",
          //               )
          //             ],
          //           );
          //         }
          //         return Container(width: 0.0, height: 0.0);
          //       },
          //     );
          //   }
          // }

          return giftData.length > 0
              ? Column(
                  children: [
                    PartyMerchantOutletDetailsWidget(
                        outletData, distance, averageReview),
                    PartyProductListWidget(
                      giftData,
                      "GIFT",
                    )
                  ],
                )
              : Container(
                  height: 350,
                  child: Center(
                      child: Text(
                    "CelebrationHome.EmptyProduct",
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(fontWeight: FontWeight.normal),
                  ).tr()),
                );

        default:
          return Container(width: 0.0, height: 0.0);
      }
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  onTapped(int step) {
    final party = Provider.of<PlanAParty>(context, listen: false);
    party.setCurrentStep(step);
    if (party.demands!.contains("VENUE") && party.venueProduct != null) {}
    if (party.demands![party.planCurrentStep!] == "F&B" &&
        checkAnyFood == false) {
      Navigator.pushNamed(context, PlanAPartyLandingPage.routeName);
    }
    if (party.demands![party.planCurrentStep!] == "DECORATION" &&
        checkAnyDeco == false) {
      Navigator.pushNamed(context, PlanAPartyLandingPage.routeName);
      // print("12345");
      // Navigator.pushNamed(context, PlanAPartyLandingPage.routeName)
      //     .then((value) {
      //   print("123");
      //   party.setCurrentStep(party.planCurrentStep! - 1);
      // });
    }
  }

  _validateInputs() {
    final party = Provider.of<PlanAParty>(context, listen: false);
    if (party.demands!.length > 0 && _currentStep != -1) {
      if (party.demands![_currentStep] == "VENUE") {
        if (party.venueProduct == null) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => Dialog(
                    child: PopUpConfirmationWidget(
                      title: "PlanAParty.ChooseYourVenue",
                      content: "PlanAParty.SelectVenue",
                      continueFunction: continued,
                      ableToSkip: false,
                    ),
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(24),
                  ));
        } else {
          continued();
        }
      }
      if (party.demands![_currentStep] == "F&B") {
        if (party.fbProducts!.length <= 0) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => Dialog(
                  child: PopUpConfirmationWidget(
                      title: "PlanAParty.ChooseYourFood",
                      content: "PlanAParty.SelectFood",
                      continueFunction: continued),
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(24)));
        } else {
          continued();
        }
      }
      if (party.demands![_currentStep] == "DECORATION") {
        if (party.decorationProducts!.length <= 0) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => Dialog(
                  child: PopUpConfirmationWidget(
                      title: "PlanAParty.ChooseYourGift",
                      content: "PlanAParty.SelectGift",
                      continueFunction: continued),
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(24)));
        } else {
          continued();
        }
      }
    }
  }
}

class PlanAPartyProductListPageArguments {
  final String merchantOutletId;

  PlanAPartyProductListPageArguments(this.merchantOutletId);
}
