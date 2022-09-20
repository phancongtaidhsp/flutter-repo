import 'package:flutter/material.dart';
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile.dart';
import 'package:gem_consumer_app/widgets/configuration_expansion_title_custom.dart';

class SpecialInstruction extends StatelessWidget {
  const SpecialInstruction({Key? key, required this.specialInstructionText})
      : super(key: key);
  final String specialInstructionText;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      // color: Colors.blue,
      child: ConfigurableExpansionTileCustom(
        initiallyExpanded: false,
        kExpand: Duration(milliseconds: 50),
        animatedWidgetFollowingHeader: Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.expand_more,
            color: Colors.black,
          ),
        ),
        headerBackgroundColorEnd: Colors.grey[200],
        headerBackgroundColorStart: Colors.grey[200]!,
        expandedBackgroundColor: Colors.grey[200],
        header: Container(
          //color: Colors.red,
          padding: EdgeInsets.only(
            left: 7,
            right: 7,
            top: 0,
            bottom: 0,
          ),
          child: Text(
            'Special Instruction:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 1,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 7,
                        right: 7,
                        top: 0,
                        bottom: 4,
                      ),
                      child: Text(
                        specialInstructionText,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
