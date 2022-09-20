class CelebrationGQL {
  static const String GET_TIME_SLOTS = """
 query GetTimeSlot(\$productOutletId: String!,\$selectedServiceType:String!, \$selectedDate:String!) {
  GetTimeSlot(productOutletId:\$productOutletId, selectedServiceType: \$selectedServiceType, selectedDate:\$selectedDate) {
   TimeSlotList
  }
}
  """;

  static const String GET_ALL_CUISINES = """
  query{
    Cuisines{
      id
      name
    }
  }
  """;

  static const String GET_ALL_AMENITIES = """
  query{
    Amenities{
      id
      name
    }
  }
  """;

  static const String GET_ALL_SPECIAL_DIETS = """
  query{
    SpecialDiets{
      id
      name
    }
  }
  """;

  static const String GET_PRODUCT_CATEGORIES_BY_TYPE = """
  query ProductCategoriesByType(\$productType: String!){
    ProductCategoriesByType(productType: \$productType){
      id
      name
    }
  }
  """;

  static const String GET_ALL_OUTLET_LOCATIONS = """
    query{
      OutletLocations
    }
  """;
}
