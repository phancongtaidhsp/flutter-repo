import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';

class NotificationAlertDialogWidget extends StatefulWidget {
  final String title;
  final String content;
  final String? caption;
  final Function? continueFunction;
  final String? buttonKey;
  final String? imageUrlPath;
  final bool? isCenter;

  const NotificationAlertDialogWidget(
      {Key? key,
      required this.title,
      required this.content,
      this.isCenter = false,
      this.caption,
      this.continueFunction,
      this.buttonKey,
      this.imageUrlPath})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _NotificationAlertDialogWidget();
}

class _NotificationAlertDialogWidget
    extends State<NotificationAlertDialogWidget> {
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
                    widget.title,
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
              widget.imageUrlPath != null
                  ? Center(child: SvgPicture.asset(widget.imageUrlPath!))
                  : Container(),
              SizedBox(height: 30),
              widget.isCenter != null
                  ? Center(
                      child: Text(widget.content,
                          style: textTheme.bodyText2!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black)))
                  : Text(widget.content,
                      style: textTheme.bodyText2!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
              widget.caption != null
                  ? SizedBox(height: 4)
                  : SizedBox(width: 0.0, height: 0.0),
              widget.caption != null
                  ? widget.isCenter != null
                      ? Center(
                          child: Text(widget.caption!,
                              textAlign: widget.isCenter!
                                  ? TextAlign.center
                                  : TextAlign.left,
                              style: textTheme.bodyText2!.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)))
                      : Text(widget.caption!,
                          textAlign: widget.isCenter != null
                              ? TextAlign.center
                              : TextAlign.left,
                          style: textTheme.bodyText2!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black))
                  : Container(width: 0.0, height: 0.0),
              SizedBox(height: 48),
              SubmitButton(
                text: widget.buttonKey != null
                    ? widget.buttonKey!
                    : 'Button.Okay',
                textColor: Colors.black,
                backgroundColor: Theme.of(context).primaryColor,
                rippleColor: Colors.white,
                onPressed: () {
                  if (widget.continueFunction != null) {
                    widget.continueFunction!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
