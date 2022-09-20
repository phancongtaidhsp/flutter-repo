import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:intl/intl.dart';

class DateTimeFormField extends StatefulWidget {
  final String? label;
  final String? field;
  final Function setValue;
  final DateTime? initialValue;
  final String? validatorStr;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? dateStr;
  final bool? isButtonDisabled;
  final bool? isCenterText;

  DateTimeFormField(
      {Key? key,
      required this.setValue,
      this.initialValue,
      this.validatorStr,
      this.label,
      this.field,
      this.startDate,
      this.endDate,
      this.dateStr,
      this.isCenterText = true,
      this.isButtonDisabled = true})
      : super(key: key);

  @override
  _DateTimeFormFieldState createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends State<DateTimeFormField> {
  var _textController = TextEditingController();
  String? dateStr;
  final dateFormat = DateFormat('dd MMMM yyyy');
  DateTime? _dateTimeFromPopup;

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    _textController.text = widget.dateStr != null ? widget.dateStr! : '';

    return InkWell(
      onTap: () => widget.isButtonDisabled ?? _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23.0),
            color: widget.isButtonDisabled == null
                ? Colors.grey.withOpacity(0.2)
                : lightPrimaryColor),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: IgnorePointer(
                child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    minLines: 1,
                    textAlign: widget.isCenterText != null
                        ? TextAlign.center
                        : TextAlign.left,
                    style: TextStyle(
                      color: grayTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Arial Rounded MT Bold',
                    ),
                    controller: _textController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                      isDense: true,
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
                      labelText: widget.label,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    validator: (String? val) => val != null
                        ? val.isEmpty
                            ? widget.validatorStr
                            : null
                        : null,
                    readOnly: true),
              )),
              SizedBox(width: 8),
              SvgPicture.asset(
                'assets/images/dropdown-button.svg',
                color: grayTextColor,
                width: 8,
                height: 8,
              ),
            ]),
      ),
    );
  }

  Future<DateTime?> _showIOSDateTimePicker(BuildContext ctx,
      {required bool timeOnly}) async {
    await showIOSDatePicker(
      context: context,
      initialDateTime:
          widget.initialValue != null ? widget.initialValue! : DateTime.now(),
      minimumDate:
          widget.startDate != null ? widget.startDate! : DateTime.now(),
      maximumDate: widget.endDate != null
          ? widget.endDate!
          : DateTime.now().add(const Duration(days: 60)),
      onDateTimeChanged: (val) {
        if (!timeOnly) {
          setState(() {
            _dateTimeFromPopup = val;
          });
        }
      },
      timeOnly: timeOnly,
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime? selectedDate;
    if (Platform.isAndroid) {
      selectedDate = await showDatePicker(
        context: context,
        initialDate:
            widget.initialValue != null ? widget.initialValue! : DateTime.now(),
        firstDate:
            widget.startDate != null ? widget.startDate! : DateTime.now(),
        lastDate: widget.endDate != null
            ? widget.endDate!
            : DateTime.now().add(const Duration(days: 60)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark(),
            child: child!,
          );
        },
      );
    } else {
      await _showIOSDateTimePicker(context, timeOnly: false);
    }
    if (Platform.isIOS) {
      selectedDate = _dateTimeFromPopup;
    }
    if (selectedDate != null) {
      setState(() {
        dateStr = DateFormat('dd MMM, yyyy').format(selectedDate!);
        _textController.text = dateStr!;
      });

      widget.setValue(selectedDate);
    }
  }
}
