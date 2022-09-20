import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/celebration/gql/celebration.gql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AmenitiesSelection extends StatefulWidget {
  AmenitiesSelection(this.tempAmenityList);
  final List<String> tempAmenityList;

  @override
  _AmenitiesSelectionState createState() => _AmenitiesSelectionState();
}

class _AmenitiesSelectionState extends State<AmenitiesSelection> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(CelebrationGQL.GET_ALL_AMENITIES),
            fetchPolicy: FetchPolicy.cacheAndNetwork),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            List amenitiesList = result.data!['Amenities'];
            if (amenitiesList.length > 10) {
              amenitiesList.removeWhere((element) => element['id'] == "SeeAll");
              if (!isExpand) {
                amenitiesList.insert(10, {'id': 'SeeAll', 'name': 'See All'});
              } else {
                amenitiesList.add({'id': 'SeeAll', 'name': 'See All'});
              }
            }
            return amenitiesList.length > 0
                ? Container(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Search.Amenities",
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
                                amenitiesList.length < 10
                                    ? amenitiesList.length
                                    : isExpand
                                        ? amenitiesList.length
                                        : 11,
                                (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (amenitiesList
                                                  .elementAt(index)["id"] ==
                                              'SeeAll') {
                                            isExpand = !isExpand;
                                            if (isExpand) {
                                              widget.tempAmenityList.add(
                                                  amenitiesList
                                                      .elementAt(index)["id"]);
                                            } else {
                                              widget.tempAmenityList.remove(
                                                  amenitiesList
                                                      .elementAt(index)["id"]);
                                            }
                                          } else {
                                            if (widget.tempAmenityList.contains(
                                                amenitiesList
                                                    .elementAt(index)["id"])) {
                                              widget.tempAmenityList.remove(
                                                  amenitiesList
                                                      .elementAt(index)["id"]);
                                            } else {
                                              widget.tempAmenityList.add(
                                                  amenitiesList
                                                      .elementAt(index)["id"]);
                                            }
                                          }
                                        });
                                      },
                                      child: Chip(
                                        backgroundColor: widget.tempAmenityList
                                                .contains(amenitiesList
                                                    .elementAt(index)["id"])
                                            ? Color.fromRGBO(253, 196, 0, 1)
                                            : Colors.grey[200],
                                        label: Text(
                                          amenitiesList
                                              .elementAt(index)["name"],
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
