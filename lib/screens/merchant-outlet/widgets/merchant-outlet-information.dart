import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MerchantOutletInformation extends StatefulWidget {
  MerchantOutletInformation(this.merchantData);

  final Map merchantData;

  @override
  _MerchantOutletInformationState createState() =>
      _MerchantOutletInformationState();
}

class _MerchantOutletInformationState extends State<MerchantOutletInformation> {
  final Map<String, String> enumDay = {
    "MON": "Monday",
    "TUE": "Tuesday",
    "WED": "Wednesday",
    "THU": "Thursday",
    "FRI": "Friday",
    "SAT": "Saturday",
    "SUN": "Sunday"
  };

  final List<String> nameOfDay = [
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
    "SUN"
  ];

  bool isExpand = false;
  bool isExpandSpecialDay = false;
  bool isExpandOffDay = false;

  var formatString = "yyyy-MM-ddTHH:mm:ssZ";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var sortedList = [];
    var listNormalBusinessHours = (widget.merchantData['businessHours'])
        .where((element) => (element["isNormalBusinessHour"] == true))
        .toList();

    var listSpecialHours = (widget.merchantData['businessHours'])
        .where((element) => (element["isNormalBusinessHour"] == false &&
            element['isClosed'] == false))
        .toList();

    var listOffDay = (widget.merchantData['businessHours'])
        .where((element) => (element["isClosed"] == true))
        .toList();

    if (listNormalBusinessHours != null) {
      nameOfDay.forEach((element) {
        sortedList.addAll((listNormalBusinessHours as List)
            .where((e) => e['startDay'] == element));
      });
    }

