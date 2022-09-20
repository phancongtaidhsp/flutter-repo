import 'package:flutter/material.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:gem_consumer_app/screens/celebration/gql/celebration.gql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class PartySelectProductCategoriesWidget extends StatefulWidget {
  PartySelectProductCategoriesWidget(
      this.tempProductCategoryList, this.productType);

  final List<String> tempProductCategoryList;
  final String productType;

  @override
  _PartySelectProductCategoriesWidgetState createState() =>
      _PartySelectProductCategoriesWidgetState();
}

class _PartySelectProductCategoriesWidgetState
    extends State<PartySelectProductCategoriesWidget> {
  late FilterProvider filterProvider;
  List<String> tempList = [];

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    tempList = List.from(filterProvider.productCategorySelection);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
            child: Query(
                options: QueryOptions(
                    variables: {"productType": widget.productType},
                    document:
                        gql(CelebrationGQL.GET_PRODUCT_CATEGORIES_BY_TYPE),
                    fetchPolicy: FetchPolicy.cacheAndNetwork),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.data != null) {
                    List productCategoryList =
                        result.data!['ProductCategoriesByType'];
                    return Wrap(
                        direction: Axis.horizontal,
                        children: List.generate(
                            productCategoryList.length,
                            (index) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (tempList.contains(
                                              productCategoryList
                                                  .elementAt(index)["id"])) {
                                            tempList.remove(productCategoryList
                                                .elementAt(index)["id"]);
                                            print(
                                                " When Exists STATE 1: ${filterProvider.productCategorySelection}");
                                            print(
                                                " When Exists STATE 2: $tempList");
                                          } else {
                                            tempList.add(productCategoryList
                                                .elementAt(index)["id"]);
                                            print(
                                                " When No Exists STATE 1: ${filterProvider.productCategorySelection}");
                                            print(
                                                " When No Exists STATE 2: $tempList");
                                          }
                                        });
                                      },
                                      child: Chip(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 11),
                                        backgroundColor: tempList.contains(
                                                    productCategoryList
                                                        .elementAt(
                                                            index)["id"]) ==
                                                false
                                            ? Colors.grey[200]
                                            : Color.fromRGBO(253, 196, 0, 1),
                                        label: Text(
                                          productCategoryList
                                              .elementAt(index)["name"],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Arial',
                                              ),
                                        ),
                                      )),
                                )));
                  }
                  return Container(
                    height: 0,
                    width: 0,
                  );
                })),
      ),
      _buildBottomButton()
    ]);
  }

  Widget _buildBottomButton() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        SubmitButton(
            text: "Button.Apply",
            textColor: Colors.white,
            backgroundColor: Color.fromRGBO(0, 0, 0, 1),
            onPressed: () {
              // print("ck: ${filterProvider.productCategorySelection}");
              filterProvider.productCategorySelection = List.from(tempList);
              // print("check: ${filterProvider.productCategorySelection}");
              Navigator.pop(context);
            }),
        SizedBox(
          height: 10,
        ),
        SubmitButton(
            text: "Button.Reset",
            textColor: Colors.black,
            backgroundColor: Color.fromRGBO(228, 229, 229, 1),
            onPressed: () {
              setState(() {
                tempList.clear();
              });
            })
      ],
    );
  }
}
