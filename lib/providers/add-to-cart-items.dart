import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/models/UserCartItem.dart';

class AddToCartItems extends ChangeNotifier {
  bool _isAvailable = true;
  double _deliveryFee = 0.0;
  double _distance = 0.0;
  double _taxAmount = 0.0;
  double _finalTotal = 0.0;
  List<Map<String, dynamic>> outletsDeliveryFee = [];
  double totalDeliveryFee = 0.00;
  double _serviceCharge = 0.00;

  bool get isAvailable => _isAvailable;
  double get deliveryFee => _deliveryFee;
  double get distance => _distance;
  double get taxAmount => _taxAmount;
  double get finalTotal => _finalTotal;
  double get serviceCharge => _serviceCharge;

  void setServiceCharge(double serviceChargeValue) {
    _serviceCharge = serviceChargeValue;
  }

  void setIsAvailable(bool isAvailable) {
    _isAvailable = isAvailable;
    notifyListeners();
  }

  void setDeliveryFee(double deliveryFee) {
    _deliveryFee = deliveryFee;
    notifyListeners();
  }

  void setDistance(double distance) {
    _distance = distance;
    notifyListeners();
  }

  void setTaxAmount(double taxAmount) {
    _taxAmount = taxAmount;
    notifyListeners();
  }

  void setFinalTotal(double finalTotal) {
    _finalTotal = finalTotal;
    notifyListeners();
  }

  //Cart
  UserCartItem? celebrationItem;
  String? selectedServiceType;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? numberOfPax;
  UserAddress? deliveryLocation;

  void addTheOutletDeliveryFee(double fee) {
    totalDeliveryFee += fee;
    notifyListeners();
  }

  void addTheOutletDeliveryFeeNoListener(double fee) {
    totalDeliveryFee += fee;
  }

  void resetTotalDeliveryFee() {
    totalDeliveryFee = 0.00;
  }

  void clearOutletsDeliveryFee() {
    outletsDeliveryFee.clear();
    notifyListeners();
  }

  String convertTime(TimeOfDay timeOfDay) {
    final now = new DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void addToCart(UserCartItem item) {
    celebrationItem = item;
    notifyListeners();
  }

  void clearCartItems() {
    celebrationItem = null;
    selectedServiceType = null;
    selectedDate = null;
    selectedTime = null;
    numberOfPax = null;
    deliveryLocation = null;
    notifyListeners();
  }

  void clearCartItemsNoListner() {
    celebrationItem = null;
    selectedServiceType = null;
    selectedDate = null;
    selectedTime = null;
    numberOfPax = null;
    deliveryLocation = null;
  }

  bool checkAnyItem() {
    if (celebrationItem != null) {
      return true;
    }
    return false;
  }

  int calculateCartItemsQuantity() {
    if (celebrationItem != null) {
      return celebrationItem!.quantity!;
    }

    return 0;
  }

  double calculateTotalPrice() {
    double totalPrice = 0.00;
    if (celebrationItem != null) {
      if (celebrationItem!.addOns.length > 0) {
        totalPrice += ((celebrationItem!.priceWhenAdded! +
                (celebrationItem!.isOutletSSTEnabled
                    ? (celebrationItem!.priceWhenAdded! * 0.06)
                    : 0) +
                (celebrationItem!.addOns
                    .map((e) =>
                        e.addOnPriceWhenAdded +
                        (celebrationItem!.isOutletSSTEnabled
                            ? (e.addOnPriceWhenAdded * 0.06)
                            : 0))
                    .reduce((a, b) => a + b))) *
            celebrationItem!.quantity!);
      } else {
        totalPrice += (celebrationItem!.priceWhenAdded! +
                (celebrationItem!.isOutletSSTEnabled
                    ? (celebrationItem!.priceWhenAdded! * 0.06)
                    : 0)) *
            celebrationItem!.quantity!;
      }
    }
    return totalPrice;
  }
}
