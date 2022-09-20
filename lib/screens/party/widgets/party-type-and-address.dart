import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../providers/plan-a-party.dart';
import '../../../widgets/location_not_found.dart';
import '../../../widgets/submit-button.dart';
import '../../../configuration.dart';
import '../../../models/UserAddress.dart';
import '../../../providers/auth.dart';
import '../../../screens/party/widgets/chip-form.dart';
import '../../../screens/party/widgets/party-popup-date-time.dart';
import '../../../screens/user-address-page/gql/address.gql.dart';
import '../../../values/color-helper.dart';
import '../../../widgets/loading_controller.dart';
import '../plan_a_party_address_list_page.dart';

class PopUpTypeAndAddress extends StatefulWidget {
  @override
  _PopUpTypeAndAddressState createState() => _PopUpTypeAndAddressState();
}

class _PopUpTypeAndAddressState extends State<PopUpTypeAndAddress> {
  late PlanAParty party;
  Position? position;
  UserAddress? currentUserLocation;
  UserAddress? deliveryLocation;
  late Auth auth;
  int typeSelected = 0;
  final Map<String, String> servicesTypeList = {
    "DINE_IN": "CollectionType.DINE_IN".tr(),
    "DELIVERY": "CollectionType.DELIVERY".tr(),
    "PICKUP": "CollectionType.PICKUP".tr(),
  };
  final List<String> serviceTypeList = [
    "CollectionType.DELIVERY".tr(),
    "CollectionType.PICKUP".tr()
  ];

