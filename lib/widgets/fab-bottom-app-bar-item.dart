import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/notification-provider.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({required this.svgFileName, required this.text});
  String svgFileName;
  String text;
}

class FABBottomAppBar extends StatefulWidget {
  FABBottomAppBar({
    required this.items,
    this.centerItemText,
    this.height: 60.0,
    this.iconSize: 20.0,
    this.backgroundColor,
    required this.color,
    required this.selectedColor,
    required this.notchedShape,
    required this.onTabSelected,
    required this.selectedIndex,
  }) {
    assert(this.items.length == 2 || this.items.length == 4);
  }
  final List<FABBottomAppBarItem> items;
  final String? centerItemText;
  final double height;
  final double iconSize;
  final Color? backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;
  final int selectedIndex;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  _updateIndex(int index) {
    widget.onTabSelected(index);
  }

  Widget _buildMiddleTabItem(int fabIndex) {
    FontWeight weight =
        widget.selectedIndex == fabIndex ? FontWeight.bold : FontWeight.normal;
    Color color =
        widget.selectedIndex == fabIndex ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            SizedBox(height: 5),
            Text(
              widget.centerItemText ?? '',
              style:
                  TextStyle(color: color, fontSize: 12.0, fontWeight: weight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required FABBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    Color color =
        widget.selectedIndex == index ? widget.selectedColor : widget.color;
    FontWeight weight =
        widget.selectedIndex == index ? FontWeight.bold : FontWeight.normal;
    Color indicatorColor = widget.selectedIndex == index
        ? Theme.of(context).primaryColor
        : Colors.transparent;
    return item.text == 'General.Notifications'.tr()
        ? Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top:
                                  BorderSide(color: indicatorColor, width: 2))),
                      child: SizedBox(
                        height: widget.height,
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: () async {
                              await Provider.of<NotificationProvider>(context,
                                      listen: false)
                                  .resetNotification();
                              onPressed(index);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                //Icon(item.iconData, color: color, size: widget.iconSize),
                                SvgPicture.asset(
                                  'assets/images/${item.svgFileName}${widget.selectedIndex == index ? "-selected" : ""}.svg',
                                  height: widget.iconSize,
                                ),
                                SizedBox(height: 5),
                                FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      item.text,
                                      style: TextStyle(
                                          color: color,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  320
                                              ? 12
                                              : 11,
                                          fontWeight: weight),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    notificationProvider.notificationCounter > 0
                        ? Positioned(
                            top: 5,
                            right: 30,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 14,
                            ),
                          )
                        : const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                  ],
                ),
              );
            },
          )
        : Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(color: indicatorColor, width: 2))),
              child: SizedBox(
                height: widget.height,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => onPressed(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Icon(item.iconData, color: color, size: widget.iconSize),
                        SvgPicture.asset(
                          'assets/images/${item.svgFileName}${widget.selectedIndex == index ? "-selected" : ""}.svg',
                          height: widget.iconSize,
                        ),
                        SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            item.text,
                            style: TextStyle(
                                color: color,
                                fontSize:
                                    MediaQuery.of(context).size.width > 320
                                        ? 12
                                        : 11,
                                fontWeight: weight),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  List<Widget> items = [
    SizedBox(
      width: 0,
    )
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem(items.length));
    return BottomAppBar(
      elevation: 12.0,
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }
}
