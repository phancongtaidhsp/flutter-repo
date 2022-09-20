import 'AddOn.dart';

class UserCartItem {
  String? id;
  Map<String, dynamic> outletProductInformation;
  String? preOrderId;
  double? priceWhenAdded; // Only Product Itself Current Price
  String? serviceType;
  String? serviceDate;
  String? serviceTime;
  int? quantity;
  String? currentDeliveryAddress;
  String? specialInstructions;
  bool? isDeliveredToVenue;
  bool? isDeposit;
  bool? isMerchantDelivery;
  double? latitude;
  double? longitude;
  List<AddOn> addOns;
  double? finalPrice; // Product Current Price + Total AddOns Price
  bool? checkAnyError;
  String? errorMessage;
  double? merchantSST;
  double? distance;
  bool isOutletSSTEnabled;
  DateTime? selectedDateTime;

  UserCartItem(
      {this.id,
      required this.outletProductInformation,
      this.preOrderId,
      this.priceWhenAdded,
      this.serviceType,
      this.serviceDate,
      this.serviceTime,
      this.quantity,
      this.isOutletSSTEnabled = false,
      required this.addOns,
      this.finalPrice,
      this.currentDeliveryAddress,
      this.specialInstructions,
      this.isDeliveredToVenue,
      this.isDeposit,
      this.isMerchantDelivery,
      this.latitude,
      this.longitude,
      this.checkAnyError = false,
      this.errorMessage,
      this.merchantSST,
      this.distance});
}
