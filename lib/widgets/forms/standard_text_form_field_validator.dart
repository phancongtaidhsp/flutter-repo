import 'package:flutter/material.dart';

class StandardTextFormFieldValidator extends StatefulWidget {
  final String label;
  final String field;
  final Function setValue;
  final Function validator;
  final String initialValue;
  final Function? submitValue;
  final TextEditingController? controller;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  const StandardTextFormFieldValidator(
      {Key? key,
      required this.label,
      required this.field,
      required this.setValue,
      required this.initialValue,
      required this.validator,
      this.submitValue,
      this.controller,
      this.maxLength,
      this.maxLines = 1,
      this.readOnly = false})
      : super(key: key);

  @override
  _StandardTextFormFieldValidatorState createState() =>
      _StandardTextFormFieldValidatorState();
}

class _StandardTextFormFieldValidatorState
    extends State<StandardTextFormFieldValidator> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        enabled: !widget.readOnly,
        controller: widget.controller,
        decoration: InputDecoration(
          errorMaxLines: 2,
          labelText: widget.label,
          suffixIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                if (widget.controller != null) {
                  widget.controller!.clear();
                }
              }),
        ),
        initialValue: widget.initialValue,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        onSaved: (String? value) {
          widget.setValue(widget.field, value);
        },
        onFieldSubmitted: (String value) {
          if (widget.submitValue != null) {
            widget.submitValue!(value);
          }
        },
        keyboardType: _getKeyboardType(widget.field, widget.maxLines > 1),
        validator: (val) => widget.validator(val));
  }

  TextInputType _getKeyboardType(String field, isMultiline) {
    if (isMultiline) {
      return TextInputType.multiline;
    } else {
      switch (field) {
        case 'phone':
        case 'businessPhone':
          return TextInputType.phone;
        case 'IDD':
          return TextInputType.number;
        case 'facebookUrl':
        case 'instagramUrl':
        case 'linkedInUrl':
        case 'twitterUrl':
          return TextInputType.url;
        case 'email':
        case 'businessEmail':
        case 'inviteeEmail':
          return TextInputType.emailAddress;
        default:
          return TextInputType.text;
      }
    }
  }
}
