import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/screens/account-page/widgets/zendesk-chat-page.dart';
import 'package:gem_consumer_app/screens/order-page/order_review_page.dart';
import 'package:gem_consumer_app/screens/order-page/widget/cancel-remark-popup.dart';
import 'package:gem_consumer_app/screens/order-page/widget/cancel_failed_popup.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:gem_consumer_app/widgets/special_instruction.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../environment.dart';
import '../../providers/auth.dart';
import '../../screens/order-page/gql/order_gql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zendesk2/chat2/zendesk_chat2.dart';
import 'package:zendesk2/zendesk2.dart';

import '../../configuration.dart';

class OrderDetailPage extends StatefulWidget {
  static String routeName = '/order-detail';

  final String orderId;

  const OrderDetailPage({required this.orderId});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  static late Auth auth;
  late Map order;
  late bool isOrderCompleted;
  late bool isOneOfOrderOperationIsCompleted;
  late bool isOrderReviewed;
  late bool isCancelable;
  final z = Zendesk.instance;
  String displayOrderId = "";

  final Map<String, String> servicesTypeList = {
    "DINE_IN": "Dine In",
    "DELIVERY": "Delivery",
    "PICKUP": "Pick Up"
  };

  final Map<String, String> statusOperation = {
    "NEW": "Order.NewStatus".tr(),
    "CONFIRMED": "Order.ConfirmStatus".tr(),
    "READY_FOR_PICKUP": "Order.ReadyStatus".tr(),
    "PICKED_UP": "Order.PickedStatus".tr(),
    "COMPLETED": "Order.CompletedStatus".tr(),
    "CANCELLED": "Order.CancelledStatus".tr(),
  };

  @override
  void initState() {
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: _buildAppBar(displayOrderId),
        preferredSize: Size(double.infinity, 56),
      ),
      body: Query(
          options: QueryOptions(
              document: gql(OrderGQL.GET_ORDER_DETAIL_BY_ORDER_ID),
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

              WidgetsBinding.instance!.addPostFrameCallback((_) {
                setState(() {
                  displayOrderId = order['displayOrderId'];
                });
              });

              isOrderCompleted = true;
              isOneOfOrderOperationIsCompleted = false;
              isOrderReviewed = true;

              order['orderOperations'].forEach((orderOperation) {
                if (orderOperation['orderStatus'] != "COMPLETED") {
                  isOrderCompleted = false;
                } else {
                  isOneOfOrderOperationIsCompleted = true;
                }

                if (!orderOperation['isReviewSubmitted']) {
                  isOrderReviewed = false;
                }
              });

              DateTime now = DateTime.now();
              var formatString = "yyyy-MM-ddTHH:mm:ssZ";
              DateTime cancelCutoffTime = new DateFormat(formatString)
                  .parse(order['cancelCutoffTime'], true)
                  .toLocal();
              isCancelable =
                  now.isBefore(cancelCutoffTime) && !order['isCancelled'];

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: ListView.separated(
                    itemCount: order['orderOperations'].length + 1,
                    itemBuilder: (context, index) {
                      if (index == order['orderOperations'].length) {
                        return _buildBottomSummary();
                      }
                      return _buildItemOutlet(order['orderOperations'][index]);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return _buildDivider(10);
                    },
                  )),
                  _buildBottomButton()
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }

