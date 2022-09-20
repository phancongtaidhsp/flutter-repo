import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';

class PaxSelectionWidget extends StatelessWidget {
  final int quantity = 1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ElevatedButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) => Container(
              height: size.height * 0.360,
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
                    child: Expanded(
                        child: Column(
                      children: [
                        Row(
                          children: [
                            Text("Search.SelectPax",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .copyWith(fontWeight: FontWeight.w400))
                                .tr(),
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
                                  ),
                                  iconSize: 18.0,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            )
                          ],
                        ),
                        Container(
                            height: 150,
                            width: 355,
                            child: Container(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      height: 36.0,
                                      width: 36.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 1,
                                                offset: Offset(0, 1)),
                                          ]),
                                      child: IconButton(
                                          icon: SvgPicture.asset(
                                              'assets/images/minus.svg'),
                                          iconSize: 36.0,
                                          onPressed: () {
                                            // setState(() {
                                            //   item.itemList
                                            //       .elementAt(productIndex)
                                            //       .quantity--;
                                          })),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    "${quantity.toString()}",
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Container(
                                      height: 36.0,
                                      width: 36.0,
                                      decoration: BoxDecoration(
                                          color: Colors.orange[300],
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 2,
                                                offset: Offset(0, 1)),
                                          ]),
                                      child: IconButton(
                                          icon: SvgPicture.asset(
                                              'assets/images/plus.svg'),
                                          iconSize: 36.0,
                                          onPressed: () {
                                            // setState(() {
                                            //   item.itemList
                                            //       .elementAt(productIndex)
                                            //       .quantity++;
                                          })),
                                ],
                              ),
                            )),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24.0),
                                primary: Color.fromRGBO(0, 0, 0, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0))),
                            onPressed: () {},
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text('Button.Apply',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(color: Colors.white))
                                      .tr()
                                ]))
                      ],
                    ))),
              ),
            ),
          );
        },
        child: Center(
            child: Row(
          children: [
            Text("Search.SelectPax",
                    style: TextStyle(
                      fontFamily: 'Arial Rounded MT Bold',
                      color: Colors.black,
                      // widget.selectionList.length > 0
                      //     ? Colors.white
                      //     : Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center)
                .tr(),
          ],
        )),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            primary: Color.fromRGBO(228, 229, 229, 1),
            // widget.selectionList.length > 0
            //     ? Color.fromRGBO(0, 0, 0, 1)
            //     : Color.fromRGBO(228, 229, 229, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))));
  }
}
