import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../screens/login/login.dart';
import '../../screens/onboarding/onboarding-page-view.dart';
import '../../screens/party/widgets/chip-form.dart';
import '../../values/color-helper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  static String routeName = '/onboarding';

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late int currentPage;
  late PageController pageController;
  late List<Widget> listPage;
  Duration pageTurnDuration = Duration(milliseconds: 500);
  Curve pageTurnCurve = Curves.ease;

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    pageController =
        PageController(viewportFraction: 1, initialPage: currentPage);
    Future.delayed(Duration.zero, () async {
      await precacheImage(
          AssetImage('assets/images/onboarding/rsz_splashscreen_1.jpg'),
          context);
      await precacheImage(
          AssetImage('assets/images/onboarding/rsz_splashscreen_2.jpg'),
          context);

      await precacheImage(
          AssetImage('assets/images/onboarding/rsz_splashscreen_3.jpg'),
          context);
    });
    listPage = [
      OnboardingPageView(
        imageBackground: 'assets/images/onboarding/rsz_splashscreen_1.jpg',
        title1: '',
        title2: '',
      ),
      OnboardingPageView(
        imageBackground: 'assets/images/onboarding/rsz_splashscreen_2.jpg',
        title1: '',
        title2: '',
      ),
      OnboardingPageView(
        imageBackground: 'assets/images/onboarding/rsz_splashscreen_3.jpg',
        title1: '',
        title2: '',
      )
    ];
  }

  void onChangePage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void goBackOnePage() {
    if (currentPage > 0) {
      setState(() {
        pageController.previousPage(
            duration: pageTurnDuration, curve: pageTurnCurve);
      });
    }
  }

  void goForwardOnePage() {
    setState(() {
      pageController.nextPage(duration: pageTurnDuration, curve: pageTurnCurve);
    });
  }

  void onSkipToLogin() {
    Navigator.pushReplacementNamed(context, Login.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView(
                  physics: BouncingScrollPhysics(),
                  onPageChanged: (value) {
                    onChangePage(value);
                  },
                  controller: pageController,
                  children: listPage,
                ),
              ),
              Positioned(
                top: 80,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: size.width,
                    child: Row(
                      children: [
                        currentPage != 0
                            ? InkResponse(
                                splashColor: lightPrimaryColor,
                                onTap: () {
                                  setState(() {
                                    goBackOnePage();
                                  });
                                },
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 12),
                                  child: SvgPicture.asset(
                                    'assets/images/icon-arrow-left.svg',
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : Container(
                                width: 36,
                                height: 36,
                              ),
                        Spacer(),
                        InkResponse(
                          splashColor: lightPrimaryColor,
                          onTap: () {
                            onSkipToLogin();
                          },
                          child: Text(
                            'SKIP',
                            style: TextStyle(
                                fontFamily: 'Arial Rounded MT Bold',
                                fontSize: 14,
                                color: Colors.black,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    )),
              ),
              Positioned(
                bottom: 30,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: size.width,
                    child: Row(
                      children: [
                        SmoothPageIndicator(
                          controller: pageController,
                          count: 3,
                          effect: WormEffect(
                              dotWidth: 10,
                              dotHeight: 10,
                              activeDotColor: primaryColor,
                              dotColor: Colors.black),
                        ),
                        Spacer(),
                        InkWell(
                          splashColor: Colors.white,
                          borderRadius: BorderRadius.circular(23.0),
                          onTap: () {
                            if (currentPage == 2) {
                              onSkipToLogin();
                            } else {
                              setState(() {
                                goForwardOnePage();
                              });
                            }
                          },
                          child: ChipForm(
                            isOnBoardingPage: true,
                            width: 120,
                            height: 50,
                            text: 'SignInWithMobile.Next'.tr(),
                            iconPath: 'assets/images/icon-arrow-right.svg',
                            iconHeight: 12,
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
