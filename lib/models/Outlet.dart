import 'package:flutter/material.dart';

class Outlet {
  final String id;
  String? name;
  String? thumbNail;
  List<String>? photos;
  String? merchantId;
  String? email;
  String? countryId;
  String? address1;
  String? address2;
  String? state;
  String? city;
  int? postalCode;
  String? location;
  int? maxPax;
  String? introduction;
  double? latitude;
  double? longitude;
  int? maxDeliveryKM;
  double? deliveryFeePerKM;
  int? firstNthKM;
  double? firstNthKMDeliveryFee;
  String? remark;
  String? commissionType;
  double? commissionRate;

  Outlet({
    required this.id,
    this.name,
    this.thumbNail,
    this.photos,
    this.merchantId,
    this.email,
    this.countryId,
    this.address1,
    this.address2,
    this.state,
    this.city,
    this.postalCode,
    this.location,
    this.maxPax,
    this.introduction,
    this.latitude,
    this.longitude,
    this.maxDeliveryKM,
    this.deliveryFeePerKM,
    this.firstNthKM,
    this.firstNthKMDeliveryFee,
    this.remark,
    this.commissionType,
    this.commissionRate,
  });
}
