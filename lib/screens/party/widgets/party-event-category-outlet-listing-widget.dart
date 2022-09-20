import 'package:flutter/material.dart';
import 'package:gem_consumer_app/screens/party/widgets/party-merchant-outlet-list-widget.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import 'event-categories-widget.dart';

class PartyEventCategoryOutletListingWidget extends StatefulWidget {
  final List<dynamic> eventCategories;
  final List<dynamic> merchantOutletList;
  final Function outletForCategory;
  final String eventCategoryName;
  final String eventCategoryId;

  PartyEventCategoryOutletListingWidget(
    this.eventCategories,
    this.merchantOutletList,
    this.outletForCategory,
    this.eventCategoryName,
    this.eventCategoryId,
  );

  @override
  State<PartyEventCategoryOutletListingWidget> createState() =>
      _PartyEventCategoryOutletListingWidgetState();
}

class _PartyEventCategoryOutletListingWidgetState
    extends State<PartyEventCategoryOutletListingWidget> {
  var _outletLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            child: widget.eventCategories.length > 0
                ? Scrollbar(
                    child: SingleChildScrollView(
                      primary: true,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0;
                              i < widget.eventCategories.length;
                              i++)
                            EventCategoriesWidget(
                              widget.eventCategories[i],
                              () {
                                widget.outletForCategory(
                                  categoryId: widget.eventCategories[i]['id'],
                                  categoryName: widget.eventCategories[i]
                                      ['name'],
                                  pageNumber: 0,
                                );
                              },
                              widget.eventCategoryId,
                            ),
                        ],
                      ),
                    ),
                  )
                : Container(width: 0.0, height: 0.0)),
        _outletLoading
            ? SizedBox(
                height: 200,
                child: LoadingController(),
              )
            : widget.merchantOutletList.length > 0
                ? Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: MerchantOutletListWidget(
                      widget.merchantOutletList,
                      widget.eventCategoryName,
                    ),
                  )
                : Container(width: 0.0, height: 0.0),
      ],
    );
  }
}
