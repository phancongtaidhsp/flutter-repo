import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/screens/order-page/gql/order_gql.dart';
import 'package:gem_consumer_app/screens/order-page/order_detail_page.dart';
import 'package:gem_consumer_app/widgets/app-bar-widget.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:easy_localization/easy_localization.dart';

class MyOrderPage extends StatefulWidget {
  static String routeName = '/order-page';

  @override
  _MyOrderPageState createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  static late Auth auth;

  final Map<String, String> servicesTypeList = {
    "DINE_IN": "Dine In",
    "DELIVERY": "Delivery",
    "PICKUP": "Pick Up"
  };

  @override
  void initState() {
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List tabList = ["Order.InProgress".tr(), "Order.PastOrder".tr()];
    List allOrder = List.empty(growable: true);
    List inProgressOrderList = List.empty(growable: true);
    List completedOrderList = List.empty(growable: true);

    return Scaffold(
      appBar: AppBarWidget('Order.MyOrder'),
      body: Container(
        color: Colors.white,
        child: Query(
            options: QueryOptions(
                document: gql(OrderGQL.GET_ORDER_LIST_BY_USER_ID),
                variables: {'userId': auth.currentUser.id},
                optimisticResult: QueryResult.optimistic(),
                fetchPolicy: FetchPolicy.networkOnly),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return LoadingController();
              }

              if (result.data != null) {
                allOrder.clear();
                inProgressOrderList.clear();
                completedOrderList.clear();

                allOrder = result.data!['Order'];
                allOrder.forEach((element) {
                  bool isThisOrderCompleted = true;
                  List tempOrderOperation = element['orderOperations'];

                  tempOrderOperation.forEach((orderOperation) {
                    if (orderOperation['orderStatus'] != "COMPLETED") {
                      isThisOrderCompleted = false;
                    }
                  });

                  if (element['isCancelled']) {
                    isThisOrderCompleted = true;
                  }

                  if (isThisOrderCompleted) {
                    completedOrderList.add(element);
                  } else {
                    inProgressOrderList.add(element);
                  }
                });

                return Container(
                  child: DefaultTabController(
                    length: tabList.length,
                    child: Scaffold(
                        backgroundColor: Colors.white,
                        primary: false,
                        appBar: PreferredSize(
                          preferredSize:
                          Size(MediaQuery.of(context).size.width, 45),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: TabBar(
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
                                  vertical: 8.0, horizontal: 5.0),
                              indicatorWeight: 4,
                              indicatorColor:
                              Color.fromRGBO(253, 196, 0, 1),
                              indicatorSize: TabBarIndicatorSize.label,
                              tabs: List.generate(
                                tabList.length,
                                    (index) => Text(
                                  tabList.toList()[index].toString(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        body: TabBarView(
                          children: [
                            inProgressOrderList.length > 0
                                ? Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: inProgressOrderList.length,
                                itemBuilder: (context, index) {
                                  return _buildItemOrder(
                                      inProgressOrderList[index]);
                                },
                              ),
                            )
                                : _buildEmptyOrderWidget(),
                            completedOrderList.length > 0
                                ? Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: completedOrderList.length,
                                itemBuilder: (context, index) {
                                  return _buildItemOrder(
                                      completedOrderList[index]);
                                },
                              ),
                            )
                                : _buildEmptyOrderWidget(),
                          ],
                        )),
                  ),
                  padding: EdgeInsets.only(top: 20),
                );
              } else {
                return Container();
              }
            }),
      ),
    );
  }

  Widget _buildItemOrder(Map order) {
    var formatString = "yyyy-MM-ddTHH:mm:ssZ";
    String orderPlaced = '';

    if (order['serviceDateTime'] != null) {
      DateTime format1 =
          new DateFormat(formatString).parse(order['serviceDateTime'], true).toLocal();
      orderPlaced = DateFormat("dd MMM yyyy, HH:mm").format(format1);
    }

    double totalMoney = 0;

    (order['orderDetails'] as List).forEach((element) {
      if(!element['isOutOfStock']) {
        totalMoney =
            totalMoney + element['payableAmount'] + element['payableSST'] + element['payableServiceCharge'];
      }
    });

    (order['orderOperations'] as List).forEach((element) {
      String outletId = element['outletId'];
      List listOrderDetail = (order['orderDetails'] as List).where((orderDetail) => orderDetail['outletId'] == outletId).toList();

      bool isOrderOperationOutOfStock =  listOrderDetail.every((orderDetail) => orderDetail['isOutOfStock']);

      if (element['serviceType'] == 'DELIVERY' && !isOrderOperationOutOfStock) {
        totalMoney += element['deliveryAmount'];
      }
    });

    bool isAllOrderDetailOutOfStock = (order['orderDetails'] as List).every((item) => item['isOutOfStock']);
    if(!isAllOrderDetailOutOfStock) {
      totalMoney += order['taxAmount'];
    }

    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      margin: EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 0.5), //(x,y)
              blurRadius: 2.0,
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order['name'],
            style: Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          SizedBox(
            height: 2,
          ),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: servicesTypeList[order['serviceType']],
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.normal,
                    ),
              ),
              TextSpan(
                text: ' - ',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.normal,
                    ),
              ),
              TextSpan(
                text: orderPlaced,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ]),
          ),
          SizedBox(
            height: 28,
          ),
          _buildViewDetailButton(totalMoney, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetailPage(
                          orderId: order['id'],
                        )));
          })
        ],
      ),
    );
  }

  Widget _buildViewDetailButton(double totalMoney, Function function) {
    return Row(children: <Widget>[
      Expanded(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0))),
              onPressed: () => function(),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 8.0),
                            Text('RM ${StringHelper.formatCurrency(totalMoney)}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(fontWeight: FontWeight.normal))
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('Order.ViewDetail'.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontWeight: FontWeight.normal)),
                    )
                  ]),
            )),
      )
    ]);
  }

  Widget _buildEmptyOrderWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Order.NoOrder'.tr(),
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        SvgPicture.asset('assets/images/logo_empty_order.svg'),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 64),
          child: Text(
            'Order.Explore'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.normal,
                ),
          ),
        ),
      ],
    );
  }
}
