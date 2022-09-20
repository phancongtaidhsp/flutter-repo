import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:collection/collection.dart';

class AmenitiesListWidget extends StatelessWidget {
  AmenitiesListWidget(this.inclusions);

  final List? inclusions;

  @override
  Widget build(BuildContext context) {
    List listInclusion = [];

    if (inclusions != null) {
      Map types = groupBy(inclusions!, (obj) {
        obj = obj as Map;
        return obj['amenity']["name"];
      });
      listInclusion = types.keys.toList();
    }

    return Container(
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 20.0),
        color: Colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Celebration.OtherInclusions',
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(fontWeight: FontWeight.w400))
                  .tr(),
              SizedBox(height: 5.0),
              Text('Celebration.OtherInclusionsAdditional',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.normal))
                  .tr(),
              SizedBox(height: 12.0),
              listInclusion.length > 0
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: listInclusion.length,
                      itemBuilder: (context, index) {
                        return _buildAmenitiesList(
                            context, listInclusion[index]);
                      })
                  : Container()
            ]));
  }
}

Widget _buildAmenitiesList(BuildContext context, String inclusion) {
  return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Padding(
          padding: EdgeInsets.only(bottom: 6.0),
          child: Row(children: <Widget>[
            Icon(Icons.check, size: 12.0),
            SizedBox(width: 12.0),
            HtmlWidget(
              inclusion,
              // set the default styling for text
              textStyle: Theme.of(context).textTheme.bodyText1,
            )
          ])));
}
