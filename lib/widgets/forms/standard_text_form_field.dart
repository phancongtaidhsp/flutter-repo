import 'package:flutter/material.dart';

class StandardTextFormField extends StatefulWidget {
  final String label;
  final String field;
  final Function setValue;
  final String? validatorStr;
  final String? initialValue;
  final Function? submitValue;
  final TextEditingController? controller;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final String? hintText;
  const StandardTextFormField(
      {Key? key,
      required this.label,
      required this.field,
      required this.setValue,
      this.initialValue,
      this.validatorStr,
      this.submitValue,
      this.controller,
      this.maxLength,
      this.maxLines = 1,
      this.readOnly = false,
      this.hintText})
      : super(key: key);

  @override
  _StandardTextFormFieldState createState() => _StandardTextFormFieldState();
}

class _StandardTextFormFieldState extends State<StandardTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      enabled: !widget.readOnly,
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText != null ? widget.hintText : '',
        labelText: widget.label,
        suffixIcon: widget.controller != null
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  if (widget.controller != null) {
                    widget.controller!.clear();
                  }
                })
            : null,
      ),
      initialValue: widget.initialValue,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      onSaved: (String? value) {
        if (value != null) {
          widget.setValue(widget.field, value);
        }
      },
      onFieldSubmitted: (String value) {
        if (widget.submitValue != null) {
          widget.submitValue!(value);
        }
      },
      keyboardType: _getKeyboardType(widget.field, widget.maxLines! > 1),
      validator: (val) => widget.validatorStr != null
          ? val != null
              ? (val.trim().isEmpty ? widget.validatorStr : null)
              : null
          : null,
    );
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
        case 'totalPax':
        case 'requestAmount': // for request payout withdraw feature
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
