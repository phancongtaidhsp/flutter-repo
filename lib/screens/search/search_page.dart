import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/configuration.dart';
import 'package:gem_consumer_app/screens/search/search_result_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  static const historyLength = 5;

  //Local Storage
  late final Box historyBox;
  late List<String> userSearchHistory;
  late List<String> trendingSearchList;

  void _addHistory(String term) {
    if (term != '') {
      if (userSearchHistory.contains(term)) {
        _moveTerm(term);
      } else {
        userSearchHistory.add(term);
        if (userSearchHistory.length > historyLength) {
          userSearchHistory.removeRange(
              0, userSearchHistory.length - historyLength);
        }
        historyBox.put('history', userSearchHistory);
      }
    }
  }

  void _deleteTerm(String term) {
    userSearchHistory.removeWhere((element) => element == term);
    historyBox.put('history', userSearchHistory);
  }

  void _moveTerm(String term) {
    _deleteTerm(term);
    _addHistory(term);
  }

  @override
  void initState() {
    historyBox = Hive.box('searchHistory');
    userSearchHistory = historyBox.get("history", defaultValue: <String>[]);
    trendingSearchList = Configuration.TRENDING_SEARCH_KEYWORDS;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
        child: Scaffold(
            body: Stack(children: [
      Positioned(
          top: 10,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                  Widget>[
            Container(
                height: 36.0,
                width: 56.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1)),
                    ]),
                child: IconButton(
                    icon: SvgPicture.asset('assets/images/icon-back.svg'),
                    iconSize: 36.0,
                    onPressed: () {
                      Navigator.pop(context);
                    })),
            Container(
              width: size.width * 0.82,
              child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _controller,
                  onTap: () {
                    _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length));
                  },
                  onChanged: (text) {},
                  onFieldSubmitted: (text) {
                    setState(() {
                      _addHistory(text);
                    });
                    _controller.clear();
                    Navigator.pushNamed(context, SearchResultPage.routeName,
                        arguments: SearchResultPageArguments(text));
                  },
                  style: textTheme.button!.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(23.0),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                      labelText: 'Search Product or Merchant...',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: TextStyle(fontSize: 12),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 31,
                        minHeight: 31,
                      ),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _addHistory(_controller.text);
                            });

                            Navigator.pushNamed(
                                context, SearchResultPage.routeName,
                                arguments: SearchResultPageArguments(
                                    _controller.text));
                            _controller.clear();
                          },
                          child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 20,
                              child: Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 28,
                              )))),
                  keyboardType: TextInputType.text),
            ),
          ])),
      Positioned(
          top: 70,
          child: SingleChildScrollView(
              child: Column(children: [
            userSearchHistory.length > 0
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                    color: Colors.white,
                    width: size.width,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Search.RecentSearches",
                              style: textTheme.button!.copyWith(
                                fontWeight: FontWeight.normal,
                              )).tr(),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                              children: List.generate(
                                  userSearchHistory.reversed.length,
                                  (index) => Row(children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                Navigator.pushNamed(context,
                                                    SearchResultPage.routeName,
                                                    arguments:
                                                        SearchResultPageArguments(
                                                            userSearchHistory
                                                                .reversed
                                                                .elementAt(
                                                                    index)));
                                                _moveTerm(userSearchHistory
                                                    .reversed
                                                    .elementAt(index));
                                              });
                                            },
                                            child: Text(
                                                userSearchHistory.reversed
                                                    .elementAt(index),
                                                style:
                                                    textTheme.button!.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                ))),
                                        Spacer(),
                                        IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {});
                                              _deleteTerm(
                                                userSearchHistory.reversed
                                                    .elementAt(index),
                                              );
                                            })
                                      ])))
                        ]))
                : Container(width: 0.0, height: 0.0),
            SizedBox(
              height: 10,
              width: MediaQuery.of(context).size.width,
            ),
            trendingSearchList.length > 0
                ? Container(
                    padding: EdgeInsets.all(20),
                    color: Colors.white,
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Search.TrendingSearches",
                            style: textTheme.button!.copyWith(
                              fontWeight: FontWeight.normal,
                            )).tr(),
                        SizedBox(
                          height: 10,
                        ),
                        Wrap(
                            spacing: 10,
                            direction: Axis.horizontal,
                            children: List.generate(
                              trendingSearchList.length,
                              (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.pushNamed(
                                          context, SearchResultPage.routeName,
                                          arguments: SearchResultPageArguments(
                                              trendingSearchList
                                                  .elementAt(index)));
                                      _addHistory(
                                          trendingSearchList.elementAt(index));
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 19, vertical: 10),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: Offset(0,
                                              2), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      trendingSearchList.elementAt(index),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12),
                                    ),
                                    // Chip(
                                    //   backgroundColor: Colors.grey[200],
                                    //   label: Text(
                                    //     trendingSearchList.elementAt(index),
                                    //     style: Theme.of(context)
                                    //         .textTheme
                                    //         .subtitle2!
                                    //         .copyWith(
                                    //             fontWeight: FontWeight.normal,
                                    //             fontSize: 12),
                                    //   ),
                                  )),
                            ))
                      ],
                    ))
                : Container(
                    width: 0,
                    height: 0,
                  ),
            SizedBox(
              height: 10,
              width: size.width,
            ),
            // Container(
            //   padding: EdgeInsets.all(20),
            //   color: Colors.white,
            //   width: size.width,
            //   child: Text("Search.TopCuisines",
            //       style: textTheme.button.copyWith(
            //         fontWeight: FontWeight.normal,
            //       )).tr(),
            // )
          ])))
    ])));
  }
}
