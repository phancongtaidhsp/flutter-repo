import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/values/color-helper.dart';
import 'package:gem_consumer_app/widgets/shimmer-effect.dart';

class EventCategoriesWidget extends StatefulWidget {
  final dynamic item;
  final Function selectedItem;
  final String selected;

  const EventCategoriesWidget(this.item, this.selectedItem, this.selected,
      {Key? key})
      : super(key: key);

  @override
  State<EventCategoriesWidget> createState() => _EventCategoriesWidgetState();
}

class _EventCategoriesWidgetState extends State<EventCategoriesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () => widget.selectedItem(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipOval(
                child: widget.selected == widget.item['id']
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: const Color(0xff7c94b6),
                          //borderRadius: BorderRadius.all(Radius.circular(4)),
                          border: Border.all(
                            color: primaryColor,
                            width: 4.0,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            imageUrl: widget.item['thumbNail'],
                            placeholder: (context, url) =>
                                ShimmerEffect(width: 52, height: 52),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      )
                    : ClipOval(
                        child: CachedNetworkImage(
                          width: 52,
                          height: 52,
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          colorBlendMode: BlendMode.modulate,
                          fit: BoxFit.cover,
                          imageUrl: widget.item['thumbNail'],
                          placeholder: (context, url) =>
                              ShimmerEffect(width: 52, height: 52),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      )),
            SizedBox(
              width: 72,
              child: Text(widget.item['name'],
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: Colors.black, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