  Widget _buildAppBar(String orderId) {
    String title = 'Order.OrderId'.tr() + '# $orderId';
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
            title,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          Container(
            width: 36,
            height: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildItemOutlet(Map orderOperation) {
    List listProduct = List.empty(growable: true);
    listProduct.clear();

    (order['orderDetails'] as List).forEach((element) {
      if (element['outletId'] == orderOperation['outletId']) {
        listProduct.add(element);
      }
    });

    DateTime dateTimeFormat;
    String time;
    String operationDate = '';
    String operationTime = '';

    time = orderOperation['deliveryDateTime'];

    var formatString = "yyyy-MM-ddTHH:mm:ssZ";
    if (orderOperation['deliveryDateTime'] != null) {
      dateTimeFormat = new DateFormat(formatString).parse(time, true).toLocal();
      operationDate = DateFormat("dd MMM yyyy").format(dateTimeFormat);
      operationTime = DateFormat("hh:mm a").format(dateTimeFormat);
    }

    bool isDelivery = orderOperation['serviceType'] == 'DELIVERY';

    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: 20, top: 20),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusOperation[orderOperation['orderStatus']]!,
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      servicesTypeList[orderOperation['serviceType']]! +
                          ', ' +
                          operationDate,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: Colors.black),
                    ),
                    Text(
                      operationTime,
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.normal),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 12,
          ),
          isDelivery
              ? _buildDeliveryAddress(orderOperation['deliveryAddress'])
              : Container(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderOperation['outlet']['name'],
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: List.generate(listProduct.length,
                        (_index) => _buildItemProduct(listProduct[_index])),
                  ),
                  SizedBox(
                    height: isOrderCompleted ? 10 : 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(String address) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
      child: Column(
        children: [
          _buildDivider(2),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order.DeliveryAddress'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontWeight: FontWeight.normal, fontSize: 12),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  address,
                  textAlign: TextAlign.end,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          _buildDivider(2),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Column(
      children: [
        _buildDivider(4),
        (isCancelable && !isOneOfOrderOperationIsCompleted)
            ? Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SubmitButton(
                  text: 'Button.Cancel',
                  backgroundColor: Colors.grey[300],
                  verticalTextPadding: 14,
                  textColor: Colors.black,
                  rippleColor: Colors.white,
                  height: 10,
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => Dialog(
                        child: CancelRemarkPopUp(order['id']),
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.all(24),
                      ),
                    ).then((value) {
                      if (value != null && value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderDetailPage(
                                      orderId: order['id'],
                                    )));
                      } else if (value != null && !value) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => Dialog(
                            child: CancelFailedPopUp(
                              isCancelSuccess: false,
                              orderId: order['id'],
                            ),
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(24),
                          ),
                        );
                      }
                    });
                  },
                ),
              )
            : Container(),
        isOrderCompleted && !isOrderReviewed
            ? Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SubmitButton(
                  text: 'Order.Review',
                  backgroundColor: primaryColor,
                  verticalTextPadding: 12,
                  textColor: Colors.black,
                  rippleColor: Colors.white,
                  height: 10,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderReviewPage(
                                  orderId: order['id'],
                                ))).then((value) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderDetailPage(
                                    orderId: order['id'],
                                  )));
                    });
                  },
                ),
              )
            : Container(),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
          child: ElevatedButton(
              onPressed: () {
                chat(context);
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text("Order.ContactGEMSpot".tr(),
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Arial Rounded MT Bold',
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center),
                  )),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)))),
        ),
      ],
    );
  }

  void chat(BuildContext context) async {
    final userName = auth.currentUser.name ?? '';
    await z.initChatSDK(
        Configuration.KEY_ZENDESK_KEY, Configuration.KEY_APP_ID);

    Zendesk2Chat zChat = Zendesk2Chat.instance;

    String environmentName =
        Environment.environment == 'DEV' ? '[TESTING] ' : '';

    await zChat.setVisitorInfo(
      name: '$environmentName$userName',
      email: auth.currentUser.email ?? '',
      phoneNumber: auth.currentUser.phone ?? '',
      tags: ['app', 'zendesk2_plugin'],
    );

    await Zendesk2Chat.instance.startChatProviders(autoConnect: false);

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ZendeskChatPage(displayOrderId: order["displayOrderId"])));
  }

  Widget _buildItemProduct(Map data) {
    bool isOutOfStock = data['isOutOfStock'];

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                "${data['quantity'].toString()}x",
                style: Theme.of(context).textTheme.button!.copyWith(
                      fontWeight: FontWeight.normal,
                      decoration: isOutOfStock
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationThickness: 1.5,
                      fontSize: 12,
                    ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['product']['title'],
                  style: Theme.of(context).textTheme.button!.copyWith(
                        fontWeight: FontWeight.normal,
                        decoration: isOutOfStock
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationThickness: 1.5,
                        fontSize: 12,
                      ),
                ),
                SizedBox(
                  height: (data['variation'] != null && data['variation'] != "")
                      ? 4
                      : 0,
                ),
                (data['variation'] != null && data['variation'] != "")
                    ? Text(
                        data['variation'],
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Color(0xFFF4B920),
                            decoration: isOutOfStock
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationThickness: 1.5),
                      )
                    : Container(),
                SizedBox(
                  height: (data['specialInstruction'] != null &&
                          data['specialInstruction'] != "")
                      ? 4
                      : 0,
                ),
                (data['specialInstruction'] != null &&
                        data['specialInstruction'] != "")
                    ? SpecialInstruction(
                        specialInstructionText: data['specialInstruction'],
                      )
                    : SizedBox(
                        width: 0,
                      ),
                SizedBox(
                  height: isOutOfStock ? 4 : 0,
                ),
                isOutOfStock
                    ? Text(
                        'Order.OutOfStock'.tr(),
                        style: Theme.of(context).textTheme.button!.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.redAccent),
                      )
                    : Container()
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            StringHelper.formatCurrency(
                data['payableAmount'] + data['payableSST']),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.black,
                  decoration: isOutOfStock
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationThickness: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    String title = 'Order.OrderId'.tr() + '# $displayOrderId';

    dynamic serviceChargeRate = 0;
    double totalServiceCharge = 0;
    double totalMoney = 0;
    double subTotalMoney = 0;
    double totalDeliveryFee = 0;

    (order['orderDetails'] as List).forEach((element) {
      if (!element['isOutOfStock']) {
        totalMoney =
            totalMoney + element['payableAmount'] + element['payableSST'];
        subTotalMoney += element['payableAmount'] + element['payableSST'];
        totalServiceCharge += element['payableServiceCharge'];
      }
    });

    var venueProduct = (order['orderDetails'] as List).firstWhere(
        (element) => element['product']['productType'] == "ROOM",
        orElse: () => null);
    var foodProduct = (order['orderDetails'] as List).firstWhere(
        (element) => element['product']['productType'] == "FOOD",
        orElse: () => null);

    bool isServiceChargeEnable = venueProduct != null &&
        foodProduct != null &&
        venueProduct["outletId"] == foodProduct["outletId"];

    if (isServiceChargeEnable)
      serviceChargeRate = foodProduct["payableServiceChargeRate"];

    (order['orderOperations'] as List).forEach((element) {
      String outletId = element['outletId'];
      List listOrderDetail = (order['orderDetails'] as List)
          .where((orderDetail) => orderDetail['outletId'] == outletId)
          .toList();

      bool isOrderOperationOutOfStock =
          listOrderDetail.every((orderDetail) => orderDetail['isOutOfStock']);

      if (element['serviceType'] == 'DELIVERY' && !isOrderOperationOutOfStock) {
        totalMoney += element['deliveryAmount'];
        totalDeliveryFee += element['deliveryAmount'];
      }
    });

    totalMoney += totalServiceCharge;

    bool isAllOrderDetailOutOfStock =
        (order['orderDetails'] as List).every((item) => item['isOutOfStock']);
    if (!isAllOrderDetailOutOfStock) {
      totalMoney += order['taxAmount'];
    }

    int numberOutlet = order['orderOperations'].length;
    String itemText;
    if (numberOutlet > 1) {
      itemText = 'Order.Items'.tr();
    } else {
      itemText = 'Order.Item'.tr();
    }

    String numberItem = 'Basket.Subtotal'.tr() + ' ($numberOutlet $itemText)';

    String orderPlaced = '';
    String operationTime = '';
    var formatString = "yyyy-MM-ddTHH:mm:ssZ";
    if (order['serviceDateTime'] != null) {
      DateTime format1 =
          new DateFormat(formatString).parse(order['orderAt'], true).toLocal();
      orderPlaced = 'Order.OrderPlaced'.tr() +
          ' ' +
          DateFormat("dd MMM yyyy").format(format1);
      operationTime = DateFormat("hh:mm a").format(format1);
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Colors.black),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          orderPlaced,
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.black),
                        ),
                        Text(
                          operationTime,
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Basket.Total'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                  Text(
                    'RM ${StringHelper.formatCurrency(totalMoney)}',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: _buildDivider(2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    numberItem,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Colors.grey[500]),
                  ),
                  Text(
                    'RM ${StringHelper.formatCurrency(subTotalMoney)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
              isServiceChargeEnable
                  ? SizedBox(
                      height: 4,
                    )
                  : Container(),
              isServiceChargeEnable
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Basket.ServiceCharge',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey[500]),
                        ).tr(namedArgs: {
                          "rate": StringHelper.formatCurrency(serviceChargeRate)
                        }),
                        Text(
                          StringHelper.formatCurrency(totalServiceCharge),
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Basket.DeliveryFee',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Colors.grey[500]),
                  ).tr(),
                  Text(
                    StringHelper.formatCurrency(totalDeliveryFee),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Removed as per #4003
                  // Text(
                  //   '6% ' + 'Basket.ServiceTax'.tr(),
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .bodyText2!
                  //       .copyWith(color: Colors.grey[500]),
                  // ),
                  // Text(
                  //   StringHelper.formatCurrency(order['taxAmount']),
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .bodyText2!
                  //       .copyWith(color: Colors.grey[500]),
                  // ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(double value) {
    return Container(
      height: value,
      color: Colors.grey[200],
    );
  }
}
