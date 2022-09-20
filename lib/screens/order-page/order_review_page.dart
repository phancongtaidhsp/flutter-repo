import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/screens/order-page/gql/order_gql.dart';
import 'package:gem_consumer_app/screens/order-page/widget/select_review_photo_popup.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_no_photo_widget.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class OrderReviewPage extends StatefulWidget {
  static String routeName = '/order-review';

  final String orderId;

  const OrderReviewPage({required this.orderId});

  @override
  _OrderReviewPageState createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  Map? order;
  List _listOutlet = List.empty(growable: true);
  late List<TextEditingController> _listTextFieldController;
  late List<List<String>> _listReviewPhoto;
  late List<double> _listRating;
  late List<bool> _listCheckRating;

  bool isSetUpTextFieldControllerValid = true;

  final picker = ImagePicker();

  @override
  void initState() {
    _listTextFieldController = List.empty(growable: true);
    _listReviewPhoto = List.empty(growable: true);
    _listRating = List.empty(growable: true);
    _listCheckRating = List.empty(growable: true);
    super.initState();
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: _buildAppBar(),
        preferredSize: Size(double.infinity, 56),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Query(
            options: QueryOptions(
                document: gql(OrderGQL.GET_ORDER_BY_ORDER_ID_WITH_REVIEW),
                variables: {'id': widget.orderId},
                fetchPolicy: FetchPolicy.networkOnly),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return LoadingController();
              }
              if (result.hasException) {
                print(result);
              }
              if (result.data != null) {
                order = result.data!['GetOrderById'];

                if (isSetUpTextFieldControllerValid &&
                    order != null &&
                    order!['orderOperations'] != null) {
                  _listOutlet = order!['orderOperations'];
                  _listOutlet.removeWhere(
                      (element) => element['isReviewSubmitted'] == true);

                  _listTextFieldController.clear();
                  _listOutlet.forEach((element) {
                    _listTextFieldController.add(new TextEditingController());
                    _listReviewPhoto.add(List.empty(growable: true));
                    _listRating.add(-1.0);
                    _listCheckRating.add(false);
                    element["isJustReviewed"] = false;
                  });
                  isSetUpTextFieldControllerValid = false;
                }

                return ListView.separated(
                  itemCount: _listOutlet.length,
                  itemBuilder: (context, index) {
                    return _buildItemReviewOutlet(_listOutlet[index], index);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return _buildDivider(10);
                  },
                );
              } else {
                return Container(width: 0.0, height: 0.0);
              }
            }),
      ),
    );
  }

  Widget _buildItemReviewOutlet(Map data, int index) {
    double? averageReview;
    if (data['outlet']['reviews'].length > 0) {
      averageReview = (data['outlet']['reviews']
              .map((e) => e['score'])
              .reduce((a, b) => a + b)) /
          data['outlet']['reviews'].length;
    }

    List businessCategoriesList = List.empty(growable: true);
    var tempBusinessCategoriesList =
        groupBy(data['outlet']["businessCategories"], (obj) {
      obj = obj as Map;
      return obj['businessCategory']['name'];
    });
    businessCategoriesList = tempBusinessCategoriesList.keys.toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(data),
          SizedBox(
            height: 12,
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LayoutBuilder(builder: (context, constraints) {
                    var height = constraints.maxWidth * 0.4;
                    return Container(
                      width: constraints.maxWidth,
                      height: height,
                      child: data['outlet']['thumbNail'] == "" &&
                              data['outlet']['thumbNail'] == null
                          ? DefaultImageHelper.defaultImageWithSize(
                              constraints.maxWidth,
                              height,
                            )
                          : CachedImage(
                              width: constraints.maxWidth,
                              height: height,
                              imageUrl: data['outlet']['thumbNail']),
                    );
                  }))),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: EdgeInsets.only(left: 2, right: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data['outlet']['name'],
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                averageReview != null
                    ? Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              WidgetSpan(
                                  child: Icon(
                                Icons.star_purple500_sharp,
                                color: primaryColor,
                                size: 15,
                              )),
                              TextSpan(
                                  text: averageReview.toStringAsFixed(2),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                          color: primaryColor, fontSize: 12))
                            ])),
                      )
                    : Text('')
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              businessCategoriesList.join(" • "),
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.grey[400], fontWeight: FontWeight.normal),
            ),
          ),
          !data['isJustReviewed']
              ? _buildReviewInfo(index, data['outletId'])
              : Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Order.ThankForReview'.tr(),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.grey[700], fontWeight: FontWeight.normal),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(Map data) {
    String orderCompleted = '';
    var formatString = "yyyy-MM-ddTHH:mm:ssZ";
    if (data['isCompletedAt'] != null) {
      DateTime format1 = new DateFormat(formatString)
          .parse(data['isCompletedAt'], true)
          .toLocal();
      orderCompleted = 'Order.OrderCompleted'.tr() +
          ' ' +
          DateFormat("dd MMM yyyy, HH:mm").format(format1);
    }

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: order!['user']['photoUrl'] != null ||
                      order!['user']['photoUrl'] == ''
                  ? CachedImage(
                      width: 50,
                      height: 50,
                      imageUrl: order!['user']['photoUrl'])
                  : DefaultImageHelper.defaultImage),
        ),
        Expanded(
          child: Container(
            height: 62,
            padding: EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  order!['user']['displayName'],
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                  orderCompleted,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildReviewInfo(int index, String outletId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 12,
        ),
        RatingBar(
          minRating: 0.0,
          maxRating: 5.0,
          itemPadding: EdgeInsets.symmetric(horizontal: 4),
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 24,
          onRatingUpdate: (rating) {
            _listRating[index] = rating;
          },
          ratingWidget: RatingWidget(
            full: SvgPicture.asset(
              'assets/images/full-star.svg',
            ),
            half: SvgPicture.asset(
              'assets/images/full-star.svg',
            ),
            empty: SvgPicture.asset(
              'assets/images/empty-star.svg',
            ),
          ),
        ),
        SizedBox(
          height: _listCheckRating[index] ? 8 : 0,
        ),
        _listCheckRating[index]
            ? Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Validation.Required',
                  style: TextStyle(color: Colors.red),
                ).tr(),
              )
            : Container(width: 0.0, height: 0.0),
        SizedBox(
          height: 12,
        ),
        _buildReviewTextField(index),
        SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) => Dialog(
                      child: SelectReviewPhotoPopUp(_listReviewPhoto[index]),
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(24),
                    ),
                  );
                },
                child: Container(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.black,
                    )),
                style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity(horizontal: -4),
                    primary: Colors.grey[100],
                    shape: CircleBorder())),
            Mutation(
                options: MutationOptions(
                  document: gql(OrderGQL.POST_REVIEW),
                  onCompleted: (dynamic resultData) {
                    print("Check Result : $resultData");
                    Loader.hide();
                    if (resultData != null) {
                      setState(() {
                        _listOutlet[index]['isJustReviewed'] = true;
                        _listOutlet[index]['reviewContent'] =
                            resultData['createUpdateUserReview']['content'];
                      });
                    }
                  },
                  onError: (dynamic resultData) {
                    Loader.hide();
                    print(resultData);
                  },
                ),
                builder: (
                  RunMutation runMutation,
                  QueryResult? result,
                ) {
                  if (result!.hasException) {
                    print("Exception: $result");
                  }
                  return SubmitButton(
                    text: 'Order.PostReview',
                    isMinWidth: true,
                    height: 40,
                    backgroundColor: primaryColor,
                    textColor: Colors.black,
                    textSize: 12,
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (_listRating[index] >= 0) {
                        setState(() {
                          _listCheckRating[index] = false;
                        });

                        showLoadingOverlay(context);

                        runMutation({
                          "UserReviewInput": {
                            "outletId": outletId,
                            "userId": order!['userId'],
                            "orderId": order!['id'],
                            "reviewPhotos": _listReviewPhoto[index],
                            "score": _listRating[index],
                            "content": _listTextFieldController[index].text,
                            "isHidden": _listRating[index] >= 4 ? false : true
                          },
                          "orderOperationId": _listOutlet[index]['id']
                        });
                      } else {
                        setState(() {
                          _listCheckRating[index] = true;
                        });
                      }
                    },
                  );
                }),
          ],
        ),
        SizedBox(
          height: _listReviewPhoto[index].length > 0 ? 8 : 0,
        ),
        _listReviewPhoto[index].length > 0
            ? GridView.count(
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                crossAxisCount: 6,
                childAspectRatio: 1,
                shrinkWrap: true,
                primary: true,
                crossAxisSpacing: 12,
                children: List.generate(
                    _listReviewPhoto[index].length,
                    (innerIndex) => Container(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _listReviewPhoto[index][innerIndex] != ''
                                  ? CachedImage(
                                      width: 100,
                                      height: 100,
                                      imageUrl: _listReviewPhoto[index]
                                          [innerIndex])
                                  : DefaultImageHelper.defaultImage),
                        )))
            : Container()
      ],
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.grey[200],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: 36,
              height: 36,
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
          Text(
            'Order.PendingReview'.tr(),
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          Container(
            width: 36,
            height: 36,
          )
        ],
      ),
    );
  }

  Widget _buildDivider(double value) {
    return Container(
      height: value,
      color: Colors.grey[200],
    );
  }

  Widget _buildReviewTextField(int index) {
    return Container(
      padding: EdgeInsets.only(left: 2),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        minLines: 3,
        maxLines: null,
        maxLength: null,
        controller: _listTextFieldController[index],
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            hintText: 'Order.WriteReview'.tr(),
            hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.grey[400], fontWeight: FontWeight.normal),
            hintMaxLines: 10),
      ),
    );
  }
}
