import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/screens/celebration/celebration-filter/celebration-filter-page.dart';
import 'package:gem_consumer_app/screens/celebration/view-celebration/view_celebration_page.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/product-category-selection-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/recommended-button-widget.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/service-type-selection-widget.dart';
import 'package:gem_consumer_app/screens/search/search.gql.dart';
import 'package:gem_consumer_app/screens/search/widgets/filter-button-widget.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';

class SearchResultPage extends StatefulWidget {
  static String routeName = '/search-result';

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late FilterProvider filterProvider;
  late AddToCartItems cart;
  TextEditingController _controller = TextEditingController();
  static const historyLength = 5;

  //Local Storage
  late final Box historyBox;
  late List<String> userSearchHistory;

  void _addHistory(String term) {
    if (term != '') {
      if (userSearchHistory.contains(term)) {
        _moveTerm(term);
      } else {
        userSearchHistory.add(term);
        if (userSearchHistory.length > historyLength) {
          userSearchHistory.removeRange(
              0, userSearchHistory.length - historyLength);
        }
        historyBox.put('history', userSearchHistory);
      }
    }
  }

  void _deleteTerm(String term) {
    userSearchHistory.removeWhere((element) => element == term);
    historyBox.put('history', userSearchHistory);
  }

  void _moveTerm(String term) {
    _deleteTerm(term);
    _addHistory(term);
  }

