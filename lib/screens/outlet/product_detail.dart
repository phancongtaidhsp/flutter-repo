import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/models/AddOnWithOptions.dart';
import 'package:gem_consumer_app/models/Product.dart';
import 'package:gem_consumer_app/screens/outlet/outlet_and_product_carousel.dart';
import 'package:gem_consumer_app/screens/outlet/product_variations.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-product-details-page-widgets/party-product-info-widget.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../widgets/loading_controller.dart';
import '../product/product.gql.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail(
      {Key? key, required this.productOutletId, required this.isSSTEnabled})
      : super(key: key);
  final String productOutletId;
  final bool isSSTEnabled;

  @override
  Widget build(BuildContext context) {
    var isSeasonal = false;
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Query(
                options: QueryOptions(
                    document: gql(ProductGQL.GET_PRODUCT_OUTLET_BY_ID),
                    variables: {'id': productOutletId},
                    fetchPolicy: FetchPolicy.networkOnly),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.isLoading) {
                    return LoadingController();
                  }
                  if (result.data != null &&
                      result.data!['ProductOutlet'] != null) {
                    var productOutletData = result.data!['ProductOutlet'];
                    List<String> photos = [];
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
                        AddOnWithOptions addOn = AddOnWithOptions(
                          minimumSelectItem:
                              newaddOn['minimumSelectItem'] as int,
                          name: newaddOn['name'] as String,
                          maximumSelectItem:
                              newaddOn['maximumSelectItem'] as int,
                          isMultiselect: newaddOn['isMultiselect'] as bool,
                          isRequired: newaddOn['isRequired'] as bool,
                          id: newaddOn['id'] as String,
                          addOnOptions: productAddonOptions,
                        );
                        addOnWithOptions.add(addOn);
                      });
                    }
                    Product product = Product(
                      id: productOutletData['id'],
                      photos: productOutletData['product']['smallPhotos'],
                      title: productOutletData['product']['title'],
                      originalPrice: double.parse(productOutletData['product']
                              ['originalPrice']
                          .toString()),
                      description: productOutletData['product']['description'],
                      outletName: productOutletData['outlet']['name'],
                      outlet: productOutletData['outlet'],
                      productType: productOutletData['product']['productType'],
                      currentPrice: double.parse(productOutletData['product']
                              ['currentPrice']
                          .toString()),
                      addOnWithOptions: addOnWithOptions,
                      thumbNail: productOutletData['product']['smallThumbNail'],
                    );

                    product.photos!.forEach((element) {
                      photos.add(element);
                    });
                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Container(
                                      color: Colors.grey[200],
                                      child: Column(
                                        children: <Widget>[
                                          OutletAndProductCarousel(
                                            merchantOutletPhotos: photos,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                          ),
                                          Container(
                                            color: Colors.grey[200],
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                PartyProductInfoWidget(
                                                  product.toMap(product),
                                                  isSeasonal,
                                                  isSSTEnabled,
                                                ),
                                                product.addOnWithOptions!
                                                        .isNotEmpty
                                                    ? ProductVariations(
                                                        product: product,
                                                        isEnableSST:
                                                            isSSTEnabled,
                                                      )
                                                    : Container(
                                                        width: 0.0,
                                                        height: 0.0),
                                                Container(
                                                    width: 0.0, height: 0.0),
                                                SizedBox(height: 10.0),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                _closeButton(context, size),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 36.0,
                              width: 56.0,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 250, 249, 249),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(0, 1)),
                                  ]),
                              child: IconButton(
                                  icon: SvgPicture.asset(
                                      'assets/images/icon-back.svg'),
                                  iconSize: 36.0,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  })),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 50),
                                Text(
                                  "General.LoadingError",
                                  style: Theme.of(context).textTheme.button,
                                ).tr()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context, Size size) {
    return Positioned(
      top: size.height * 0.0246,
      left: size.width * 0.85,
      child: Container(
        height: 36.0,
        width: 36.0,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: IconButton(
            icon: Icon(
              Icons.close,
            ),
            iconSize: 18.0,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }
}
