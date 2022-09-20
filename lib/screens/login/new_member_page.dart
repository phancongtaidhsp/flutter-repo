import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import '../../UI/Buttons/primary_button.dart';
import '../../UI/Buttons/primary_button_icon.dart';
import '../../providers/auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../screens/login/login.gql.dart';
import 'package:provider/provider.dart';

class NewMember extends StatefulWidget {
  final String dialCode;
  final String phoneNumber;
  final String? email;

  NewMember(this.dialCode, this.phoneNumber, {this.email});

  @override
  _NewMemberState createState() => _NewMemberState();
}

class _NewMemberState extends State<NewMember> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String? _selectedTitle;
  String? _tempSelectedTitle;
  bool isNameInvalid = false;
  bool isEnableEmailEditing = true;
  List<Map<String, dynamic>> titleList = [];
  late Auth authProvider;

  Widget _buildTitlePicker() {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 60.0,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: CupertinoColors.activeBlue.withOpacity(0.1),
              ),
              onSelectedItemChanged: (int _selectedIndex) {
                print(titleList[_selectedIndex]['id']);
                _tempSelectedTitle = titleList[_selectedIndex]['id'];
              },
              scrollController: FixedExtentScrollController(
                  initialItem: titleList.indexWhere(
                      (element) => element['id'] == _selectedTitle)),
              children: List.generate(
                  titleList.length,
                  (index) => Center(
                        child: Text(titleList[index]['name']),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    authProvider.isOpeningNewMemberPage = false;
    Loader.hide();
    super.dispose();
  }

  @override
  void initState() {
    authProvider = context.read<Auth>();
    titleList = [
      {'id': 'Mr', 'name': 'Mr'},
      {'id': 'Mrs', 'name': 'Mrs'},
      {'id': 'Madam', 'name': 'Madam'},
      {'id': 'Miss', 'name': 'Miss'},
      {'id': 'Ms', 'name': 'Ms'},
      {'id': 'Dr', 'name': 'Dr'},
      {'id': 'Sir', 'name': 'Sir'},
      {'id': "Dato'", 'name': "Dato'"},
      {'id': 'Datuk', 'name': 'Datuk'},
      {'id': 'Datin', 'name': 'Datin'},
      {'id': "Dato' Sri", 'name': "Dato' Sri"},
      {'id': 'Datuk Sri', 'name': 'Datuk Sri'},
      {'id': 'Datin Sri', 'name': 'Datin Sri'},
      {'id': 'Datuk Seri', 'name': 'Datuk Seri'},
      {'id': 'Datin Seri', 'name': 'Datin Seri'},
      {'id': 'Tan Sri', 'name': 'Tan Sri'},
      {'id': 'Puan Sri ', 'name': 'Puan Sri '},
      {'id': 'Datin Paduka', 'name': 'Datin Paduka'},
      {'id': 'Datin Paduka Seri', 'name': 'Datin Paduka Seri'},
      {'id': 'Tun', 'name': 'Tun'},
      {'id': 'Toh Puan', 'name': 'Toh Puan'},
      {'id': 'Tunku', 'name': 'Tunku'},
      {'id': 'Tengku', 'name': 'Tengku'},
    ];
    if (widget.email != null) {
      isEnableEmailEditing = false;
      emailController.text = widget.email!;
    }
    super.initState();
  }

  Future<bool> _onWillPopScope() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: Form(
              key: _formKey,
              child: Container(
                height: size.height,
                width: double.infinity,
                margin: EdgeInsets.only(
                  left: size.width * 0.0666,
                  right: size.width * 0.0666,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.0213),
                      SizedBox(height: size.height * 0.2),
                      Container(
                        width: size.width * 0.87,
                        alignment: Alignment.center,
                        child: Text(
                          'NewMember.Description',
                          style: textTheme.headline1!.copyWith(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ).tr(),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.0307),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            child: PrimaryButtonIcon(
                              action: () async {
                                await showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoActionSheet(
                                          actions: [_buildTitlePicker()],
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            child: Text('Select'),
                                            onPressed: () {
                                              setState(() {
                                                Navigator.of(context).pop();
                                                _selectedTitle =
                                                    _tempSelectedTitle;
                                              });
                                            },
                                          ));
                                    });
                              },
                              btnText:
                                  _selectedTitle == '' || _selectedTitle == null
                                      ? 'NewMember.Title'.tr()
                                      : _selectedTitle!,
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.text,
                              style: Theme.of(context).textTheme.button,
                              controller: nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Validation.Required'.tr();
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 22),
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
                                hintText: 'Your Name',
                                hintStyle: TextStyle(fontSize: 14),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                labelStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Visibility(
                          visible: isNameInvalid,
                          child: Text(
                            'Validation.Required',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal),
                          ).tr(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.emailAddress,
                        style: Theme.of(context).textTheme.button,
                        enabled: isEnableEmailEditing,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Validation.Required'.tr();
                          }

                          if (!EmailValidator.Validate(value)) {
                            return 'Email is not valid';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 22),
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
                          hintText: 'Your Email',
                          hintStyle: TextStyle(fontSize: 14),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                      Spacer(),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: Mutation(
                          options: MutationOptions(
                            document: gql(LoginGQL.CREATE_FIRST_USER),
                            onCompleted: (dynamic resultData) {
                              Loader.hide();
                              if (resultData != null) {
                                if (resultData['createFirstUser']['status'] ==
                                    'SUCCESS') {
                                  authProvider.setCurrentUserProfile(
                                      authProvider.currentUser.id!,
                                      nameController.text,
                                      emailController.text,
                                      _selectedTitle == 'Mr'
                                          ? 'MALE'
                                          : 'FEMALE');
                                  authProvider.setUserInfo(
                                      nameController.text,
                                      emailController.text,
                                      widget.dialCode + widget.phoneNumber);
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                            onError: (dynamic resultData) {
                              Loader.hide();
                              print("FAIL");
                              print(resultData);
                            },
                          ),
                          builder: (
                            RunMutation runMutation,
                            QueryResult? result,
                          ) {
                            return PrimaryButton(
                              action: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_selectedTitle == null) {
                                    setState(() {
                                      isNameInvalid = true;
                                    });
                                  } else {
                                    setState(() {
                                      isNameInvalid = false;
                                    });
                                    runMutation({
                                      "createUser": {
                                        "id": authProvider.currentUser.id,
                                        "displayName": "${nameController.text}",
                                        "email": "${emailController.text}",
                                        "phone":
                                            "${widget.dialCode}${widget.phoneNumber}",
                                        "title": "$_selectedTitle",
                                        "gender": null,
                                        "countryId": "MY"
                                      }
                                    });

                                    showLoadingOverlay(context);
                                  }
                                }
                              },
                              btnText: 'NewMember.Explore',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
