import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_info_container.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_or_edit_occasion.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class ProfileSpecialOccasion extends StatelessWidget {
  final Map<String, dynamic> data;
  final FutureOr<dynamic> Function(dynamic) function;

  const ProfileSpecialOccasion(this.data, this.function);

  @override
  Widget build(BuildContext context) {
    List userSpecialOccasion = data['specialDays'].take(5).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            'Profile.MySpecialOccasions'.tr(),
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.grey[900]),
          ),
          SizedBox(
            height: 20,
          ),
          userSpecialOccasion.length > 0
              ? _buildListSpecialOccasions(userSpecialOccasion, context)
              : ProfileAddInfoContainer(
                  text: 'Profile.AddEventReminder'.tr(),
                  onPress: () {
                    Navigator.of(context)
                        .pushNamed(ProfileAddOrEditOccasion.routeName)
                        .then(function);
                  },
                ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildListSpecialOccasions(List data, BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: List.generate(
              data.length, (index) => _buildItemOccasion(data, index, context)),
        ),
        SizedBox(
          height: 4,
        ),
        Visibility(
          visible: data.length < 5,
          child: SubmitButton(
            text: 'Profile.AddEventReminder',
            backgroundColor: Colors.grey[300],
            verticalTextPadding: 12,
            textColor: Colors.black,
            rippleColor: Colors.white,
            height: 10,
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(ProfileAddOrEditOccasion.routeName)
                  .then(function);
            },
          ),
        )
      ],
    );
  }

  Widget _buildItemOccasion(List data, int index, BuildContext context) {
    var formatString = "yyyy-MM-ddTHH:mm:ss.mmmZ";
    DateTime format1 =
        new DateFormat(formatString).parse(data[index]['date'], true).toLocal();
    String date = DateFormat("EE, dd MMM yyyy").format(format1);
    String subTextOccasion;

    if (data[index]['reminderInterval'] != null &&
        data[index]['reminderIntervalUnit'] != null) {
      String durationBeforeRemind;
      if (data[index]['reminderInterval'] == 1) {
        durationBeforeRemind = 'Profile.RemindBeforeOneDay'.tr();
      } else if(data[index]['reminderInterval'] == 7) {
        durationBeforeRemind = 'Profile.RemindBeforeOneWeek'.tr();
      } else {
        durationBeforeRemind = 'Profile.RemindBeforeOneMonth'.tr();
      }

      subTextOccasion = durationBeforeRemind + ' ' +
          date;
    } else {
      subTextOccasion = date;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/images/icon_calendar.svg',
              width: 28, height: 28),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data[index]['name'],
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.normal, fontSize: 14),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  subTextOccasion,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 12, color: Colors.grey[400]),
                )
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileAddOrEditOccasion(
                          data: data[index],
                        ))).then(function);
              },
              child: SvgPicture.asset(
                'assets/images/icon_edit.svg',
                width: 28,
                height: 28,
                color: Colors.black,
              ))
        ],
      ),
    );
  }
}
