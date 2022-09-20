import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class UserPositionProvider extends ChangeNotifier {
  late Position _userPosition;
  double _userLatitude = 0;
  double _userLongitude = 0;

  double get userLatitude => _userLatitude;
  double get userLongitude => _userLongitude;
  Position get userPosition => _userPosition;

  void setUserPosition(Position position) {
    _userPosition = position;
    _userLatitude = position.latitude;
    _userLongitude = position.longitude;
  }
}
