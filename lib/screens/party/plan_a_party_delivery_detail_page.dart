import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/providers/plan-a-party.dart';
import 'package:gem_consumer_app/screens/party/plan_a_party_reselect_delivery_address_page.dart';
import 'package:gem_consumer_app/screens/user-address-page/widgets/address-text-field-widget.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class PlanAPartyDeliveryDetailPage extends StatefulWidget {
  static String routeName = '/plan-a-party-delivery-detail-page';

  final UserAddress userSelectedAddress;

  PlanAPartyDeliveryDetailPage({required this.userSelectedAddress});

  @override
  _PlanAPartyDeliveryDetailPageState createState() =>
      _PlanAPartyDeliveryDetailPageState();
}

class _PlanAPartyDeliveryDetailPageState
    extends State<PlanAPartyDeliveryDetailPage> {
  final _labelTextController = TextEditingController();
  final _addressDetailsTextController = TextEditingController();
  final _instructionsForDeliveryTextController = TextEditingController();
  final Map<String, Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _globalController;

  void addLocationIntoMap(GoogleMapController controller) async {
    controller = await _controller.future;
    _globalController = controller;
    controller.animateCamera(CameraUpdate.newLatLng(LatLng(
        widget.userSelectedAddress.latitude,
        widget.userSelectedAddress.longitude)));
    setState(() {
      final marker = Marker(
          markerId: MarkerId("UserSelectedLocation"),
          position: LatLng(widget.userSelectedAddress.latitude,
              widget.userSelectedAddress.longitude),
          infoWindow: InfoWindow.noText);
      _markers["UserSelectedLocation"] = marker;
    });
  }

  void refreshLocationOnMap(double latitude, double longitude) async {
    _globalController = await _controller.future;
    _globalController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          latitude,
          longitude,
        ),
      ),
    );

    print('selected latitude from previous current');
    print('$latitude $longitude');
    setState(() {
      final marker = Marker(
        markerId: MarkerId("UserSelectedLocation"),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow.noText,
      );
      _markers["UserSelectedLocation"] = marker;
    });
  }

  late PlanAParty event;

  @override
  void initState() {
    event = context.read<PlanAParty>();
    _labelTextController.text = widget.userSelectedAddress.name;
    _addressDetailsTextController.text =
        widget.userSelectedAddress.address2 ?? '';
    _instructionsForDeliveryTextController.text =
        widget.userSelectedAddress.notes ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;

    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(
          widget.userSelectedAddress.latitude,
          widget.userSelectedAddress
              .longitude), //LatLng(this.latitude, this.longitude),
      zoom: 16,
    );

    return Scaffold(
      appBar: PreferredSize(
        child: _buildAppBar(),
        preferredSize: Size(double.infinity, 56),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Center(child: _buildAddressInfo()),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: size.width,
                          height: size.height * 0.246,
                          child: GoogleMap(
                            scrollGesturesEnabled: false,
                            zoomControlsEnabled: false,
                            zoomGesturesEnabled: false,
                            markers: _markers.values.toSet(),
                            myLocationButtonEnabled: false,
                            mapType: MapType.normal,
                            initialCameraPosition: cameraPosition,
                            onMapCreated: (controller) {
                              addLocationIntoMap(controller);
                              _controller.complete(controller);
                            },
                          )),
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              AddressTextFieldWidget('e.g. Partner\'s home',
                                  _labelTextController, TextInputType.text),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "UserAddressPage.AddressDetails",
                                style: textTheme.headline3!
                                    .copyWith(fontWeight: FontWeight.normal),
                              ).tr(),
                              SizedBox(
                                height: 10,
                              ),
                              AddressTextFieldWidget(
                                  'e.g. Floor/ Unit number',
                                  _addressDetailsTextController,
                                  TextInputType.text),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "UserAddressPage.Instructions",
                                style: textTheme.headline3!
                                    .copyWith(fontWeight: FontWeight.normal),
                              ).tr(),
                              SizedBox(
                                height: 10,
                              ),
                              AddressTextFieldWidget(
                                  'e.g. Leave it as the font door',
                                  _instructionsForDeliveryTextController,
                                  TextInputType.multiline,
                                  maxLines: 5),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              SubmitButton(
                                  text: "Button.Select",
                                  textColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  onPressed: () {
                                    widget.userSelectedAddress.name =
                                        _labelTextController.text;
                                    widget.userSelectedAddress.address2 =
                                        _addressDetailsTextController.text;
                                    widget.userSelectedAddress.notes =
                                        _instructionsForDeliveryTextController
                                            .text;

                                    Navigator.pop(
                                        context, widget.userSelectedAddress);
                                  })
                            ],
                          )),
                    ],
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
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
            'UserAddressPage.AddressDetails'.tr(),
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

  Widget _buildAddressInfo() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 4.0,
              )
            ]),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: SvgPicture.asset("assets/images/location.svg")),
              SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("UserAddressPage.Address",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.button!.copyWith(
                              fontSize: 12, fontWeight: FontWeight.bold))
                      .tr(),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.48,
                      child: Text(
                        "${widget.userSelectedAddress.address1}",
                        style: Theme.of(context).textTheme.bodyText1,
                      ))
                ],
              ),
              Spacer(),
              Center(
                child: IconButton(
                    icon: Icon(
                      Icons.mode_edit,
                      color: primaryColor,
                    ),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PlanAPartyReselectDeliveryAddressPage(
                                    userSelectedAddress:
                                        widget.userSelectedAddress,
                                    refreshLocationOnMap: refreshLocationOnMap,
                                  ))).then((value) {
                        if (value != null) {
                          setState(() {
                            UserAddress newLocation = value as UserAddress;
                            widget.userSelectedAddress.latitude =
                                newLocation.latitude;
                            widget.userSelectedAddress.longitude =
                                newLocation.longitude;
                            widget.userSelectedAddress.address1 =
                                newLocation.address1;
                            widget.userSelectedAddress.city = newLocation.city;
                            widget.userSelectedAddress.state =
                                newLocation.state;
                            widget.userSelectedAddress.postalCode =
                                newLocation.postalCode;
                          });
                        }
                      });
                    }),
              ),
            ]));
  }
}
