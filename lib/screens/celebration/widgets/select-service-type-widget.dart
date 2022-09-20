import 'package:flutter/material.dart';
import 'package:gem_consumer_app/providers/filter-provider.dart';
import 'package:gem_consumer_app/widgets/submit-button.dart';
import 'package:provider/provider.dart';

class SelectServiceType extends StatefulWidget {
  final Map<String, String> dataList = {
    "DINE_IN": "Dine In",
    "DELIVERY": "Delivery",
    "PICKUP": "Pick Up"
  };
  final List<String> tempServiceTypeLists;

  SelectServiceType(this.tempServiceTypeLists);

  @override
  _SelectServiceTypeState createState() => _SelectServiceTypeState();
}

class _SelectServiceTypeState extends State<SelectServiceType> {
  late FilterProvider filterProvider;
  List<String> tempList = [];

  @override
  void initState() {
    filterProvider = context.read<FilterProvider>();
    tempList = List.from(filterProvider.serviceTypeSelection);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.23,
              child: Center(
                  child: Wrap(
                      direction: Axis.horizontal,
                      children: List.generate(
                          widget.dataList.length,
                          (index) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (tempList.contains(widget
                                            .dataList.keys
                                            .elementAt(index)
                                            .toString())) {
                                          tempList.remove(widget.dataList.keys
                                              .elementAt(index)
                                              .toString());
                                        } else {
                                          tempList.add(widget.dataList.keys
                                              .elementAt(index)
                                              .toString());
                                        }
                                      });
                                    },
                                    child: Chip(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 11),
                                      backgroundColor: tempList.contains(widget
                                                  .dataList.keys
                                                  .elementAt(index)
                                                  .toString()) ==
                                              false
                                          ? Colors.grey[200]
                                          : Color.fromRGBO(253, 196, 0, 1),
                                      label: Text(
                                        widget.dataList[widget.dataList.keys
                                                .elementAt(index)]
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Arial',
                                            ),
                                      ),
                                    )),
                              ))))),
          Spacer(),
          SubmitButton(
              text: "Button.Apply",
              textColor: Colors.white,
              backgroundColor: Color.fromRGBO(0, 0, 0, 1),
              onPressed: () {
                filterProvider.serviceTypeSelection = List.from(tempList);
                Navigator.pop(context);
              }),
          SizedBox(
            height: 10,
          ),
          SubmitButton(
              text: "Button.Reset",
              textColor: Colors.black,
              backgroundColor: Color.fromRGBO(228, 229, 229, 1),
              onPressed: () {
                setState(() {
                  tempList.clear();
                });
              })
        ]));
  }
}
