import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../../models/Product.dart';
import '../../../models/UserCartItem.dart';
import '../../../providers/add-to-cart-items.dart';
import '../../../providers/auth.dart';
import '../../../configuration.dart';
import '../../../models/UserAddress.dart';
import '../../../providers/auth.dart';
import '../../../providers/plan-a-party.dart';
import '../../../screens/celebration/gql/celebration.gql.dart';
import '../../../screens/party/plan_a_party_address_list_page.dart';
import '../../../screens/party/widgets/chip-form.dart';
import '../../../screens/user-address-page/gql/address.gql.dart';
import '../../../values/color-helper.dart';
import '../../../widgets/forms/datetime_form_field.dart';
import 'package:collection/collection.dart';
import '../../../widgets/loading_controller.dart';
import '../../../widgets/location_not_found.dart';

class PopUpDialogDeliveryWidget extends StatefulWidget {
  PopUpDialogDeliveryWidget(
      this.productMap, this.selectedProduct, this.confirmFunction);

  final Function confirmFunction;
  final Map productMap;
  final UserCartItem selectedProduct;
  final Map<String, String> dataList = {
    "DINE_IN": "Dine In",
    "DELIVERY": "Delivery",
    "PICKUP": "Pick Up"
  };

  @override
  _PopUpDialogDeliveryWidgetState createState() =>
      _PopUpDialogDeliveryWidgetState();
}

class _PopUpDialogDeliveryWidgetState extends State<PopUpDialogDeliveryWidget> {
  final dateFormat = DateFormat('dd MMM yyyy');

  //String collectionTypes;
  List<String> _selectedCollectionType = [];
  List<Map<String, dynamic>> timeList = List.empty(growable: true);
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _tempSelectedTime;
  late Auth auth;
  late AddToCartItems userCart;

  //String _selectedRemark;
  //TimeOfDay currentTime = TimeOfDay.now();
  DateTime currentDateTime = DateTime.now();
  late Position position;
  late UserAddress currentUserLocation;
  late UserAddress deliveryLocation;
  late PlanAParty event;
  List productCollectionTypes = List.empty(growable: true);

