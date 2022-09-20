import 'package:flutter/material.dart';
import 'package:gem_consumer_app/models/AddOn.dart';
import 'package:gem_consumer_app/values/color-helper.dart';

class DisplayAddonWidget extends StatelessWidget {
  const DisplayAddonWidget(this.addOnData);

  final Map<String, List<AddOn>> addOnData;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(4),
      width: MediaQuery.of(context).size.width * 1,
      child: Wrap(
          children: List.generate(addOnData.keys.length, (index) {
        var currentText = '';
        var titleText =
            addOnData[addOnData.keys.elementAt(index)]![0].addOnTitle;
        var addOnText = addOnData[addOnData.keys.elementAt(index)]!
            .map((e) => e.name)
            .join(",");
        if ((addOnData.keys.length - 1) != index) {
          currentText += titleText! + ": " + addOnText + '; ';
        } else {
          currentText += titleText! + ": " + addOnText;
        }

        return Text(
          currentText,
          style: Theme.of(context).textTheme.button!.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
          maxLines: 3,
        );
      })),
    );
  }
}
