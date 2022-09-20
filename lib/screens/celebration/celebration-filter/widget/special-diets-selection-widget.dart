import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/celebration/gql/celebration.gql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SpecialDietsSelection extends StatefulWidget {
  SpecialDietsSelection(this.tempSpecialDietList);
  final List<String> tempSpecialDietList;

  @override
  _SpecialDietsSelectionState createState() => _SpecialDietsSelectionState();
}

class _SpecialDietsSelectionState extends State<SpecialDietsSelection> {
  bool isExpand = false;
  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(CelebrationGQL.GET_ALL_SPECIAL_DIETS),
            fetchPolicy: FetchPolicy.cacheAndNetwork),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            List specialDietsList = result.data!['SpecialDiets'];
            if (specialDietsList.length > 10) {
              specialDietsList
                  .removeWhere((element) => element['name'] == "See All");
              if (!isExpand) {
                specialDietsList.insert(10, {'name': 'See All'});
              } else {
                specialDietsList.add({'name': 'See All'});
              }
            }
            return specialDietsList.length > 0
                ? Container(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Search.SpecialDiets",
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
                                isExpand ? specialDietsList.length : 11,
                                (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (specialDietsList
                                                  .elementAt(index)["name"] ==
                                              'See All') {
                                            isExpand = !isExpand;
                                            if (isExpand) {
                                              widget.tempSpecialDietList.add(
                                                  specialDietsList.elementAt(
                                                      index)["name"]);
                                            } else {
                                              widget.tempSpecialDietList.remove(
                                                  specialDietsList.elementAt(
                                                      index)["name"]);
                                            }
                                          } else {
                                            if (widget.tempSpecialDietList
                                                .contains(
                                                    specialDietsList.elementAt(
                                                        index)["name"])) {
                                              widget.tempSpecialDietList.remove(
                                                  specialDietsList.elementAt(
                                                      index)["name"]);
                                            } else {
                                              widget.tempSpecialDietList.add(
                                                  specialDietsList.elementAt(
                                                      index)["name"]);
                                            }
                                          }
                                        });
                                      },
                                      child: Chip(
                                        backgroundColor: widget
                                                .tempSpecialDietList
                                                .contains(specialDietsList
                                                    .elementAt(index)["name"])
                                            ? Color.fromRGBO(253, 196, 0, 1)
                                            : Colors.grey[200],
                                        label: Text(
                                          specialDietsList
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
