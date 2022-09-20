import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class DropdownFormField extends StatefulWidget {
  final String? validatorTextKey;
  final String initialTextKey;
  final Map<String, dynamic>? initialValue;
  final List<Map<String, dynamic>> dropDownItemList;
  final Function selectedIndexChanged;
  final bool? isDense;
  final Color? fillColor;

  const DropdownFormField(
      {Key? key,
      this.validatorTextKey,
      this.initialValue,
      required this.dropDownItemList,
      required this.selectedIndexChanged,
      required this.initialTextKey,
      this.isDense = false,
      this.fillColor})
      : super(key: key);
  @override
  _DropdownFormFieldState createState() => _DropdownFormFieldState();
}

class _DropdownFormFieldState extends State<DropdownFormField> {
  DropdownItem? _selectedValue;
  List<DropdownItem>? _dropdownItemList;

  @override
  void initState() {
    _selectedValue = null;
    if (widget.initialValue != null) {
      _selectedValue = DropdownItem.fromJson(widget.initialValue!);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dropdownItemList = widget.dropDownItemList.map((item) {
      return DropdownItem.fromJson(item);
    }).toList();
    return FormField<DropdownItem>(
        initialValue: _selectedValue ?? null,
        builder: (FormFieldState<DropdownItem> state) {
          return InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: widget.fillColor != null
                  ? widget.fillColor
                  : Colors.grey[200],
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              floatingLabelBehavior: FloatingLabelBehavior.never,
              errorText: state.hasError ? state.errorText : null,
            ),
            child: Container(
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<DropdownItem>(
                        icon: SvgPicture.asset(
                          'assets/images/dropdown-button.svg',
                          color: grayTextColor,
                          width: 8,
                          height: 8,
                        ),
                        isExpanded: true,
                        hint: Text(widget.initialTextKey,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: grayTextColor,
                                        fontSize: 14,
                                        fontFamily: 'Arial Rounded MT Bold',
                                        fontWeight: FontWeight.w400))
                            .tr(),
                        value: _selectedValue,
                        isDense: widget.isDense ?? false,
                        onChanged: (DropdownItem? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedValue = newValue;
                            });
                            widget.selectedIndexChanged(newValue.id);
                            state.didChange(newValue);
                          }
                        },
                        items: _dropdownItemList!
                            .map<DropdownMenuItem<DropdownItem>>(
                                (DropdownItem data) {
                          return DropdownMenuItem<DropdownItem>(
                              value: data,
                              child: Text(data.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          color: grayTextColor,
                                          fontSize: 14,
                                          fontFamily: 'Arial Rounded MT Bold',
                                          fontWeight: FontWeight.w400)));
                        }).toList()))),
          );
        },
        validator: (val) {
          return val == null ? widget.validatorTextKey : null;
        });
  }
}

class DropdownItem {
  final String id;
  final String name;
  bool operator ==(o) => o is DropdownItem && o.id == id;
  int get hashCode => id.hashCode;
  DropdownItem({required this.id, required this.name});

  static DropdownItem fromJson(Map<String, dynamic> data) {
    return DropdownItem(id: data['id'], name: data['name']);
  }
}
