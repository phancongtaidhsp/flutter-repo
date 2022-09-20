import 'package:flutter/material.dart';

class ScrollPartyProvider extends ChangeNotifier {
  int _scrollerCounter = 0;
  int get scrollerCounter => _scrollerCounter;
  bool _temp = false;

  void updateScroller() {
    _scrollerCounter = _scrollerCounter + 1;
    notifyListeners();
  }

  void updateBlock() {
    _temp = !_temp;
    notifyListeners();
  }

  void resetScroller() {
    _scrollerCounter = 0;
  }
}
