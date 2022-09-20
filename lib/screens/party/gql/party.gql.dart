class PartyGQL {
  static const String GET_EVENT_CATEGORIES = """
  query EventCategories {
    EventCategories {
      id,
      name,
      thumbNail,
      order
    }
  }
  """;

  static const String GET_OUTLETS = """
  query GetOutlets(\$merchantOutlet: GetMerchantOutletsInput!,\$filterSelection: FilterMerchantOutletsInput, \$searchText: String, \$productType:String!,\$userLatitude: Float!, \$userLongitude: Float!, \$selectedServiceType:String!, \$venueOutletId:String, \$selectedServiceTime:String!) {
    Outlets(merchantOutlet: \$merchantOutlet, filterSelection: \$filterSelection, searchText:\$searchText,productType:\$productType, userLatitude:\$userLatitude,userLongitude:\$userLongitude, selectedServiceType:\$selectedServiceType, venueOutletId:\$venueOutletId, selectedServiceTime: \$selectedServiceTime) {
      id,
      tags,
      thumbNail,
      name,
      maxPax,
      maxDeliveryKM,
      longitude,
      latitude,
      location,
      priceRange,
      isSSTEnabled,
      productOutlets {
        product {
          productType
          productCategories{
              category{
                  name
              }
          }
        }
      },
      reviews {
        id,
        score
      },
      merchant {
        id,
        name,
        photoUrl
        photos
        merchantOutlets{
          id
        }
      },
      amenities {
        amenity {
          name
        }
      },
      collectionTypes {
        type,
        maxDeliveryKM,
        firstNthKM,
        firstNthKMDeliveryFee,
        deliveryFeePerKM
      },
      distance
      reviewScore
    }
  }
  """;

  static const String GET_MERCHANT_OUTLET_BY_MERCHANT_ID = """
  query GetMerchantOutletsByMerchantId(\$selectedServiceTime: String!, \$selectedServiceType: String!, \$merchantId: String!, \$userLatitude: Float!, \$userLongitude: Float! \$productType: String!) {
    GetMerchantOutletsByMerchantId(selectedServiceTime: \$selectedServiceTime, selectedServiceType: \$selectedServiceType, merchantId: \$merchantId, userLatitude: \$userLatitude, userLongitude: \$userLongitude, productType: \$productType) {
      id,
      name,
      thumbNail,
      maxPax,
      maxDeliveryKM,
      distance,
      longitude,
      latitude,
      location,
      priceRange,
      collectionTypes {
        type,
        maxDeliveryKM
      },
      amenities {
        amenity {
            name
        }
      },
      reviewScore,
      distance
    }
  }
  """;

  static const String GET_FEATURED_VENUE_MERCHANT_OUTLETS = """
   query GetFeaturedVenueMerchantOutlets(\$userLatitude: Float!,\$userLongitude: Float!) {
    GetFeaturedVenueMerchantOutlets(userLatitude: \$userLatitude, userLongitude: \$userLongitude) {
      id,
      thumbNail,
      name,
      maxPax,
      maxDeliveryKM,
      longitude,
      latitude,
      location,
      priceRange,
      merchant {
        id,
        name,
        merchantOutlets{
          id
        }
      },
      amenities {
        amenity {
          name
        }
      },
      collectionTypes {
        type
        maxDeliveryKM,
        firstNthKM,
        firstNthKMDeliveryFee,
        deliveryFeePerKM
      }
      distance
      reviewScore
    }
  }
  """;

  static const String GET_MERCHANT_OUTLETS_WITH_FOOD_PRODUCT = """
  query GetMerchantOutletsWithFoodProduct(\$userLatitude: Float!,\$userLongitude: Float!) {
    GetMerchantOutletsWithFoodProduct(userLatitude: \$userLatitude, userLongitude: \$userLongitude) {
      id,
      thumbNail,
      name,
      maxPax,
      maxDeliveryKM,
      longitude,
      latitude,
      location,
      priceRange,
      merchant {
        id,
        name,
      },
      amenities {
        amenity {
          name
        }
      },
      collectionTypes {
        type
      }
      distance
      reviewScore
    }
  }
  """;

  static const String GET_MERCHANT_OUTLETS_WITH_GIFT_PRODUCT = """
  query GetMerchantOutletsWithGiftProduct(\$userLatitude: Float!,\$userLongitude: Float!) {
    GetMerchantOutletsWithGiftProduct(userLatitude: \$userLatitude, userLongitude: \$userLongitude) {
      id,
      thumbNail,
      name,
      maxPax,
      maxDeliveryKM,
      longitude,
      latitude,
      location,
      priceRange,
      merchant {
        id,
        name,
      },
      amenities {
        amenity {
          name
        }
      },
      collectionTypes {
        type
      }
      distance
      reviewScore
    }
  }
  """;

  static const String GET_MERCHANT_OUTLETS_WITH_ROOM_PRODUCT = """
  query GetMerchantOutletsWithRoomProduct(\$userLatitude: Float!,\$userLongitude: Float!) {
    GetMerchantOutletsWithRoomProduct(userLatitude: \$userLatitude, userLongitude: \$userLongitude) {
      id,
      thumbNail,
      name,
      maxPax,
      maxDeliveryKM,
      longitude,
      latitude,
      location,
      priceRange,
      merchant {
        id,
        name,
      },
      amenities {
        amenity {
          name
        }
      },
      collectionTypes {
        type
      }
      distance
      reviewScore
    }
  }
  """;

  static const String GET_VENUE_MERCHANT_OUTLETS_BY_EVENT_CATEGORY = """
  query GetVenueMerchantOutletsByEventCategory(\$userLatitude:Float!,\$userLongitude: Float!, \$eventCategoryId: String!,\$pageNumber: Int!, \$takeNumber: Int!, \$totalCount: Int) {
    getVenueMerchantOutletsByEventCategory(userLatitude: \$userLatitude, userLongitude: \$userLongitude,eventCategoryId: \$eventCategoryId, pageNumber: \$pageNumber,takeNumber: \$takeNumber, totalCount: \$totalCount) {
      hasNext
      totalCount
      merchantOutlets {
        id
        thumbNail
        tags
        name
        maxPax
        maxDeliveryKM
        longitude
        latitude
        location
        priceRange
        merchant {
          id
          name
          merchantOutlets {
            id
          }
        }
        amenities {
          amenity {
            name
          }
        }
        collectionTypes {
          type
          maxDeliveryKM
          firstNthKM
          firstNthKMDeliveryFee
          deliveryFeePerKM
        }
        distance
        reviewScore
      }
    }
  }
  """;
}
