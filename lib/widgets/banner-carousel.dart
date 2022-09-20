import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/home/home.gql.dart';

class BannerCarousel extends StatelessWidget {
  BannerCarousel(this.area,
      {this.height = 245, this.child, this.isBottomCurve = false});

  final String area;
  final double height;
  final Widget? child;
  final bool isBottomCurve;

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(HomeGQL.GET_BANNER),
            fetchPolicy: FetchPolicy.cacheAndNetwork),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            final homeData = result.data!['banners']
                .where((b) => b['area'] == area)
                .toList();
            return homeData != null && homeData.length > 0
                ? Container(
                    height: height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        CarouselSlider.builder(
                            options: CarouselOptions(
                                height: height,
                                viewportFraction: 1.0,
                                autoPlayInterval: Duration(seconds: 5),
                                enableInfiniteScroll:
                                    homeData.length > 1 ? true : false,
                                autoPlay: homeData.length > 1 ? true : false),
                            itemCount: homeData.length,
                            itemBuilder:
                                (BuildContext context, int index, int _) {
                              return InkWell(
                                onTap: () {
                                  if (homeData[index]['actionType'] == 'URL')
                                    launch(homeData[index]['redirectUrl']);
                                },
                                child: homeData[index]['photoUrl'] != null ||
                                        homeData[index]['photoUrl'] != ''
                                    ? CachedImage(
                                        imageUrl: homeData[index]['photoUrl'],
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: height,
                                      )
                                    : DefaultImageHelper.defaultImage,
                              );
                            }),
                        isBottomCurve
                            ? Positioned(
                                bottom: 0,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 24,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(24),
                                          topLeft: Radius.circular(24)),
                                      color: Colors.white),
                                ))
                            : Container(),
                      ],
                    ),
                  )
                : child ?? SizedBox(width: 0.0, height: 0.0);
          }
          return Container(width: 0.0, height: 0.0);
        });
  }
}
