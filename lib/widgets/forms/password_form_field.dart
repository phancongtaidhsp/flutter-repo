import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField(
      {Key? key,
      required this.label,
      required this.formData,
      this.isConfirmPassword =
          false}) //Optional field with default value of false
      : super(key: key);

  final String label;
  final Map<String, dynamic> formData;
  final bool isConfirmPassword;

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool passwordVisible = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: passwordVisible,
      validator: (value) {
        if (value!.length == 0) {
          return widget.isConfirmPassword
              ? 'Validation.ConfirmPasswordRequired'
              : 'Validation.PasswordRequired';
        } else if (value.length < 6) {
          return 'Validation.InvalidPassword';
        } else if (widget.isConfirmPassword) {
          if (widget.formData['password'] != value.toString()) {
            return 'Validation.ConfirmPasswordMismatch';
          }
        } else {
          widget.formData['password'] = value;
        }
        return null;
      },
      onSaved: (String? value) {
        if (value != null) {
          if (widget.isConfirmPassword) {
            widget.formData['confirmPassword'] = value.toString();
          } else {
            widget.formData['password'] = value.toString();
          }
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            // Update the state i.e. toogle the state of passwordVisible variable
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
      ),
    );
  }
}