  @override
  void initState() {
    event = context.read<PlanAParty>();
    auth = context.read<Auth>();
    userCart = context.read<AddToCartItems>();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Map types = groupBy(widget.productMap["collectionTypes"], (obj) {
      obj = obj as Map;
      return obj['type'];
    });
    productCollectionTypes = types.keys.toList();

    return Material(
      color: Colors.transparent,
      child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16), topLeft: Radius.circular(16))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text("Service Type",
                      style: Theme.of(context).textTheme.headline3),
                  Spacer(),
                  Container(
                    height: 36.0,
                    width: 36.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(0, 1)),
                        ]),
                    child: IconButton(
                        icon: Icon(
                          Icons.close,
                        ),
                        iconSize: 18.0,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Wrap(
                direction: Axis.horizontal,
                children: List.generate(
                    productCollectionTypes.length,
                    (index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedCollectionType.length > 0) {
                                  if (_selectedCollectionType.contains(
                                      productCollectionTypes
                                          .elementAt(index))) {
                                    _selectedCollectionType.clear();
                                    timeList.clear();
                                    _selectedDate = null;
                                    _selectedTime = null;
                                  } else {
                                    _selectedCollectionType.clear();
                                    timeList.clear();
                                    _selectedDate = null;
                                    _selectedTime = null;
                                    _selectedCollectionType.add(
                                        productCollectionTypes
                                            .elementAt(index));
                                    widget.selectedProduct.serviceDate =
                                        _selectedCollectionType[0];
                                  }
                                } else {
                                  _selectedCollectionType.add(
                                      productCollectionTypes.elementAt(index));
                                  widget.selectedProduct.serviceDate =
                                      _selectedCollectionType[0];
                                }
                              });
                            },
                            child: Chip(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              backgroundColor: _selectedCollectionType.contains(
                                      productCollectionTypes.elementAt(index))
                                  ? Color(0xFFFDC400)
                                  : Colors.grey[200],
                              label: Text(
                                widget.dataList[productCollectionTypes
                                        .elementAt(index)] ??
                                    '',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Arial',
                                        fontSize: 16),
                              ),
                            ),
                          ),
                        )),
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: _selectedCollectionType.contains("DELIVERY"),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Celebration.DeliverTo",
                              style: Theme.of(context).textTheme.headline3)
                          .tr(),
                      SizedBox(
                        height: 10,
                      ),
                      Chip(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        backgroundColor: Colors.grey[200],
                        label: Query(
                            options: QueryOptions(
                                document: gql(AddressGQL.GET_USER_ADDRESSES),
                                variables: {'userId': auth.currentUser.id}),
                            builder: (QueryResult result,
                                {VoidCallback? refetch, FetchMore? fetchMore}) {
                              if (result.hasException) {
                                return Text(
                                  result.exception.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(fontWeight: FontWeight.normal),
                                );
                              }
                              if (result.isLoading) {
                                return LoadingController();
                              }
                              if (result.data != null) {
                                Map<String, dynamic>? defaultAddress;
                                List tempList =
                                    List.from(result.data!["UserAddresses"]);
                                if (tempList.length > 0) {
                                  if (tempList
                                      .map((e) => e["isDefault"])
                                      .contains(true)) {
                                    defaultAddress = tempList.firstWhere(
                                        (element) =>
                                            element["isDefault"] == true);
                                    if (defaultAddress == null) {
                                      deliveryLocation = UserAddress(
                                        id: defaultAddress!["id"],
                                        name: defaultAddress["name"],
                                        address1: defaultAddress["address1"],
                                        address2: defaultAddress["address2"],
                                        notes: defaultAddress["notes"],
                                        state: defaultAddress["state"],
                                        city: defaultAddress["city"],
                                        postalCode:
                                            defaultAddress["postalCode"],
                                        longitude: defaultAddress["longitude"],
                                        latitude: defaultAddress["latitude"],
                                        isDefault: defaultAddress["isDefault"],
                                      );
                                    }
                                  }
                                  if (defaultAddress == null) {
                                    deliveryLocation = currentUserLocation;
                                  }
                                } else {
                                  deliveryLocation = currentUserLocation;
                                }

                                return deliveryLocation == null &&
                                        event.deliveryAddress == null
                                    ? Row(children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(deliveryLocation.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'Arial Rounded MT Bold',
                                                        fontSize: 16,
                                                      )),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(deliveryLocation.address1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .copyWith(
                                                          fontFamily: 'Arial',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12))
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        SvgPicture.asset(
                                          'assets/images/dropdown-button.svg',
                                          color: grayTextColor,
                                          width: 8,
                                          height: 8,
                                        )
                                      ])
                                    : Consumer<PlanAParty>(
                                        builder: (context, item, child) {
                                        return item.deliveryAddress != null
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context,
                                                      PlanAPartyAddressListPage
                                                          .routeName);
                                                },
                                                child: Row(children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                            item.deliveryAddress!
                                                                .name,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subtitle2!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'Arial Rounded MT Bold',
                                                                  fontSize: 16,
                                                                )),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        item.deliveryAddress !=
                                                                null
                                                            ? Text(
                                                                item.deliveryAddress!
                                                                    .address1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText1!
                                                                    .copyWith(
                                                                        fontFamily:
                                                                            'Arial',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontSize:
                                                                            12))
                                                            : Container(
                                                                width: 0.0,
                                                                height: 0.0),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 2),
                                                  SvgPicture.asset(
                                                    'assets/images/dropdown-button.svg',
                                                    color: grayTextColor,
                                                    width: 8,
                                                    height: 8,
                                                  )
                                                ]))
                                            : Container(width: 0, height: 0);
                                      });
                              }
                              return Container(width: 0.0, height: 0.0);
                            }),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
              ),
              Row(children: [
                Expanded(
                  flex: 1,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date",
                            style: Theme.of(context).textTheme.headline3),
                        SizedBox(height: 10),
                        DateTimeFormField(
                          initialValue: _selectedCollectionType.length > 0
                              ? _selectedDate
                              : null,
                          setValue: (DateTime date) {
                            setState(() {
                              widget.selectedProduct.serviceDate =
                                  date.toString();
                              timeList.clear();
                              _selectedDate = date;

                              _selectedTime = null;
                            });
                          },
                          dateStr: _selectedDate != null
                              ? dateFormat.format(_selectedDate!)
                              : "Select Date",
                          isButtonDisabled:
                              _selectedCollectionType.length > 0 ? false : true,
                        ),
                      ]),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Time",
                          style: Theme.of(context).textTheme.headline3),
                      SizedBox(
                        height: 10,
                      ),
                      Query(
                          options: QueryOptions(
                              variables: {
                                "productOutletId": widget.productMap["id"],
                                "selectedServiceType":
                                    _selectedCollectionType.length > 0
                                        ? _selectedCollectionType[0]
                                        : "",
                                "selectedDate": _selectedDate != null
                                    ? _selectedDate.toString()
                                    : null
                              },
                              document: gql(CelebrationGQL.GET_TIME_SLOTS),
                              fetchPolicy: FetchPolicy.cacheAndNetwork),
                          builder: (QueryResult result,
                              {VoidCallback? refetch, FetchMore? fetchMore}) {
                            if (result.data != null) {
                              timeList.clear();
                              result.data!['GetTimeSlot']['TimeSlotList']
                                  .forEach((key) {
                                timeList.add({
                                  'id': key.toString(),
                                  'name': key.toString()
                                });
                              });
                            }
                            if (timeList.length > 0 && _selectedDate != null) {
                              return InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (builder) {
                                          return Container(
                                            height: size.height * 0.35,
                                            child: Column(
                                              children: [
                                                Container(
                                                  color: Colors.grey[100],
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CupertinoButton(
                                                        child: Text(
                                                            'Button.Cancel'
                                                                .tr()),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 5.0,
                                                        ),
                                                      ),
                                                      CupertinoButton(
                                                        child: Text(
                                                            'Button.Confirm'
                                                                .tr()),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            _selectedTime =
                                                                _tempSelectedTime;
                                                            widget.selectedProduct
                                                                    .serviceTime =
                                                                _selectedTime
                                                                    .toString();
                                                          });
                                                        },
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 5.0,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: CupertinoPicker(
                                                    scrollController:
                                                        FixedExtentScrollController(
                                                            initialItem: timeList
                                                                .indexWhere((element) =>
                                                                    element[
                                                                        'name'] ==
                                                                    _selectedTime)),
                                                    itemExtent: 40,
                                                    children: <Widget>[
                                                      for (Map item in timeList)
                                                        Center(
                                                          child: Text(
                                                            item['id'],
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        )
                                                    ],
                                                    onSelectedItemChanged:
                                                        (value) {
                                                      _tempSelectedTime =
                                                          timeList[value]['id'];
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: ChipForm(
                                    text: _selectedTime ??
                                        'PlanAParty.HintTimePicker'.tr(),
                                  ));
                            } else {
                              return ChipForm(
                                text: "General.None".tr(),
                                isEnable: false,
                              );
                            }
                          }),
                    ],
                  ),
                )
              ]),
              SizedBox(height: 50),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24.0),
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0))),
                  onPressed: () {
                    //userCart.addToCartTesting(widget.selectedProduct);
                    var combineDateTime = new DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        TimeOfDay(
                                hour: int.parse(_selectedTime!.split(":")[0]),
                                minute: int.parse(_selectedTime!.split(":")[1]))
                            .hour,
                        TimeOfDay(
                                hour: int.parse(_selectedTime!.split(":")[0]),
                                minute: int.parse(_selectedTime!.split(":")[1]))
                            .minute);
                    //Insert here
                    widget.confirmFunction({
                      "createCartItemInput": {
                        "userId": auth.currentUser.id,
                        "productOutletId": widget
                            .selectedProduct.outletProductInformation["id"],
                        "quantity": widget.selectedProduct.quantity,
                        "currentDeliveryAddress":
                            _selectedCollectionType[0] == "DELIVERY"
                                ? deliveryLocation.address1
                                : null,
                        "latitude": _selectedCollectionType[0] == "DELIVERY"
                            ? deliveryLocation.latitude
                            : null,
                        "longitude": _selectedCollectionType[0] == "DELIVERY"
                            ? deliveryLocation.longitude
                            : null,
                        "remarks": widget.selectedProduct.specialInstructions,
                        "priceWhenAdded": widget.selectedProduct.priceWhenAdded,
                        "collectionType": _selectedCollectionType[0],
                        "serviceDateTime":
                            DateFormat("y-MM-d HH:mm").format(combineDateTime),
                        "isDeliveredToVenue": false,
                      }
                    });
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('Button.Done',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Arial Rounded MT Bold',
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )).tr()
                      ])),
              SizedBox(height: 10),
            ],
          )),
    );
  }

  getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    var addresses = await Geocoder.google(Configuration.ANDROID_API_KEY)
        .findAddressesFromCoordinates(
            Coordinates(position.latitude, position.longitude));
    if (addresses.isEmpty) {
      errorDialog(
        errorMessage: 'We are unable to get your current address. Try later.',
        okButtonAction: () {},
        context: context,
        okButtonText: 'OK',
      );
      return;
    }
    if (addresses.length > 0) {
      var useAddress = addresses[0];

      setState(() {
        currentUserLocation = UserAddress(
            id: '000',
            name: 'UserAddressPage.CurrentLocation'.tr(),
            address1: useAddress.featureName,
            address2: '',
            postalCode: useAddress.postalCode,
            city: useAddress.subAdminArea ?? useAddress.locality,
            state: useAddress.adminArea,
            longitude: position.longitude,
            latitude: position.latitude);
      });
    }
  }
}
