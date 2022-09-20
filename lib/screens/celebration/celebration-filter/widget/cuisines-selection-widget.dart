import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/celebration/gql/celebration.gql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CuisinesSelection extends StatefulWidget {
  CuisinesSelection(this.tempCuisineList);
  final List<String> tempCuisineList;

  @override
  _CuisinesSelectionState createState() => _CuisinesSelectionState();
}

class _CuisinesSelectionState extends State<CuisinesSelection> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(CelebrationGQL.GET_ALL_CUISINES),
            fetchPolicy: FetchPolicy.cacheAndNetwork),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            List cuisinesList = result.data!['Cuisines'];
            if (cuisinesList.length > 10) {
              cuisinesList.removeWhere((element) => element['id'] == "SeeAll");
              if (!isExpand) {
                cuisinesList.insert(10, {'id': 'SeeAll', 'name': 'See All'});
              } else {
                cuisinesList.add({'id': 'SeeAll', 'name': 'See All'});
              }
            }

            return cuisinesList.length > 0
                ? Container(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Search.Cuisines",
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
                                isExpand ? cuisinesList.length : 11,
                                (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (cuisinesList
                                                  .elementAt(index)["id"] ==
                                              'SeeAll') {
                                            isExpand = !isExpand;
                                            if (isExpand) {
                                              widget.tempCuisineList.add(
                                                  cuisinesList
                                                      .elementAt(index)["id"]);
                                            } else {
                                              widget.tempCuisineList.remove(
                                                  cuisinesList
                                                      .elementAt(index)["id"]);
                                            }
                                          } else {
                                            if (widget.tempCuisineList.contains(
                                                cuisinesList
                                                    .elementAt(index)["id"])) {
                                              widget.tempCuisineList.remove(
                                                  cuisinesList
                                                      .elementAt(index)["id"]);
                                            } else {
                                              widget.tempCuisineList.add(
                                                  cuisinesList
                                                      .elementAt(index)["id"]);
                                            }
                                          }
                                        });
                                      },
                                      child: Chip(
                                        backgroundColor: widget.tempCuisineList
                                                .contains(cuisinesList
                                                    .elementAt(index)["id"])
                                            ? Color.fromRGBO(253, 196, 0, 1)
                                            : Colors.grey[200],
                                        label: Text(
                                          cuisinesList.elementAt(index)["name"],
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
