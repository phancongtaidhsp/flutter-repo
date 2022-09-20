import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  final String label;
  final Map<String, dynamic> formData;
  const EmailFormField({Key? key, required this.label, required this.formData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        validator: (String? value) {
          if (value != null) {
            if (value.length == 0) {
              return 'Validation.InvalidEmail';
            } else {
              String pattern =
                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
              RegExp regExp = RegExp(pattern);
              return regExp.hasMatch(value.trim())
                  ? null
                  : 'Validation.InvalidEmail';
            }
          } else {
            return 'Validation.InvalidEmail';
          }
        },
        onSaved: (String? value) {
          if (value != null) {
            formData['email'] = value.trim().toLowerCase();
          }
        },
        keyboardType: TextInputType.emailAddress,
        decoration:
            InputDecoration(labelText: label != null ? label : 'Form.Email'));
  }
}
