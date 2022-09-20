import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/models/Payment.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/dialog-payment-fail.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/dialog-payment-success.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:rms_mobile_xdk_flutter/rms_mobile_xdk_flutter.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gem_consumer_app/screens/review-basket/gql/basket.gql.dart';
import 'package:gem_consumer_app/screens/review-basket/widgets/dialog-checkout-fail.dart';
import 'package:gem_consumer_app/screens/review-basket/review_basket_page.dart';

typedef void DoubleCallback(double val);

class CheckOutWidget extends StatefulWidget {
  CheckOutWidget(
      {required this.price,
      required this.serviceCharge,
      required this.itemCount,
      required this.preOrderId,
      required this.orderName,
      this.deliveryFee});
  final double price;
  final double? serviceCharge;
  final int itemCount;
  final String preOrderId;
  final String orderName;
  final double? deliveryFee;

  @override
  _CheckOutWidgetState createState() => _CheckOutWidgetState();
}

class _CheckOutWidgetState extends State<CheckOutWidget> {
  late Auth auth;
  late AddToCartItems basket;
  late PlanAParty party;

  @override
  void initState() {
    super.initState();
    auth = context.read<Auth>();
    basket = context.read<AddToCartItems>();
    party = context.read<PlanAParty>();
    //addBasketListener();
  }