  @override
  void initState() {
    cart = context.read<AddToCartItems>();
    filterProvider = context.read<FilterProvider>();
    historyBox = Hive.box('searchHistory');
    userSearchHistory = historyBox.get("history", defaultValue: <String>[]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('search_result_page');
    final args =
        ModalRoute.of(context)!.settings.arguments as SearchResultPageArguments;
    args.selectedServiceType = cart.selectedServiceType!;
    args.selectedDate = cart.selectedDate!;
    args.selectedTime = cart.selectedTime!;
    args.pax = cart.numberOfPax;
    _controller.text = args.searchQuery;
    if (args.selectedServiceType == "DELIVERY") {
      args.selectedAddress = cart.deliveryLocation!;
    }
    var combineDateTime = new DateTime(
        cart.selectedDate!.year,
        cart.selectedDate!.month,
        cart.selectedDate!.day,
        cart.selectedTime!.hour,
        cart.selectedTime!.minute);
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Consumer<FilterProvider>(builder: (context, filter, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: <Widget>[
              Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width,
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          height: 36.0,
                          width: 36.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: Offset(0, 1)),
                              ]),
                          child: IconButton(
                              icon: SvgPicture.asset(
                                  'assets/images/icon-back.svg'),
                              iconSize: 36.0,
                              onPressed: () {
                                Navigator.pop(context);
                                filterProvider
                                    .clearAdvancedFilterAndSmartFilter();
                              })),
                      SizedBox(width: 5),
                      Container(
                        width: size.width * 0.8,
                        child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: _controller,
                            onTap: () {
                              _controller.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: _controller.text.length));
                            },
                            onChanged: (text) {
                              // setState(() {
                              //   filteredSearchHistory =
                              //       filterSearchTerms(filter: text);
                              // });
                            },
                            onFieldSubmitted: (text) {
                              setState(() {
                                args.searchQuery = text;
                                _addHistory(text);
                              });
                              // Navigator.pushNamed(
                              //     context, SearchResultPage.routeName,
                              //     arguments:
                              //         SearchResultPageArguments(text, list));
                            },
                            style: textTheme.button!.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
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
                              labelText: 'Search Product or Merchant...',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelStyle: TextStyle(fontSize: 12),
                            ),
                            keyboardType: TextInputType.text),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.024),
              Container(
                height: 42,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(width: size.width * 0.060),
                    FilterButtonWidget(function: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CelebrationFilterPage()));
                    }),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.024),
                    RecommendedButtonWidget(),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.024),
                    ProductCategorySelectionWidget("BUNDLE"),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.024),
                    ServiceTypeSelectionWidget(),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.024),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              Query(
                  options: QueryOptions(
                      variables: {
                        'queryPattern': {
                          "data": {
                            "query": "${args.searchQuery}",
                            "facets": ["*"],
                            "filters": "productType:BUNDLE",
                            "facetFilters": [
                              filterProvider.priceIndicatorSelection.length > 0
                                  ? List.generate(
                                      filterProvider
                                          .priceIndicatorSelection.length,
                                      (index) =>
                                          'priceIndicator:${filterProvider.priceIndicatorSelection.elementAt(index)}')
                                  : "",
                              filterProvider.amenitySelection.length > 0
                                  ? List.generate(
                                      filterProvider.amenitySelection.length,
                                      (index) =>
                                          'amenities:${filterProvider.amenitySelection.elementAt(index)}')
                                  : "",
                              filterProvider.cuisineSelection.length > 0
                                  ? List.generate(
                                      filterProvider.cuisineSelection.length,
                                      (index) =>
                                          'cuisines:${filterProvider.cuisineSelection.elementAt(index)}')
                                  : "",
                              filterProvider.specialDietSelection.length > 0
                                  ? List.generate(
                                      filterProvider
                                          .specialDietSelection.length,
                                      (index) =>
                                          'specialDiets:${filterProvider.specialDietSelection.elementAt(index)}')
                                  : "",
                              filterProvider.locationSelection.length > 0
                                  ? List.generate(
                                      filterProvider.locationSelection.length,
                                      (index) =>
                                          'location:${filterProvider.locationSelection.elementAt(index)}')
                                  : "",
                              filterProvider.isRecommended()
                                  ? "isRecommended:${filterProvider.isRecommended()}"
                                  : "",
                              filterProvider.productCategorySelection.length > 0
                                  ? List.generate(
                                      filterProvider
                                          .productCategorySelection.length,
                                      (index) =>
                                          'productCategories:${filterProvider.productCategorySelection.elementAt(index)}')
                                  : "",
                              filterProvider.serviceTypeSelection.length > 0
                                  ? List.generate(
                                      filterProvider
                                          .serviceTypeSelection.length,
                                      (index) =>
                                          'serviceType:${filterProvider.serviceTypeSelection.elementAt(index)}')
                                  : "",
                            ],
                          }
                        },
                        "selectedServiceType": args.selectedServiceType,
                        "selectedDate":
                            combineDateTime.toUtc().toIso8601String(),
                        "userLatitude": args.selectedServiceType == "DELIVERY"
                            ? args.selectedAddress!.latitude
                            : null,
                        "userLongitude": args.selectedServiceType == "DELIVERY"
                            ? args.selectedAddress!.longitude
                            : null,
                        "pax": args.pax,
                      },
                      document: gql(AlgoliaGQL.ALGOLIA_SEARCH),
                      fetchPolicy: FetchPolicy.cacheAndNetwork),
                  builder: (QueryResult result,
                      {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (result.isLoading) {
                      return Expanded(
                        child: Center(
                          child: LoadingController(),
                        ),
                      );
                    }
                    if (result.data != null) {
                      //print("Check reuslt data : ${result.data}");
                      var dataList;
                      if (result.data!['SearchProducts'] != null &&
                          result.data!['SearchProducts']['items'].length > 0) {
                        dataList = result.data!['SearchProducts']['items'];
                      } else {
                        dataList = [];
                      }
                      return dataList.length > 0
                          ? Expanded(
                              child: SingleChildScrollView(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: _productList(context, dataList))))
                          : Expanded(
                              child: Center(
                                child: Text(
                                  "No Product or Merchant related to '${args.searchQuery}' keyword",
                                  style: TextStyle(
                                    fontFamily: 'Arial Rounded MT Bold',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                    }
                    return Container(width: 0.0, height: 0.0);
                  }),
            ],
          ),
        );
      }),
    );
  }
}

