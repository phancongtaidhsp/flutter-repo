import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/helpers/default-image-helper.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/providers/scroll_party_provider.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-popup-name-and-demand.dart';
import 'package:gem_consumer_app/widgets/cached-image.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:provider/provider.dart';

import '../../outlet/outlet_screen.dart';

class MerchantOutletListWidget extends StatefulWidget {
  MerchantOutletListWidget(this.dataMap, this.title);
  final List<dynamic> dataMap;
  final String title;

  @override
  _MerchantOutletListWidgetState createState() =>
      _MerchantOutletListWidgetState();
}

class _MerchantOutletListWidgetState extends State<MerchantOutletListWidget> {
  late PlanAParty event;
  late AddToCartItems userCartItems;
  late Auth auth;
  bool isLoggedIn = false;

  final ScrollController _controller = ScrollController();
  bool _isLoading = false;
  int displayLength = 1;

  @override
  void initState() {
    userCartItems = context.read<AddToCartItems>();
    event = context.read<PlanAParty>();
    auth = context.read<Auth>();
    if (auth.currentUser.isAuthenticated!) {
      isLoggedIn = true;
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[arty-outlet-list] build');
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: widget.dataMap.length > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text(widget.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .copyWith(fontWeight: FontWeight.w400)),
                    SizedBox(height: 16.0),
                    _merchantList(context, widget.dataMap)
                  ])
            : Center(
                child: Container(
                  height: 150,
                  child: Center(
                    child: Text("PlanAParty.NoEventCategoryOutlet",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .button!
                                .copyWith(fontSize: 14))
                        .tr(),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _merchantList(BuildContext context, List<dynamic> dataList) {
    return Consumer<ScrollPartyProvider>(
        builder: (context, scrollPartyProvider, _) {
      // var scrollCounter = 0;
      // if (scrollPartyProvider.scrollerCounter > dataList.length) {
      //   scrollCounter = dataList.length;
      // } else {
      //   scrollCounter = scrollPartyProvider.scrollerCounter;
      // }
      // if (scrollCounter == 0) {
      //   scrollCounter++;
      // }
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: dataList.length,
          //dataList.length,
          itemBuilder: (BuildContext context, int index) {
            if (dataList.length == index) {
              return LoadingController();
            }
            return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return OutletScreen(
                          outletId: dataList[index]['id'],
                        );
                      },
                    ),
                  );
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LayoutBuilder(builder: (context, constraints) {
                        var imageDynamicHeight = constraints.maxWidth * 0.4;
                        print(
                            'width:: ${constraints.maxWidth} :::: height: ${constraints.maxWidth * 0.4}');
                        return Container(
                          height: imageDynamicHeight,
                          width: constraints.maxWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: dataList[index]['thumbNail'] == "" ||
                                    dataList[index]['thumbNail'] == null
                                ? DefaultImageHelper.defaultImageWithSize(
                                    constraints.maxWidth,
                                    imageDynamicHeight,
                                  )
                                : CachedImage(
                                    imageUrl: dataList[index]['thumbNail'],
                                    width: constraints.maxWidth,
                                    height: imageDynamicHeight,
                                  ),
                          ),
                        );
                      }),
                      SizedBox(height: 8.0),
                      Text(
                        dataList[index]['name'],
                        style: Theme.of(context).textTheme.button,
                      ),
                      dataList[index]['tags'] == null ||
                              dataList[index]['tags'].length == 0
                          ? Container(width: 0.0, height: 0.0)
                          : Text(_buildTagsList(dataList[index]['tags']),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: Colors.grey[400],
                                  )),
                      SizedBox(height: 4.0),
                      Row(children: [
                        _buildPriceIndicator(
                            context, dataList[index]['priceRange']),
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
                                " ${dataList[index]['maxPax'].toString()} pax ",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400))
                          ],
                        ),
                        dataList[index]['distance'] != null
                            ? Text(
                                " •  ${StringHelper.formatAddress(dataList[index]['distance'])} km",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400))
                            : Container(width: 0, height: 0)
                      ]),
                      SizedBox(height: 20.0),
                    ]));
          });
    });
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

  void popUpNameAndDemandDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: PopUpNameAndDemand(),
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(24),
      ),
    );
  }
}
