import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth.dart';
import '../../../screens/profile/gql/profile.gql.dart';
import '../../../screens/profile/widgets/profile_no_photo_widget.dart';
import '../../../values/color-helper.dart';
import '../../../widgets/submit-button.dart';

class ProfileAddHospitalityPreferencesPopUp extends StatefulWidget {
  final List userHospitalityPreferencesList;

  const ProfileAddHospitalityPreferencesPopUp(
      this.userHospitalityPreferencesList);

  @override
  _ProfileAddHospitalityPreferencesPopUpState createState() =>
      _ProfileAddHospitalityPreferencesPopUpState();
}

class _ProfileAddHospitalityPreferencesPopUpState
    extends State<ProfileAddHospitalityPreferencesPopUp> {
  List userHospitalityData = List.empty(growable: true);
  static late Auth auth;

  @override
  void initState() {
    super.initState();
    auth = context.read<Auth>();
    userHospitalityData.addAll(widget.userHospitalityPreferencesList);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(16), topLeft: Radius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height * 0.75,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 36.0,
                      width: 36.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0.5,
                                blurRadius: 2,
                                offset: Offset(0, 1.5))
                          ]),
                      child: IconButton(
                          icon: SvgPicture.asset('assets/images/icon-back.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            Navigator.pop(context);
                          })),
                  Spacer(),
                  Mutation(
                      options: MutationOptions(
                        document: gql(ProfileGQL.ADD_OR_EDIT_HOSPITALITY),
                        onCompleted: (dynamic resultData) {
                          Navigator.pop(context, true);
                        },
                        onError: (dynamic resultData) {
                          print(resultData);
                        },
                      ),
                      builder: (
                        RunMutation runMutation,
                        QueryResult? result,
                      ) {
                        return SubmitButton(
                          text: 'Button.Done',
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                          rippleColor: Colors.grey,
                          width: 100,
                          height: 40,
                          textSize: 12,
                          verticalTextPadding: 14,
                          isUppercase: true,
                          onPressed: () {
                            print(userHospitalityData.length);
                            List<String> listHospitality =
                                List.empty(growable: true);
                            userHospitalityData.forEach((element) {
                              listHospitality.add(element['itemId']);
                            });
                            runMutation({
                              "userId": auth.currentUser.id,
                              "hospitalIds": listHospitality
                            });
                          },
                        );
                      })
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Profile.YourHospitalityPreferences'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: Query(
                    options: QueryOptions(
                        document:
                            gql(ProfileGQL.GET_ALL_HOSPITALITY_PREFERENCES),
                        fetchPolicy: FetchPolicy.cacheAndNetwork),
                    builder: (QueryResult result,
                        {VoidCallback? refetch, FetchMore? fetchMore}) {
                      if (result.data != null) {
                        List hospitalityList = result.data!['Amenities'];

                        return Scrollbar(
                          child: GridView.count(
                              physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              crossAxisCount: 3,
                              childAspectRatio: 0.8,
                              shrinkWrap: true,
                              crossAxisSpacing: 12,
                              children: List.generate(
                                  hospitalityList.length,
                                  (index) => Container(
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (userHospitalityData.any(
                                                      (element) =>
                                                          element['itemId'] ==
                                                          hospitalityList[index]
                                                              ['id'])) {
                                                    userHospitalityData
                                                        .removeWhere(
                                                            (element) =>
                                                                element[
                                                                    'itemId'] ==
                                                                hospitalityList[
                                                                        index]
                                                                    ['id']);
                                                  } else {
                                                    userHospitalityData.add({
                                                      'itemId':
                                                          hospitalityList[index]
                                                              ['id']
                                                    });
                                                  }
                                                });
                                              },
                                              child: Container(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        width:
                                                            (size.width - 112) /
                                                                3,
                                                        height:
                                                            (size.width - 112) /
                                                                3,
                                                        child: hospitalityList[
                                                                        index][
                                                                    'thumbNail'] !=
                                                                null
                                                            ? CachedImage(
                                                                imageUrl: hospitalityList[
                                                                        index][
                                                                    'thumbNail'],
                                                                height:
                                                                    (size.width -
                                                                            112) /
                                                                        3,
                                                                width:
                                                                    (size.width -
                                                                            112) /
                                                                        3,
                                                              )
                                                            : DefaultImageHelper
                                                                .defaultImage,
                                                      ),
                                                      Positioned(
                                                        top: 8,
                                                        right: 8,
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              if (userHospitalityData.any((element) =>
                                                                  element[
                                                                      'itemId'] ==
                                                                  hospitalityList[
                                                                          index]
                                                                      ['id'])) {
                                                                userHospitalityData.removeWhere((element) =>
                                                                    element[
                                                                        'itemId'] ==
                                                                    hospitalityList[
                                                                            index]
                                                                        ['id']);
                                                              } else {
                                                                userHospitalityData
                                                                    .add({
                                                                  'itemId':
                                                                      hospitalityList[
                                                                              index]
                                                                          ['id']
                                                                });
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 24,
                                                            width: 24,
                                                            decoration: BoxDecoration(
                                                                color: userHospitalityData.any((element) =>
                                                                        element[
                                                                            'itemId'] ==
                                                                        hospitalityList[index]
                                                                            [
                                                                            'id'])
                                                                    ? primaryColor
                                                                    : Colors
                                                                        .white,
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.3),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          1,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              1)),
                                                                ]),
                                                            child: Icon(
                                                              FontAwesomeIcons
                                                                  .heart,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              hospitalityList[index]['name'],
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      color: Colors.grey[800],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            )
                                          ],
                                        ),
                                      ))),
                        );
                      }
                      return Container(
                        height: 0,
                        width: 0,
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
