import 'package:flutter/material.dart';

class AddressTextFieldWidget extends StatefulWidget {
  AddressTextFieldWidget(this.hintText, this.controller, this.textInputType,
      {this.maxLines});
  final String hintText;
  final TextEditingController controller;
  final int? maxLines;
  final TextInputType textInputType;

  @override
  _AddressTextFieldWidgetState createState() => _AddressTextFieldWidgetState();
}

class _AddressTextFieldWidgetState extends State<AddressTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
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
          hintText: widget.hintText,
          hintStyle:
              Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        maxLines: widget.maxLines,
        keyboardType: widget.textInputType);
  }
}
