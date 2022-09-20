import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_info_container.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_add_favorite_cuisine_popup.dart';

class ProfileFavoriteCuisine extends StatelessWidget {
  final List userFavoriteCuisine;
  final FutureOr<dynamic> Function(dynamic) function;

  const ProfileFavoriteCuisine(this.userFavoriteCuisine, this.function);

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
              'Profile.FavoriteCuisines'.tr(),
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.normal, color: Colors.grey[900]),
            ),
            userFavoriteCuisine.length > 0
                ? IconButton(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => Dialog(
                          child: ProfileAddFavoriteCuisinePopUp(
                              userFavoriteCuisine),
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
        userFavoriteCuisine.length > 0
            ? _buildListFavoriteCuisine(userFavoriteCuisine, context)
            : Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  ProfileAddInfoContainer(
                    text: 'Profile.AddFavoriteCuisine'.tr(),
                    onPress: () {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => Dialog(
                          child: ProfileAddFavoriteCuisinePopUp(
                              userFavoriteCuisine),
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
