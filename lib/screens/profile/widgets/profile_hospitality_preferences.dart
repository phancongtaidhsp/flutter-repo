import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_hospitally_popup.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_info_container.dart';

class ProfileHospitalityPreferences extends StatelessWidget {
  final List userHospitalityPreferences;
  final FutureOr<dynamic> Function(dynamic) function;

  const ProfileHospitalityPreferences(
      this.userHospitalityPreferences, this.function);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile.HospitalityPreferences'.tr(),
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.normal, color: Colors.grey[900]),
            ),
            userHospitalityPreferences.length > 0
                ? IconButton(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => Dialog(
                          child: ProfileAddHospitalityPreferencesPopUp(
                              userHospitalityPreferences),
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.all(24),
                        ),
                      ).then(function);
                    },
                    icon: SvgPicture.asset(
                      'assets/images/icon_edit.svg',
                      width: 24,
                      height: 24,
                      color: Colors.black,
                    ))
                : Container()
          ],
        ),
        userHospitalityPreferences.length > 0
            ? _buildListFavoriteCuisine(userHospitalityPreferences, context)
            : Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  ProfileAddInfoContainer(
                    text: 'Profile.AddHospitalityPreferences'.tr(),
                    onPress: () {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => Dialog(
                          child: ProfileAddHospitalityPreferencesPopUp(
                              userHospitalityPreferences),
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.all(24),
                        ),
                      ).then(function);
                    },
                  )
                ],
              ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget _buildListFavoriteCuisine(List list, BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: -4,
      children: List.generate(
          list.length,
          (index) => Chip(
                padding: EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                backgroundColor: Colors.grey[200],
                label: Text(
                  list[index]['itemName'].toString(),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.normal, fontSize: 12),
                ),
              )),
    );
  }
}
