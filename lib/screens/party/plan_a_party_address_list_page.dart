import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import '../../../configuration.dart';
import '../../../models/UserAddress.dart';
import '../../../providers/auth.dart';
import '../../../screens/party/plan_a_party_delivery_detail_page.dart';
import '../../../screens/user-address-page/gql/address.gql.dart';
import '../../../values/color-helper.dart';
import '../../../widgets/loading_controller.dart';
import '../../widgets/location_not_found.dart';

class PlanAPartyAddressListPage extends StatefulWidget {
  // AddressListPage
  static String routeName = '/plan-a-party-address-page';

  //final UserAddress address

  @override
  _PlanAPartyAddressListPageState createState() =>
      _PlanAPartyAddressListPageState();
}

class _PlanAPartyAddressListPageState extends State<PlanAPartyAddressListPage> {
  late Auth auth;
  Position? position;
  UserAddress? currentUserLocation;

  @override
  void initState() {
    auth = context.read<Auth>();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List userAddressesList = List.empty(growable: true);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: PreferredSize(
        child: _buildAppBar(),
        preferredSize: Size(double.infinity, 56),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            currentUserLocation != null
                ? _buildCurrentLocation(currentUserLocation!)
                : Container(),
            Container(
              height: 10,
              color: Colors.grey[200],
            ),
            Query(
                options: QueryOptions(
                    document: gql(AddressGQL.GET_USER_ADDRESSES),
                    variables: {'userId': auth.currentUser.id}),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Text(
                      result.exception.toString(),
                      style: textTheme.subtitle2!
                          .copyWith(fontWeight: FontWeight.normal),
                    );
                  }
                  if (result.isLoading) {
                    return LoadingController();
                  }
                  if (result.data != null &&
                      result.data!["UserAddresses"].length > 0) {
                    userAddressesList.clear();
                    List tempList = List.from(result.data!["UserAddresses"]);
                    if (tempList.map((e) => e["isDefault"]).contains(true)) {
                      dynamic defaultAddress = tempList.firstWhere(
                          (element) => element["isDefault"] == true);
                      UserAddress userDefaultAddress = UserAddress(
                          id: defaultAddress["id"],
                          name: defaultAddress["name"],
                          address1: defaultAddress["address1"],
                          address2: defaultAddress["address2"],
                          notes: defaultAddress["notes"],
                          state: defaultAddress["state"],
                          city: defaultAddress["city"],
                          postalCode: defaultAddress["postalCode"],
                          longitude: defaultAddress["longitude"],
                          latitude: defaultAddress["latitude"],
                          isDefault: defaultAddress["isDefault"]);
                      userAddressesList.add(userDefaultAddress);
                      tempList.remove(tempList.firstWhere(
                          (element) => element["isDefault"] == true));
                    }

                    tempList.forEach((address) {
                      UserAddress userAddress = UserAddress(
                          id: address["id"],
                          name: address["name"],
                          address1: address["address1"],
                          address2: address["address2"],
                          notes: address["notes"],
                          state: address["state"],
                          city: address["city"],
                          postalCode: address["postalCode"],
                          longitude: address["longitude"],
                          latitude: address["latitude"],
                          isDefault: address["isDefault"]);
                      userAddressesList.add(userAddress);
                    });

                    return Column(
                        children: List.generate(
                            userAddressesList.length,
                            (index) =>
                                buildListTile(userAddressesList[index])));
                  }
                  return Container(width: 0.0, height: 0.0);
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocation(UserAddress item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: ListTile(
        onTap: () {
          Navigator.pop(context, item);
        },
        contentPadding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10, left: 5),
                child: Icon(
                  Icons.location_on_outlined,
                  color: primaryColor,
                  size: 30,
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      child: Text(item.name,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontWeight: FontWeight.normal)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    item.isDefault
                        ? Container(
                            child: Text("UserAddressPage.Default",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: primaryColor))
                                .tr(),
                          )
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                  ]),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "${item.address1}, ${item.postalCode}, ${item.city}",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Arial Rounded MT Light'),
                  )
                ],
              )),
              InkResponse(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlanAPartyDeliveryDetailPage(
                                  userSelectedAddress: item,
                                ))).then((value) {
                      if (value != null) {
                        Navigator.pop(context, value);
                      }
                    });
                  },
                  child: Container(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_forward_ios, size: 18.0)))
            ]),
      ),
    );
  }

  Widget buildListTile(UserAddress item) => ListTile(
        contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 25.0, 0.0),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 6),
                child: Radio(
                  value: false,
                  groupValue: true,
                  fillColor:
                      MaterialStateColor.resolveWith((states) => primaryColor),
                  onChanged: (value) {
                    Navigator.pop(context, item);
                  },
                  visualDensity: VisualDensity(vertical: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      child: Text(item.name,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontWeight: FontWeight.normal)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    item.isDefault
                        ? Container(
                            child: Text("UserAddressPage.Default",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: primaryColor))
                                .tr(),
                          )
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                  ]),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "${item.address1}, ${item.postalCode}, ${item.city}",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Arial Rounded MT Light'),
                  )
                ],
              )),
            ]),
      );

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
            'PlanAParty.DeliveryTo'.tr(),
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

  getCurrentLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    var addresses = await Geocoder.google(Configuration.ANDROID_API_KEY)
        .findAddressesFromCoordinates(
            Coordinates(position!.latitude, position!.longitude));
    if (addresses.isEmpty) {
      errorDialog(
        errorMessage: 'We are unable to get your current address. Try later.',
        okButtonAction: () {},
        context: context,
        okButtonText: 'OK',
      );
      return;
    }
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
        latitude: position!.latitude,
      );
    });
  }
}
