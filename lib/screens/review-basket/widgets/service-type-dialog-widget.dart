import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gem_consumer_app/screens/search/widgets/selection-button.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/forms/datetime_form_field.dart';
import 'package:gem_consumer_app/widgets/forms/dropdown_form_field.dart';

class ServiceTypeDialogWidget extends StatefulWidget {
  ServiceTypeDialogWidget(
    this.initialEventCriteria,
    this.outlet,
    this.setDeliveryInfo,
  );

  final Map<String, dynamic> outlet;
  final Function setDeliveryInfo;
  final Map<String, dynamic>? initialEventCriteria;

  @override
  _ServiceTypeDialogWidgetState createState() =>
      _ServiceTypeDialogWidgetState();
}

class _ServiceTypeDialogWidgetState extends State<ServiceTypeDialogWidget> {
  final dateFormat = DateFormat('dd MMMM yyyy');
  late List<Widget> collectionTypes;
  List<String> _selectedCollectionType = [];
  List<Map<String, dynamic>> deliveryTimeList = [];
  DateTime? _selectedDeliveryDate;
  String? _selectedDeliveryTime;
  String? _selectedRemark;
  TimeOfDay currentTime = TimeOfDay.now();

  @override
  void initState() {
    if (widget.initialEventCriteria != null) {
      if (widget.initialEventCriteria!['deliveryType'] != null &&
          widget.initialEventCriteria!['deliveryType'].length > 0) {
        _selectedCollectionType = widget.initialEventCriteria!['deliveryType'];
      }
      if (widget.initialEventCriteria!['deliveryDate'] != null) {
        _selectedDeliveryDate = widget.initialEventCriteria!['deliveryDate'];
      }
      if (widget.initialEventCriteria!['deliveryTime'] != null) {
        _selectedDeliveryTime = widget.initialEventCriteria!['deliveryTime'];
      }
      if (widget.initialEventCriteria!['remark'] != null) {
        _selectedRemark = widget.initialEventCriteria!['remark'];
      }
    }
    collectionTypes = List.generate(
        widget.outlet['collectionTypes'].toList().length, (int index) {
      String name = "";
      if (widget.outlet['collectionTypes'][index]['type'] == "DELIVERY") {
        name = "Delivery";
      } else if (widget.outlet['collectionTypes'][index]['type'] == "PICKUP") {
        name = "Pick Up";
      } else if (widget.outlet['collectionTypes'][index]['type'] == "DINE_IN") {
        name = "Dine In";
      }
      return SelectionButton(name, _selectedCollectionType,
          selected: _selectedCollectionType.contains(name));
    });
    // TODO: get from outlet collection type order slot
    deliveryTimeList = [
      {'id': '06:00', 'name': '06:00'},
      {'id': '06:30', 'name': '06:30'},
      {'id': '07:00', 'name': '07:00'}
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.83,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('ServiceType.UpdateEventCriteria',
                        style: Theme.of(context).textTheme.headline2)
                    .tr(),
                SizedBox(height: 30.0),
                Text('ServiceType.Title',
                        style: Theme.of(context).textTheme.subtitle2)
                    .tr(),
                SizedBox(height: 20.0),
                Wrap(children: collectionTypes),
                SizedBox(height: 20.0),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('ServiceType.DeliveryDate',
                              style: Theme.of(context).textTheme.subtitle2)
                          .tr(),
                      SizedBox(height: 10),
                      DateTimeFormField(
                          isCenterText: false,
                          initialValue: _selectedDeliveryDate != null
                              ? _selectedDeliveryDate
                              : null,
                          setValue: (DateTime date) {
                            setState(() {
                              _selectedDeliveryDate = date;
                            });
                          },
                          isButtonDisabled: false,
                          dateStr: _selectedDeliveryDate != null
                              ? dateFormat.format(_selectedDeliveryDate!)
                              : "Select Delivery Date"),
                    ]),
                SizedBox(height: 20.0),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('ServiceType.DeliveryTime',
                              style: Theme.of(context).textTheme.subtitle2)
                          .tr(),
                      SizedBox(height: 10.0),
                      DropdownFormField(
                          initialValue: _selectedDeliveryTime != null
                              ? {'id': _selectedDeliveryTime}
                              : null,
                          fillColor: lightPrimaryColor,
                          isDense: true,
                          dropDownItemList: deliveryTimeList,
                          selectedIndexChanged: (String value) {
                            setState(() {
                              _selectedDeliveryTime = value;
                            });
                          },
                          initialTextKey: 'General.SelectOptions')
                    ]),
                SizedBox(height: 20.0),
                Text("ServiceType.ItemNotAvailableMsg",
                        style: TextStyle(
                          fontFamily: 'Arial',
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left)
                    .tr(),
                SizedBox(height: 20.0),
                DropdownFormField(
                    initialValue: _selectedRemark != null
                        ? {'id': _selectedRemark}
                        : null,
                    fillColor: lightPrimaryColor,
                    isDense: true,
                    dropDownItemList: [
                      {'id': '0', 'name': 'Remove it From My Order'},
                      {'id': '1', 'name': 'Cancel Entire Order'},
                      {'id': '2', 'name': 'Call Me'}
                    ],
                    selectedIndexChanged: (String value) {
                      setState(() {
                        _selectedRemark = value;
                      });
                    },
                    initialTextKey: 'General.SelectOptions'),
                SizedBox(height: 30.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24.0),
                        primary: Color.fromRGBO(0, 0, 0, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                    onPressed: () {
                      widget.setDeliveryInfo({
                        "deliveryType": _selectedCollectionType,
                        "deliveryDate": _selectedDeliveryDate,
                        "deliveryTime": _selectedDeliveryTime,
                        "remark": _selectedRemark
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('Button.UpdateCap',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(color: Colors.white))
                              .tr()
                        ])),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24.0),
                        primary: Color.fromRGBO(228, 229, 229, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                    onPressed: () {
                      setState(() {
                        _selectedCollectionType = [];
                        _selectedDeliveryDate = null;
                        _selectedDeliveryTime = null;
                        _selectedRemark = null;
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('Button.Reset',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(color: Colors.black))
                              .tr()
                        ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
