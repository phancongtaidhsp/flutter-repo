import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/screens/profile/gql/profile.gql.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class ProfileEditNamePopUp extends StatefulWidget {
  final String userName;

  ProfileEditNamePopUp({required this.userName});

  @override
  _ProfileEditNamePopUpState createState() => _ProfileEditNamePopUpState();
}

class _ProfileEditNamePopUpState extends State<ProfileEditNamePopUp> {
  TextEditingController _controller = TextEditingController();
  bool isNameInvalid = false;
  static late Auth auth;

  @override
  void initState() {
    super.initState();
    auth = context.read<Auth>();
    _controller.text = widget.userName;
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        document: gql(ProfileGQL.UPDATE_USER_INFO),
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
                            if (_controller.text != '') {
                              isNameInvalid = false;
                              runMutation({
                                "updateProfile": {
                                  "userId": auth.currentUser.id,
                                  "displayName": _controller.text,
                                }
                              });
                            } else {
                              setState(() {
                                isNameInvalid = true;
                              });
                            }
                          },
                        );
                      }),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Profile.EditName'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 24,
              ),
              _buildTextFieldEditName(),
              SizedBox(
                height: 4,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Visibility(
                  visible: isNameInvalid,
                  child: Text(
                    'Validation.Required',
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.normal),
                  ).tr(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldEditName() {
    return TextFormField(
        textCapitalization: TextCapitalization.sentences,
        controller: _controller,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: Colors.black),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.grey[200],
          errorStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Colors.red, fontSize: 10, fontWeight: FontWeight.normal),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23.0),
              borderSide: BorderSide(
                color: Colors.transparent,
              )),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23.0),
              borderSide: BorderSide(
                color: Colors.transparent,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23.0),
              borderSide: BorderSide(
                color: Colors.transparent,
              )),
          labelText: tr('Profile.NameSpecialDay'),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: Theme.of(context).textTheme.bodyText1,
          suffixIconConstraints: BoxConstraints(
            minWidth: 31,
            minHeight: 31,
          ),
        ),
        keyboardType: TextInputType.text);
  }
}
