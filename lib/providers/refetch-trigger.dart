import 'package:flutter/material.dart';

class RefetchTrigger with ChangeNotifier {
  bool _banner = false;
  bool get banner => _banner;

  void refetchBanner() {
    _banner = true;
    notifyListeners();
  }

  void completeBannerRefetch() {
    _banner = false;
  }
}
