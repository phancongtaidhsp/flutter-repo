import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/screens/party/widgets/select-outlet-widget.dart';
import 'package:gem_consumer_app/screens/review-basket/gql/basket.gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:gem_consumer_app/widgets/pop-up-error-message-widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/auth.dart';
import '../../screens/party/widgets/select-outlet-widget.dart';
import '../../screens/review-basket/gql/basket.gql.dart';
import '../../values/color-helper.dart';

import '../../providers/plan-a-party.dart';

import 'edit-party/widgets/dialog-widget.dart';
import 'plan_a_party_product_list_page.dart';

class PartyPlanningOutletList extends StatefulWidget {
  PartyPlanningOutletList(this.outletDataList, this.productType);

  final List<dynamic>? outletDataList;
  final String productType;

  @override
  _PartyPlanningOutletListState createState() =>
      _PartyPlanningOutletListState();
}

class _PartyPlanningOutletListState extends State<PartyPlanningOutletList> {
  late PlanAParty party;
  late Auth auth;

  @override
  void initState() {
    party = context.read<PlanAParty>();
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('plan_a_party_outlet_list_page');
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: SingleChildScrollView(
          child: _outletListing(context, widget.outletDataList!)),
    );
  }

  Widget _outletListing(BuildContext context, List<dynamic> outletDataList) {
    return outletDataList.length <= 0
        ? Center(
            child: Container(
              padding: EdgeInsets.only(top: 48),
              child: Text(
                "CelebrationHome.EmptyProduct",
                style: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(fontWeight: FontWeight.normal),
              ).tr(),
            ),
          )
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: outletDataList.length,
            itemBuilder: (BuildContext context, int index) {
              var merchantInfo = outletDataList[index]['merchant'];
              double averageReview =
                  double.parse(outletDataList[index]['reviewScore'].toString());
              return GestureDetector(
                onTap: () {
                  if (merchantInfo['merchantOutlets'] != null &&
                      merchantInfo['merchantOutlets'].length > 1) {
                    //Pop Up Multi Outlet
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: SelectOutletWidget(
                                  merchantInfo, widget.productType,
                                  onPressed: _onSelectOutlet),
                            ));
                  } else {
                    _onSelectOutlet(outletDataList[index]);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LayoutBuilder(builder: (context, constraints) {
                      var imageDynamicHeight = constraints.maxWidth * 0.4;
                      //print(outletDataList[index].toString());
                      print(
                          'width:  ${constraints.maxWidth} :: ${imageDynamicHeight} :: ${constraints.maxWidth * 0.4}  ');

                      return Container(
                        width: constraints.maxWidth,
                        height: imageDynamicHeight,
                        // color: Colors.red,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              outletDataList[index]['thumbNail'] == "" ||
                                      outletDataList[index]['thumbNail'] == null
                                  ? DefaultImageHelper.defaultImageWithSize(
                                      constraints.maxWidth,
                                      imageDynamicHeight,
                                    )
                                  : CachedImage(
                                      imageUrl: outletDataList[index]
                                          ['thumbNail'],
                                      width: constraints.maxWidth,
                                      height: imageDynamicHeight,
                                    ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 8.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            outletDataList[index]['name'],
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        averageReview > 0
                            ? RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  WidgetSpan(
                                      child: Icon(
                                    Icons.star_purple500_sharp,
                                    color: primaryColor,
                                    size: 15,
                                  )),
                                  TextSpan(
                                      text: averageReview.toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              color: primaryColor,
                                              fontSize: 12))
                                ]))
                            : Text('')
                      ],
                    ),
                    outletDataList[index]['tags'] == null ||
                            outletDataList[index]['tags'].length == 0
                        ? Container(width: 0.0, height: 0.0)
                        : Text(_buildTagsList(outletDataList[index]['tags']),
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      color: Colors.grey[400],
                                    )),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        _buildPriceIndicator(
                            context, outletDataList[index]['priceRange']),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(" •  ",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(fontSize: 12)),
                            Icon(
                              Icons.people,
                              size: 12.0,
                            ),
                            Text(
                                " ${outletDataList[index]['maxPax'].toString()} pax ",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400))
                          ],
                        ),
                        outletDataList[index]['distance'] != null
                            ? Text(
                                " •  ${StringHelper.formatAddress(outletDataList[index]['distance'])} km",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400))
                            : Container(width: 0, height: 0)
                      ],
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              );
            },
          );
  }

  String _buildTagsList(List<dynamic> tags) {
    String amenityStr = "";
    for (var i = 0; i < tags.length; i++) {
      if (i != tags.length - 1) {
        amenityStr += tags[i] + " • ";
      } else {
        amenityStr += tags[i];
      }
    }
    return amenityStr;
  }

  Widget _buildPriceIndicator(BuildContext context, String priceIndicator) {
    List<Widget> widgets = [];
    String priceStr = "";
    String greyPriceStr = "";
    int price = int.tryParse(priceIndicator.toString()) ?? 0;

    for (int i = 0; i < price; i++) {
      priceStr += "\$";
    }
    if (priceStr != "") {
      widgets.add(Text(priceStr,
          style:
              Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 12)));
    }
    if (priceStr.length < 4) {
      for (int j = 0; j < 4 - priceStr.length; j++) {
        greyPriceStr += "\$";
      }
      if (greyPriceStr != "") {
        widgets.add(Text(greyPriceStr,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontSize: 12, color: Colors.grey)));
      }
    }

    return Row(children: widgets);
  }

  void _onSelectOutlet(dynamic outlet) {
    if (outlet != null) {
      party.setOutletId(outlet['id']);
      if (party.demands![party.planCurrentStep!] == "VENUE" &&
          party.venueProduct != null &&
          (party.venueProduct!.outletProductInformation['outlet']["id"] !=
              outlet["id"])) {
        showDialog(
            context: context,
            builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(10),
                child: Mutation(
                    options: MutationOptions(
                      document: gql(BasketGQL.CLEAR_USER_CART_ITEM),
                      onCompleted: (dynamic resultData) {
                        if (resultData != null) {
                          if (resultData["clearUserCartItem"]["status"] ==
                                  "SUCCESS" ||
                              resultData["clearUserCartItem"]["status"] ==
                                  "NOT_EXISTS_IN_DATABASE") {
                            party.clearPartyItems();
                            party.setCurrentStep(0);
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, PlanAPartyProductListPage.routeName,
                                arguments: PlanAPartyProductListPageArguments(
                                    outlet['id']));
                          } else {
                            Navigator.pop(context);
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => Dialog(
                                child: PopUpErrorMessageWidget(),
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.all(24),
                              ),
                            );
                          }
                        }
                      },
                      onError: (dynamic resultData) {
                        print("FAIL");
                        print(resultData);
                      },
                    ),
                    builder: (
                      RunMutation runMutation,
                      QueryResult? result,
                    ) {
                      return DialogWidget(
                          title: "EditAParty.RemoveVenueTitle",
                          content: "EditAParty.RemoveVenueContent",
                          continueButtonText: "Button.Yes",
                          continueFunction: () {
                            runMutation({"userId": auth.currentUser.id});
                          },
                          cancelButtonText: "Button.No",
                          cancelFunction: () {
                            Navigator.pop(context);
                          });
                    })));
      } else {
        Navigator.pushNamed(context, PlanAPartyProductListPage.routeName,
            arguments: PlanAPartyProductListPageArguments(outlet['id']));
      }
    }
  }
}
