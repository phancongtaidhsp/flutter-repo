import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  //SmartFilter
  bool _recommended = false;
  List<String> _productCategorySelection = [];
  List<String> _serviceTypeSelection = [];
  int _maxPax = 0;

  bool get recommended => _recommended;
  List<String> get productCategorySelection => _productCategorySelection;
  List<String> get serviceTypeSelection => _serviceTypeSelection;
  int get maxPax => _maxPax;

  set recommended(bool isSelected) {
    _recommended = isSelected;
    notifyListeners();
  }

  set productCategorySelection(List<String> selectedList) {
    _productCategorySelection = selectedList;
    notifyListeners();
  }

  set serviceTypeSelection(List<String> selectedList) {
    _serviceTypeSelection = selectedList;
    notifyListeners();
  }

  set maxPax(int pax) {
    _maxPax = pax;
    notifyListeners();
  }

  set maxPaxNoListener(int pax) {
    _maxPax = pax;
  }

  bool isRecommended() {
    if (recommended) {
      return true;
    }
    return false;
  }

  bool isProductCategorySelected() {
    if (productCategorySelection.length > 0) {
      return true;
    }
    return false;
  }

  bool isServiceTypeSelected() {
    if (serviceTypeSelection.length > 0) {
      return true;
    }
    return false;
  }

  void clearSmartFilterSelection() {
    _recommended = false;
    _productCategorySelection.clear();
    _serviceTypeSelection.clear();
    notifyListeners();
  }

  //AdvancedFilter
  List<int> _priceIndicatorSelection = [];
  List<String> _locationSelection = [];
  List<String> _cuisineSelection = [];
  List<String> _specialDietSelection = [];
  List<String> _amenitySelection = [];

  List<int> get priceIndicatorSelection => _priceIndicatorSelection;
  List<String> get locationSelection => _locationSelection;
  List<String> get cuisineSelection => _cuisineSelection;
  List<String> get specialDietSelection => _specialDietSelection;
  List<String> get amenitySelection => _amenitySelection;

  set priceIndicatorSelection(List<int> selectionList) {
    _priceIndicatorSelection = selectionList;
    notifyListeners();
  }

  set locationSelection(List<String> selectionList) {
    _locationSelection = selectionList;
    notifyListeners();
  }

  set cuisineSelection(List<String> selectionList) {
    _cuisineSelection = selectionList;
    notifyListeners();
  }

  set specialDietSelection(List<String> selectionList) {
    _specialDietSelection = selectionList;
    notifyListeners();
  }

  set amenitySelection(List<String> selectionList) {
    _amenitySelection = selectionList;
    notifyListeners();
  }

  bool isAnyAdvancedFilterSelected() {
    if (_priceIndicatorSelection.length +
            _locationSelection.length +
            _cuisineSelection.length +
            _specialDietSelection.length +
            _amenitySelection.length >
        0) {
      return true;
    }
    return false;
  }

  //Clear All Filter
  void clearAdvancedFilterAndSmartFilter() {
    _recommended = false;
    _productCategorySelection.clear();
    _serviceTypeSelection.clear();
    _priceIndicatorSelection.clear();
    _locationSelection.clear();
    _cuisineSelection.clear();
    _specialDietSelection.clear();
    _amenitySelection.clear();
    notifyListeners();
  }

  void clearAdvancedFilterAndSmartFilterNoListener() {
    _recommended = false;
    _productCategorySelection.clear();
    _serviceTypeSelection.clear();
    _priceIndicatorSelection.clear();
    _locationSelection.clear();
    _cuisineSelection.clear();
    _specialDietSelection.clear();
    _amenitySelection.clear();
  }
}
