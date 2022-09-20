import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';

class OptionCheckboxFormField extends StatefulWidget {
  final String? validatorTextKey;
  final String? productId;
  final String? addonId;
  final List<dynamic> options;
  final UserCartItem selectedItem;
  final int maximumSelectItem;
  final int minimumSelectItem;
  final Function checkBoxesFunction;
  final bool isEnableSST;

  const OptionCheckboxFormField(
      {Key? key,
      required this.options,
      required this.maximumSelectItem,
      required this.minimumSelectItem,
      required this.checkBoxesFunction,
      required this.selectedItem,
      this.productId,
      this.validatorTextKey,
      required this.isEnableSST,
      this.addonId})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<OptionCheckboxFormField> {
  List _selectedCheckboxes = [];
  List<Map<String, dynamic>> _selectedCheckboxesWithPrice = [];
  bool isSelectOverMaximumNumber = false;

  @override
  void initState() {
    if (widget.selectedItem.addOns.length > 0) {
      widget.selectedItem.addOns.forEach((addOn) {
        if (widget.addonId == addOn.addonId) {
          _selectedCheckboxes.add(addOn.addOnOptionsId);
          _selectedCheckboxesWithPrice.add({
            'id': addOn.addOnOptionsId,
            'price': addOn.addOnPriceWhenAdded,
            'addonId': widget.addonId
          });
        }
      });
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      widget.checkBoxesFunction(_selectedCheckboxes,
          _selectedCheckboxesWithPrice, widget.productId, widget.addonId, true);
    });
    super.initState();
  }

  void _handleValueChange(bool selected, String selectedId, dynamic price) {
    if (selected == true &&
        _selectedCheckboxes.length >= widget.maximumSelectItem) {
      setState(() {
        isSelectOverMaximumNumber = true;
      });
    } else {
      isSelectOverMaximumNumber = false;
      setState(() {
        if (selected) {
          _selectedCheckboxes.add(selectedId);
          _selectedCheckboxesWithPrice.add(
              {'id': selectedId, 'price': price, 'addonId': widget.addonId});
        } else {
          _selectedCheckboxes.remove(selectedId);
          _selectedCheckboxesWithPrice.removeWhere(
              (Map<String, dynamic> item) => item['id'] == selectedId);
        }
      });
      widget.checkBoxesFunction(_selectedCheckboxes,
          _selectedCheckboxesWithPrice, widget.productId, widget.addonId, true);
    }
  }

  _generateCheckboxListTiles() {
    if (widget.options.length == 0) {
      return Container(width: 0.0, height: 0.0);
    }

    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
          decoration: InputDecoration(
            isCollapsed: true,
            isDense: true,
            border: InputBorder.none,
            errorStyle: TextStyle(
                color: Colors.red, fontWeight: FontWeight.w600, fontSize: 11),
            errorText: state.hasError ? state.errorText : null,
          ),
          child: Material(
              color: Colors.white,
              child: Column(
                  children: List<CheckboxListTile>.generate(
                      widget.options.length, (int index) {
                return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _selectedCheckboxes
                        .contains(widget.options[index]['id']),
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(widget.options[index]['name'],
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                )),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                              '+${StringHelper.formatCurrency((widget.options[index]['price'] + (widget.isEnableSST ? widget.options[index]['price'] * 0.06 : 0)))}',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ))
                        ]),
                    onChanged: (bool? selected) {
                      if (selected != null) {
                        _handleValueChange(
                            selected,
                            widget.options[index]['id'],
                            widget.options[index]['price']);
                      }
                    });
              }))));
    }, validator: (val) {
      return _selectedCheckboxes.length < widget.minimumSelectItem
          ? widget.validatorTextKey
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isSelectOverMaximumNumber
            ? Text(
                'Product.MaximumSelectedError'.tr(),
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 11),
              )
            : SizedBox(),
        _generateCheckboxListTiles()
      ],
    );
  }
}
