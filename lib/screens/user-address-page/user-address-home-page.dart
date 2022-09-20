import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/UserAddress.dart';
import '../../providers/auth.dart';
import '../../screens/user-address-page/gql/address.gql.dart';
import '../../screens/user-address-page/update-address-details-page.dart';
import '../../screens/user-address-page/widgets/add-new-address-widget.dart';
import '../../screens/user-address-page/widgets/pop-up-confirmation-widget.dart';
import '../../values/color-helper.dart';
import '../../UI/Layout/custom_app_bar.dart';
import '../../widgets/loading_controller.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class UserAddressHomePage extends StatefulWidget {
  static String routeName = '/user-address-page';

  @override
  _UserAddressHomePageState createState() => _UserAddressHomePageState();
}

class _UserAddressHomePageState extends State<UserAddressHomePage> {
  late Auth auth;

  @override
  void initState() {
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List userAddressesList = List.empty(growable: true);

    TextTheme textTheme = Theme.of(context).textTheme;
    //print(context.isDarkMode());

    return Scaffold(
        body: Container(
            child: Query(
                options: QueryOptions(
                    document: gql(AddressGQL.GET_USER_ADDRESSES),
                    variables: {'userId': auth.currentUser.id}),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppBar(text: 'UserAddressPage.MyAddresses'),
                      (!result.hasException &&
                              !result.isLoading &&
                              result.data != null &&
                              result.data!["UserAddresses"].length > 0)
                          ? Center(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 10.0),
                                  child: Text(
                                    "UserAddressPage.LabelDeleteAddress",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            fontFamily:
                                                'Arial Rounded MT Light'),
                                  ).tr()))
                          : Center(),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(builder: (context) {
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
                                List tempList =
                                    List.from(result.data!["UserAddresses"]);
                                if (tempList
                                    .map((e) => e["isDefault"])
                                    .contains(true)) {
                                  dynamic defaultAddress = tempList.firstWhere(
                                      (element) =>
                                          element["isDefault"] == true);
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
                                      (element) =>
                                          element["isDefault"] == true));
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
                                        (index) => Slidable(
                                            actionPane:
                                                SlidableDrawerActionPane(),
                                            secondaryActions: [
                                              Mutation(
                                                  options: MutationOptions(
                                                    document: gql(AddressGQL
                                                        .DELETE_USER_ADDRESS),
                                                    onCompleted:
                                                        (dynamic resultData) {},
                                                  ),
                                                  builder: (
                                                    RunMutation runMutation,
                                                    QueryResult? result,
                                                  ) {
                                                    return IconSlideAction(
                                                        caption: 'Delete',
                                                        color: Colors.red,
                                                        icon: Icons.delete,
                                                        onTap: () {
                                                          showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    Dialog(
                                                              child: PopUpConfirmation(
                                                                  userAddressesList[
                                                                          index]
                                                                      .id),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              insetPadding:
                                                                  EdgeInsets
                                                                      .all(24),
                                                            ),
                                                          );
                                                        });
                                                  })
                                            ],
                                            child: buildListTile(
                                                userAddressesList[index]))));
                              }
                              return Container(width: 0.0, height: 0.0);
                            }),
                            AddNewAddressWidget(),
                          ],
                        ),
                      ))
                    ],
                  );
                })));
  }

  Widget buildListTile(UserAddress item) {
    String postcode =
        '${item.postalCode != null ? ',' : ''}${item.postalCode ?? ''}';
    String city = '${item.city != '' ? ',' : ''} ${item.city}';
    String address = "${item.address1}";
    return InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UpdateAddressPage(item)));
        },
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fontWeight: FontWeight.normal,
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
                      address + postcode + city,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Arial Rounded MT Light'),
                    )
                  ],
                )),
                SizedBox(
                  width: 8,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.arrow_forward_ios, size: 18.0))
              ]),
        ));
  }
}
