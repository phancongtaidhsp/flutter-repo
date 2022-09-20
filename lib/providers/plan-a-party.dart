import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';

class PlanAParty extends ChangeNotifier {
  String? _eventName;
  UserAddress? _eventDeliveryAddress;
  String? _eventCategory;
  DateTime? _eventDate;
  String? _eventTimeStr;
  TimeOfDay? _eventTime;
  String? _eventCollectionType;
  int? _eventPax;
  List<String>? _eventDemands;
  int? _planCurrentStep = 0;

  UserCartItem? _venueProduct;
  List<UserCartItem>? _fbProducts = [];
  List<UserCartItem>? _decorationProducts = [];

  //FOR: check currentVenueProduct any FB or Deco
  bool _currentVenueAnyFB = false;
  bool _currentVenueAnyDeco = false;

  String? _currentSelectedOutletId;
  String? get outletId => _currentSelectedOutletId ?? null;

  String? _featuredVenueOutletId;
  String? get featuredVenueOutletId => _featuredVenueOutletId ?? null;

  List<String>? get demands => _eventDemands;
  String? get name => _eventName;
  UserAddress? get deliveryAddress => _eventDeliveryAddress;
  DateTime? get date => _eventDate;
  String? get time => _eventTimeStr;
  TimeOfDay? get timeOfDay => _eventTime;
  String? get collectionType => _eventCollectionType;
  String? get eventCategory => _eventCategory;
  int? get pax => _eventPax;
  int? get planCurrentStep => _planCurrentStep;
  UserCartItem? get venueProduct => _venueProduct;
  List<UserCartItem>? get fbProducts => _fbProducts;
  List<UserCartItem>? get decorationProducts => _decorationProducts;
  bool get currentVenueAnyFB => _currentVenueAnyFB;
  bool get currentVenueAnyDeco => _currentVenueAnyDeco;

  void setFeaturedVenueOutletId(String value) {
    _featuredVenueOutletId = value;
  }

  void setOutletId(String value) {
    _currentSelectedOutletId = value;
  }

  void setCurrentVenueAnyFB(bool value) {
    _currentVenueAnyFB = value;
  }

  void setCurrentVenueAnyDeco(bool value) {
    _currentVenueAnyDeco = value;
  }

  void setEventName(String value) {
    _eventName = value;
    notifyListeners();
  }

  void setEventPax(int value) {
    _eventPax = value;
    notifyListeners();
  }

  void setEventCategory(String value) {
    _eventCategory = value;
    notifyListeners();
  }

  void setEventDeliveryAddress(UserAddress? value) {
    _eventDeliveryAddress = value;
    notifyListeners();
  }

  void setEventDate(DateTime value) {
    _eventDate = value;
    notifyListeners();
  }

  void setEventTime(TimeOfDay value) {
    _eventTimeStr = convertTime(value);
    _eventTime = value;
    notifyListeners();
  }

  void setEventDemands(List<String> value) {
    _eventDemands = value;
    notifyListeners();
  }

  void setEventCollectionType(String value) {
    _eventCollectionType = value;
    notifyListeners();
  }

  void setCurrentStep(int value) {
    _planCurrentStep = value;
    notifyListeners();
  }

  void setCurrentStepNoListener(int value) {
    _planCurrentStep = value;
  }

  void setVenueProduct(UserCartItem product) {
    _venueProduct = product;
    notifyListeners();
  }

  void setVenueProductNoListener(UserCartItem product) {
    _venueProduct = product;
  }

  void setFBProducts(List<UserCartItem> productList) {
    _fbProducts = productList;
    notifyListeners();
  }

  void setDecorationProducts(List<UserCartItem> productList) {
    _decorationProducts = productList;
    notifyListeners();
  }

  void addFBProduct(UserCartItem product) {
    _fbProducts?.add(product);
    notifyListeners();
  }

  void addFBProductNoListener(UserCartItem product) {
    _fbProducts?.add(product);
  }

  void addDecorationProduct(UserCartItem product) {
    _decorationProducts?.add(product);
    notifyListeners();
  }

  void addDecorationProductNoListener(UserCartItem product) {
    _decorationProducts?.add(product);
  }

  void resetParty() {
    _eventName = null;
    _eventCategory = null;
    _eventDate = null;
    _eventTime = null;
    _eventTimeStr = null;
    _eventDeliveryAddress = null;
    _eventCollectionType = null;
    _eventDemands = [];
    _planCurrentStep = 0;
    _venueProduct = null;
    _fbProducts = [];
    _decorationProducts = [];
    _currentVenueAnyDeco = false;
    _currentVenueAnyFB = false;
    _featuredVenueOutletId = null;
    notifyListeners();
  }

