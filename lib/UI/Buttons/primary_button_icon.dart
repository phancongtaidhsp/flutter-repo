import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PrimaryButtonIcon extends StatelessWidget {
  const PrimaryButtonIcon({required this.action, required this.btnText});
  final Function action;
  final String btnText;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.8666,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () {
          action();
        },
        label: Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
        ),
        icon: Container(
          width: size.width * 0.1,
          child: Text(
            btnText.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 10),
          primary: Color.fromRGBO(253, 196, 0, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }
}
