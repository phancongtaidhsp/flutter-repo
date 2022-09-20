import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/widgets/app-bar-widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterHomePage extends StatefulWidget {
  static String routeName = '/help-center-page';

  @override
  _HelpCenterHomePageState createState() => _HelpCenterHomePageState();
}

class _HelpCenterHomePageState extends State<HelpCenterHomePage> {
  List<Map<String, dynamic>> settingsList = [];

  Widget _buildDivider(double value) {
    return Container(
      height: value,
      color: Colors.grey[200],
    );
  }

  @override
  Widget build(BuildContext context) {
    settingsList = [
      {
        "text": "General.TermAndCondition",
        "function": () {
          launch('https://www.mygemspot.com/terms-and-conditions/');
        }
      },
      {
        "text": "General.PrivacyPolicy",
        "function": () {
          launch('https://www.mygemspot.com/privacy-policy/');
        }
      },
    ];
    return Scaffold(
      appBar: AppBarWidget('AccountPage.HelpCenter'),
      body: ListView.separated(
        itemCount: settingsList.length + 1,
        separatorBuilder: (BuildContext context, int index) {
          return _buildDivider(1);
        },
        itemBuilder: (context, index) {
          if (index == settingsList.length) {
            return const SizedBox(
              width: 0,
            ); // zero height: not visible
          }
          return InkWell(
            onTap: settingsList[index]['function'],
            child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                              children: [
                                Container(
                                  child: Text(settingsList[index]['text'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(color: Colors.black))
                                      .tr(),
                                ),
                              ],
                            )
                          ])),
                    ])),
          );
        },
      ),
    );
  }
}
