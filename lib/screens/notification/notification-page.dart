import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/login/login.gql.dart';
import 'package:gem_consumer_app/screens/order-page/order_detail_page.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_occasion_coming_popup.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class NotificationPage extends StatefulWidget {
  static String routeName = '/notification-page';
  final Function goToPage;
  final Function goToPackage;

  NotificationPage({required this.goToPage, required this.goToPackage});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static late Auth auth;

  @override
  void initState() {
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                shadowColor: Colors.grey[200],
                title: Text("General.Notifications",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontWeight: FontWeight.w400))
                    .tr()),
            body: Query(
                options: QueryOptions(
                    document: gql(LoginGQL.GET_NOTIFICATION),
                    variables: {'userId': auth.currentUser.id},
                    fetchPolicy: FetchPolicy.cacheAndNetwork),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.data != null) {
                    List<dynamic> notifications = result.data!['Notifications'];
                    Map<String, dynamic> groupedNotifications =
                        groupBy(notifications, (obj) {
                      obj = obj as Map;
                      return obj['type'];
                    });
                    return Container(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 40.0),
                        child: notifications.length > 0 ?  DefaultTabController(
                          length: groupedNotifications.keys.length,
                          child: Scaffold(
                            backgroundColor: Colors.white,
                            primary: false,
                            appBar: TabBar(
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .button!
                                  .copyWith(fontWeight: FontWeight.normal),
                              unselectedLabelStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(fontSize: 14),
                              isScrollable: true,
                              labelPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                              indicatorWeight: 4,
                              indicatorColor: primaryColor,
                              indicatorSize: TabBarIndicatorSize.label,
                              tabs: List.generate(
                                groupedNotifications.keys.length,
                                (index) => _buildTabHeader(
                                    groupedNotifications, index),
                              ),
                            ),
                            body: Container(
                              margin: EdgeInsets.only(top: 16),
                              child: TabBarView(
                                children: List.generate(
                                  groupedNotifications.keys.length,
                                  (index) => _notificationList(
                                    context,
                                    groupedNotifications[groupedNotifications
                                        .keys
                                        .toList()[index]
                                        .toString()],
                                    () => refetch!(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ) : 
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/icon-no-item.png',
                                  width: 160,
                                  height: 160,
                                ),
                                SizedBox(height: 16,),
                                Text(
                                  'Notification.NoNotification'.tr(),
                                  style: Theme.of(context).textTheme.headline2!.copyWith(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                        ))
                        
                        ;
                  }
                  return Container(width: 0.0, height: 0.0);
                })));
  }

  Widget _notificationList(
      BuildContext context, List<dynamic> dataList, Function refetch) {
    if (dataList.length > 0) {
      dataList.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));
    }
    return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 7.0),
        scrollDirection: Axis.vertical,
        itemCount: dataList.length,
        itemBuilder: (BuildContext context, int index) {

          bool isHaveOrderId = false;
          String orderId = '';

          if(dataList[index]["additionalInfo"] != null && dataList[index]["additionalInfo"]['displayOrderId'] != null) {
            isHaveOrderId = true;
            orderId = dataList[index]["additionalInfo"]['displayOrderId'] ;
          }

          return Mutation(
            options: MutationOptions(
                document: gql(LoginGQL.UDPATE_READ_NOTIFICATION),
                onCompleted: (dynamic resultData) {
                  refetch();
                }),
            builder: (
              RunMutation runMutation,
              QueryResult? result,
            ) {
              return InkWell(
                  onTap: () {
                    if (index != -1 &&
                        dataList[index] != null &&
                        dataList[index]['id'] != null) {
                      if (dataList[index]['readAt'] == null) {
                        runMutation({"id": dataList[index]['id']});
                      }
                      if (dataList[index]['additionalInfo'] != null &&
                          ["ORDER_STATUS", "SERVICE_TIME", "FEED_BACK", "OUT_OF_STOCK"]
                              .contains(dataList[index]['type'])) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderDetailPage(
                                      orderId: dataList[index]['additionalInfo']
                                          ['orderId'],
                                    )));
                      } else if (dataList[index]['type'] ==
                          "SPECIAL_OCCASION") {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => Dialog(
                              child: OccasionComingPopup(dataList[index]['additionalInfo']['date'],
                                  dataList[index]['additionalInfo']['name'],
                                widget.goToPackage,
                                widget.goToPage
                              ),
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.all(24),
                            ));
                      }
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.0, color: Color(0xFFE4E5E5)))),
                      child: Row(children: [
                        Container(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Stack(children: [
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                    _buildIcon(dataList[index]),
                                    width: 24.0,
                                    height: 24.0),
                              ),
                              dataList[index]['readAt'] == null
                                  ? Positioned(
                                      top: 8.0,
                                      right: 4.0,
                                      child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.red, // border color
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container()))
                                  : Container(width: 0.0, height: 0.0)
                            ])),
                        Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        child: Text(dataList[index]['titleKey'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!.copyWith(fontWeight: FontWeight.normal)
                                        )),
                                    SizedBox(width: 20.0),
                                    Text(
                                        DateFormat('dd MMM').format(
                                            DateTime.parse(
                                                dataList[index]['createdAt'])),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!.copyWith(fontWeight: FontWeight.normal)
                                    )
                                  ]),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  isHaveOrderId ? Text(
                                    'Order ID: $orderId',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(fontWeight: FontWeight.normal),
                                  ) : Container(),
                                  SizedBox(
                                    height: isHaveOrderId ? 4 : 0,
                                  ),
                              Text(dataList[index]['contentKey'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[400]))
                            ]))
                      ])));
            },
          );
        });
  }

  Widget _buildTabHeader(Map<String, dynamic> groupedNotifications, int index) {
    Color color = primaryColor;
    List<dynamic> notifications =
        groupedNotifications[groupedNotifications.keys.toList()[index]];
    List<dynamic> unReadNotification = notifications
        .where((dynamic element) => element['readAt'] == null)
        .toList();
    return Row(children: [
      Text(
        groupedNotifications.keys
            .toList()[index]
            .toString()
            .replaceAll("_", " ")
            .toUpperCase(),
      ),
      unReadNotification.length > 0
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              margin: EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Text(
                unReadNotification.length.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 12, color: Colors.black),
              ),
            )
          : Container(width: 0.0, height: 0.0)
    ]);
  }

  String _buildIcon(dynamic item) {
    if (item['type'] == 'ORDERS') {
      return 'assets/images/icon-basket.svg';
    } else if (item['type'] == 'REMINDER') {
      return 'assets/images/icon_calendar.svg';
    } else {
      return 'assets/images/icon-alarm.svg';
    }
  }
}
