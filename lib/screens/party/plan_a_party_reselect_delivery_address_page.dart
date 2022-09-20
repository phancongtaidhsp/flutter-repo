import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../configuration.dart';
import '../../widgets/location_not_found.dart';

import '../../models/UserAddress.dart';
import '../../providers/plan-a-party.dart';
import '../../values/color-helper.dart';
import '../../widgets/submit-button.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_pin_picker/map_pin_picker.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PlanAPartyReselectDeliveryAddressPage extends StatefulWidget {
  static String routeName = '/plan-a-party-reselect-delivery-page';

  final UserAddress userSelectedAddress;
  final Function refreshLocationOnMap;

  PlanAPartyReselectDeliveryAddressPage({
    required this.userSelectedAddress,
    required this.refreshLocationOnMap,
  });

  @override
  _PlanAPartyReselectDeliveryAddressPageState createState() =>
      _PlanAPartyReselectDeliveryAddressPageState();
}

class _PlanAPartyReselectDeliveryAddressPageState
    extends State<PlanAPartyReselectDeliveryAddressPage> {
  static String androidKey = Configuration.ANDROID_API_KEY;
  static String iosKey = Configuration.IOS_API_KEY;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;
  MapPickerController mapPickerController = MapPickerController();
  late CameraPosition cameraPosition1;
  Address? selectedAddress;

  late GoogleMapController googleMapController;

  List searchResult = [];

  final controller = FloatingSearchBarController();

  bool isAllowGoogleMapFetchAddress = true;

  late PlanAParty event;

  @override
  void initState() {
    super.initState();
    event = context.read<PlanAParty>();
    cameraPosition1 = CameraPosition(
      target: LatLng(widget.userSelectedAddress.latitude,
          widget.userSelectedAddress.longitude), //user's location
      zoom: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        child: _buildAppBar(),
        preferredSize: Size(double.infinity, 56),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Stack(
            fit: StackFit.expand,
            children: [
              MapPicker(
                  iconWidget: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 50,
                  ),
                  mapPickerController: mapPickerController,
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      new Factory<OneSequenceGestureRecognizer>(
                        () => new EagerGestureRecognizer(),
                      ),
                    ].toSet(),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: cameraPosition1,
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                    },
                    onCameraMoveStarted: () {
                      mapPickerController.mapMoving();
                    },
                    onCameraMove: (cameraPosition) {
                      cameraPosition1 = cameraPosition;
                    },
                    onCameraIdle: () async {
                      mapPickerController.mapFinishedMoving();

                      if (isAllowGoogleMapFetchAddress) {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => SpinKitFadingCircle(
                                  color: primaryColor,
                                  size: 42.0,
                                ));

                        List<Address> addresses =
                            await Geocoder.google(apiKey)
                                .findAddressesFromCoordinates(Coordinates(
                                    cameraPosition1.target.latitude,
                                    cameraPosition1.target.longitude));

                        if (addresses.isEmpty) {
                          errorDialog(
                            errorMessage:
                                'We are unable to get your current address. Try later.',
                            okButtonAction: () {},
                            context: context,
                            okButtonText: 'OK',
                          );
                          return;
                        }
                        print('selected latitude from this current');
                        print(
                            '${cameraPosition1.target.latitude} ${cameraPosition1.target.longitude}');
                        widget.refreshLocationOnMap(
                          cameraPosition1.target.latitude,
                          cameraPosition1.target.longitude,
                        );
                        selectedAddress = addresses[0];

                        controller.query = '${addresses[0].addressLine ?? ''}';

                        Navigator.pop(context);
                      } else {
                        isAllowGoogleMapFetchAddress = true;
                      }
                    },
                  )),
              buildFloatingSearchBar(),
              Align(
                widthFactor: size.width,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: size.width,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: SubmitButton(
                        text: "Button.Select",
                        textColor: Colors.white,
                        backgroundColor: Colors.black,
                        onPressed: () {
                          widget.userSelectedAddress.latitude =
                              selectedAddress!.coordinates.latitude;
                          widget.userSelectedAddress.longitude =
                              selectedAddress!.coordinates.longitude;
                          widget.userSelectedAddress.address1 =
                              selectedAddress!.featureName;
                          widget.userSelectedAddress.city =
                              selectedAddress!.subAdminArea ??
                                  selectedAddress!.locality;
                          widget.userSelectedAddress.state =
                              selectedAddress!.adminArea;
                          widget.userSelectedAddress.postalCode =
                              selectedAddress!.postalCode;

                          Navigator.pop(context, widget.userSelectedAddress);
                        }),
                  ),
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  void animateCamera(LatLng latLng) async {
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(latLng.latitude, latLng.longitude), zoom: 17)));
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      controller: controller,
      hint: 'Search...',
      closeOnBackdropTap: true,
      clearQueryOnClose: false,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
        _makeRequest(query);
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: searchResult.map((data) {
                return InkWell(
                  onTap: () async {
                    isAllowGoogleMapFetchAddress = false;
                    var addresses = await Geocoder.google(androidKey)
                        .findAddressesFromQuery(data['description']);
                    if (addresses.isEmpty) {
                      errorDialog(
                        errorMessage:
                            'We are unable to get your current address. Try later.',
                        okButtonAction: () {},
                        context: context,
                        okButtonText: 'OK',
                      );
                      return;
                    }
                    selectedAddress = addresses.first;
                    setState(() {
                      controller.query = data['description'];
                    });
                    animateCamera(LatLng(selectedAddress!.coordinates.latitude,
                        selectedAddress!.coordinates.longitude));

                    controller.hide();
                    controller.close();
                  },
                  child: Container(
                    height: 48,
                    padding: EdgeInsets.only(left: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(data['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                  fontWeight: FontWeight.w100,
                                  color: grayTextColor)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _makeRequest(input) async {
    searchResult.clear();

    String url =
        "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$input&key=$apiKey&language=en&types=geocode";

    // url += "&components=country:MY";

    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);

    if (json["error_message"] != null) {
      var error = json["error_message"];
      if (error == "This API project is not authorized to use this API.")
        error +=
            " Make sure the Places API is activated on your Google Cloud Platform";
      throw Exception(error);
    } else {
      final predictions = json["predictions"];
      setState(() {
        searchResult = predictions;
      });
      return predictions;
    }
  }

  Widget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: lightBack,
          statusBarIconBrightness: Brightness.light),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.grey[200],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.5,
                        blurRadius: 2,
                        offset: Offset(0, 1.5))
                  ]),
              child: IconButton(
                  icon: SvgPicture.asset('assets/images/icon-back.svg'),
                  iconSize: 36.0,
                  onPressed: () {
                    Navigator.pop(context);
                  })),
          Text(
            'UserAddressPage.SelectAddress'.tr(),
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          Container(
            width: 36,
            height: 36,
          )
        ],
      ),
    );
  }
}
