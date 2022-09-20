class MerchantOutletGQL {
  static const String GET_MERCHANT_OUTLET_PHOTOS = """
  query GetMerchantOutlet(\$id: String!) {
    MerchantOutlet(id:\$id) {
      photos,
    }
  }
  """;

  static const String GET_MERCHANT_OUTLET = """
  query GetMerchantOutlet(\$id: String!, \$userLatitude: Float!, \$userLongitude: Float!) {
    MerchantOutlet(id:\$id, userLatitude: \$userLatitude, userLongitude: \$userLongitude) {
      id,
      name,
      photos,
      address1,
      address2,
      collectionTypes {
        type
        maxDeliveryKM,
        firstNthKM,
        firstNthKMDeliveryFee,
        deliveryFeePerKM
      },
      state,
      priceRange,
      city,
      postalCode,
      location,
      maxPax,
      introduction,
      latitude,
      longitude,
      remark,
      deliveryFeePerKM,
      firstNthKM,
      firstNthKMDeliveryFee,
      distance,
      reviewScore,
      phones {
        contactNo
      }
      reviews {
        id,
        content,
        isHidden
        user {
          id,
          displayName,
          photoUrl
        }
        reviewPhotos,
        createdAt,
        score
      },
      merchant {
          id,
          name
      },
      amenities {
        amenity {
          name
        }
      },
      businessHours {
          name
          startDate,
          endDate,
          startDay,
          endDay,
          startTime,
          endTime,
          isNormalBusinessHour,
          isClosed
      },
      businessCategories {
        businessCategory {
            name
        }
      },
      productCategories {
        category {
          id,
          name,
          productType
        },
        order
      },
      productOutlets {
        id,
        availableQuantity,
        isAlwaysAvailable,
        menuItemBusinessHours {
          day,
          startTime,
          endTime,
          startDate,
          endDate,
        },
        productCategories {
          category {
            id,
            name,
            productType
          }
        },
        collectionTypes {
          type
        },
        product {
          id,
          title,
          subTitle,
          pax,
          description,
          thumbNail,
          smallThumbNail,
          photos,
          currentPrice,
          originalPrice,
          isNew,
          isRecommended,
          productType
        },
        outlet {
          id
          name
          address1
          merchant {
            id
            name
          }
          collectionTypes {
            id
            type
            timeSlots
            collectionCutoffPeriod
            orderSlots {
              startTime
              endTime
              orderSlot
            }
          }
          amenities {
            amenity {
              name
            }
          }
          businessHours {
            name
            startDay
            endDay
            startTime
            endTime
          }
        }
      }
    }
  }
  """;
}
