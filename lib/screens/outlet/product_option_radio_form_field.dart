import 'package:flutter/material.dart';
import 'package:gem_consumer_app/helpers/string-helper.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';

class ProductOptionRadioFormField extends StatefulWidget {
  final String validatorTextKey;
  final String? productId;
  final String? addonId;
  final List<dynamic> options;

  final int minimumSelectItem;
  final bool isEnableSST;

  const ProductOptionRadioFormField(
      {Key? key,
      required this.options,
      this.productId,
      required this.validatorTextKey,
      required this.minimumSelectItem,
      required this.isEnableSST,
      this.addonId})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ProductOptionRadioFormField> {
  String? _selectedRadio;

  @override
  void initState() {
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
                children: List<ListTile>.generate(
                  widget.options.length,
                  (int index) {
                    return ListTile(
                      //toggleable: true,
                      contentPadding: EdgeInsets.zero,
                      tileColor: Colors.white,
                      dense: true,
                      // value: widget.options[index]['id'],
                      // groupValue: _selectedRadio,
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
                    );
                  },
                ),
              ),
            ),
          );
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
