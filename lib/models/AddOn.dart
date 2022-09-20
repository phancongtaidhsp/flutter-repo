class AddOn {
  String addOnOptionsId;
  double addOnPriceWhenAdded;
  String? cartItemId;
  String? name;
  String? addOnTitle;
  String? addonId;
  int? minimumSelectItem;
  bool? isMultiselect;
  bool? isRequired;
  int? maximumSelectItem;
  // isRequired: true, isMultiselect: false, minimumSelectItem: 1, maximumSelectItem: 1

  AddOn({
    required this.addOnOptionsId,
    required this.addOnPriceWhenAdded,
    this.maximumSelectItem,
    this.minimumSelectItem,
    this.isMultiselect,
    this.isRequired,
    this.cartItemId,
    this.name,
    this.addOnTitle,
    this.addonId,
  });
}
