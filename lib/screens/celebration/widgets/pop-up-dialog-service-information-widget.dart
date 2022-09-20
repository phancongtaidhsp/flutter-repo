import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/api-client.dart';
import 'package:gem_consumer_app/configuration.dart';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/providers/user-position-provider.dart';
import 'package:gem_consumer_app/screens/user-address-page/widgets/pop-up-set-location-service.dart';
import 'package:location/location.dart' as loca;
import '../../../screens/celebration/celebration_homepage.dart';
import '../../../screens/party/plan_a_party_address_list_page.dart';
import '../../../screens/party/widgets/chip-form.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:geocoder/geocoder.dart';
import '../../../values/color-helper.dart';
import '../../../widgets/loading_controller.dart';
import '../../../widgets/location_not_found.dart';
import '../../../widgets/submit-button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class PopUpDialogServiceInformationWidget extends StatefulWidget {
  @override
  _PopUpDialogServiceInformationWidgetState createState() =>
      _PopUpDialogServiceInformationWidgetState();
}

class _PopUpDialogServiceInformationWidgetState
    extends State<PopUpDialogServiceInformationWidget> {
  late Auth auth;
  late UserPositionProvider positionProvider;
  late Position position;
  late AddToCartItems cart;

  UserAddress? currentUserLocation;
  UserAddress? deliveryLocation;

  List<String> _selectedCollectionType = [];
  DateTime? _dateSelected;
  TimeOfDay? _timeSelected;
  bool isNumberOfPAXInvalid = false;
  bool isServiceTypeSelected = false;
  int numberOfPAX = 0;
  bool isTouchedDate = false;
  bool isTouchedTime = false;
  var _isAddressLoading = true;

  bool isGetDeliveryAddressFirstTime = true;
  TextEditingController _controller = TextEditingController();

  List collectionTypes = ["DINE_IN", "DELIVERY", "PICKUP"];
  Map<String, String> dataList = {
    "DINE_IN": "Dine In",
    "DELIVERY": "Delivery",
    "PICKUP": "Pick Up"
  };

  loca.Location location = new loca.Location();
  late bool _serviceEnabled;

  Future<void> _showIOSDateTimePicker(BuildContext ctx,
      {required bool timeOnly}) async {
    await showIOSDatePicker(
      context: context,
      timeOnly: timeOnly,
      minimumYear: DateTime.now().year,
      initialDateTime: _dateSelected == null ? DateTime.now() : _dateSelected!,
      minimumDate: DateTime.now(),
      maximumDate: DateTime.now().add(const Duration(days: 60)),
      onDateTimeChanged: (val) {
        if (!timeOnly) {
          setState(() {
            _dateSelected = val;
          });
        } else {
          setState(() {
            _timeSelected = TimeOfDay.fromDateTime(val);
          });
        }
      },
    );
  }

  @override
  void initState() {
    auth = context.read<Auth>();
    cart = context.read<AddToCartItems>();
    positionProvider = context.read<UserPositionProvider>();
    _controller.text = "0";
    _selectedCollectionType.add(collectionTypes[0]); //set default service type
    checkPermission();
    checkServiceEnabled();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
                  Text("Celebration.ServiceType",
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(fontWeight: FontWeight.normal))
                      .tr(),
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
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1)),
                          ]),
                      child: IconButton(
                          icon:
                              SvgPicture.asset('assets/images/icon-close.svg'),
                          iconSize: 36.0,
                          onPressed: () {
                            Navigator.pop(context);
                          }))
                ],
              ),
              SizedBox(height: 22),
              Wrap(
                direction: Axis.horizontal,
                children: List.generate(
                    collectionTypes.length,
                    (index) => Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              changeType(index);
                            },
                            child: Chip(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              backgroundColor: _selectedCollectionType.contains(
                                      collectionTypes.elementAt(index))
                                  ? lightPrimaryColor
                                  : Colors.grey[200],
                              label: Text(
                                dataList[collectionTypes.elementAt(index)] ??
                                    '',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Arial',
                                        fontSize: 15),
                              ),
                            ),
                          ),
                        )),
              ),
              SizedBox(height: 10),
              Visibility(
                visible: _selectedCollectionType.contains("DELIVERY"),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Celebration.DeliverTo",
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 20,
                            fontFamily: 'Arial Rounded MT Bold',
                            fontWeight: FontWeight.w400),
                      ).tr(),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PlanAPartyAddressListPage()))
                              .then((value) {
                            if (value != null) {
                              setState(() {
                                deliveryLocation = value;
                                cart.deliveryLocation = value;
                              });
                            }
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(40)),
                          child: _isAddressLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : deliveryLocation != null
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(deliveryLocation!.name,
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
                                              Text(deliveryLocation!.address1,
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
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text('',
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
                                              Text('',
                                                  textAlign: TextAlign.center,
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
                                      ],
                                    ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PlanAParty.Date'.tr(),
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 20,
                              fontFamily: 'Arial Rounded MT Bold',
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                            onTap: () async {
                              if (Platform.isAndroid) {
                                showDatePicker(
                                    context: context,
                                    initialDate: _dateSelected == null
                                        ? DateTime.now()
                                        : _dateSelected!,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 60)),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child ??
                                            SizedBox(
                                              width: 0,
                                            ),
                                      );
                                    }).then((value) {
                                  setState(() {
                                    _dateSelected = value;
                                  });
                                });
                              } else {
                                await _showIOSDateTimePicker(context,
                                    timeOnly: false);
                              }
                            },
                            child: ChipForm(
                                text: _dateSelected != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_dateSelected!)
                                    : 'PlanAParty.HintDatePicker'.tr())),
                        SizedBox(height: 4),
                        isTouchedDate && (_dateSelected == null)
                            ? Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Validation.Required',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontFamily: 'Arial Rounded MT Bold'),
                                ).tr(),
                              )
                            : Container(width: 0.0, height: 0.0),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PlanAParty.Time'.tr(),
                          style: TextStyle(
                              color: grayTextColor,
                              fontSize: 20,
                              fontFamily: 'Arial Rounded MT Bold',
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                            onTap: () async {
                              if (Platform.isAndroid) {
                                showTimePicker(
                                    context: context,
                                    initialTime: _timeSelected != null
                                        ? _timeSelected!
                                        : TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child ??
                                            SizedBox(
                                              width: 0,
                                            ),
                                      );
                                    }).then((value) {
                                  setState(() {
                                    _timeSelected = value;
                                  });
                                });
                              } else {
                                await _showIOSDateTimePicker(context,
                                    timeOnly: true);
                              }
                            },
                            child: ChipForm(
                                text: _timeSelected != null
                                    ? convertTime(_timeSelected!)
                                    : 'PlanAParty.HintTimePicker'.tr())),
                        SizedBox(height: 4),
                        isTouchedTime && _timeSelected == null
                            ? Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  'Validation.Required',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontFamily: 'Arial Rounded MT Bold'),
                                ).tr(),
                              )
                            : Container(width: 0.0, height: 0.0),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Text(
                'PlanAParty.NumberPAX'.tr(),
                style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 20,
                    fontFamily: 'Arial Rounded MT Bold',
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 10),
              _buildNumberPAX(
                  controller: _controller,
                  minusFunction: () {
                    setState(() {
                      try {
                        numberOfPAX = int.parse(_controller.text);
                        if (_controller.text == "") {
                          numberOfPAX = 0;
                        }
                        numberOfPAX--;
                        if (numberOfPAX < 0) {
                          numberOfPAX = 0;
                        }
                        _controller.text = numberOfPAX.toString();
                        _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: _controller.text.length));
                        isNumberOfPAXInvalid = false;
                      } catch (error) {
                        isNumberOfPAXInvalid = true;
                      }
                    });
                  },
                  plusFunction: () {
                    setState(() {
                      try {
                        numberOfPAX = int.parse(_controller.text);
                        if (_controller.text == "") {
                          numberOfPAX = 0;
                        }
                        numberOfPAX++;
                        _controller.text = numberOfPAX.toString();
                        _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: _controller.text.length));
                        isNumberOfPAXInvalid = false;
                      } catch (error) {
                        isNumberOfPAXInvalid = true;
                      }
                    });
                  }),
              SizedBox(height: 6),
              isNumberOfPAXInvalid
                  ? Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Validation.InvalidNumber',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Arial Rounded MT Bold'),
                      ).tr(),
                    )
                  : Container(width: 0.0, height: 0.0),
              SizedBox(height: 30),
              SubmitButton(
                text: 'Celebration.Explore',
                isUppercase: true,
                rippleColor: Colors.white,
                textColor: Colors.white,
                backgroundColor: Colors.black,
                onPressed: () async {
                  await location.hasPermission().then((value) {
                    if (value != loca.PermissionStatus.granted) {
                      print("Permission granted");
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => Dialog(
                          child: PopUpSetLocationService(),
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.all(24),
                        ),
                      ).then((value) {
                        setState(() {});
                      });
                    } else {
                      numberOfPAX = int.parse(_controller.text);
                      if (_timeSelected == null) {
                        isTouchedTime = true;
                      }

                      if (_dateSelected == null) {
                        isTouchedDate = true;
                      }

                      if (_controller.text.isNotEmpty) {
                        numberOfPAX = int.parse(_controller.text);
                        if (numberOfPAX < 1) {
                          isNumberOfPAXInvalid = true;
                        } else {
                          isNumberOfPAXInvalid = false;
                        }
                      } else {
                        isNumberOfPAXInvalid = true;
                      }

                      if (_selectedCollectionType.isNotEmpty &&
                          _selectedCollectionType.length > 0) {
                        isServiceTypeSelected = true;
                      }

                      setState(() {
                        if (_selectedCollectionType.length > 0) {
                          if ((!isNumberOfPAXInvalid &&
                                  isServiceTypeSelected &&
                                  !(_selectedCollectionType[0] ==
                                      "DELIVERY")) ||
                              (_selectedCollectionType[0] == "DELIVERY" &&
                                  deliveryLocation != null &&
                                  isServiceTypeSelected &&
                                  !isNumberOfPAXInvalid)) {
                            cart.selectedServiceType =
                                _selectedCollectionType[0];
                            cart.selectedDate = _dateSelected;
                            cart.selectedTime = _timeSelected;
                            cart.numberOfPax = numberOfPAX;
                            Navigator.pushNamed(
                                context, CelebrationHomePage.routeName,
                                arguments: CelebrationHomePageArguments(
                                    _selectedCollectionType[0],
                                    _dateSelected!,
                                    _timeSelected!,
                                    numberOfPAX,
                                    selectedAddress: deliveryLocation));
                          } else {
                            print('invalid');
                          }
                        }
                      });
                    }
                    return value;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPAX(
      {required TextEditingController controller,
      required Function minusFunction,
      required Function plusFunction}) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23.0), color: lightPrimaryColor),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: Material(
              shape: CircleBorder(),
              color: Colors.white,
              child: InkWell(
                onTap: () => minusFunction(),
                customBorder: CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: SvgPicture.asset(
                    'assets/images/minus.svg',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grayTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arial Rounded MT Bold',
              ),
              onTap: () {
                controller.clear();
              },
              controller: controller,
              decoration: InputDecoration(
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
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Material(
              shape: CircleBorder(),
              color: Colors.white,
              child: InkWell(
                onTap: () => plusFunction(),
                customBorder: CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      'assets/images/plus.svg',
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String convertTime(TimeOfDay timeOfDay) {
    final now = new DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

//isAddressLoading Set HERE
  getUserAddress() async {
    deliveryLocation =
        await APIClient.getAddress(auth.currentUser.id!); //API call
    if (deliveryLocation != null) {
      cart.deliveryLocation = deliveryLocation;
    } else {
      await getCurrentLocation();
    }
    setState(() {
      _isAddressLoading = false;
    });
  }

  checkServiceEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("serviceEnabled");
        return;
      }
    }
  }

  void changeType(int index) {
    setState(() {
      if (_selectedCollectionType.length > 0) {
        if (_selectedCollectionType
            .contains(collectionTypes.elementAt(index))) {
        } else {
          _selectedCollectionType.clear();
          _selectedCollectionType.add(collectionTypes.elementAt(index));
        }
      }
    });
  }

  checkPermission() async {
    await location.hasPermission().then((value) {
      if (value == loca.PermissionStatus.granted) {
        print("Permission granted");
        getUserAddress();
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => Dialog(
            child: PopUpSetLocationService(),
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(24),
          ),
        ).then((value) {
          setState(() {});
          getUserAddress();
        });
      }
      print("return Value  $value");
      return value;
    });
  }

  getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    positionProvider.setUserPosition(position);
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

      print(useAddress.postalCode);
      print('useAddress.postalCode');

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
          latitude: position.latitude,
        );
        cart.deliveryLocation = currentUserLocation;
        deliveryLocation = currentUserLocation;
      });
    }
  }
}
