import 'package:flutter/material.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';

class ServiceInfoWidget extends StatelessWidget {
  const ServiceInfoWidget({
    Key? key,
    required this.userCartItems,
    required this.iconPath,
    required this.serviceDateAndTimeInfo,
  }) : super(key: key);

  final List<UserCartItem> userCartItems;
  final String iconPath;
  final String serviceDateAndTimeInfo;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: size.width * 0.893,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1)),
          ]),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 60,
            height: 50,
          ),
          SizedBox(width: 4,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    userCartItems[0].outletProductInformation["outlet"]["name"],
                    style: Theme.of(context).textTheme.headline3!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),),
                SizedBox(height: 2,),
                Text(serviceDateAndTimeInfo,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Arial',
                    ),),
              ],
            ),
          )
        ],
      ),
    );
  }
}
