import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem_consumer_app/screens/search/search_page.dart';

class SearchBar extends StatelessWidget {
  SearchBar({this.showBackButton = false});

  final bool showBackButton;
  @override
  Widget build(BuildContext context) {
    return showBackButton
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
            Widget>[
            Navigator.canPop(context)
                ? Container(
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
                        }))
                : Container(width: 0.0, height: 0.0),
            Container(
              padding: Navigator.canPop(context)
                  ? EdgeInsets.all(0.0)
                  : EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
              width: Navigator.canPop(context)
                  ? MediaQuery.of(context).size.width * 0.82
                  : MediaQuery.of(context).size.width,
              child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  readOnly: true,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SearchPage()));
                  },
                  style: Theme.of(context).textTheme.button!.copyWith(
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
                      hintText: 'Discover celebration places around you',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintStyle: TextStyle(fontSize: 12),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 31,
                        minHeight: 31,
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 20,
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 28,
                            )),
                      )),
                  keyboardType: TextInputType.text),
            ),
          ])
        : Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchPage()));
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                child: AbsorbPointer(
                  child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      readOnly: true,
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
                          labelText: 'Discover celebration places around you',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(fontSize: 12),
                          suffixIconConstraints: BoxConstraints(
                            minWidth: 31,
                            minHeight: 31,
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.all(4),
                            child: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 20,
                                child: Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 28,
                                )),
                          )),
                      keyboardType: TextInputType.text),
                ),
              ),
            ));
  }
}
