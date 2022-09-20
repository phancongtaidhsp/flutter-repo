import 'package:flutter/material.dart';

enum Gender { male, female }

class GenderFormField extends StatefulWidget {
  final Function setGender;
  final String? initialValue;

  const GenderFormField({Key? key, required this.setGender, this.initialValue})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<GenderFormField> {
  Gender? _selectedGender;

  void _handleValueChange(Gender? value) {
    if (value != null) {
      setState(() {
        _selectedGender = value;
        widget.setGender(_extractEnumStringValue(value));
      });
    }
  }

  String _extractEnumStringValue(Gender gender) {
    return gender.toString().substring(Gender.male.toString().indexOf('.') + 1);
  }

  @override
  void initState() {
    if (widget.initialValue != null) {
      _selectedGender = Gender.values
          .firstWhere((e) => e.toString() == 'Gender.' + widget.initialValue!);
      if (_selectedGender != null) {
        widget.setGender(widget.initialValue);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Text('Form.Gender'),
      Row(children: <Widget>[
        Radio(
            value: Gender.male,
            groupValue: _selectedGender,
            onChanged: _handleValueChange),
        Text('Form.Gender.${_extractEnumStringValue(Gender.male)}')
      ]),
      Row(children: <Widget>[
        Radio(
            value: Gender.female,
            groupValue: _selectedGender,
            onChanged: _handleValueChange),
        Text('Form.Gender${_extractEnumStringValue(Gender.female)}')
      ])
    ]);
  }
}
