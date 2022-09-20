import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class TermAndCondition extends StatelessWidget {
  TermAndCondition(this.termsAndConditions);

  final String termsAndConditions;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "General.TermAndCondition".tr(),
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
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
                          icon:
                              SvgPicture.asset('assets/images/icon-close.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            Navigator.pop(context);
                          })),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              termsAndConditions != ''
                  ? HtmlWidget(
                      termsAndConditions,
                      customStylesBuilder: (element) {
                        return {'color': 'black'};
                      },
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
