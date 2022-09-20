import 'package:flutter/material.dart';

class CascadeDropdownFormField extends StatefulWidget {
  final String? validatorTextKey;
  final String initialTextKey;
  final Map<String, dynamic>? initialValue;
  final String? parentId;
  final List<Map<String, dynamic>> dropDownItemList;
  final Function selectedIndexChanged;

  const CascadeDropdownFormField(
      {Key? key,
      this.validatorTextKey,
      this.initialValue,
      required this.dropDownItemList,
      required this.selectedIndexChanged,
      required this.initialTextKey,
      this.parentId})
      : super(key: key);
  @override
  _CascadeDropdownFormFieldState createState() =>
      _CascadeDropdownFormFieldState();
}

class _CascadeDropdownFormFieldState extends State<CascadeDropdownFormField> {
  CascadeDropdownItem? _selectedValue;
  late List<CascadeDropdownItem> _dropdownItemList;

  @override
  void initState() {
    _selectedValue = widget.initialValue != null
        ? CascadeDropdownItem.fromJson(widget.initialValue!)
        : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dropdownItemList = widget.dropDownItemList.map((item) {
      return CascadeDropdownItem.fromJson(item);
    }).toList();
    return FormField<CascadeDropdownItem>(
        initialValue: _selectedValue ?? null,
        builder: (FormFieldState<CascadeDropdownItem> state) {
          return InputDecorator(
            decoration: InputDecoration(
              errorText: state.hasError ? state.errorText : null,
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<CascadeDropdownItem>(
                    isExpanded: true,
                    hint: Text(widget.initialTextKey,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Theme.of(context).hintColor)),
                    value: _selectedValue,
                    isDense: false,
                    onChanged: (CascadeDropdownItem? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedValue = newValue;
                        });
                        widget.selectedIndexChanged(newValue.id);
                        state.didChange(newValue);
                      }
                    },
                    items: _dropdownItemList
                        .map<DropdownMenuItem<CascadeDropdownItem>>(
                            (CascadeDropdownItem data) {
                      return DropdownMenuItem<CascadeDropdownItem>(
                          value: data,
                          child: Text(data.name,
                              style: Theme.of(context).textTheme.bodyText2));
                    }).toList())),
          );
        },
        validator: (val) {
          return _selectedValue == null ? widget.validatorTextKey : null;
        });
  }

  @override
  void didUpdateWidget(CascadeDropdownFormField oldWidget) {
    if (oldWidget.parentId != widget.parentId) {
      _selectedValue = null;
    }
    super.didUpdateWidget(oldWidget);
  }
}

class CascadeDropdownItem {
  final String id;
  final String parentId;
  final String name;
  bool operator ==(o) => o is CascadeDropdownItem && o.id == id;
  int get hashCode => id.hashCode;
  CascadeDropdownItem(
      {required this.id, required this.parentId, required this.name});

  static CascadeDropdownItem fromJson(Map<String, dynamic> data) {
    return CascadeDropdownItem(
        id: data['id'], parentId: data['parentId'], name: data['name']);
  }
}
