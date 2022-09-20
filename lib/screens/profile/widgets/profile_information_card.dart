import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import '../../../providers/auth.dart';
import '../../../screens/profile/gql/profile.gql.dart';
import '../../../screens/profile/widgets/profile_edit_name_popup.dart';
import '../../../screens/profile/widgets/profile_no_photo_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

class ProfileInformationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final FutureOr<dynamic> Function(dynamic) function;

  ProfileInformationCard(this.data, this.function);

  @override
  _ProfileInformationCardState createState() => _ProfileInformationCardState();
}

class _ProfileInformationCardState extends State<ProfileInformationCard> {
  final picker = ImagePicker();
  File? _imageFile;
  String? profilePhoto;
  static late Auth auth;

  @override
  void initState() {
    super.initState();
    auth = context.read<Auth>();
    if (widget.data['photoUrl'] != null) {
      profilePhoto = widget.data['photoUrl'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 20, left: 16, right: 16),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 0.2),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                spreadRadius: 0.5,
                blurRadius: 3,
                offset: Offset(0, 2.0))
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              SizedBox(
                width: 6,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['title'],
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      InkWell(
                          onTap: () {
                            showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) => Dialog(
                                child: ProfileEditNamePopUp(
                                    userName: widget.data['displayName']),
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.all(24),
                              ),
                            ).then(widget.function);
                          },
                          child: Text(
                            widget.data['displayName'],
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20),
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Mutation(
        options: MutationOptions(
          document: gql(ProfileGQL.UPDATE_USER_AVATAR),
          update: (cache, result) {
            if (result != null && result.data != null) {
              imageCache!.clear();
              setState(() {
                profilePhoto =
                    result.data!['createUpdateUserProfilePhoto']['photoUrl'];
              });
            }
          },
          onCompleted: widget.function,
          onError: (dynamic resultData) {
            print('upload error: $resultData');
          },
        ),
        builder: (
          RunMutation runMutation,
          QueryResult? result,
        ) {
          return InkWell(
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return _cupertinoImagePicker(context);
                  }).then((value) {
                if (value != null && _imageFile != null) {
                  var byteData = _imageFile!.readAsBytesSync();

                  var multipartFile = MultipartFile.fromBytes(
                    'file',
                    byteData,
                    filename: '${DateTime.now().second}.jpg',
                    contentType: MediaType("image", "jpg"),
                  );

                  runMutation({
                    "id": auth.currentUser.id,
                    "index": 0,
                    "file": multipartFile
                  });
                }
              });
            },
            child: Container(
              width: 66,
              height: 64,
              child: Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: profilePhoto != null
                            ? CachedImage(
                                imageUrl: profilePhoto!,
                                width: 60,
                                height: 60,
                              )
                            : DefaultImageHelper.defaultImage),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Container(
                        width: 20,
                        height: 20,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                        child:
                            SvgPicture.asset('assets/images/icon_pencil.svg'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _materialImagePicker(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          InkWell(
            onTap: () {
              _getImage(context, ImageSource.camera);
            },
            child: Container(
              height: 48,
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 24,
                    color: Colors.grey[500],
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Text(
                    'Profile.Camera'.tr(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  )
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _getImage(context, ImageSource.gallery);
            },
            child: Container(
              height: 48,
              child: Row(
                children: [
                  Icon(
                    Icons.photo,
                    size: 24,
                    color: Colors.grey[500],
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Text(
                    'Profile.Gallery'.tr(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  )
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 48,
              child: Row(
                children: [
                  Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.grey[500],
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Text(
                    'Button.Cancel'.tr(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                        fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ]));
  }

  Widget _cupertinoImagePicker(BuildContext context) {
    return CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            'Profile.Camera'.tr(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w400,
                fontSize: 16),
          ),
          onPressed: () {
            _getImage(context, ImageSource.camera);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            'Profile.Gallery'.tr(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w400,
                fontSize: 16),
          ),
          onPressed: () {
            _getImage(context, ImageSource.gallery);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Button.Cancel'.tr(),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w400,
              fontSize: 16),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, maxWidth: 400.0);

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
    }

    Navigator.pop(context, true);
  }
}
