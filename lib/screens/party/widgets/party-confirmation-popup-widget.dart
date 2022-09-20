import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/screens/review-basket/review_basket_page.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class PopUpConfirmationWidget extends StatefulWidget {
  final String title;
  final String content;
  final Function continueFunction;
  final bool ableToSkip;
  final bool lastStep;

  const PopUpConfirmationWidget(
      {Key? key,
      required this.title,
      required this.content,
      required this.continueFunction,
      this.ableToSkip = true,
      this.lastStep = false})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _PopUpConfirmationWidget();
}

class _PopUpConfirmationWidget extends State<PopUpConfirmationWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16), topLeft: Radius.circular(16))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Text(
                    widget.title.tr(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Arial Rounded MT Bold',
                        fontWeight: FontWeight.w400),
                  )),
                  Container(
                      height: 36.0,
                      width: 36.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1)),
                          ]),
                      child: IconButton(
                          icon:
                              SvgPicture.asset('assets/images/icon-close.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            Navigator.pop(context);
                          }))
                ],
              ),
              SizedBox(height: 15),
              Text(widget.content.tr(),
                  style: textTheme.bodyText2!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
              SizedBox(height: 48),
              SubmitButton(
                text: 'Button.ContinuePlanning',
                textColor: Colors.black,
                backgroundColor: Theme.of(context).primaryColor,
                rippleColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10),
              widget.ableToSkip
                  ? SubmitButton(
                      text: 'Button.Skip',
                      textColor: Colors.white,
                      backgroundColor: Colors.black,
                      rippleColor: Colors.white,
                      onPressed: () {
                        widget.continueFunction();
                        if (!widget.lastStep) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, ReviewBasketPage.routeName);
                        }
                      },
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
