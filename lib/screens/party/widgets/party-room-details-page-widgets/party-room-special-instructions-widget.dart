import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PartyRoomSpecialInstructionsWidget extends StatefulWidget {
  PartyRoomSpecialInstructionsWidget(this.controller);
  final TextEditingController controller;
  @override
  _PartyRoomSpecialInstructionsWidgetState createState() =>
      _PartyRoomSpecialInstructionsWidgetState();
}

class _PartyRoomSpecialInstructionsWidgetState
    extends State<PartyRoomSpecialInstructionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product.SpecialInstructions",
            style: Theme.of(context).textTheme.button,
          ).tr(),
          Container(
              padding: EdgeInsets.only(top: 20.0),
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.normal),
                  controller: widget.controller,
                  onChanged: (value) async {},
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        )),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23.0),
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        )),
                    hintText: "Special Instructions",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 14),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  keyboardType: TextInputType.text)),
        ],
      ),
    );
  }
}
