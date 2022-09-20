import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class MerchantOutletRemark extends StatelessWidget {
  MerchantOutletRemark(this.remark);
  final String remark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(63, 148, 227, 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: HtmlWidget(
        "$remark",
        // set the default styling for text
        textStyle: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }
}
