import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';

class OptionRadioFormField extends StatefulWidget {
  final String validatorTextKey;
  final String? productId;
  final String? addonId;
  final List<dynamic> options;
  final UserCartItem selectedItem;
  final Function selectedRadio;
  final int minimumSelectItem;
  final bool isEnableSST;

  const OptionRadioFormField(
      {Key? key,
      required this.options,
      required this.selectedRadio,
      required this.selectedItem,
      this.productId,
      required this.validatorTextKey,
      required this.minimumSelectItem,
      required this.isEnableSST,
      this.addonId})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<OptionRadioFormField> {
  String? _selectedRadio;

  @override
  void initState() {
    if (widget.selectedItem.addOns.length > 0) {
      widget.selectedItem.addOns.forEach((element) {
        if (widget.addonId == element.addonId) {
          _selectedRadio = element.addOnOptionsId;
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            widget.selectedRadio(element.addOnOptionsId, widget.productId,
                widget.addonId, element.addOnPriceWhenAdded);
          });
        }
      });
    }
    super.initState();
  }

  Widget _generateRadioListTiles() {
    if (widget.options.length == 0) {
      return Container(width: 0.0, height: 0.0);
    }

    return FormField<String>(
        initialValue: _selectedRadio ?? null,
        builder: (FormFieldState<String> state) {
          return InputDecorator(
              decoration: InputDecoration(
                isCollapsed: true,
                isDense: true,
                border: InputBorder.none,
                errorText: state.hasError ? state.errorText : null,
              ),
              child: Material(
                  color: Colors.white,
                  child: Column(
                      children: List<RadioListTile<String>>.generate(
                          widget.options.length, (int index) {
                    return RadioListTile<String>(
                        toggleable: true,
                        contentPadding: EdgeInsets.zero,
                        tileColor: Colors.white,
                        dense: true,
                        value: widget.options[index]['id'],
                        groupValue: _selectedRadio,
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
                              SizedBox(width: 8,),
                              Text(
                                  '+${StringHelper.formatCurrency((widget.options[index]['price'] + (widget.isEnableSST ? widget.options[index]['price'] * 0.06 : 0)))}',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ))
                            ]),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRadio = value;
                          });
                          widget.selectedRadio(_selectedRadio, widget.productId,
                              widget.addonId, widget.options[index]['price']);
                          state.didChange(value);
                        });
                  }))));
        },
        validator: (val) {
          if (widget.minimumSelectItem > 0 &&
              (_selectedRadio == null || _selectedRadio!.isEmpty)) {
            return widget.validatorTextKey;
          }

          return null;
        });
  }

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (oldWidget.productId != widget.productId) {
      _selectedRadio = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _generateRadioListTiles();
  }
}
