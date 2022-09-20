import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SmartFilterButton extends StatefulWidget {
  SmartFilterButton({required this.selected});
  bool selected;

  @override
  _SmartFilterButtonState createState() => _SmartFilterButtonState();
}

class _SmartFilterButtonState extends State<SmartFilterButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            if (widget.selected == false) {
              widget.selected = true;
            } else {
              widget.selected = false;
            }
          });
        },
        child: Center(
            child: Row(
          children: [
            Text("PlanAParty.SmartFilter",
                    style: TextStyle(
                      fontFamily: 'Arial Rounded MT Bold',
                      color:
                          widget.selected == true ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center)
                .tr(),
          ],
        )),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            primary: widget.selected == true
                ? Color.fromRGBO(0, 0, 0, 1)
                : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }
}
