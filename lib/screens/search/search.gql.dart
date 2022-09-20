class AlgoliaGQL {
  static const ALGOLIA_SEARCH = """
    query SearchProducts(\$queryPattern: GetProductsInput!, \$selectedServiceType: String!, \$selectedDate: String!, \$pax:Int,\$userLatitude: Float, \$userLongitude: Float){
    SearchProducts(queryPattern: \$queryPattern, selectedServiceType: \$selectedServiceType, selectedDate: \$selectedDate, pax:\$pax, userLatitude:\$userLatitude, userLongitude:\$userLongitude){
       items,
       totalPages,
       totalItems,
       facets
    }
}
  """;
}
