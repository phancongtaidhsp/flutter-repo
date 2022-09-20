import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../providers/auth.dart';
import '../../../screens/profile/gql/profile.gql.dart';
import '../../../values/color-helper.dart';
import '../../../widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class ProfileAddDietaryPopUp extends StatefulWidget {
  final List userDietaryList;

  const ProfileAddDietaryPopUp(this.userDietaryList);

  @override
  _ProfileAddDietaryPopUpState createState() => _ProfileAddDietaryPopUpState();
}

class _ProfileAddDietaryPopUpState extends State<ProfileAddDietaryPopUp> {
  List userDietData = List.empty(growable: true);
  static late Auth auth;

  @override
  void initState() {
    super.initState();
    auth = context.read<Auth>();
    userDietData.addAll(widget.userDietaryList);
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
                        document: gql(ProfileGQL.ADD_OR_EDIT_DIETARY),
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
                            print(userDietData.length);
                            List<String> listDietData =
                                List.empty(growable: true);
                            userDietData.forEach((element) {
                              listDietData.add(element['itemId']);
                            });
                            runMutation({
                              "userId": auth.currentUser.id,
                              "dietIds": listDietData
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
                'Profile.YourDietaryRestrictions'.tr(),
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
                        document: gql(ProfileGQL.GET_ALL_SPECIAL_DIETS),
                        fetchPolicy: FetchPolicy.cacheAndNetwork),
                    builder: (QueryResult result,
                        {VoidCallback? refetch, FetchMore? fetchMore}) {
                      if (result.data != null) {
                        List specialDietsList = result.data!['SpecialDiets'];

                        return Scrollbar(
                          child: ListView.builder(
                            itemCount: specialDietsList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 24),
                                        child: Text(
                                          specialDietsList[index]['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  color: Colors.grey[800],
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      visualDensity:
                                          VisualDensity(vertical: -4),
                                      checkColor: Colors.white,
                                      activeColor: lightPrimaryColor,
                                      value: userDietData.any((element) =>
                                          element['itemId'] ==
                                          specialDietsList[index]['id']),
                                      shape: CircleBorder(),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          setState(() {
                                            if (userDietData.any((element) =>
                                                element['itemId'] ==
                                                specialDietsList[index]
                                                    ['id'])) {
                                              userDietData.removeWhere(
                                                  (element) =>
                                                      element['itemId'] ==
                                                      specialDietsList[index]
                                                          ['id']);
                                            } else {
                                              userDietData.add({
                                                'itemId':
                                                    specialDietsList[index]
                                                        ['id']
                                              });
                                            }
                                          });
                                        });
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
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
