import 'package:flutter/material.dart';
import 'package:gem_consumer_app/widgets/forms/standard_text_form_field_validator.dart';

class ContactNumberFormField extends StatefulWidget {
  final TextEditingController controller;
  final Map<String, dynamic> field;
  final String initialValue;
  final Function setInputValue;

  const ContactNumberFormField(
      {Key? key,
      required this.controller,
      required this.field,
      required this.initialValue,
      required this.setInputValue})
      : super(key: key);
  @override
  _ContactNumberFormFieldState createState() => _ContactNumberFormFieldState();
}

class _ContactNumberFormFieldState extends State<ContactNumberFormField> {
  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          flex: 1,
          child: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              controller: widget.controller,
              enabled: false,
              decoration: InputDecoration(labelText: 'Form.DialCode'))),
      SizedBox(width: 15.0),
      Expanded(
          flex: 2,
          child: StandardTextFormFieldValidator(
            maxLines: widget.field['maxLines'],
            label: widget.field['label'],
            field: widget.field['field'],
            setValue: widget.setInputValue,
            initialValue: widget.initialValue,
            validator: _validatePhone,
          ))
    ]);
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'Validation.PhoneRequired';
    }
    // ^ Start of string
    // (?:[+0]9)? Optionally match a + or 0 followed by 9
    // [0-9]{7, 12} Match 7 to 12 digits
    // $ End of string
    String p = r'(^(?:[+0]9)?[0-9]{7,12}$)';
    RegExp regExp = RegExp(p);
    if (regExp.hasMatch(value)) {
      return null;
    }
    return 'Validation.InvalidPhoneFormat';
  }
}
