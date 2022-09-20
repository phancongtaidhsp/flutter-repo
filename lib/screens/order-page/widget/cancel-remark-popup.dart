import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/screens/order-page/gql/order_gql.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CancelRemarkPopUp extends StatefulWidget {
  final String orderId;

  const CancelRemarkPopUp(this.orderId);

  @override
  _CancelRemarkPopUpState createState() => _CancelRemarkPopUpState();
}

class _CancelRemarkPopUpState extends State<CancelRemarkPopUp> {
  late TextEditingController _controller;
  bool isRemarkInvalid = false;

  @override
  void initState() {
    _controller = TextEditingController();
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                            icon:
                                SvgPicture.asset('assets/images/icon-back.svg'),
                            iconSize: 36.0,
                            onPressed: () {
                              Navigator.pop(context);
                            })),
                    Spacer(),
                    Mutation(
                        options: MutationOptions(
                          document: gql(OrderGQL.CANCEL_ORDER),
                          onCompleted: (dynamic resultData) {
                            Loader.hide();
                            if (resultData['cancelOrder']['status'] ==
                                'SUCCESS') {
                              Navigator.pop(context, true);
                            } else {
                              Navigator.pop(context, false);
                            }
                          },
                          onError: (dynamic resultData) {
                            Loader.hide();
                            Navigator.pop(context, false);
                          },
                        ),
                        builder: (
                          RunMutation runMutation,
                          QueryResult? result,
                        ) {
                          return SubmitButton(
                            text: 'Button.Done',
                            textColor: Colors.white,
                            backgroundColor: Colors.black,
                            rippleColor: Colors.grey,
                            width: 100,
                            height: 40,
                            textSize: 12,
                            verticalTextPadding: 14,
                            isUppercase: true,
                            onPressed: () {
                              if (_controller.text != '') {
                                isRemarkInvalid = false;

                                showLoadingOverlay(context);

                                runMutation({
                                  "id": widget.orderId,
                                  "cancellationRemark": _controller.text
                                });
                              } else {
                                setState(() {
                                  isRemarkInvalid = true;
                                });
                              }
                            },
                          );
                        }),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Order.CancellationRemark'.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: 24,
                ),
                _buildTextFieldCancelledRemark(),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Visibility(
                    visible: isRemarkInvalid,
                    child: Text(
                      'Validation.Required',
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.normal),
                    ).tr(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Order.CancellationFeeDes'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.red),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Order.CancellationFeeDesAdditional'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.red),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldCancelledRemark() {
    return Container(
      padding: EdgeInsets.only(left: 2),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        minLines: 4,
        maxLines: null,
        maxLength: null,
        controller: _controller,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                )),
            hintText: tr('Order.EnterRemark'),
            hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Colors.grey[400], fontWeight: FontWeight.normal),
            hintMaxLines: 10),
      ),
    );
  }
}
