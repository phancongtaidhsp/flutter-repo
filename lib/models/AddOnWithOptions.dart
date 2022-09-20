class AddOnWithOptions {
  String name;
  String id;
  int minimumSelectItem;
  bool isMultiselect;
  bool isRequired;
  int maximumSelectItem;
  List<Map<String, dynamic>> addOnOptions;
  // isRequired: true, isMultiselect: false, minimumSelectItem: 1, maximumSelectItem: 1

  AddOnWithOptions({
    required this.maximumSelectItem,
    required this.minimumSelectItem,
    required this.isMultiselect,
    required this.isRequired,
    required this.name,
    required this.id,
    required this.addOnOptions,
  });
}