ListView _productList(BuildContext context, List dataList) {
  final Map<String, String> allCollectionType = {
    "DINE_IN": "CollectionType.DINE_IN".tr(),
    "DELIVERY": "CollectionType.DELIVERY".tr(),
    "PICKUP": "CollectionType.PICKUP".tr(),
  };
  final args =
      ModalRoute.of(context)!.settings.arguments as SearchResultPageArguments;
  return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: dataList.length,
      itemBuilder: (BuildContext context, int index) {
        List<String> productOutletCollectionTypes = [];
        dataList[index]["serviceType"].forEach((element) {
          productOutletCollectionTypes.add(allCollectionType[element] ?? '');
        });

        String collectTypeText = productOutletCollectionTypes.join(" / ");

        //PreOrder Time
        String saleText = "";
        if (dataList[index]['advancePurchaseDuration'] != null) {
          int saleDuration = dataList[index]['advancePurchaseDuration'];
          String saleUnit = dataList[index]['advancePurchaseUnit'];
          saleText = saleDuration.toString() + " " + saleUnit.toLowerCase();

          if (saleDuration > 1) {
            saleText += "s";
          }
        }
        bool isAvailable = dataList[index]["available"];
        return GestureDetector(
            onTap: () {
              if (isAvailable) {
                Navigator.pushNamed(context, ViewCelebrationPage.routeName,
                    arguments: ViewCelebrationPageArguments(
                        dataList[index]['objectID'],
                        args.selectedServiceType!,
                        args.selectedDate!,
                        args.selectedTime!,
                        args.pax!,
                        selectedAddress: args.selectedAddress));
              }
            },
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              LayoutBuilder(builder: (context, constraints) {
                var imageDynamicHeight = constraints.maxWidth * 0.4;
                print(
                    '${constraints.maxWidth} :: ${constraints.maxWidth * 0.4}  ');

                return Container(
                    width: constraints.maxWidth,
                    height: imageDynamicHeight,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Container(
                              width: constraints.maxWidth,
                              height: imageDynamicHeight,
                              child: dataList[index]['smallThumbNail'] == "" ||
                                      dataList[index]['smallThumbNail'] == null
                                  ? DefaultImageHelper.defaultImageWithSize(
                                      constraints.maxWidth,
                                      imageDynamicHeight,
                                    )
                                  : CachedImage(
                                      imageUrl: dataList[index]['product']
                                          ['smallThumbNail'],
                                      width: constraints.maxWidth,
                                      height: imageDynamicHeight,
                                    ),
                            ),
                            !isAvailable
                                ? Container(
                                    height:
                                        MediaQuery.of(context).size.width * 0.4,
                                    width: MediaQuery.of(context).size.width,
                                    child: SvgPicture.asset(
                                      'assets/images/grey-overlay.svg',
                                      fit: BoxFit.cover,
                                    ))
                                : Container(
                                    width: 0,
                                    height: 0,
                                  ),
                            !isAvailable
                                ? Positioned.fill(
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text("Product.NotAvailable",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white))
                                            .tr()))
                                : Container(
                                    width: 0,
                                    height: 0,
                                  ),
                            dataList[index]['isNew']
                                ? Positioned(
                                    top: 10,
                                    right: 12,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Text(
                                        'Product.New'.tr(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 0,
                                    width: 0,
                                  ),
                            Positioned(
                              top: 12,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  saleText.length > 0
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/icon-sale.svg',
                                                color: grayTextColor,
                                                width: 14,
                                                height: 14,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                saleText,
                                                style: TextStyle(
                                                    color: grayTextColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    fontFamily: 'Arial'),
                                              )
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(12),
                                                  bottomRight:
                                                      Radius.circular(12))),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: saleText.length > 0 ? 6 : 0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )));
              }),
              SizedBox(height: 8.0),
              Text(
                dataList[index]['title'],
                style: Theme.of(context).textTheme.button,
              ),
              dataList[index]['outletName'] == null
                  ? Text("Product.MerchantName",
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.grey[400],
                          )).tr()
                  : Text(dataList[index]['outletName'],
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.grey[400],
                          )),
              SizedBox(height: 4.0),
              RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                    text:
                        "RM ${StringHelper.formatCurrency((double.parse(dataList[index]['currentPrice'].toString()) + (dataList[index]['isSSTEnabled'] ? double.parse(dataList[index]['currentPrice'].toString()) * 0.06 : 0)))} ",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w400)),
                double.parse(dataList[index]['originalPrice'].toString()) >
                        double.parse(dataList[index]['currentPrice'].toString())
                    ? TextSpan(
                        text:
                            "RM ${StringHelper.formatCurrency((double.parse(dataList[index]['originalPrice'].toString()) + (dataList[index]['isSSTEnabled'] ? double.parse(dataList[index]['originalPrice'].toString()) * 0.06 : 0)))}",
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontFamily: 'Arial Rounded MT Bold',
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ))
                    : TextSpan(text: ""),
                TextSpan(
                    text:
                        " • ${dataList[index]['pax'] == null ? 0 : dataList[index]['pax']} pax",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w400)),
                TextSpan(
                    text: " • $collectTypeText",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w400))
              ])),
              SizedBox(height: 20.0),
            ]));
      });
}

class SearchResultPageArguments {
  String searchQuery;
  String? selectedServiceType;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? pax;
  UserAddress? selectedAddress;

  SearchResultPageArguments(this.searchQuery);
}
