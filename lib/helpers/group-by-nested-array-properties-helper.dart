import 'package:collection/collection.dart';

class GroupByArray {
  static Map<String, List<dynamic>> groupByArray(
      List<dynamic> d, List<dynamic> categoriesList) {
    List<Map<String, dynamic>> tempList = [];
    d.forEach((element) {
      List list = element["productCategories"] as List;
      list.forEach((each) {
        tempList.add({...element, "key": each["category"]["name"]});
      });
    });

    Map<String, List<dynamic>> newMap = groupBy(tempList, (obj) {
      obj as Map;
      return obj['key'];
    });

    Map<String, List<dynamic>> newMap2 = {};
    categoriesList.sort((a, b) => a['order'].compareTo(b['order']));

    categoriesList.forEach((cat) {
      String name = cat["name"];
      if (newMap.keys.contains(name)) {
        newMap2.putIfAbsent(name, () => newMap["$name"]!);
      }
    });
    return newMap2;
  }
}
