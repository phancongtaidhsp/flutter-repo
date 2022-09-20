import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_dietary_restriction_popup.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_info_container.dart';

class ProfileDietaryRestriction extends StatelessWidget {
  final List userDietaryRestriction;
  final FutureOr<dynamic> Function(dynamic) function;

  ProfileDietaryRestriction(this.userDietaryRestriction, this.function);

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
              'Profile.DietaryRestrictions'.tr(),
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.normal, color: Colors.grey[900]),
            ),
            userDietaryRestriction.length > 0
                ? IconButton(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => Dialog(
                          child: ProfileAddDietaryPopUp(userDietaryRestriction),
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
        userDietaryRestriction.length > 0
            ? _buildListDietaryRestriction(userDietaryRestriction, context)
            : Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  ProfileAddInfoContainer(
                    text: 'Profile.AddDietaryRestrictions'.tr(),
                    onPress: () {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => Dialog(
                          child: ProfileAddDietaryPopUp(userDietaryRestriction),
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.all(24),
                        ),
                      ).then(function);
                    },
                  )
                ],
              ),
      ],
    );
  }

  Widget _buildListDietaryRestriction(List list, BuildContext context) {
    return Wrap(
      children: List.generate(
          list.length,
          (index) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                visualDensity: VisualDensity(vertical: -4),
                title: Text(
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
