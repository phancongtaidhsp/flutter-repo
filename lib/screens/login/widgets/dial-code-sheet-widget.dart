import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DialCodeSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return IconButton(
        splashRadius: 1.0,
        padding: EdgeInsets.all(0.0),
        icon: SvgPicture.asset(
          'assets/images/dropdown-button.svg',
        ),
        onPressed: () {
          //   showBottomSheet(
          //     context: context,
          //     builder: (context) => Container(
          //       height: size.height * 0.360,
          //       width: MediaQuery.of(context).size.width,
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.circular(5.0),
          //         child: Container(
          //             margin: EdgeInsets.only(top: 1),
          //             decoration: BoxDecoration(
          //               borderRadius:
          //                   BorderRadius.vertical(top: Radius.circular(15)),
          //               color: Colors.white,
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.grey,
          //                   offset: Offset(0, 0), //(x,y)
          //                   blurRadius: 5,
          //                 ),
          //               ],
          //             ),
          //             //Insert Data here - Now is Hard Code
          //             child: ListView(
          //               padding: const EdgeInsets.all(8),
          //               children: <Widget>[
          //                 Container(
          //                   height: 50,
          //                   color: Colors.white,
          //                   child: Center(
          //                     child: Text(
          //                       'Malaysia (+06)',
          //                       style: TextStyle(
          //                         fontFamily: 'Arial Rounded MT Bold',
          //                         color: Colors.black,
          //                         fontWeight: FontWeight.w400,
          //                         fontSize: 16,
          //                       ),
          //                       textAlign: TextAlign.left,
          //                     ),
          //                   ),
          //                 ),
          //                 // Container(
          //                 //   height: 50,
          //                 //   color: Colors.white,
          //                 //   child: Center(
          //                 //     child: Text(
          //                 //       'Malaysia (+06)',
          //                 //       style: TextStyle(
          //                 //         fontFamily: 'Arial Rounded MT Bold',
          //                 //         color: Colors.black,
          //                 //         fontWeight: FontWeight.w400,
          //                 //         fontSize: 16,
          //                 //       ),
          //                 //       textAlign: TextAlign.left,
          //                 //     ),
          //                 //   ),
          //                 // ),
          //                 // Container(
          //                 //   height: 50,
          //                 //   color: Colors.white,
          //                 //   child: Center(
          //                 //     child: Text(
          //                 //       'Malaysia (+60)',
          //                 //       style: TextStyle(
          //                 //         fontFamily: 'Arial Rounded MT Bold',
          //                 //         color: Colors.black,
          //                 //         fontWeight: FontWeight.w400,
          //                 //         fontSize: 16,
          //                 //       ),
          //                 //       textAlign: TextAlign.left,
          //                 //     ),
          //                 //   ),
          //                 // ),
          //               ],
          //             )),
          //       ),
          //     ),
          //   );
        });
  }
}
