import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TimePickerFormField extends StatefulWidget {
  final String field;
  final Function setValue;
  final TimeOfDay initialValue;
  final String? timeStr;
  final DateTime? selectedDay;
  final Map<String, dynamic> formData;

  const TimePickerFormField({
    Key? key,
    required this.field,
    required this.setValue,
    required this.initialValue,
    required this.timeStr,
    required this.formData,
    this.selectedDay,
  }) : super(key: key);
  @override
  _TimePickerFormFieldState createState() => _TimePickerFormFieldState();
}

class _TimePickerFormFieldState extends State<TimePickerFormField> {
  var _textController = TextEditingController();
  final timeFormat = DateFormat('yyyy-dd-mm hh:mm a');
  String? timeStr;
  @override
  void initState() {
    _textController.text = widget.timeStr ?? '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Expanded(
          child: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              controller: _textController,
              readOnly: true,
              validator: (val) {
                if (widget.formData['endTime'] != null &&
                    widget.formData['startTime'] != null) {
                  if (widget.field == 'endTime' &&
                      DateTime.fromMillisecondsSinceEpoch(
                              (widget.formData['endTime'].seconds * 1000))
                          .isBefore(DateTime.fromMillisecondsSinceEpoch(
                              (widget.formData['startTime'].seconds * 1000)))) {
                    return 'Validation.InvalidTime';
                  }
                }
                return '';
              })),
      IconButton(
          icon: Icon(FontAwesomeIcons.clock,
              color: Theme.of(context).accentColor, size: 20.0),
          onPressed: () => _selectTime(context)),
    ]));
  }

  Future<Null> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: widget.initialValue,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark(),
            child: child ??
                SizedBox(
                  width: 0,
                ),
          );
        });
    if (selectedTime != null) {
      setState(() {
        timeStr = selectedTime.format(context);
        _textController.text = timeStr!;
        widget.setValue(
            widget.field, selectedTime, widget.selectedDay, timeStr);
      });
    }
  }
}
