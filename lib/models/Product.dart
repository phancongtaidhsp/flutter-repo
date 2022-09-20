import 'package:flutter/material.dart';
import 'package:gem_consumer_app/models/AddOnWithOptions.dart';
import 'AddOn.dart';

class Product {
  final String id;

  final String title;
  final String outletName;
  final String description;
  final Map<String, dynamic> outlet;
  final double originalPrice;

  final String? status;
  final String? subTitle;
  final String? productOutletId;

  final String? thumbNail;
  final String? smallThumbNail;
  final List<dynamic>? photos;
  final List<dynamic>? smallPhotos;
  final double? rating, priceWhenAdded;
  final bool? isRecommended, isNew, isMerchantDelivery;

  final List<dynamic>? productBundles;

  final String? productType;
  List<AddOn>? addOns;
  List<AddOnWithOptions>? addOnWithOptions;

  double? finalPrice;
  String? cartId; //OPTIONAL
  String? fromPage; //OPTIONAL
  String? specialInstructions;
  String? selectedCollectionType, selectedDate, selectedTime;
  int? quantity;
  int? limitQuantity;
  List? productOutlet;
  bool? isDeposit;
  bool? isDeliveredToVenue;
  String? currentDeliveryAddress;
  String? preOrderId;
  double? currentPrice;

  Product(
      {required this.id,
      required this.photos,
      this.smallPhotos,
      required this.title,
      required this.originalPrice,
      required this.description,
      required this.outletName,
      required this.outlet,
      required this.productType,
      required this.currentPrice,
      this.status,
      this.productOutletId,
      this.addOns,
      this.thumbNail,
      this.smallThumbNail,
      this.subTitle,
      this.rating = 0.0,
      this.isRecommended = false,
      this.isNew = false,
      this.isMerchantDelivery,
      this.quantity = 0,
      this.limitQuantity = 0,
      this.priceWhenAdded,
      this.isDeposit = false,
      this.finalPrice = 0.0,
      this.productOutlet,
      this.selectedCollectionType,
      this.selectedDate,
      this.selectedTime,
      this.currentDeliveryAddress,
      this.isDeliveredToVenue,
      this.specialInstructions,
      this.cartId,
      this.productBundles,
      this.preOrderId,
      this.addOnWithOptions,
      this.fromPage});

  Map<String, dynamic> toMap(Product product) {
    return {
      'id': product.id,
      'photos': product.photos,
      'title': product.title,
      'originalPrice': product.originalPrice,
      'description': product.description,
      'outletName': product.outletName,
      'outlet': product.outlet,
      'productType': product.productType,
      'status': product.status,
      'productOutletId': null,
      'addOns': null,
      'thumbNail': product.thumbNail ?? null,
      'subTitle': product.subTitle ?? null,
      'rating': 0.0,
      'isRecommended': false,
      'isNew': false,
      'isMerchantDelivery': null,
      'quantity': null,
      'limitQuantity': null,
      'priceWhenAdded': null,
      'isDeposit': false,
      'finalPrice': 0.0,
      'productOutlet': null,
      'selectedCollectionType': null,
      'selectedDate': null,
      'selectedTime': null,
      'currentDeliveryAddress': null,
      'isDeliveredToVenue': null,
      'specialInstructions': null,
      'cartId': null,
      'productBundles': null,
      'preOrderId': null,
      'fromPage': null,
      'currentPrice': product.currentPrice,
      'addOnWithOptions': product.addOnWithOptions,
    };
  }
}
