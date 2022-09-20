import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/product-detail-widget.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:gem_consumer_app/widgets/product-carousel.dart';

class PackageListWidget extends StatelessWidget {
  PackageListWidget(this.list);

  final List<dynamic> list;

  @override
  Widget build(BuildContext context) {
    print('package-list-widget');
    return Container(
        padding: EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 0.0),
        color: Colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Celebration.PackageInclusions',
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.w400))
                  .tr(),
              GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: list.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 0.0,
                      crossAxisCount: 2),
                  padding: EdgeInsets.only(top: 20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildProductList(context, list[index]);
                  })
            ]));
  }
}

Widget _buildProductList(BuildContext context, Map<String, dynamic> bundle) {
  return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Stack(children: <Widget>[
                    ProductPhotoCarousel(bundle['product']['id'],
                        height: 245.0, roundedCorder: true),
                    Positioned(
                        top: 20,
                        left: 20,
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.close,
                                    color: Colors.grey[400]))))
                  ]),
                  ProductDetailsWidget(bundle)
                ])));
      },
      child: Column(children: <Widget>[
        LayoutBuilder(builder: (context, constraints) {
          return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedImage(
                imageUrl: bundle['product']['smallThumbNail'],
                width: constraints.maxWidth,
                height: constraints.maxWidth * 0.667,
              ));
        }),
        Container(
            padding: EdgeInsets.only(top: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('${bundle['quantity']}x | ${bundle['product']['title']}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))
                ]))
      ]));
}
