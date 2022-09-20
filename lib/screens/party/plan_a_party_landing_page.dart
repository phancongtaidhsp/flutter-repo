import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/providers/user-position-provider.dart';
import 'package:gem_consumer_app/screens/party/widgets/next-widget.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-confirmation-popup-widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:status_change/status_change.dart';
import '../../configuration.dart';
import '../../providers/plan-a-party.dart';
import '../../screens/celebration/widgets/product-category-selection-widget.dart';
import '../../screens/party/gql/party.gql.dart';
import '../../screens/party/plan_a_party_product_list_page.dart';
import '../../screens/party/widgets/event-info-header-app-bar.dart';
import '../../screens/party/plan_a_party_outlet_list_page.dart';
import '../../screens/party/widgets/party-filter-widgets/party-room-pax-selection-widget.dart';
import '../../screens/party/widgets/party-filter-widgets/party-room-smart-filter-page.dart';
import '../../screens/party/widgets/selected-outlet-widget.dart';
import '../../values/color-helper.dart';
import '../../widgets/loading_controller.dart';
import '../review-basket/review_basket_page.dart';

class PlanAPartyLandingPage extends StatefulWidget {
  static String routeName = '/plan-a-party-landing-page';

  @override
  _PlanAPartyLandingPageState createState() => _PlanAPartyLandingPageState();
}

class _PlanAPartyLandingPageState extends State<PlanAPartyLandingPage> {
  late FilterProvider filterProvider;
  late UserPositionProvider positionProvider;
  late PlanAParty party;
  Map<String, String> _processesMap = {
    'VENUE': 'PlanAParty.Venue'.tr(),
    'F&B': 'PlanAParty.F&B'.tr(),
    'DECORATION': 'PlanAParty.Decoration'.tr()
  };
  final _processesTitle = [];
  List<String> selectedDemand = [];

  TextEditingController venueTextController = TextEditingController();
  TextEditingController fbTextController = TextEditingController();
  TextEditingController decoTextController = TextEditingController();

  Color getColor(int index) {
    if (index > party.planCurrentStep!) {
      return Colors.grey.withOpacity(0.5);
    } else {
      return primaryColor;
    }
  }

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    party = context.read<PlanAParty>();
    positionProvider = context.read<UserPositionProvider>();

