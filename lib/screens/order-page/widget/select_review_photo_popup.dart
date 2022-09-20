import 'dart:io';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';

import '../../../screens/profile/widgets/profile_no_photo_widget.dart';
import '../../../values/color-helper.dart';
import 'package:http_parser/http_parser.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../screens/order-page/gql/order_gql.dart';
import '../../../widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

class SelectReviewPhotoPopUp extends StatefulWidget {
  List<String> listPhoto;

  SelectReviewPhotoPopUp(this.listPhoto);

  @override
  _SelectReviewPhotoPopUpState createState() => _SelectReviewPhotoPopUpState();
}

class _SelectReviewPhotoPopUpState extends State<SelectReviewPhotoPopUp> {
  late List<String> _list;

  final picker = ImagePicker();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _list = widget.listPhoto;
    super.initState();
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
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
                        document: gql(OrderGQL.UPLOAD_IMAGE),
                        onCompleted: (dynamic resultData) {
                          Loader.hide();
                          if (resultData != null) {
                            setState(() {
                              _list.add(
                                  resultData['createUploadPhotoUrl']['url']);
                            });
                          }
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
                          text: 'Button.Select',
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                          rippleColor: Colors.grey,
                          width: 100,
                          height: 40,
                          textSize: 12,
                          verticalTextPadding: 14,
                          isUppercase: true,
                          onPressed: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return _cupertinoImagePicker(context);
                                }).then((value) async {
                              if (value != null) {
                                showLoadingOverlay(context);
                                if (value[1]) {
                                  for (final element in value[0]) {
                                    var path = element.path;
                                    var byteData = File(path).readAsBytesSync();

                                    var multipartFile = MultipartFile.fromBytes(
                                      'file',
                                      byteData,
                                      filename:
                                          '${DateTime.now().microsecondsSinceEpoch}.jpg',
                                      contentType: MediaType("image", "jpg"),
                                    );

                                    runMutation({"file": multipartFile});
                                    await Future.delayed(
                                        Duration(milliseconds: 2000));
                                  }
                                } else {
                                  var byteData =
                                      File(value[0].path).readAsBytesSync();

                                  var multipartFile = MultipartFile.fromBytes(
                                    'file',
                                    byteData,
                                    filename:
                                        '${DateTime.now().microsecondsSinceEpoch}.jpg',
                                    contentType: MediaType("image", "jpg"),
                                  );

                                  runMutation({"file": multipartFile});
                                }
                              }
                            });
                          },
                        );
                      }),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Order.SelectPhotos'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: Scrollbar(
                  child: GridView.count(
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      shrinkWrap: true,
                      primary: true,
                      crossAxisSpacing: 12,
                      children: List.generate(
                          _list.length,
                          (innerIndex) => Container(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                            child: _list[innerIndex] != ''
                                                ? CachedImage(
                                                    imageUrl: _list[innerIndex],
                                                    width: 200,
                                                    height: 200,
                                                  )
                                                : DefaultImageHelper
                                                    .defaultImage,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _list.removeAt(innerIndex);
                                              });
                                            },
                                            child: Container(
                                              height: 24,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset: Offset(0, 1)),
                                                  ]),
                                              child: Icon(
                                                Icons.close_sharp,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ))),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
            _getMultipleImage(context);
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

  Future<void> _getMultipleImage(BuildContext context) async {
    final listPickedFile = await _picker.pickMultiImage(maxWidth: 400.0);

    if (listPickedFile != null) {
      Navigator.pop(context, [listPickedFile, true]);
    }
  }

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, maxWidth: 400.0);

    if (pickedFile != null) {
      Navigator.pop(context, [pickedFile, false]);
    }
  }
}
