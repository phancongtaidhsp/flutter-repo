import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/shimmer-effect.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class OccasionComingPopup extends StatelessWidget {
  final String date;
  final String title;
  final Function goToPackage;
  final Function goToPage;

  OccasionComingPopup(this.date, this.title, this.goToPackage, this.goToPage);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                    height: 36.0,
                    width: 36.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1.75,
                              blurRadius: 1,
                              offset: Offset(0, 1)),
                        ]),
                    child: IconButton(
                        icon: SvgPicture.asset('assets/images/icon-close.svg'),
                        iconSize: 36.0,
                        onPressed: () {
                          Navigator.pop(context);
                        })),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Notification.UpcomingCelebration'.tr(),
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.w400),
              ),
              SvgPicture.asset(
                'assets/images/logo_calendar.svg',
                placeholderBuilder: (context) => ShimmerEffect(
                  width: 140,
                  height: 140,
                  borderRadius: 12,
                ),
                width: 140,
                height: 140,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.headline3!.copyWith(
                    fontWeight: FontWeight.w400, color: Colors.grey[600]),
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontWeight: FontWeight.w400, fontSize: 12),
              ),
              SizedBox(
                height: 40,
              ),
              SubmitButton(
                text: 'PlanAParty.PlanParty'.tr(),
                backgroundColor: primaryColor,
                textColor: Colors.black,
                rippleColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                  goToPage();
                },
              ),
              SizedBox(
                height: 10,
              ),
              SubmitButton(
                text: 'CelebrationHome.Plan'.tr(),
                backgroundColor: primaryColor,
                textColor: Colors.black,
                rippleColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                  goToPackage();
                },
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
