import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/auth.dart';
import '../../screens/user-address-page/gql/address.gql.dart';
import '../../screens/user-address-page/user-address-home-page.dart';
import '../../screens/user-address-page/widgets/address-text-field-widget.dart';
import '../../screens/user-address-page/widgets/address-top-bar-widget.dart';
import '../../widgets/app-bar-widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geocoder/geocoder.dart';

class AddressDetailsPage extends StatefulWidget {
  AddressDetailsPage(this.selectedAddress);
  final Address selectedAddress;
  @override
  _AddressDetailsPageState createState() => _AddressDetailsPageState();
}

class _AddressDetailsPageState extends State<AddressDetailsPage> {
  final _labelTextController = TextEditingController();
  final _addressDetailsTextController = TextEditingController();
  final _instructionsForDeliveryTextController = TextEditingController();
  List<String> labelList = ["Home", "Work", "Others"];
  String selectedLabel = "Home";
  final Map<String, Marker> _markers = {};
  bool isDefaultAddress = false;
  Completer<GoogleMapController> _controller = Completer();
  late Auth auth;

  void addLocationIntoMap(GoogleMapController controller) async {
    controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(LatLng(
        widget.selectedAddress.coordinates.latitude,
        widget.selectedAddress.coordinates.longitude)));
    setState(() {
      final marker = Marker(
          markerId: MarkerId("UserSelectedLocation"),
          position: LatLng(widget.selectedAddress.coordinates.latitude,
              widget.selectedAddress.coordinates.longitude),
          infoWindow: InfoWindow.noText);
      _markers["UserSelectedLocation"] = marker;
    });
  }

  @override
  void initState() {
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;

    final CameraPosition _kGooglePlex = CameraPosition(
      target:
          LatLng(3.099905, 101.729384), //LatLng(this.latitude, this.longitude),
      zoom: 16,
    );
    return Scaffold(
        appBar: AppBarWidget("UserAddressPage.AddressDetails"),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 10,
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
                      zoomGesturesEnabled: true,
                      markers: _markers.values.toSet(),
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (controller) {
                        addLocationIntoMap(controller);
                        _controller.complete(controller);
                      },
                    )),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "UserAddressPage.Label",
                            style: textTheme.headline3!
                                .copyWith(fontWeight: FontWeight.normal),
                          ).tr(),
                          SizedBox(
                            height: 10,
                          ),
                          Wrap(
                              direction: Axis.horizontal,
                              children: List.generate(
                                  labelList.length,
                                  (index) => Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedLabel =
                                                  labelList.elementAt(index);
                                            });
                                          },
                                          child: Chip(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                              backgroundColor: selectedLabel ==
                                                      (labelList
                                                          .elementAt(index))
                                                  ? Color(0xFFFDC400)
                                                  : Colors.grey[200],
                                              label: Text(
                                                labelList.elementAt(index),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Arial',
                                                        fontSize: 16),
                                              )))))),
                          SizedBox(
                            height: 15,
                          ),
                          Visibility(
                              visible: selectedLabel == "Others" ? true : false,
                              child: Column(children: [
                                AddressTextFieldWidget('e.g. Partner\'s home',
                                    _labelTextController, TextInputType.text),
                                SizedBox(
                                  height: 15,
                                )
                              ])),
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
                            maxLines: 5,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(children: [
                            Checkbox(
                                value: this.isDefaultAddress,
                                onChanged: (bool? value) {
                                  setState(() {
                                    this.isDefaultAddress = value!;
                                  });
                                }),
                            Text(
                              "UserAddressPage.SetAsDefaultAddress",
                              style: textTheme.headline3!
                                  .copyWith(fontWeight: FontWeight.normal),
                            ).tr()
                          ]),
                          SizedBox(
                            height: 30,
                          ),
                          Mutation(
                              options: MutationOptions(
                                  document: gql(AddressGQL.CREATE_NEW_ADDRESS),
                                  onCompleted: (dynamic resultData) {
                                    print("completed:$resultData");
                                    if (resultData != null) {
                                      if (resultData["createDeliveryAddress"]
                                              ["status"] ==
                                          "SUCCESS") {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            UserAddressHomePage.routeName,
                                            ModalRoute.withName('/home'));
                                      }
                                    }
                                  },
                                  onError: (dynamic error) {
                                    print("error :$error");
                                  }),
                              builder: (
                                RunMutation runMutation,
                                QueryResult? result,
                              ) {
                                return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24.0),
                                        primary: Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0))),
                                    onPressed: () => runMutation({
                                          "createAddress": {
                                            "userId": auth.currentUser.id,
                                            "name": selectedLabel == "Others"
                                                ? "${_labelTextController.text}"
                                                : selectedLabel,
                                            "address1":
                                                "${widget.selectedAddress.featureName}",
                                            "address2":
                                                "${_addressDetailsTextController.text}",
                                            "state":
                                                "${widget.selectedAddress.adminArea}",
                                            "city": widget.selectedAddress
                                                        .subAdminArea !=
                                                    null
                                                ? "${widget.selectedAddress.subAdminArea}"
                                                : "${widget.selectedAddress.locality}",
                                            "postalCode": widget.selectedAddress
                                                        .postalCode !=
                                                    null
                                                ? widget
                                                    .selectedAddress.postalCode
                                                : '',
                                            "longitude": widget.selectedAddress
                                                .coordinates.longitude,
                                            "latitude": widget.selectedAddress
                                                .coordinates.latitude,
                                            "countryId":
                                                "${widget.selectedAddress.countryCode}",
                                            "notes":
                                                "${_instructionsForDeliveryTextController.text}",
                                            "isDefault": isDefaultAddress
                                          }
                                        }),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text('Button.SaveAddress',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    'Arial Rounded MT Bold',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              )).tr()
                                        ]));
                              })
                        ]))
              ]))
        ])));
  }
}
