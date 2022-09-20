import 'package:flutter/material.dart';
import 'package:gem_consumer_app/screens/home/widgets/home-content.dart';
import 'package:gem_consumer_app/widgets/banner-carousel.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeTab extends StatefulWidget {
  final Function goToPage;
  final Function goToPackage;

  const HomeTab({Key? key, required this.goToPage, required this.goToPackage})
      : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            BannerCarousel(
              'HOME',
              height: MediaQuery.of(context).size.width * 0.6,
              isBottomCurve: true,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.32,
                  width: MediaQuery.of(context).size.width,
                  color: Color.fromRGBO(255, 213, 107, 1),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: 64.0, left: 25.0),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'PlanAPartyHome.HomeTitle',
                                      style: TextStyle(
                                        fontFamily: 'Arial Rounded MT Bold',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 34,
                                      ),
                                      textAlign: TextAlign.left,
                                    ).tr(),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'PlanAPartyHome.HomeSubTitle',
                                      style: TextStyle(
                                        fontFamily: 'Arial Rounded MT Light',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.left,
                                    ).tr(),
                                  ])),
                          Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 24,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(24),
                                    topLeft: Radius.circular(24)),
                                color: Colors.white),
                          )
                        ],
                      ))),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white),
              child: HomeContent(
                goToPage: widget.goToPage,
                goToPackage: widget.goToPackage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
