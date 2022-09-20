import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/screens/celebration/celebration-filter/widget/amenities-selection-widget.dart';
import 'package:gem_consumer_app/screens/celebration/celebration-filter/widget/cuisines-selection-widget.dart';
import 'package:gem_consumer_app/screens/celebration/celebration-filter/widget/location-selection-widget.dart';
import 'package:gem_consumer_app/screens/celebration/celebration-filter/widget/price-indicators-selection-widget.dart';
import 'package:gem_consumer_app/screens/celebration/celebration-filter/widget/special-diets-selection-widget.dart';
import 'package:provider/provider.dart';

class PartyRoomSmartFilterPage extends StatefulWidget {
  @override
  _PartyRoomSmartFilterPageState createState() =>
      _PartyRoomSmartFilterPageState();
}

class _PartyRoomSmartFilterPageState extends State<PartyRoomSmartFilterPage> {
  //late AdvancedFilterProvider filterSelection;
  late FilterProvider filterProvider;
  List<int> tempPriceIndicatorList = [];
  List<String> tempLocationList = [];
  List<String> tempCuisineList = [];
  List<String> tempSpecialDietList = [];
  List<String> tempAmenityList = [];

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    tempPriceIndicatorList = List.from(filterProvider.priceIndicatorSelection);
    tempLocationList = List.from(filterProvider.locationSelection);
    tempCuisineList = List.from(filterProvider.cuisineSelection);
    tempSpecialDietList = List.from(filterProvider.specialDietSelection);
    tempAmenityList = List.from(filterProvider.amenitySelection);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 1)),
              ]),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 25),
                    height: 36.0,
                    width: 36.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1)),
                        ]),
                    child: IconButton(
                        icon: Icon(
                          Icons.close,
                        ),
                        iconSize: 18.0,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  SizedBox(width: size.width * 0.237),
                  Text(
                    "Search.AddFilter",
                    style: TextStyle(
                      fontFamily: 'Arial Rounded MT Bold',
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ).tr(),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(
                      right: 10,
                    ),
                    child: _button(context, "Button.Apply", function: () {
                      tempCuisineList
                          .removeWhere((element) => element == "SeeAll");
                      tempSpecialDietList
                          .removeWhere((element) => element == "SeeAll");
                      tempAmenityList
                          .removeWhere((element) => element == "SeeAll");
                      tempLocationList
                          .removeWhere((element) => element == "See All");
                      filterProvider.priceIndicatorSelection =
                          tempPriceIndicatorList;
                      filterProvider.amenitySelection = tempAmenityList;
                      filterProvider.cuisineSelection = tempCuisineList;
                      filterProvider.locationSelection = tempLocationList;
                      filterProvider.specialDietSelection = tempSpecialDietList;
                      Navigator.pop(context);
                    }),
                  )
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PriceIndicatorSelection(tempPriceIndicatorList),
                  LocationSelection(tempLocationList),
                  CuisinesSelection(tempCuisineList),
                  SpecialDietsSelection(tempSpecialDietList),
                  AmenitiesSelection(tempAmenityList)
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

ElevatedButton _button(BuildContext context, String buttonText,
    {String? icon, required Function function}) {
  return ElevatedButton(
      onPressed: () => function(),
      child: Row(children: <Widget>[
        icon != null ? SvgPicture.asset(icon) : Container(height: 0, width: 0),
        Center(
            child: Text(buttonText,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center)
                .tr())
      ]),
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
          primary: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(23))));
}
