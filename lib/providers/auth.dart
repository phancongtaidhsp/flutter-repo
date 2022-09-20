import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gem_consumer_app/screens/home/home.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CurrentUser {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? gender;
  String? lastLogin;
  bool? isAuthenticated;

  CurrentUser({
    this.id,
    this.name,
    this.email,
    this.lastLogin,
    this.phone,
    this.gender,
    this.isAuthenticated = false,
  });
}

class Auth with ChangeNotifier {
  CurrentUser _currentUser = CurrentUser();
  int _selectedIndex = 0;
  CurrentUser get currentUser => _currentUser;
  int get selectedIndex => _selectedIndex;

  bool isOpeningNewMemberPage = false;

  bool isOpeningApp = false;

  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  Future<void> checkLogin(BuildContext context, {bool isLogout = false}) async {
    var box = await Hive.openBox('tokens');
    final accessToken = box.get('at');
    final refreshToken = box.get('rt');
    var loginInfo = JwtDecoder.tryDecode(accessToken);
    print(!_currentUser.isAuthenticated!);

    if (!_currentUser.isAuthenticated! &&
        loginInfo != null &&
        accessToken != null &&
        refreshToken != null) {
      _currentUser.isAuthenticated = true;

      if(loginInfo['provider'] == 'PHONE') {
        _currentUser.phone = loginInfo['userName'];
      } else {
        _currentUser.phone = loginInfo['phone'];
        _currentUser.email = loginInfo['userName'];
      }

      _currentUser.id = loginInfo['aid'];
      _currentUser.lastLogin = loginInfo['lastSignedIn'];
      _selectedIndex = 0;
      Navigator.pushNamedAndRemoveUntil(
          context, Home.routeName, (route) => false);
    } else if (isLogout) {
      _currentUser = CurrentUser();
      _selectedIndex = 0;
      _firebaseToken = '';
    }
  }

  Future<void> logout(BuildContext context) async {
    var box = await Hive.openBox('tokens');
    await box.delete('at');
    await box.delete('rt');
    this.checkLogin(context, isLogout: true);
  }

  login(BuildContext context) async {
    this.checkLogin(context);
  }

  void setCurrentUserProfile(
      String id, String name, String email, String gender) {
    if (_currentUser.id != id ||
        _currentUser.name != name ||
        _currentUser.email != email ||
        _currentUser.gender != gender) {
      _currentUser.id = id;
      _currentUser.name = name;
      _currentUser.email = email;
      _currentUser.gender = gender;
      notifyListeners();
    }
  }

  void setUserInfo(String name, String email, String phoneNumber) {
    _currentUser.name = name;
    _currentUser.phone = phoneNumber;
    _currentUser.email = email;
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setFirebaseDeviceToken(String token) {
    _firebaseToken = token;
  }
}
