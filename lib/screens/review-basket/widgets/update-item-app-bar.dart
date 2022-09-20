import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/models/Product.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/screens/review-basket/widgets/service-type-dialog-widget.dart';
import 'package:provider/provider.dart';

class UpdateItemAppBar extends StatefulWidget {
  const UpdateItemAppBar({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  _UpdateItemAppBarState createState() => _UpdateItemAppBarState();
}

class _UpdateItemAppBarState extends State<UpdateItemAppBar> {
  String eventCriteriaStr = "";
  Map<String, dynamic>? selectedEventCriteria;
  late AddToCartItems basket;
  final dateFormat = DateFormat('dd MMMM yyyy');

  @override
  void initState() {
    basket = context.read<AddToCartItems>();
    eventCriteriaStr = "Delivery • Current Location Today • ASAP";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                height: 36.0,
                width: 36.0,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                    icon: SvgPicture.asset('assets/images/icon-back.svg'),
                    iconSize: 36.0,
                    onPressed: () {
                      // int productIndex =
                      //     basket.itemList.indexWhere((element) => element.id == widget.product.id);
                      // basket.updateItem(productIndex, widget.product);
                      Navigator.pop(context);
                    })),
            GestureDetector(
              onTap: () {
                if (widget.product.outlet != null &&
                    widget.product.outlet['collectionTypes'].length > 0) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Stack(children: <Widget>[
                                  ServiceTypeDialogWidget(
                                      selectedEventCriteria!,
                                      widget.product.outlet,
                                      _setDeliveryServiceInfo),
                                  Positioned(
                                      top: 20,
                                      right: 20,
                                      child: InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset: Offset(0, 1)),
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Icon(Icons.close,
                                                  color: Colors.grey[400]))))
                                ]),
                              ])));
                }
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23.0),
                  ),
                  height: 36.0,
                  width: MediaQuery.of(context).size.width * 0.621,
                  //color: Colors.transparent,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 22,
                          width: 140,
                          child: Text(
                            eventCriteriaStr,
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Colors.black87,
                                      fontSize: 10,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 15.33,
                        right: 15.67,
                        child: SvgPicture.asset(
                          'assets/images/dropdown-button.svg',
                        ),
                      )
                    ],
                  )
                  // DropdownFormField(
                  //     isDense: true,
                  //     dropDownItemList: [],
                  //     selectedIndexChanged: () {},
                  //     initialTextKey:
                  //         'Delivery. Current Location/nToday . ASAP')
                  ),
            ),
            Container(
                height: 36.0,
                width: 36.0,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                    icon: SvgPicture.asset('assets/images/icon-cart.svg'),
                    iconSize: 36.0,
                    onPressed: () {}))
          ],
        ),
      ),
    );
  }

  _setDeliveryServiceInfo(Map<String, dynamic> value) {
    if (value != null) {
      eventCriteriaStr = "";
      setState(() {
        selectedEventCriteria = value;
        if (value['deliveryType'] != null && value['deliveryType'].length > 0) {
          eventCriteriaStr += value['deliveryType'][0] + " • ";
        }
        if (value['deliveryDate'] != null) {
          eventCriteriaStr += dateFormat.format(value['deliveryDate']) + " • ";
        }
        if (value['deliveryTime'] != null) {
          eventCriteriaStr += value['deliveryTime'];
        }
      });
      print("event criteria: $value");
      Navigator.pop(context);
    }
  }
}
