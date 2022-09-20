import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:gem_consumer_app/models/Product.dart';
import 'package:gem_consumer_app/screens/outlet/product_detail.dart';
import 'package:gem_consumer_app/screens/outlet/product_room_detail.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import '../../models/AddOnWithOptions.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    Key? key,
    required this.dataList,
    required this.outletName,
    required this.outlet,
    required this.roomSelected,
  }) : super(key: key);
  final List<dynamic> dataList;
  final String outletName;
  final Map<String, dynamic> outlet;
  final bool roomSelected;
  @override
  Widget build(BuildContext context) {
    return _productList(dataList, context);
  }

  Widget _productList(List<dynamic> dataList, BuildContext context) {
    print('product_list');
    return roomSelected
        ? ListView.builder(
            // FOR ROOM
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: dataList.length,
            itemBuilder: (BuildContext context, int index) {
              var productOutletData = dataList[index];
              var currentPrice =
                  productOutletData['product']['currentPrice'] ?? 0.0;
              List<AddOn> addOnsCollection = [];
              var productAddons =
                  productOutletData['product']['productAddons'] as List;
              /**
               * __typename: ProductAddon, id: ckw0e7yu41594281bnaeceianbr, name: Choose One,
               *  isRequired: true, isMultiselect: false, minimumSelectItem: 1, maximumSelectItem: 1,
               * 
               * 
               * productAddonOptions: [
               *  {__typename: ProductAddonOption, id: ckw0e7yun1594371bnasnvukcid, name: Cold, price: 0, order: 1},
               *  {__typename: ProductAddonOption, id: ckw0e7yum1594351bna8bmpnk0x, name: Hot, price: 0, order: 0}]}
               * ]
               */
              productAddons.forEach((newaddOn) {
                var name = '';
                var addOnTitle = '';
                var addonId = '';
                var addOnOptionsId = '';
                var productAddonOptions =
                    newaddOn['productAddonOptions'] as List;
                name = newaddOn['name'];
                addOnOptionsId = newaddOn['id'];
                productAddonOptions.forEach((productAddonOption) {
                  addOnTitle = productAddonOption['addOnTitle'];
                  addonId = productAddonOption['addonId'];
                  AddOn addOn = AddOn(
                    addOnOptionsId: addOnOptionsId,
                    addOnPriceWhenAdded: 0.0,
                    cartItemId: '',
                    name: name,
                    addOnTitle: addOnTitle,
                    addonId: addonId,
                  );

                  addOnsCollection.add(addOn);
                });
              });

              Product product = Product(
                id: productOutletData['product']['id'],
                photos: productOutletData['product']['smallPhotos'],
                title: productOutletData['product']['title'],
                originalPrice: double.parse(
                    productOutletData['product']['originalPrice'].toString()),
                description: productOutletData['product']['description'],
                outletName: outletName,
                outlet: outlet,
                productType: productOutletData['product']['productType'],
                productOutletId: productOutletData['id'],
                //productOutlet: productData['productOutlets'],
                currentPrice: double.parse(currentPrice.toString()),
                addOns: addOnsCollection,
                thumbNail: productOutletData['product']['smallThumbNail'],
              );

              // Sales Text
              String saleText = "";
              if (productOutletData['product']['advancePurchaseDuration'] !=
                  null) {
                int saleDuration =
                    productOutletData['product']['advancePurchaseDuration'];
                String saleUnit =
                    productOutletData['product']['advancePurchaseUnit'];
                saleText =
                    saleDuration.toString() + " " + saleUnit.toLowerCase();

                if (saleDuration > 1) {
                  saleText += "s";
                }
              }
// dataList[index]['availableQuantity'] > 0 &&
//isAlwaysAvailable
//available
// dataList[index]['numberOfRoom'] > 0 &&
              bool isSeasonal = !productOutletData['isAlwaysAvailable'];
              bool isAvailable = true;
              //   productData['productOutlets'][0]['available'] ?? false;

              var isSSTEnabled = outlet['isSSTEnabled'] ?? false;

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return ProductRoomDetail(
                            productOutletId: productOutletData['id']);
                      },
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 8),
                    LayoutBuilder(builder: (context, constraints) {
                      var imageDynamicHeight = constraints.maxWidth * 0.4;
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
                                  child: dataList[index]['product']
                                                  ['smallThumbNail'] ==
                                              "" ||
                                          dataList[index]['product']
                                                  ['smallThumbNail'] ==
                                              null
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
                                dataList[index]['product']['isNew']
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
                                    : Container(),
                                Positioned(
                                  top: 12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    width: 12,
                                                    height: 12,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    saleText,
                                                    style: TextStyle(
                                                        color: grayTextColor,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        fontFamily: 'Arial'),
                                                  )
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  12),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  12))),
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: saleText.length > 0 ? 6 : 0,
                                      ),
                                      isSeasonal
                                          ? Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 6),
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/icon_seasonal.svg',
                                                    color: grayTextColor,
                                                    width: 12,
                                                    height: 12,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    'Product.Seasonal'.tr(),
                                                    style: TextStyle(
                                                        color: grayTextColor,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        fontFamily: 'Arial'),
                                                  )
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  12),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  12))),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                                Container(width: 0.0, height: 0.0),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.4,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(),
                                )
                              ],
                            )),
                      );
                    }),
                    SizedBox(height: 8.0),
                    Text(
                      dataList[index]['product']['title'],
                      style: Theme.of(context).textTheme.button,
                    ),
                    SizedBox(height: 4.0),
                    product.productType == "ROOM"
                        ? RichText(
                            text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text:
                                    "RM ${StringHelper.formatCurrency((dataList[index]['product']['originalPrice'] + (isSSTEnabled ? dataList[index]['product']['originalPrice'] * 0.06 : 0)))}",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400)),
                            TextSpan(
                                text:
                                    " • ${dataList[index]['product']['pax'] == null ? 10 : dataList[index]['product']['pax']} pax",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400)),
                            TextSpan(text: "")
                          ]))
                        : RichText(
                            text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text:
                                    "RM ${StringHelper.formatCurrency((product.currentPrice! + (isSSTEnabled ? product.currentPrice! * 0.06 : 0)))} ",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400)),
                            dataList[index]['product']['originalPrice'] >
                                    product.currentPrice!
                                ? TextSpan(
                                    text:
                                        "RM ${StringHelper.formatCurrency((dataList[index]['product']['originalPrice'] + (isSSTEnabled ? dataList[index]['product']['originalPrice'] * 0.06 : 0)))}",
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
                                    " • ${dataList[index]['product']['pax'] == null ? 10 : dataList[index]['product']['pax']} pax",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400)),
                            TextSpan(text: "")
                          ])),
                    SizedBox(height: 20.0),
                  ],
                ),
              );
            })
        : GridView.builder(
            shrinkWrap: true,
            cacheExtent: 999999,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dataList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.95,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 10.0,
                mainAxisExtent: 190,
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              var productOutletData = dataList[index];
              var currentPrice =
                  productOutletData['product']['currentPrice'] ?? 0.0;
              var productAddons =
                  productOutletData['product']['productAddons'] as List;

              List<Map<String, dynamic>> productAddonOptions = [];

              List<AddOnWithOptions> addOnWithOptions = [];

              if (productAddons.isNotEmpty) {
                productAddons.forEach((newaddOn) {
                  productAddonOptions = [];
                  var paoptionsObjectCollection =
                      newaddOn['productAddonOptions'] as List;
                  paoptionsObjectCollection.forEach((p) {
                    var m = {
                      'id': p['id'],
                      'name': p['name'],
                      'order': p['order'],
                      'price': p['price'],
                    };
                    productAddonOptions.add(m);
                  });
                  // print(productAddonOptions.length.toString());
                  // print('a:::${newaddOn['name']}');
                  AddOnWithOptions addOn = AddOnWithOptions(
                    minimumSelectItem: newaddOn['minimumSelectItem'] as int,
                    name: newaddOn['name'] as String,
                    maximumSelectItem: newaddOn['maximumSelectItem'] as int,
                    isMultiselect: newaddOn['isMultiselect'] as bool,
                    isRequired: newaddOn['isRequired'] as bool,
                    id: newaddOn['id'] as String,
                    addOnOptions: productAddonOptions,
                  );
                  addOnWithOptions.add(addOn);
                });
              }

              Product product = Product(
                id: productOutletData['product']['id'],
                photos: productOutletData['product']['smallPhotos'],
                title: productOutletData['product']['title'],
                originalPrice: double.parse(
                    productOutletData['product']['originalPrice'].toString()),
                description: productOutletData['product']['description'],
                outletName: outletName,
                outlet: outlet,
                productType: productOutletData['product']['productType'],
                //productOutlet: productData['productOutlets'],
                productOutletId: productOutletData['id'],
                currentPrice: double.parse(currentPrice.toString()),
                addOnWithOptions: addOnWithOptions,
                thumbNail: productOutletData['product']['smallThumbNail'],
              );

              // if (product.title.contains('Fresh Lemongrass')) {
              //   // log(addOnWithOptions[0].addOnOptions.toString());
              //   // log(productData['productAddons'].toString());
              //   //log(product.toMap(product).toString());
              //   product.addOnWithOptions!.forEach((element) {
              //     print(element.addOnOptions.length.toString());
              //     print(element.name);
              //   });
              // }

              String saleText = "";
              if (productOutletData['product']['advancePurchaseDuration'] !=
                  null) {
                int saleDuration =
                    productOutletData['product']['advancePurchaseDuration'];
                String saleUnit =
                    productOutletData['product']['advancePurchaseUnit'];
                saleText =
                    saleDuration.toString() + " " + saleUnit.toLowerCase();

                if (saleDuration > 1) {
                  saleText += "s";
                }
              }
              bool isSeasonal = !productOutletData['isAlwaysAvailable'];
              var isSSTEnabled = outlet['isSSTEnabled'] ?? false;
              var title = productOutletData['product']['title'];

              return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return ProductDetail(
                              productOutletId: productOutletData['id'],
                              isSSTEnabled: isSSTEnabled);
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 410,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            LayoutBuilder(builder: (context, constraints) {
                              var imageDynamicHeight =
                                  constraints.maxWidth * 0.667;
                              return SizedBox(
                                width: constraints.maxWidth,
                                height: imageDynamicHeight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      productOutletData['product']
                                                      ['smallThumbNail'] ==
                                                  "" ||
                                              productOutletData['product']
                                                      ['smallThumbNail'] ==
                                                  null
                                          ? DefaultImageHelper
                                              .defaultImageWithSize(
                                              constraints.maxWidth,
                                              imageDynamicHeight,
                                            )
                                          : CachedImage(
                                              width: constraints.maxWidth,
                                              height: imageDynamicHeight,
                                              imageUrl:
                                                  productOutletData['product']
                                                      ['smallThumbNail']),
                                      productOutletData['product']['isNew']
                                          ? Positioned(
                                              top: 10,
                                              right: 12,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12))),
                                                child: Text(
                                                  'Product.New'.tr(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Arial',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Positioned(
                                        top: 12,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            saleText.length > 0
                                                ? Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/icon-sale.svg',
                                                          color: grayTextColor,
                                                          width: 12,
                                                          height: 12,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          saleText,
                                                          style: TextStyle(
                                                              color:
                                                                  grayTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Arial'),
                                                        )
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: primaryColor,
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        12),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        12))),
                                                  )
                                                : Container(),
                                            SizedBox(
                                              height:
                                                  saleText.length > 0 ? 6 : 0,
                                            ),
                                            isSeasonal
                                                ? Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/icon_seasonal.svg',
                                                          color: grayTextColor,
                                                          width: 12,
                                                          height: 12,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Product.Seasonal'
                                                              .tr(),
                                                          style: TextStyle(
                                                              color:
                                                                  grayTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Arial'),
                                                        )
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: primaryColor,
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        12),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        12))),
                                                  )
                                                : SizedBox(width: 0, height: 0)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8.0),
                            Text(
                              productOutletData['product']['pax'] != null
                                  ? "${productOutletData['product']['pax']} Pax | $title"
                                  : title,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.normal),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Expanded(
                              child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: product.productType == "ROOM"
                                      ? TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  "RM ${StringHelper.formatCurrency((productOutletData['product']['originalPrice'] + (isSSTEnabled ? productOutletData['product']['originalPrice'] * 0.06 : 0)))}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400))
                                        ])
                                      : TextSpan(children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  "RM ${StringHelper.formatCurrency((product.currentPrice! + (isSSTEnabled ? productOutletData['product']['currentPrice'] * 0.06 : 0)))} ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                          productOutletData['product']
                                                      ['originalPrice'] >
                                                  product.currentPrice!
                                              ? TextSpan(
                                                  text:
                                                      "RM ${StringHelper.formatCurrency((productOutletData['product']['originalPrice'] + (isSSTEnabled ? productOutletData['product']['originalPrice'] * 0.06 : 0)))}",
                                                  style: const TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontFamily:
                                                        'Arial Rounded MT Bold',
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                  ))
                                              : const TextSpan(text: "")
                                        ])),
                            ),
                          ]),
                    ),
                  ));
            });
  }
}
