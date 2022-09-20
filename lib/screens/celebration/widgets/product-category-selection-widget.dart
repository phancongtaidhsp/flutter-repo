import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-filter-widgets/party-select-product-categories-widget.dart';
import 'package:provider/provider.dart';

class ProductCategorySelectionWidget extends StatefulWidget {
  ProductCategorySelectionWidget(this.productType);
  final String productType;
  @override
  _ProductCategorySelectionWidgetState createState() =>
      _ProductCategorySelectionWidgetState();
}

class _ProductCategorySelectionWidgetState
    extends State<ProductCategorySelectionWidget> {
  late FilterProvider filterProvider;
  List<String> tempProductCategoryList = [];

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ElevatedButton(
        onPressed: () {
          showBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => Container(
              height: size.height * 0.53,
              width: size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                    padding: EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 10),
                    margin: EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 0), //(x,y)
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(children: [
                      Row(
                        children: [
                          Text("ProductCategorySelection.SelectProductCategory",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .copyWith(fontWeight: FontWeight.w400))
                              .tr(),
                          Spacer(),
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
                                icon: Icon(
                                  Icons.close,
                                ),
                                iconSize: 18.0,
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Expanded(
                        child: PartySelectProductCategoriesWidget(
                            tempProductCategoryList, widget.productType),
                      ),
                    ])),
              ),
            ),
          );
        },
        child: Center(
            child: Row(
          children: [
            Text("ProductCategorySelection.ProductCategory",
                    style: TextStyle(
                      fontFamily: 'Arial Rounded MT Bold',
                      color: filterProvider.isProductCategorySelected()
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center)
                .tr(),
          ],
        )),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            primary: filterProvider.isProductCategorySelected()
                ? Color.fromRGBO(0, 0, 0, 1)
                : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }
}
