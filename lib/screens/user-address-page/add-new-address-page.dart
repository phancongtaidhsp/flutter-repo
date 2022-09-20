import 'dart:convert';
import 'dart:io';
import 'package:gem_consumer_app/helpers/ui_theme.dart';
import 'package:gem_consumer_app/providers/user-position-provider.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../configuration.dart';
import '../../screens/user-address-page/address-details-page.dart';
import 'package:provider/provider.dart';
import '../../widgets/submit-button.dart';
import '../../widgets/app-bar-widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_pin_picker/map_pin_picker.dart';
import 'package:geocoder/geocoder.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class AddNewAddressPage extends StatefulWidget {
  @override
  _AddNewAddressPageState createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  static String androidKey = Configuration.ANDROID_API_KEY;
  static String iosKey = Configuration.IOS_API_KEY;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;
  //Google Map
  late GoogleMapController googleMapController;
  MapPickerController mapPickerController = MapPickerController();
  Position? position;
  CameraPosition cameraPosition1 = CameraPosition(
    target: LatLng(0, 0), //user's location
    zoom: 16,
  );
  late Address selectedAddress;

  List searchResult = [];

  final controller = FloatingSearchBarController();

  bool isAllowGoogleMapFetchAddress = true;
  late UserPositionProvider positionProvider;

  @override
  void initState() {
    positionProvider = context.read<UserPositionProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget("UserAddressPage.AddNewAddress"),
      body: SafeArea(
        child: FutureBuilder<Position?>(
            future: getCurrentLocation(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                cameraPosition1 = CameraPosition(
                  target: LatLng(snapshot.data!.latitude,
                      snapshot.data!.longitude), //user's location
                  zoom: 16,
                );
                return Stack(
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
                          gestureRecognizers:
                              <Factory<OneSequenceGestureRecognizer>>[
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
                              showLoadingDialog(context);

                              List<Address> addresses =
                                  await Geocoder.google(apiKey)
                                      .findAddressesFromCoordinates(Coordinates(
                                          cameraPosition1.target.latitude,
                                          cameraPosition1.target.longitude));

                              selectedAddress = addresses[0];

                              controller.query =
                                  '${addresses[0].addressLine ?? ''}';

                              Navigator.of(context).pop();

                              setState(() {});
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
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          child: SubmitButton(
                              text: "Button.Select",
                              textColor: Colors.white,
                              backgroundColor: Colors.black,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddressDetailsPage(
                                                selectedAddress)));
                              }),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return LoadingController();
              }
            }),
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
      queryStyle: TextStyle(
          color: Colors.black,
          fontSize: 14,
          wordSpacing: 1,
          fontFamily: 'Arial'),
      hintStyle: TextStyle(
          color: Colors.black,
          fontSize: 14,
          wordSpacing: 1,
          fontFamily: 'Arial'),
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
                    showLoadingDialog(context);

                    var addresses = await Geocoder.google(androidKey)
                        .findAddressesFromQuery(data['description']);
                    selectedAddress = addresses.first;

                    Navigator.of(context).pop();

                    setState(() {
                      controller.query = data['description'];
                    });
                    animateCamera(LatLng(selectedAddress.coordinates.latitude,
                        selectedAddress.coordinates.longitude));

                    controller.hide();
                    controller.close();
                  },
                  child: Column(
                    children: [
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 12, bottom: 14, top: 16, right: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.place,
                                size: 24,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(data['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        wordSpacing: 1,
                                        fontFamily: 'Arial')),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 44, right: 4),
                          child: Container(
                            color: Colors.grey,
                            height: 0.25,
                            width: MediaQuery.of(context).size.width,
                          ))
                    ],
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

  Future<Position?>? getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (position != null) {
      positionProvider.setUserPosition(position!);
    }

    return position;
  }
}
