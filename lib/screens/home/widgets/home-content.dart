import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/widgets/banner-static.dart';
import 'package:gem_consumer_app/widgets/shimmer-effect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeContent extends StatelessWidget {
  final Function goToPage;
  final Function goToPackage;

  const HomeContent(
      {Key? key, required this.goToPage, required this.goToPackage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String _url = 'https://flutter.dev';
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
              onTap: () => goToPage(),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(2.5, 2.5), //(x,y)
                        spreadRadius: 0.5,
                        blurRadius: 3,
                      ),
                    ]),
                child: Stack(
                  children: [
                    Image.asset('assets/images/home/plan_wo_box.png',
                        width: size.width * 0.41, height: 200),
                    // NOTE: For further change , if need to use svg
                    // SvgPicture.asset(
                    //   'assets/images/home/B01.svg',
                    //   placeholderBuilder: (context) => ShimmerEffect(
                    //     width: size.width * 0.41,
                    //     height: 200,
                    //     borderRadius: 12,
                    //   ),
                    //   width: size.width * 0.41,
                    // ),
                    Positioned(
                        left: 15,
                        bottom: 15,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                child: Text('Plan A Party',
                                        style: Theme.of(context)
                                            .textTheme
                                            .button!
                                            .copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black))
                                    .tr(),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                width: 120,
                                child: Text('Customise Your Event',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                                fontSize: 7.5,
                                                color: Colors.black))
                                    .tr(),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 6),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Start Here',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 8,
                                                    color: Colors.black))
                                        .tr(),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 7,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                  ],
                ),
              )),
          SizedBox(
            width: size.width * 0.04,
          ),
          GestureDetector(
              onTap: () => goToPackage(),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(2.5, 2.5), //(x,y)
                        spreadRadius: 0.5,
                        blurRadius: 3,
                      ),
                    ]),
                child: Stack(
                  children: [
                    Image.asset('assets/images/home/celebration_wo_box.png',
                        width: size.width * 0.41, height: 200),
                    // SvgPicture.asset(
                    //   'assets/images/home/B03.svg',
                    //   placeholderBuilder: (context) => ShimmerEffect(
                    //     width: size.width * 0.41,
                    //     height: 200,
                    //     borderRadius: 12,
                    //   ),
                    //   width: size.width * 0.41,
                    // ),
                    Positioned(
                        left: 15,
                        bottom: 15,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                child: Text('Celebration Package',
                                        style: Theme.of(context)
                                            .textTheme
                                            .button!
                                            .copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black))
                                    .tr(),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                width: 120,
                                child: Text('Specially Curated Sets',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                                fontSize: 7.5,
                                                color: Colors.black))
                                    .tr(),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 6),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('View All',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 8,
                                                    color: Colors.black))
                                        .tr(),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 7,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                  ],
                ),
              ))
        ]),
        SizedBox(
          height: size.height * 0.018,
        ),
        BannerStatic(
          'SPECIAL_DEALS',
          height: size.width * 0.4,
        ),
        GestureDetector(
          onTap: _launchURL,
          child: Container(
            height: size.height * 0.25,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
            child: SvgPicture.asset(
              'assets/images/home/banner-contact.svg',
              placeholderBuilder: (context) => ShimmerEffect(
                width: size.width,
                height: size.height * 0.25,
              ),
              height: MediaQuery.of(context).size.width,
            ),
          ),
        ),
        SizedBox(
          height: 12,
        )
      ],
    ));
  }

  _launchURL() async {
    if (!await launch(
        "https://docs.google.com/forms/d/e/1FAIpQLSc1j6H-JeI7LZX3oVEbBqhby79T-iUacUU_eGLj8OjwCJ3QdQ/viewform"))
      throw 'Could not launch this google form';
  }
}
