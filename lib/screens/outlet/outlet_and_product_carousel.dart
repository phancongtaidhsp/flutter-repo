import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';

class OutletAndProductCarousel extends StatefulWidget {
  OutletAndProductCarousel(
      {this.height = 245,
      this.roundedCorder = false,
      required this.merchantOutletPhotos});

  final double height;
  final bool roundedCorder;
  final List<String> merchantOutletPhotos;

  @override
  _OutletAndProductCarouselState createState() =>
      _OutletAndProductCarouselState();
}

class _OutletAndProductCarouselState extends State<OutletAndProductCarousel> {
  List<dynamic> imgList = [];
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    // print(widget.merchantOutletPhotos.length);
    // print(' widget.merchantOutletPhotos.length ');
    return Container(
        decoration: BoxDecoration(color: Colors.grey[200],
            // color: Colors.blue,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              )
            ]),
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        child: widget.merchantOutletPhotos.length > 0
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
                            widget.merchantOutletPhotos.length > 1
                                ? true
                                : false,
                        autoPlay: widget.merchantOutletPhotos.length > 1
                            ? true
                            : false),
                    itemCount: widget.merchantOutletPhotos.length,
                    itemBuilder: (BuildContext context, int index, int _) {
                      // print(widget.merchantOutletPhotos[index]);

                      // print('done1');
                      return widget.merchantOutletPhotos.length == 0
                          ? DefaultImageHelper.defaultImage
                          : CachedImage(
                              imageUrl: widget.merchantOutletPhotos[index],
                              width: MediaQuery.of(context).size.width,
                              height: widget.height,
                            );
                    }),
                Positioned(
                    bottom: 0.0,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      //height: 100,
                      //color: Colors.red,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.merchantOutletPhotos.map(
                            (image) {
                              //these two lines
                              int index = widget.merchantOutletPhotos
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
                          ).toList()),
                    ))
              ])
            : DefaultImageHelper.defaultImage);
  }
}