    return Container(
      padding: EdgeInsets.only(left: 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 76,
                child: Text(
                  "ViewMerchantOutlet.Phone",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontSize: 12, color: Colors.black),
                ).tr(),
              ),
              SizedBox(
                width: 8,
              ),
              widget.merchantData['phones'][0]['contactNo'] != null
                  ? Text(
                      widget.merchantData['phones'][0]['contactNo'],
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    )
                  : Text(
                      "-",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 76,
                child: Text(
                  "ViewMerchantOutlet.Capacity",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontSize: 12, color: Colors.black),
                ).tr(),
              ),
              SizedBox(width: 8),
              Text(
                "Product.MaxPax",
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontSize: 12, fontWeight: FontWeight.normal),
              ).tr(
                  namedArgs: {"pax": widget.merchantData['maxPax'].toString()}),
            ],
          ),
          SizedBox(height: 10),
          // Normal Business hour
          Container(
            width: size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 6),
                    width: 76,
                    child: Text(
                      "ViewMerchantOutlet.Hours",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(fontSize: 12, color: Colors.black),
                    ).tr(),
                  ),
                  // Normal business hour
                  sortedList.length > 0
                      ? SizedBox(width: 8)
                      : Container(width: 0.0, height: 0.0),
                  sortedList.length > 0
                      ? Container(
                          padding: EdgeInsets.only(top: 6),
                          child: Column(
                              children: List.generate(
                                  isExpand ? sortedList.length : 1, (index) {
                            bool isNextDaySameAsPreviousDay = true;

                            if (index == 0) {
                              isNextDaySameAsPreviousDay = false;
                            } else if (index > 0) {
                              isNextDaySameAsPreviousDay = sortedList[index]
                                      ["startDay"] ==
                                  sortedList[index - 1]["startDay"];
                            }

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    child: Text(
                                      !isNextDaySameAsPreviousDay
                                          ? enumDay[sortedList[index]
                                                      ["startDay"]
                                                  .toString()] ??
                                              ''
                                          : '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                  sortedList[index]["startTime"] != null
                                      ? Container(
                                          width: 80, //80,
                                          child: Text(
                                            "${sortedList[index]["startTime"].toString()} - ${sortedList[index]["endTime"].toString()}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          child: Text(
                                            "24 Hours",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          )),
                                ],
                              ),
                            );
                          })))
                      : Container(width: 0.0, height: 0.0),
                  SizedBox(
                    width: 8,
                  ),
                  sortedList.length > 0
                      ? Container(
                          child: IconButton(
                            alignment: Alignment.topCenter,
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(!isExpand
                                ? Icons.expand_more
                                : Icons.expand_less),
                            onPressed: () {
                              setState(() {
                                isExpand = !isExpand;
                              });
                            },
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
          // Special Business hour
          (listSpecialHours != null && listSpecialHours.length > 0)
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 6),
                          width: 76,
                          child: Text(
                            "ViewMerchantOutlet.SpecialDay",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontSize: 12, color: Colors.black),
                          ).tr(),
                        ),
                        SizedBox(width: 8),
                        Container(
                            padding: EdgeInsets.only(top: 6),
                            child: Column(
                                children: List.generate(
                                    isExpandSpecialDay
                                        ? listSpecialHours.length
                                        : 1, (index) {
                              String startDate =
                                  listSpecialHours[index]["startDate"] != null
                                      ? DateFormat("dd MMM")
                                          .format(DateFormat(formatString)
                                              .parse(
                                                listSpecialHours[index]
                                                    ["startDate"],
                                                true,
                                              )
                                              .toLocal())
                                      : '';

                              bool isEndDateDiffStartDate =
                                  (listSpecialHours[index]["endDate"] !=
                                          null) &&
                                      (listSpecialHours[index]["endDate"] !=
                                          listSpecialHours[index]["startDate"]);
                              String endDate = "";
                              if (isEndDateDiffStartDate) {
                                endDate = DateFormat("dd MMM")
                                    .format(DateFormat(formatString)
                                        .parse(
                                          listSpecialHours[index]["endDate"],
                                          true,
                                        )
                                        .toLocal());
                              }

                              bool isNextDaySameAsPreviousDay = true;

                              if (index == 0) {
                                isNextDaySameAsPreviousDay = false;
                              } else if (index > 0 && startDate != '') {
                                String startDatePrevious = '';
                                String enDatePrevious = '';

                                if(listSpecialHours[index - 1]["startDate"] != null) {
                                  startDatePrevious = DateFormat("dd MMM")
                                      .format(DateFormat(formatString)
                                      .parse(
                                    listSpecialHours[index - 1]["startDate"],
                                    true,
                                  ).toLocal());
                                }

                                if(listSpecialHours[index - 1]["endDate"] != null) {
                                  enDatePrevious = DateFormat("dd MMM")
                                      .format(DateFormat(formatString)
                                      .parse(
                                    listSpecialHours[index - 1]["endDate"],
                                    true,
                                  ).toLocal());
                                }

                                isNextDaySameAsPreviousDay =
                                    (startDate == startDatePrevious) &&
                                        (endDate == enDatePrevious);
                              }

                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      child: !isNextDaySameAsPreviousDay
                                          ? RichText(
                                              text: TextSpan(children: [
                                                TextSpan(
                                                    text: startDate,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                TextSpan(
                                                    text: isEndDateDiffStartDate
                                                        ? " to "
                                                        : "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                TextSpan(
                                                    text: endDate,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                              ]),
                                            )
                                          : null,
                                    ),
                                    listSpecialHours[index]["startTime"] != null
                                        ? Container(
                                            width: 80, //80,
                                            child: Text(
                                              "${listSpecialHours[index]["startTime"].toString()} - ${listSpecialHours[index]["endTime"].toString()}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            ),
                                          )
                                        : Container(
                                            width: 80,
                                            child: Text(
                                              "24 Hours",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            )),
                                  ],
                                ),
                              );
                            }))),
                        SizedBox(
                          width: 8,
                        ),
                        listSpecialHours.length > 1
                            ? Container(
                                child: IconButton(
                                  alignment: Alignment.topCenter,
                                  iconSize: 24,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(!isExpandSpecialDay
                                      ? Icons.expand_more
                                      : Icons.expand_less),
                                  onPressed: () {
                                    setState(() {
                                      isExpandSpecialDay = !isExpandSpecialDay;
                                    });
                                  },
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                )
              : Container(),
          // Off Business hour
          (listOffDay != null && listOffDay.length > 0)
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 6),
                          width: 76,
                          child: Text(
                            "ViewMerchantOutlet.OffDay",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontSize: 12, color: Colors.black),
                          ).tr(),
                        ),
                        // Normal business hour
                        // Special day
                        SizedBox(width: 8),
                        Container(
                            padding: EdgeInsets.only(top: 6),
                            child: Column(
                                children: List.generate(
                                    isExpandOffDay ? listOffDay.length : 1,
                                    (index) {
                              String startDate =
                                  listOffDay[index]["startDate"] != null
                                      ? DateFormat("dd MMM")
                                          .format(DateFormat(formatString)
                                              .parse(
                                                listOffDay[index]["startDate"],
                                                true,
                                              )
                                              .toLocal())
                                      : '';

                              bool isEndDateDiffStartDate =
                                  (listOffDay[index]["endDate"] != null) &&
                                      (listOffDay[index]["endDate"] !=
                                          listOffDay[index]["startDate"]);
                              String endDate = "";
                              if (isEndDateDiffStartDate) {
                                endDate = DateFormat("dd MMM")
                                    .format(DateFormat(formatString)
                                        .parse(
                                          listOffDay[index]["endDate"],
                                          true,
                                        )
                                        .toLocal());
                              }

                              bool isNextDaySameAsPreviousDay = true;

                              if (index == 0) {
                                isNextDaySameAsPreviousDay = false;
                              } else if (index > 0) {
                                String startDatePrevious = '';
                                String enDatePrevious = '';

                                if(listSpecialHours[index - 1]["startDate"] != null) {
                                  startDatePrevious = DateFormat("dd MMM")
                                      .format(DateFormat(formatString)
                                      .parse(
                                    listSpecialHours[index - 1]["startDate"],
                                    true,
                                  ).toLocal());
                                }

                                if(listSpecialHours[index - 1]["endDate"] != null) {
                                  enDatePrevious = DateFormat("dd MMM")
                                      .format(DateFormat(formatString)
                                      .parse(
                                    listSpecialHours[index - 1]["endDate"],
                                    true,
                                  ).toLocal());
                                }

                                isNextDaySameAsPreviousDay =
                                    (startDate == startDatePrevious) &&
                                        (endDate == enDatePrevious);
                              }

                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      child: !isNextDaySameAsPreviousDay
                                          ? RichText(
                                              text: TextSpan(children: [
                                                TextSpan(
                                                    text: startDate,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                TextSpan(
                                                    text: isEndDateDiffStartDate
                                                        ? " to "
                                                        : "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                TextSpan(
                                                    text: endDate,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                              ]),
                                            )
                                          : null,
                                    ),
                                    Container(
                                      width: 80, //80,
                                      child: Text(
                                        "ViewMerchantOutlet.Close".tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }))),
                        SizedBox(
                          width: 8,
                        ),
                        listOffDay.length > 1
                            ? Container(
                                child: IconButton(
                                  alignment: Alignment.topCenter,
                                  iconSize: 24,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(!isExpandOffDay
                                      ? Icons.expand_more
                                      : Icons.expand_less),
                                  onPressed: () {
                                    setState(() {
                                      isExpandOffDay = !isExpandOffDay;
                                    });
                                  },
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
