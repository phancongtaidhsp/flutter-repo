import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';

class AddVoucherWidget extends StatelessWidget {
  const AddVoucherWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
            width: 1,
            style: BorderStyle.solid,
            color: Color.fromRGBO(228, 229, 229, 1)),
      )),
      child: Row(
        children: [
          Text(
            "Basket.AddVoucher",
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ).tr(),
          SizedBox(
            width: 10,
          ),
          SvgPicture.asset('assets/images/voucher.svg'),
        ],
      ),
    );
  }
}
