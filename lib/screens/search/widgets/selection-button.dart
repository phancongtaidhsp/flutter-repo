import 'package:flutter/material.dart';

class SelectionButton extends StatefulWidget {
  SelectionButton(this.buttonText, this.filterSelection,
      {this.selected = false});
  final String buttonText;
  final List<String> filterSelection;
  bool selected;

  @override
  _SelectionButtonState createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (widget.filterSelection.contains(widget.buttonText)) {
              widget.filterSelection.remove(widget.buttonText);
              widget.selected = false;
            } else {
              widget.filterSelection.add(widget.buttonText);
              widget.selected = true;
            }
          });
        },
        child: Chip(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          backgroundColor: widget.selected == false
              ? Colors.grey[200]
              : Color.fromRGBO(253, 196, 0, 1),
          label: Text(
            widget.buttonText,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
          ),
        ),
      ),
    );
  }
}
