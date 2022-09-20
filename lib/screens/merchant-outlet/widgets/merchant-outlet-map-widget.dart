import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MerchantOutletMap extends StatelessWidget {
  MerchantOutletMap(this.latitude, this.longitude);
  final double longitude;
  final double latitude;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Completer<GoogleMapController> _controller = Completer();

    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(this.latitude, this.longitude),
      zoom: 16,
    );

    final Map<String, Marker> _markers = {};

    final marker = Marker(
        markerId: MarkerId("MerchantOutlet"),
        position: LatLng(this.latitude, this.longitude),
        infoWindow: InfoWindow.noText);
    _markers["MerchantOutlet"] = marker;

    return Container(
        width: size.width,
        height: size.height * 0.246, //200,
        child: GoogleMap(
          markers: _markers.values.toSet(),
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ));
  }
}
