class UserAddress {
  final String id;
  String name;
  String address1;
  String? address2;
  String state;
  String city;
  String? postalCode;
  double longitude;
  double latitude;
  String? notes;
  bool isDefault;

  UserAddress({
    required this.id,
    required this.name,
    required this.address1,
    this.address2,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.longitude,
    required this.latitude,
    this.notes,
    this.isDefault = false,
  });
}
