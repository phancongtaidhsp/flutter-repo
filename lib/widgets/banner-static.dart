import 'package:flutter/material.dart';
import 'package:gem_consumer_app/screens/home/home.gql.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerStatic extends StatelessWidget {
  BannerStatic(this.area, {this.height = 160});

  final String area;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(document: gql(HomeGQL.GET_BANNER)),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.data != null) {
            final homeData = result.data!['banners']
                .where((b) => b['area'] == area)
                .toList();
            if (homeData.length > 0) {
              var actionType = homeData[0]['actionType']; //URL
              var actionUrl = homeData[0]['redirectUrl'];

              return homeData != null && homeData.length > 0
                  ? actionType == 'URL'
                      ? GestureDetector(
                          onTap: (() async {
                            if (!await launch(actionUrl)) {
                              throw 'Could not launch this url:  $actionUrl';
                            }
                          }),
                          child: CachedImage(
                            imageUrl: homeData[0]['photoUrl'],
                            width: MediaQuery.of(context).size.width,
                            height: height,
                          ),
                        )
                      : CachedImage(
                          imageUrl: homeData[0]['photoUrl'],
                          width: MediaQuery.of(context).size.width,
                          height: height,
                        )
                  : Container(width: 0.0, height: 0.0);
            }
          }
          return Container(width: 0.0, height: 0.0);
        });
  }
}
