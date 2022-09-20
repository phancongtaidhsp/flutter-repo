import 'package:flutter/material.dart';
// import 'Outlet.dart';
// import 'Product.dart';

class OutletProduct {
  final String id;
  Map<String, dynamic>? productInformation;
  Map<String, dynamic>? outletInformation;
  // Product product;
  // Outlet outlet;
  int? availableQuantity;
  bool? quantityResetDaily; //isOptional
  int? resetQuantity; //isOptional
  bool? isAlwaysAvailable; //isOptional
  int? numberOfRoom; //Only For ROOM product type;

  OutletProduct(
      {required this.id,
      this.productInformation,
      this.outletInformation,
      // this.product,
      // this.outlet,
      this.availableQuantity,
      this.quantityResetDaily,
      this.resetQuantity,
      this.isAlwaysAvailable,
      this.numberOfRoom});
}