  void addBasketListener() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        basket.addListener(() {
          //print("Check Called");
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("PreOrder ID : ${widget.preOrderId}");
    double totalAmount = widget.price;
    double? serviceCharge = widget.serviceCharge;
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 90, //MediaQuery.of(context).size.height * 0.12,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, -2.0), //(x,y)
            blurRadius: 4.0,
          )
        ]),
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    'RM ${StringHelper.formatCurrency(totalAmount + (serviceCharge ?? 0))}',
                    style: Theme.of(context).textTheme.button),
                Text('Basket.Items',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    )).tr(namedArgs: {"count": widget.itemCount.toString()})
              ]),
          Consumer<AddToCartItems>(builder: (context, item, child) {
            return Mutation(
                options: MutationOptions(
                    document: gql(BasketGQL.CREATE_PAYMENT),
                    onError: (dynamic error) {
                      Loader.hide();
                      print("createpayment");
                    },
                    onCompleted: (dynamic resultData) {
                      print("createpayment");
                      Loader.hide();
                      if (resultData['createUserOrder']['status'] ==
                          'SUCCESS') {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => Dialog(
                            child: DialogPaymentSuccess(),
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(24),
                          ),
                        );
                        basket.clearCartItems();
                        party.resetParty();
                      } else {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => Dialog(
                                  child: DialogCheckoutFail(
                                      resultData['createUserOrder']['status']
                                          .toString()
                                          .substring(5)),
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.all(24),
                                ));
                      }
                    }),
                builder: (
                  RunMutation runPaymentSuccessMutation,
                  QueryResult? result,
                ) {
                  return Mutation(
                      options: MutationOptions(
                          document: gql(BasketGQL.LOG_PAYMENT_ERROR),
                          onCompleted: (dynamic resultData) {
                            print("log error");
                          }),
                      builder: (
                        RunMutation runPaymentErrorMutation,
                        QueryResult? result,
                      ) {
                        return Mutation(
                            options: MutationOptions(
                              document: gql(BasketGQL.VALIDATE_BASKET),
                              onCompleted: (dynamic resultData) async {
                                Loader.hide();
                                print(
                                    "result: ${resultData['validateUserOrder']['status']}");
                                if (resultData['validateUserOrder']['status'].toString() ==
                                    "ZERO AMOUNT TRANSACTION") {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: DialogPaymentSuccess(),
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.all(24),
                                    ),
                                  );
                                  basket.clearCartItems();
                                  party.resetParty();
                                } else if (resultData['validateUserOrder']
                                            ['status']
                                        .toString()
                                        .substring(0, 4) ==
                                    "FAIL") {
                                  // Navigator.pop(context);
                                  // Navigator.pushNamed(
                                  //     context, ReviewBasketPage.routeName);
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => Dialog(
                                            child: DialogCheckoutFail(
                                                resultData['validateUserOrder']
                                                        ['status']
                                                    .toString()
                                                    .substring(5)),
                                            backgroundColor: Colors.transparent,
                                            insetPadding: EdgeInsets.all(24),
                                          ));
                                  print("fail validate checkout");
                                } else if ((resultData['validateUserOrder']
                                                ['status']
                                            .toString()
                                            .length >
                                        12) &&
                                    (resultData['validateUserOrder']['status']
                                            .toString()
                                            .substring(0, 13) ==
                                        "ORDER CREATED")) {
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => Dialog(
                                            child: DialogCheckoutFail(
                                                resultData['validateUserOrder']
                                                        ['status']
                                                    .toString()),
                                            backgroundColor: Colors.transparent,
                                            insetPadding: EdgeInsets.all(24),
                                          ));
                                  print("fail previous order has been created");
                                } else {
                                  if (item.isAvailable) {
                                    print("name: ${auth.currentUser.name}");
                                    print("email: ${auth.currentUser.phone}");
                                    print("phone: ${auth.currentUser.email}");
                                    Payment paymentDetails = new Payment(
                                        mp_amount:
                                            '${(widget.price + (serviceCharge ?? 0)).toStringAsFixed(2)}',
                                        mp_bill_description:
                                            '${widget.orderName}',
                                        mp_bill_email:
                                            auth.currentUser.email ?? '',
                                        mp_bill_mobile:
                                            auth.currentUser.phone ?? '',
                                        mp_bill_name:
                                            auth.currentUser.name ?? '',
                                        mp_order_ID: '${widget.preOrderId}');
                                    String? result = await MobileXDK.start(
                                        paymentDetails.toJson());

                                    var parsed = jsonDecode(result!);
                                    var status = parsed['status_code'];
                                    print("result: $parsed");

                                    if (status == '00') {
                                      showLoadingDialog();
                                      runPaymentSuccessMutation({
                                        "createOrderInput": {
                                          "preOrderId": widget.preOrderId,
                                          "orderName": widget.orderName,
                                          "paymentMode":
                                              "RAZER_PAYMENT_GATEWAY",
                                          "deliveryAmount":
                                              basket.outletsDeliveryFee,
                                          "taxAmount": basket.taxAmount,
                                          "CallBackResponseInput": parsed
                                        }
                                      });
                                    } else {
                                      print("error return from razor");
                                      runPaymentErrorMutation({
                                        "createPaymentLogInput": {
                                          "preOrderId": widget.preOrderId,
                                          "errorMessage": parsed
                                              .toString(), // change to json?
                                          "transactionAmount":
                                              paymentDetails.mp_amount,
                                          "paymentChannel":
                                              paymentDetails.mp_channel,
                                          "CallBackResponseInput": parsed
                                        }
                                      });
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: DialogPaymentFail(),
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.all(24),
                                        ),
                                      );
                                      print("Status : $status");
                                    }
                                  }
                                }
                              },
                            ),
                            builder: (
                              RunMutation runMutation,
                              QueryResult? result,
                            ) {
                              return

                                  //mutation
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 24.0),
                                          primary: item.isAvailable
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).disabledColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0))),
                                      onPressed: () {
                                        print(
                                            "total preorderid: ${widget.preOrderId}");
                                        showLoadingDialog();

                                        runMutation({
                                          "validationInput": {
                                            "preOrderId": widget.preOrderId,
                                            "deliveryAmount":
                                                basket.outletsDeliveryFee,
                                            "payableServiceCharge":
                                                serviceCharge != null
                                                    ? double.parse(serviceCharge
                                                        .toStringAsFixed(2))
                                                    : 0,
                                          }
                                        });
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Text('Button.Checkout',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .button)
                                                .tr(),
                                          ]));
                            });
                      });
                });
          })
        ]));
  }

  void showLoadingDialog() {
    showLoadingOverlay(context);
  }
}
