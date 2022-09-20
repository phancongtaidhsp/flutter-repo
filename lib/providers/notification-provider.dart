import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  int _notificationCounter = 0;
  int get notificationCounter => _notificationCounter;

  Future<void> setNotification() async {
    _notificationCounter = _notificationCounter + 1;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var notificationCounter = preferences.getInt('notificationCounter') ?? 0;
    notificationCounter = notificationCounter + 1;
    preferences.setInt('notificationCounter', notificationCounter);
    notifyListeners();
  }

  Future<void> resetNotification() async {
    _notificationCounter = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt('notificationCounter', 0);
    print(preferences.getInt('notificationCounter'));

    notifyListeners();
  }
}
