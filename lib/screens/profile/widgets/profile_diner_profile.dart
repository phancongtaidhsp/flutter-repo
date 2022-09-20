import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_dietary_restriction.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_favorite_cuisine.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_hospitality_preferences.dart';

class ProfileDinerProfile extends StatelessWidget {
  final Map<String, dynamic> data;
  final FutureOr<dynamic> Function(dynamic) function;

  const ProfileDinerProfile(this.data, this.function);

  @override
  Widget build(BuildContext context) {
    List userFavoriteCuisineList = List.empty(growable: true);
    List userDietaryRestriction = List.empty(growable: true);
    List userHospitalityPreferences = List.empty(growable: true);

    data['preferences'].forEach((value) {
      switch (value['preferenceType'].toString()) {
        case 'CUISINE':
          userFavoriteCuisineList.add(value);
          break;
        case 'DIET':
          userDietaryRestriction.add(value);
          break;
        default:
          userHospitalityPreferences.add(value);
          break;
      }
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            'Profile.DinerProfile'.tr(),
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.grey[900]),
          ),
          ProfileFavoriteCuisine(userFavoriteCuisineList, function),
          ProfileDietaryRestriction(userDietaryRestriction, function),
          ProfileHospitalityPreferences(userHospitalityPreferences, function)
        ],
      ),
    );
  }
}