  String convertTime(TimeOfDay timeOfDay) {
    final now = new DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  bool checkAnyItem() {
    var decorationProductsLength = 0;
    var fbProductsLength = 0;
    if (decorationProducts != null) {
      decorationProductsLength = decorationProducts!.length;
    }
    if (fbProducts != null) {
      fbProductsLength = fbProducts!.length;
    }
    if (venueProduct != null ||
        decorationProductsLength > 0 ||
        fbProductsLength > 0) {
      return true;
    }
    return false;
  }

  void clearPartyItems() {
    _planCurrentStep = 0;
    _venueProduct = null;
    _fbProducts = [];
    _decorationProducts = [];
    _currentVenueAnyDeco = false;
    _currentVenueAnyFB = false;
    _featuredVenueOutletId = null;
    notifyListeners();
  }

  void clearPartyItemsNoListner() {
    _venueProduct = null;
    _fbProducts = [];
    _decorationProducts = [];
    // _currentVenueAnyDeco = false;
    // _currentVenueAnyFB = false;
    _featuredVenueOutletId = null;
  }

  void clearVenueItemsOnly() {
    _venueProduct = null;
    notifyListeners();
  }

  void arrangeDemandsOrder() {
    if (_eventDemands != null) {
      List<String> tempDemandsList = [];
      if (_eventDemands!.contains("VENUE")) {
        tempDemandsList.add("VENUE");
      }
      if (_eventDemands!.contains("F&B")) {
        tempDemandsList.add("F&B");
      }
      if (_eventDemands!.contains("DECORATION")) {
        tempDemandsList.add("DECORATION");
      }
      _eventDemands = List.from(tempDemandsList);
    }
  }

  bool checkIsSelectedOutlet(String outletId) {
    int times = 0;
    if (_venueProduct != null) {
      if (_venueProduct!.outletProductInformation["outlet"]["id"] == outletId) {
        times += 1;
      }
    }
    if (_fbProducts != null) {
      bool selected = false;
      _fbProducts!.forEach((fbProduct) {
        if (fbProduct.outletProductInformation["outlet"]["id"] == outletId) {
          selected = true;
        }
      });
      if (selected) {
        times += 1;
      }
    }
    if (_decorationProducts != null) {
      bool selected = false;
      _decorationProducts!.forEach((decoProduct) {
        if (decoProduct.outletProductInformation["outlet"]["id"] == outletId) {
          selected = true;
        }
      });
      if (selected) {
        times += 1;
      }
    }
    if (times > 1) {
      return true;
    } else {
      return false;
    }
  }

  void updateItem(UserCartItem updateProduct) {
    if (updateProduct.outletProductInformation["product"]["productType"] ==
        "GIFT") {
      if (_decorationProducts != null) {
        int index = _decorationProducts!.indexWhere((element) =>
            element.outletProductInformation["product"]["id"] ==
            updateProduct.outletProductInformation["product"]["id"]);
        if (index >= 0) {
          _decorationProducts![index] = updateProduct;
        }
      }
    }
    if (updateProduct.outletProductInformation["product"]["productType"] ==
        "FOOD") {
      if (_fbProducts != null) {
        int index = _fbProducts!.indexWhere((element) =>
            element.outletProductInformation["product"]["id"] ==
            updateProduct.outletProductInformation["product"]["id"]);
        if (index >= 0) {
          _fbProducts![index] = updateProduct;
        }
      }
    }
    notifyListeners();
  }

  void removeItem(String productId, String productType) {
    if (productType == "GIFT") {
      if (_decorationProducts != null) {
        _decorationProducts!.removeWhere((element) =>
            element.outletProductInformation["product"]["id"] == productId);
      }
    }
    if (productType == "FOOD") {
      if (_fbProducts != null) {
        _fbProducts!.removeWhere((element) =>
            element.outletProductInformation["product"]["id"] == productId);
      }
    }
    notifyListeners();
  }

  int countCartItem() {
    int numberItem = 0;
    if (_venueProduct != null) {
      numberItem = _venueProduct!.quantity ?? 1;
    }

    _fbProducts!.forEach((element) {
      numberItem += element.quantity ?? 0;
    });

    _decorationProducts!.forEach((element) {
      numberItem += element.quantity ?? 0;
    });

    return numberItem;
  }

  double calculatedTotalCartItemPrice() {
    double totalPrice = 0;
    if (_venueProduct != null) {
      totalPrice += _venueProduct!.isOutletSSTEnabled
          ? (_venueProduct!.quantity ?? 1) * (_venueProduct!.finalPrice! * 1.06)
          : (_venueProduct!.quantity ?? 1) * (_venueProduct!.finalPrice ?? 0);
    }

    _fbProducts!.forEach((element) {
      totalPrice += element.isOutletSSTEnabled
          ? (element.quantity ?? 1) * (element.finalPrice! * 1.06)
          : (element.quantity ?? 1) * (element.finalPrice ?? 0);
    });
    _decorationProducts!.forEach((element) {
      totalPrice += element.isOutletSSTEnabled
          ? (element.quantity ?? 1) * (element.finalPrice! * 1.06)
          : (element.quantity ?? 1) * (element.finalPrice ?? 0);
    });

    return totalPrice;
  }

  double calculateServiceCharge() {
    double serviceCharge = 0;
    double serviceChargeRate = 0;
    if (_venueProduct != null &&
        _currentVenueAnyFB &&
        _fbProducts != null &&
        _fbProducts!.length > 0) {
      var collectionTypes = (_venueProduct!.outletProductInformation["outlet"]
              ["collectionTypes"] as List)
          .firstWhere((element) => element["type"] == "DINE_IN",
              orElse: () => null);
      if (collectionTypes != null)
        serviceChargeRate = collectionTypes["serviceChargeRate"] / 100;
      _fbProducts!.forEach((element) {
        serviceCharge +=
            (element.quantity ?? 1) * (element.finalPrice! * serviceChargeRate);
      });
    }

    return serviceCharge;
  }
}