    if (party.demands!.contains("VENUE")) {
      filterProvider.maxPaxNoListener = party.pax!;
    }
    super.initState();
  }

  @override
  void dispose() {
    filterProvider.clearAdvancedFilterAndSmartFilterNoListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("PlanAPartyLandingPage build");
    var combineDateTime = new DateTime(
      party.date!.year,
      party.date!.month,
      party.date!.day,
      party.timeOfDay!.hour,
      party.timeOfDay!.minute,
    );
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarColor: lightBack,
            statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SafeArea(
              child:
                  Consumer<FilterProvider>(builder: (context, filter, child) {
                return Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 10),
                        child: EventInfoAppBar(
                          cancel: cancel,
                          routeName: PlanAPartyLandingPage.routeName,
                        )),
                    Expanded(
                        child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      child: Consumer<PlanAParty>(
                          builder: (context, party, child) {
                        _processesTitle.clear();
                        party.demands!.forEach((element) {
                          _processesTitle.add(_processesMap[element]);
                        });
                        return SingleChildScrollView(
                          child: Column(children: [
                            party.demands!.length > 1
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
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
                                            MediaQuery.of(context).size.width /
                                            _processesTitle.length,
                                        nameWidgetBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                                            FontWeight.normal,
                                                        color: grayTextColor),
                                              ),
                                            ),
                                          );
                                        },
                                        indicatorWidgetBuilder: (_, index) {
                                          return InkWell(
                                              onTap: () {
                                                if (party.demands!
                                                    .contains("VENUE")) {
                                                  if (party.venueProduct !=
                                                      null) {
                                                    party.setCurrentStep(index);
                                                    filterProvider
                                                        .clearAdvancedFilterAndSmartFilter();
                                                  }
                                                } else {
                                                  party.setCurrentStep(index);
                                                  filterProvider
                                                      .clearAdvancedFilterAndSmartFilter();
                                                }
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
                            _buildContent(combineDateTime)
                          ]),
                        );
                      }),
                    )),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          offset: Offset(0.0, -2.0), //(x,y)
                          blurRadius: 4.0,
                        )
                      ]),
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Consumer<PlanAParty>(
                        builder: (context, value, child) {
                          return NextWidget(
                            lastStep: party.planCurrentStep ==
                                (party.demands!.length - 1),
                            validateInputs: _validateInputs,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ));
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

  Widget _buildContent(DateTime combineDateTime) {
    switch (party.demands![party.planCurrentStep!]) {
      case "VENUE":
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 42,
                child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: venueTextController,
                    onChanged: (text) {
                      setState(() {});
                    },
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.normal, color: grayTextColor),
                    decoration: InputDecoration(
                        isDense: false,
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        labelText: 'Search...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(fontSize: 12),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 31,
                          minHeight: 31,
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 28,
                          ),
                        )),
                    keyboardType: TextInputType.text),
              ),
              SizedBox(height: 10),
              Container(
                height: 57,
                padding: EdgeInsets.only(bottom: 15),
                child: ListView(
                  padding: EdgeInsets.only(bottom: 3),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterButton(context, "CelebrationHome.Filter",
                        icon: "assets/images/icon-filter.svg"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.024,
                    ),
                    ProductCategorySelectionWidget("ROOM"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.024,
                    ),
                    PartyPaxSelectionWidget(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Query(
                    options: QueryOptions(
                        document: gql(PartyGQL.GET_OUTLETS),
                        variables: {
                          "selectedServiceTime":
                              combineDateTime.toUtc().toIso8601String(),
                          'merchantOutlet': {
                            "eventCategoryId": party.eventCategory,
                            "merchantTypeIds":
                                Configuration.VENUE_MERCHANT_TYPE_IDS
                          },
                          "filterSelection": {
                            "maxPax": filterProvider.maxPax,
                            "priceIndicatorsList":
                                filterProvider.priceIndicatorSelection,
                            "locationsList": filterProvider.locationSelection,
                            "specialDietsList":
                                filterProvider.specialDietSelection,
                            "productCategoriesList":
                                filterProvider.productCategorySelection,
                            "amenitiesList": filterProvider.amenitySelection,
                            "cuisinesList": filterProvider.cuisineSelection
                          },
                          "productType": "ROOM",
                          "searchText": venueTextController.text,
                          "userLatitude": party.collectionType == 'DELIVERY'
                              ? party.deliveryAddress!.latitude
                              : positionProvider.userLatitude,
                          "userLongitude": party.collectionType == 'DELIVERY'
                              ? party.deliveryAddress!.longitude
                              : positionProvider.userLongitude,
                          "selectedServiceType": party.collectionType,
                          "venueOutletId": null,
                        },
                        fetchPolicy: FetchPolicy.noCache),
                    builder: (QueryResult result,
                        {VoidCallback? refetch, FetchMore? fetchMore}) {
                      if (result.hasException) {
                        print("exception: ${result.exception.toString()}");
                      }
                      if (result.isLoading) {
                        return Container(
                            height: MediaQuery.of(context).size.height * 0.431,
                            child: LoadingController());
                      }
                      if (result.data != null) {
                        List<dynamic> merchantOutletList =
                            result.data!['Outlets'];
                        return merchantOutletList.length > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Consumer<PlanAParty>(
                                        builder: (context, party, child) {
                                      return party.venueProduct != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'EditAParty.SelectedOutlet'
                                                      .tr(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w400),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          PlanAPartyProductListPage
                                                              .routeName,
                                                          arguments: PlanAPartyProductListPageArguments(party
                                                                  .venueProduct!
                                                                  .outletProductInformation[
                                                              'outlet']['id']));
                                                    },
                                                    child: SelectedOutletWidget(
                                                        party.venueProduct!
                                                                .outletProductInformation[
                                                            'outlet']))
                                              ],
                                            )
                                          : Container(width: 0, height: 0);
                                    }),
                                    Text(
                                      'PlanAParty.VenueNearYour'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .copyWith(
                                              fontWeight: FontWeight.w400),
                                    ),
                                    PartyPlanningOutletList(
                                        merchantOutletList, "ROOM"),
                                  ])
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PlanAParty.VenueNearYour'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .copyWith(fontWeight: FontWeight.w400),
                                  ),
                                  Container(
                                    height: 150,
                                    child: Center(
                                      child: Text(
                                        "PlanAParty.NoVenue",
                                        style: Theme.of(context)
                                            .textTheme
                                            .button!
                                            .copyWith(
                                                fontWeight: FontWeight.normal),
                                      ).tr(),
                                    ),
                                  ),
                                ],
                              );
                      }
                      return Container(width: 0.0, height: 0.0);
                    }),
              )
            ]),
          ),
        );
      case "F&B":
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Container(
                height: 42,
                child: TextFormField(
                    controller: fbTextController,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (text) {
                      setState(() {});
                    },
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.normal, color: grayTextColor),
                    decoration: InputDecoration(
                        isDense: false,
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        labelText: 'Search...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(fontSize: 12),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 31,
                          minHeight: 31,
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 28,
                          ),
                        )),
                    keyboardType: TextInputType.text),
              ),
              SizedBox(height: 10),
              Container(
                height: 57,
                padding: EdgeInsets.only(bottom: 15),
                child: ListView(
                  padding: EdgeInsets.only(bottom: 3),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterButton(context, "CelebrationHome.Filter",
                        icon: "assets/images/icon-filter.svg"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.024,
                    ),
                    ProductCategorySelectionWidget("FOOD"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.024,
                    )
                  ],
                ),
              ),
              Consumer<PlanAParty>(builder: (context, partyItems, child) {
                late Map outletMap;
                if (partyItems.fbProducts != null &&
                    partyItems.fbProducts!.length > 0) {
                  outletMap =
                      groupBy(partyItems.fbProducts!, (UserCartItem obj) {
                    return obj.outletProductInformation['outlet']['id'];
                  });
                }
                return (partyItems.fbProducts!.length > 0)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EditAParty.SelectedOutlet'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Column(
                              children: List.generate(
                                  outletMap.keys.length,
                                  (index) => GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            PlanAPartyProductListPage.routeName,
                                            arguments:
                                                PlanAPartyProductListPageArguments(
                                                    outletMap.keys
                                                        .elementAt(index)));
                                      },
                                      child: SelectedOutletWidget((outletMap[
                                                      outletMap.keys
                                                          .elementAt(index)][0]
                                                  as UserCartItem)
                                              .outletProductInformation[
                                          "outlet"]))))
                        ],
                      )
                    : Container(width: 0, height: 0);
              }),
              !party.currentVenueAnyFB
                  ? Text(
                      'PlanAParty.RestaurantNearYou'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.w400),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              !party.currentVenueAnyFB // !(true)
                  ? Query(
                      options: QueryOptions(
                          document: gql(PartyGQL.GET_OUTLETS),
                          variables: {
                            "selectedServiceTime":
                                (party.collectionType == "DINE_IN" &&
                                        !party.currentVenueAnyFB)
                                    ? combineDateTime
                                        .subtract(Duration(hours: 1))
                                        .toUtc()
                                        .toIso8601String()
                                    : combineDateTime.toUtc().toIso8601String(),
                            'merchantOutlet': {
                              "eventCategoryId": null,
                              "merchantTypeIds":
                                  Configuration.FOOD_MERCHANT_TYPE_IDS
                            },
                            "filterSelection": {
                              "maxPax": filterProvider.maxPax,
                              "priceIndicatorsList":
                                  filterProvider.priceIndicatorSelection,
                              "locationsList": filterProvider.locationSelection,
                              "specialDietsList":
                                  filterProvider.specialDietSelection,
                              "productCategoriesList":
                                  filterProvider.productCategorySelection,
                              "amenitiesList": filterProvider.amenitySelection,
                              "cuisinesList": filterProvider.cuisineSelection
                            },
                            "productType": "FOOD",
                            "searchText": fbTextController.text,
                            "userLatitude": party.collectionType == "DINE_IN"
                                ? party.venueProduct!
                                        .outletProductInformation["outlet"]
                                    ["latitude"]
                                : party.collectionType == 'DELIVERY'
                                    ? party.deliveryAddress!.latitude
                                    : positionProvider.userLatitude,
                            "userLongitude": party.collectionType == "DINE_IN"
                                ? party.venueProduct!
                                        .outletProductInformation["outlet"]
                                    ["longitude"]
                                : party.collectionType == 'DELIVERY'
                                    ? party.deliveryAddress!.longitude
                                    : positionProvider.userLongitude,
                            "selectedServiceType":
                                (party.collectionType == "DINE_IN" &&
                                        !party.currentVenueAnyFB)
                                    ? "DELIVERY"
                                    : party.collectionType,
                            "venueOutletId": (party.collectionType ==
                                        "DINE_IN" &&
                                    party.venueProduct != null)
                                ? party.venueProduct!
                                    .outletProductInformation["outlet"]["id"]
                                : null,
                          },
                          fetchPolicy: FetchPolicy.noCache),
                      builder: (QueryResult result,
                          {VoidCallback? refetch, FetchMore? fetchMore}) {
                        if (result.hasException) {
                          print(result.exception.toString());
                        }
                        if (result.isLoading) {
                          return Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.431,
                              child: LoadingController());
                        }
                        if (result.data != null) {
                          print('FOOD :: PartyPlanningOutletList');
                          var merchantOutletList = result.data!['Outlets'];
                          return merchantOutletList.length > 0
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: PartyPlanningOutletList(
                                      merchantOutletList, "FOOD"))
                              : Container(
                                  height: 150,
                                  child: Center(
                                    child: Text(
                                      "PlanAParty.NoVendor",
                                      style: Theme.of(context)
                                          .textTheme
                                          .button!
                                          .copyWith(
                                              fontWeight: FontWeight.normal),
                                    ).tr(),
                                  ),
                                );
                        }
                        return Container(width: 0.0, height: 0.0);
                      })
                  : party.fbProducts!.length >
                          0 // currentVenueAnyFb (true), party.fbProducts!.length >0 (Any Item selected )
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PlanAParty.RestaurantNearYou'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Column(
                                children: List.generate(
                                    1,
                                    (index) => GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context,
                                              PlanAPartyProductListPage
                                                  .routeName,
                                              arguments:
                                                  PlanAPartyProductListPageArguments(
                                                      party.venueProduct!
                                                              .outletProductInformation[
                                                          'outlet']['id']));
                                        },
                                        child: SelectedOutletWidget(party
                                                .venueProduct!
                                                .outletProductInformation[
                                            'outlet'])))), // (UI) shows only one outlet
                          ],
                        )
            ]),
          ),
        );
      case "DECORATION":
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Container(
                height: 42,
                child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: decoTextController,
                    onChanged: (text) {
                      setState(() {});
                    },
                    onFieldSubmitted: (text) {},
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.normal, color: grayTextColor),
                    decoration: InputDecoration(
                        isDense: false,
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(23.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            )),
                        labelText: 'Search...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(fontSize: 12),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 31,
                          minHeight: 31,
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 28,
                          ),
                        )),
                    keyboardType: TextInputType.text),
              ),
              SizedBox(height: 10),
              Container(
                height: 57,
                padding: EdgeInsets.only(bottom: 15),
                child: ListView(
                  padding: EdgeInsets.only(bottom: 3),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterButton(context, "CelebrationHome.Filter",
                        icon: "assets/images/icon-filter.svg"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.024,
                    ),
                    ProductCategorySelectionWidget("GIFT"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.024,
                    )
                  ],
                ),
              ),
              Consumer<PlanAParty>(builder: (context, partyItems, child) {
                late Map outletMap;
                if (partyItems.decorationProducts != null &&
                    partyItems.decorationProducts!.length > 0) {
                  outletMap = groupBy(partyItems.decorationProducts!, (obj) {
                    obj = obj as UserCartItem;
                    return obj.outletProductInformation["outlet"]["id"];
                  });
                }

                return (partyItems.decorationProducts != null &&
                        partyItems.decorationProducts!.length > 0)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EditAParty.SelectedOutlet'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Column(
                              children: List.generate(
                                  outletMap.length,
                                  (index) => GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            PlanAPartyProductListPage.routeName,
                                            arguments:
                                                PlanAPartyProductListPageArguments(
                                                    outletMap.keys
                                                        .elementAt(index)));
                                      },
                                      child: SelectedOutletWidget((outletMap[
                                                      outletMap.keys
                                                          .elementAt(index)][0]
                                                  as UserCartItem)
                                              .outletProductInformation[
                                          "outlet"])))),
                        ],
                      )
                    : Container(width: 0, height: 0);
              }),
              !party.currentVenueAnyDeco
                  ? Text(
                      'PlanAParty.SuggestionsForDecorations'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.w400),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              !party.currentVenueAnyDeco
                  ? Query(
                      options: QueryOptions(
                          document: gql(PartyGQL.GET_OUTLETS),
                          variables: {
                            "selectedServiceTime":
                                (party.collectionType == "DINE_IN" &&
                                        !party.currentVenueAnyDeco)
                                    ? combineDateTime
                                        .subtract(Duration(hours: 1))
                                        .toUtc()
                                        .toIso8601String()
                                    : combineDateTime.toUtc().toIso8601String(),
                            'merchantOutlet': {
                              "eventCategoryId": party.eventCategory,
                              "merchantTypeIds":
                                  Configuration.GIFT_MERCHANT_TYPE_IDS
                            },
                            "filterSelection": {
                              "maxPax": filterProvider.maxPax,
                              "priceIndicatorsList":
                                  filterProvider.priceIndicatorSelection,
                              "locationsList": filterProvider.locationSelection,
                              "specialDietsList":
                                  filterProvider.specialDietSelection,
                              "productCategoriesList":
                                  filterProvider.productCategorySelection,
                              "amenitiesList": filterProvider.amenitySelection,
                              "cuisinesList": filterProvider.cuisineSelection
                            },
                            "productType": "GIFT",
                            "searchText": decoTextController.text,
                            "userLatitude": party.collectionType == "DINE_IN"
                                ? party.venueProduct!
                                        .outletProductInformation["outlet"]
                                    ["latitude"]
                                : party.collectionType == 'DELIVERY'
                                    ? party.deliveryAddress!.latitude
                                    : positionProvider.userLatitude,
                            "userLongitude": party.collectionType == "DINE_IN"
                                ? party.venueProduct!
                                        .outletProductInformation["outlet"]
                                    ["longitude"]
                                : party.collectionType == 'DELIVERY'
                                    ? party.deliveryAddress!.longitude
                                    : positionProvider.userLongitude,
                            "selectedServiceType":
                                (party.collectionType == "DINE_IN" &&
                                        !party.currentVenueAnyDeco)
                                    ? "DELIVERY"
                                    : party.collectionType,
                            "venueOutletId": (party.collectionType ==
                                        "DINE_IN" &&
                                    party.venueProduct != null)
                                ? party.venueProduct!
                                    .outletProductInformation["outlet"]["id"]
                                : null,
                          },
                          fetchPolicy: FetchPolicy.noCache),
                      builder: (QueryResult result,
                          {VoidCallback? refetch, FetchMore? fetchMore}) {
                        if (result.hasException) {
                          print(result.exception.toString());
                        }
                        if (result.isLoading) {
                          return Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.431,
                              child: LoadingController());
                        }
                        if (result.data != null) {
                          var merchantOutletList = result.data!['Outlets'];
                          return merchantOutletList.length > 0
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: PartyPlanningOutletList(
                                      merchantOutletList, "GIFT"))
                              : Container(
                                  height: 150,
                                  child: Center(
                                    child: Text(
                                      "PlanAParty.NoVendor",
                                      style: Theme.of(context)
                                          .textTheme
                                          .button!
                                          .copyWith(
                                              fontWeight: FontWeight.normal),
                                    ).tr(),
                                  ),
                                );
                        }
                        return Container(width: 0.0, height: 0.0);
                      })
                  : party.decorationProducts!.length > 0
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PlanAParty.SuggestionsForDecorations'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Column(
                                children: List.generate(
                                    1,
                                    (index) => GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context,
                                              PlanAPartyProductListPage
                                                  .routeName,
                                              arguments:
                                                  PlanAPartyProductListPageArguments(
                                                      party.venueProduct!
                                                              .outletProductInformation[
                                                          'outlet']["id"]));
                                        },
                                        child: SelectedOutletWidget(party
                                                .venueProduct!
                                                .outletProductInformation[
                                            'outlet'])))),
                          ],
                        )
            ]),
          ),
        );
      default:
        return Center(
          child: Icon(
            Icons.book,
            color: primaryColor,
          ),
        );
    }
  }

  Widget _filterButton(BuildContext context, String buttonText,
      {String? icon}) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PartyRoomSmartFilterPage();
          }));
        },
        child: Row(children: <Widget>[
          icon != null
              ? Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: filterProvider.isAnyAdvancedFilterSelected()
                      ? Colors.white
                      : Colors.black,
                )
              : Container(width: 0.0, height: 0.0),
          Center(
              child: Text(buttonText,
                      style: TextStyle(
                        fontFamily: 'Arial Rounded MT Bold',
                        color: filterProvider.isAnyAdvancedFilterSelected()
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center)
                  .tr())
        ]),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            primary: filterProvider.isAnyAdvancedFilterSelected()
                ? Color.fromRGBO(0, 0, 0, 1)
                : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }

  continued() {
    if (party.planCurrentStep! < party.demands!.length - 1) {
      // 2 <  2
      party.setCurrentStep(party.planCurrentStep! + 1);
      filterProvider.clearAdvancedFilterAndSmartFilter();
    } else {
      print("REACH LIMIT ");
      print(
          "LIMIT: ${party.demands!.length} CURRENT STEP: ${party.planCurrentStep}");
    }
  }

  cancel() {
    if (party.planCurrentStep! > 0) {
      setState(() {
        party.setCurrentStep(party.planCurrentStep! - 1);
        filterProvider.clearAdvancedFilterAndSmartFilter();
      });
    } else {
      print("CANCEL BUTTON");
    }
  }

  _validateInputs() {
    if (party.demands!.length > 0 && party.planCurrentStep != -1) {
      if (party.demands![party.planCurrentStep!] == "VENUE") {
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
          if (party.planCurrentStep == party.demands!.length - 1) {
            Navigator.pushNamed(context, ReviewBasketPage.routeName);
          } else {
            continued();
          }
        }
      } else if (party.demands![party.planCurrentStep!] == "F&B") {
        if (party.fbProducts!.length <= 0) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => Dialog(
                  child: PopUpConfirmationWidget(
                      title: "PlanAParty.ChooseYourFood",
                      content: "PlanAParty.SelectFood",
                      continueFunction: continued,
                      lastStep:
                          party.planCurrentStep == party.demands!.length - 1
                              ? true
                              : false),
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(24)));
        } else {
          if (party.planCurrentStep == party.demands!.length - 1) {
            Navigator.pushNamed(context, ReviewBasketPage.routeName);
          } else {
            continued();
          }
        }
      } else if (party.demands![party.planCurrentStep!] == "DECORATION") {
        if (party.decorationProducts!.length <= 0) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => Dialog(
                  child: PopUpConfirmationWidget(
                      title: "PlanAParty.ChooseYourGift",
                      content: "PlanAParty.SelectGift",
                      continueFunction: continued,
                      lastStep:
                          party.planCurrentStep == party.demands!.length - 1
                              ? true
                              : false),
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(24)));
        } else {
          if (party.planCurrentStep == party.demands!.length - 1) {
            Navigator.pushNamed(context, ReviewBasketPage.routeName);
          } else {
            continued();
          }
        }
      }
    }
  }
}
