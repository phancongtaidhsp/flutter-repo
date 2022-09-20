import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shimmer/shimmer.dart';

class ProductPhotoCarousel extends StatefulWidget {
  ProductPhotoCarousel(this.productId,
      {this.height = 245, this.roundedCorder = false});

  final String productId;
  final double height;
  final bool roundedCorder;

  @override
  _ProductPhotoCarouselState createState() => _ProductPhotoCarouselState();
}

class _ProductPhotoCarouselState extends State<ProductPhotoCarousel> {
  List<dynamic> imgList = [];
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    print('productData ::');
    return Query(
        options: QueryOptions(
            variables: {'id': widget.productId},
            document: gql(ProductGQL.GET_PRODUCT_PHOTOS),
            fetchPolicy: FetchPolicy.cacheAndNetwork),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: widget.height,
                color: Colors.grey[300],
              ),
            );
          }
          if (result.data != null) {
            final productData = result.data!['Product']['smallPhotos'];
            imgList = productData;
            print(imgList.length);
            return Container(
                decoration: BoxDecoration(
                    borderRadius: widget.roundedCorder
                        ? BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))
                        : null,
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      )
                    ]),
                height: widget.height,
                width: MediaQuery.of(context).size.width,
                child: imgList.length > 0
                    ? Stack(alignment: Alignment.center, children: <Widget>[
                        CarouselSlider.builder(
                            options: CarouselOptions(
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                },
                                height: widget.height,
                                viewportFraction: 1.0,
                                autoPlayInterval: Duration(seconds: 5),
                                enableInfiniteScroll:
                                    productData.length > 1 ? true : false,
                                autoPlay:
                                    productData.length > 1 ? true : false),
                            itemCount: productData.length,
                            itemBuilder:
                                (BuildContext context, int index, int _) {
                              print(productData[index]);
                              print('productData ::');

                              return widget.roundedCorder
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0)),
                                      child: CachedImage(
                                        imageUrl: productData[index],
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: widget.height,
                                      ))
                                  : CachedImage(
                                      imageUrl: productData[index],
                                      width: MediaQuery.of(context).size.width,
                                      height: widget.height,
                                    );
                            }),
                        Positioned(
                            bottom: 0.0,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: imgList.map(
                                  (image) {
                                    //these two lines
                                    int index = productData
                                        .indexOf(image); //are changed
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == index
                                              ? Color.fromRGBO(255, 255, 255, 1)
                                              : Color.fromRGBO(0, 0, 0, 1)),
                                    );
                                  },
                                ).toList()))
                      ])
                    : DefaultImageHelper.defaultImage);
          }
          print('sfadsfasd');
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: widget.height,
              color: Colors.grey[300],
            ),
          );
        });
  }
}
