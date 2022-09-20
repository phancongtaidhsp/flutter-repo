import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/UserAddress.dart';
import '../../providers/auth.dart';
import '../../screens/user-address-page/gql/address.gql.dart';
import '../../screens/user-address-page/user-address-home-page.dart';
import '../../screens/user-address-page/widgets/address-text-field-widget.dart';
import '../../screens/user-address-page/widgets/information-bar-widget.dart';
import '../../widgets/app-bar-widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class UpdateAddressPage extends StatefulWidget {
  UpdateAddressPage(this.userSelectedAddress);
  final UserAddress userSelectedAddress;
  @override
  _UpdateAddressPageState createState() => _UpdateAddressPageState();
}

class _UpdateAddressPageState extends State<UpdateAddressPage> {
  final _labelTextController = TextEditingController();
  final _addressDetailsTextController = TextEditingController();
  final _instructionsForDeliveryTextController = TextEditingController();
  List<String> labelList = ["Home", "Work", "Others"];
  final Map<String, Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  String? selectedLabel;
  late Auth auth;

  void addLocationIntoMap(GoogleMapController controller) async {
    controller = await _controller.future;
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

  @override
  void initState() {
    selectedLabel = (widget.userSelectedAddress.name == "Home" ||
            widget.userSelectedAddress.name == "Work")
        ? widget.userSelectedAddress.name
        : "Others";
    _labelTextController.text = widget.userSelectedAddress.name;
    _addressDetailsTextController.text =
        widget.userSelectedAddress.address2 ?? '';
    _instructionsForDeliveryTextController.text =
        widget.userSelectedAddress.notes ?? '';
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      appBar: AppBarWidget("UserAddressPage.AddressDetails"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15,
            ),
            Center(child: InformationBarWidget(widget.userSelectedAddress)),
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
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
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
                                                  (labelList.elementAt(index))
                                              ? Color(0xFFFDC400)
                                              : Colors.grey[200],
                                          label: Text(
                                            labelList.elementAt(index),
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
                            height: 15,
                          ),
                          Visibility(
                              visible: (selectedLabel != "Home" &&
                                      selectedLabel != "Work")
                                  ? true
                                  : false,
                              child: Column(children: [
                                AddressTextFieldWidget('e.g. Partner\'s home',
                                    _labelTextController, TextInputType.text),
                                SizedBox(
                                  height: 15,
                                ),
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
                              maxLines: 5),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: widget.userSelectedAddress.isDefault,
                                onChanged: (bool? value) {
                                  setState(() {
                                    widget.userSelectedAddress.isDefault =
                                        value!;
                                  });
                                },
                              ),
                              Text(
                                "UserAddressPage.SetAsDefaultAddress",
                                style: textTheme.headline3!
                                    .copyWith(fontWeight: FontWeight.normal),
                              ).tr(),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Mutation(
                              options: MutationOptions(
                                  document: gql(AddressGQL.UPDATE_USER_ADDRESS),
                                  onCompleted: (dynamic resultData) {
                                    if (resultData["createDeliveryAddress"]
                                            ["status"] ==
                                        "SUCCESS") {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          UserAddressHomePage.routeName,
                                          ModalRoute.withName('/home'));
                                    }
                                  },
                                  onError: (dynamic error) {
                                    print(error);
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
                                            "id": widget.userSelectedAddress.id,
                                            "userId": auth.currentUser.id,
                                            "name": selectedLabel == "Others"
                                                ? "${_labelTextController.text}"
                                                : selectedLabel,
                                            "address1":
                                                "${widget.userSelectedAddress.address1}",
                                            "address2":
                                                "${_addressDetailsTextController.text}",
                                            "state":
                                                "${widget.userSelectedAddress.state}",
                                            "city":
                                                "${widget.userSelectedAddress.city}",
                                            "postalCode": widget
                                                .userSelectedAddress.postalCode,
                                            "longitude": widget
                                                .userSelectedAddress.longitude,
                                            "latitude": widget
                                                .userSelectedAddress.latitude,
                                            "countryId": "MY",
                                            "notes":
                                                "${_instructionsForDeliveryTextController.text}",
                                            "isDefault": widget
                                                .userSelectedAddress.isDefault
                                          }
                                        }),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text('Button.UpdateAddress',
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
                        ],
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
