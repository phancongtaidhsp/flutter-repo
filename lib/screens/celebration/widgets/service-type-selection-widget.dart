import 'package:flutter/material.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/screens/celebration/widgets/select-service-type-widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class ServiceTypeSelectionWidget extends StatefulWidget {
  @override
  _ServiceTypeSelectionWidgetState createState() =>
      _ServiceTypeSelectionWidgetState();
}

class _ServiceTypeSelectionWidgetState
    extends State<ServiceTypeSelectionWidget> {
  late FilterProvider filterProvider;
  List<String> tempServiceTypeList = [];

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    tempServiceTypeList = List.from(filterProvider.serviceTypeSelection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ElevatedButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) => Container(
              height: size.height * 0.53,
              width: size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 0), //(x,y)
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "ServiceTypeSelection.SelectServiceType",
                              style: TextStyle(
                                fontFamily: 'Arial Rounded MT Bold',
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                              ),
                            ).tr(),
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
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: Offset(0, 1)),
                                  ]),
                              child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                  ), //SvgPicture.asset('assets/images/icon-back.svg'),
                                  iconSize: 18.0,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        SelectServiceType(tempServiceTypeList)
                      ],
                    )),
              ),
            ),
          );
        },
        child: Center(
            child: Row(
          children: [
            Text("ServiceTypeSelection.ServiceType",
                    style: TextStyle(
                      fontFamily: 'Arial Rounded MT Bold',
                      color: filterProvider.isServiceTypeSelected()
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center)
                .tr(),
          ],
        )),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            primary: filterProvider.isServiceTypeSelected()
                ? Color.fromRGBO(0, 0, 0, 1)
                : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }
}
