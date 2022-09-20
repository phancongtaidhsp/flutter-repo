import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/celebration/gql/celebration.gql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LocationSelection extends StatefulWidget {
  LocationSelection(this.tempLocationList);
  final List<String> tempLocationList;

  @override
  _LocationSelectionState createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {
  bool isExpand = false;
  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(CelebrationGQL.GET_ALL_OUTLET_LOCATIONS),
            fetchPolicy: FetchPolicy.cacheAndNetwork),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            List locationsList = result.data!['OutletLocations'];
            if (locationsList.length > 10) {
              locationsList.removeWhere((element) => element == "See All");
              if (!isExpand) {
                locationsList.insert(10, 'See All');
              } else {
                locationsList.add({'See All'});
              }
            }

            return locationsList.length > 0
                ? Container(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Search.Locations",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(fontWeight: FontWeight.w700))
                            .tr(),
                        SizedBox(
                          height: 10,
                        ),
                        Wrap(
                            spacing: 7,
                            direction: Axis.horizontal,
                            children: List.generate(
                                locationsList.length < 10
                                    ? locationsList.length
                                    : isExpand
                                        ? locationsList.length
                                        : 11,
                                (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (locationsList.elementAt(index) ==
                                              'See All') {
                                            isExpand = !isExpand;
                                            if (isExpand) {
                                              widget.tempLocationList.add(
                                                  locationsList
                                                      .elementAt(index));
                                            } else {
                                              widget.tempLocationList.remove(
                                                  locationsList
                                                      .elementAt(index));
                                            }
                                          } else {
                                            if (widget.tempLocationList
                                                .contains(locationsList
                                                    .elementAt(index))) {
                                              widget.tempLocationList.remove(
                                                  locationsList
                                                      .elementAt(index));
                                            } else {
                                              widget.tempLocationList.add(
                                                  locationsList
                                                      .elementAt(index));
                                            }
                                          }
                                        });
                                      },
                                      child: Chip(
                                        backgroundColor: widget.tempLocationList
                                                .contains(locationsList
                                                    .elementAt(index))
                                            ? Color.fromRGBO(253, 196, 0, 1)
                                            : Colors.grey[200],
                                        label: Text(
                                          locationsList.elementAt(index),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12),
                                        ),
                                      ),
                                    ))),
                      ],
                    ))
                : Container(
                    height: 0,
                    width: 0,
                  );
          }
          return Container(
            height: 0,
            width: 0,
          );
        });
  }
}