  @override
  void initState() {
    party = context.read<PlanAParty>();
    auth = context.read<Auth>();
    getCurrentLocation();
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => party.setEventCollectionType("DELIVERY"));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    print('partytypeandaddress');
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer<PlanAParty>(builder: (context, party, child) {
                    return party.name != null
                        ? Expanded(
                            child: Text(
                              party.name!,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        : Container(width: 0, height: 0);
                  }),
                  SizedBox(
                    width: 8,
                  ),
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
                            if (party.deliveryAddress != null) {
                              party.setEventDeliveryAddress(null);
                            }
                            Navigator.pop(context);
                          }))
                ],
              ),
              SizedBox(height: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("ServiceTypeSelection.ServiceType".tr(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Arial Rounded MT Bold',
                        fontWeight: FontWeight.w400)),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: _customChoiceChip(
                            servicesTypeList["DELIVERY"]!, 0)),
                    SizedBox(width: 20),
                    Expanded(
                        child:
                            _customChoiceChip(servicesTypeList["PICKUP"]!, 1)),
                  ],
                )
              ]),
              SizedBox(height: 20),
              typeSelected == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text("PlanAParty.DeliveryTo".tr(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Arial Rounded MT Bold',
                                  fontWeight: FontWeight.w400)),
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context,
                                      PlanAPartyAddressListPage.routeName)
                                  .then((value) {
                                UserAddress? v = value as UserAddress?;

                                if (v != null) {
                                  party.setEventDeliveryAddress(v);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 11),
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(40)),
                              child: Query(
                                  options: QueryOptions(
                                      document:
                                          gql(AddressGQL.GET_USER_ADDRESSES),
                                      variables: {
                                        'userId': auth.currentUser.id
                                      }),
                                  builder: (QueryResult result,
                                      {VoidCallback? refetch,
                                      FetchMore? fetchMore}) {
                                    if (result.hasException) {
                                      return Text(
                                        result.exception.toString(),
                                        style: textTheme.subtitle2!.copyWith(
                                            fontWeight: FontWeight.normal),
                                      );
                                    }
                                    if (result.isLoading) {
                                      return LoadingController();
                                    }
                                    if (result.data != null) {
                                      Map<String, dynamic>? defaultAddress;
                                      List tempList = List.from(
                                          result.data!["UserAddresses"]);
                                      if (tempList.length > 0) {
                                        if (tempList
                                            .map((e) => e["isDefault"])
                                            .contains(true)) {
                                          defaultAddress = tempList.firstWhere(
                                              (element) =>
                                                  element["isDefault"] == true);

                                          deliveryLocation = UserAddress(
                                              id: defaultAddress!["id"],
                                              name: defaultAddress["name"],
                                              address1:
                                                  defaultAddress["address1"],
                                              address2:
                                                  defaultAddress["address2"],
                                              notes: defaultAddress["notes"],
                                              state: defaultAddress["state"],
                                              city: defaultAddress["city"],
                                              postalCode:
                                                  defaultAddress["postalCode"],
                                              longitude:
                                                  defaultAddress["longitude"],
                                              latitude:
                                                  defaultAddress["latitude"],
                                              isDefault:
                                                  defaultAddress["isDefault"]);
                                        }

                                        if (defaultAddress == null) {
                                          deliveryLocation =
                                              currentUserLocation;
                                        }
                                      } else {
                                        deliveryLocation = currentUserLocation;
                                      }

                                      WidgetsBinding.instance!
                                          .addPostFrameCallback((_) =>
                                              party.setEventDeliveryAddress(
                                                  deliveryLocation));

                                      return deliveryLocation == null &&
                                              party.deliveryAddress == null
                                          ? Row(children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                        deliveryLocation != null
                                                            ? deliveryLocation!
                                                                .name
                                                            : '. . .',
                                                        style: Theme.of(context)
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
                                                    Text(
                                                        deliveryLocation != null
                                                            ? deliveryLocation!
                                                                .address1
                                                            : '. . .',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1!
                                                            .copyWith(
                                                                fontFamily:
                                                                    'Arial',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
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
                                              return item.deliveryAddress !=
                                                      null
                                                  ? Row(children: [
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
                                                                      fontSize:
                                                                          16,
                                                                    )),
                                                            SizedBox(
                                                              height: 4,
                                                            ),
                                                            item.deliveryAddress !=
                                                                    null
                                                                ? Text(
                                                                    item.deliveryAddress!
                                                                        .address1,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyText1!
                                                                        .copyWith(
                                                                            fontFamily:
                                                                                'Arial',
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                            fontSize:
                                                                                12))
                                                                : Container(
                                                                    width: 0.0,
                                                                    height:
                                                                        0.0),
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
                                                  : Container(
                                                      width: 0, height: 0);
                                            });
                                    }
                                    return Container(width: 0.0, height: 0.0);
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ])
                  : Container(),
              SizedBox(height: 30),
              SubmitButton(
                text: 'SignInWithMobile.Next',
                isUppercase: true,
                rippleColor: Colors.white,
                textColor: Colors.white,
                backgroundColor: Colors.black,
                onPressed: () {
                  if ((party.collectionType == "DELIVERY" &&
                          party.deliveryAddress != null) ||
                      party.collectionType == "PICKUP") {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => Dialog(
                              child: PopUpDateTime(),
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.all(24),
                            ));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void changeIndex(int index) {
    setState(() {
      typeSelected = index;
      if (typeSelected == 0) {
        party.setEventCollectionType("DELIVERY");
      }
      if (typeSelected == 1) {
        party.setEventCollectionType("PICKUP");
      }

      print("check set : ${party.collectionType}");
    });
  }

  Widget _customChoiceChip(String text, int index) {
    return InkWell(
        onTap: () => changeIndex(index),
        child: ChipForm(
          text: text,
          isShowIcon: false,
          isEnable: typeSelected == index,
          fontWeight: FontWeight.w400,
        ));
  }

  getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    var addresses = await Geocoder.google(Configuration.ANDROID_API_KEY)
        .findAddressesFromCoordinates(
            Coordinates(position!.latitude, position!.longitude));
    // var addresses = [];
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
            longitude: position!.longitude,
            latitude: position!.latitude);
      });
    }
  }
}
