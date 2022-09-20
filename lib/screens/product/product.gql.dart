class ProductGQL {
  static const String GET_PRODUCT_PHOTOS = """
  query GetProduct(\$id: String!) {
    Product(id:\$id) {
      photos
      smallPhotos
    }
  }
  """;

  static const String GET_PRODUCT = """
  query GetProduct(\$id: String!) {
    Product(id: \$id) {
      id
      title
      subTitle
      pax
      remarks
      description
      productType
      thumbNail
      smallThumbNail
      photos
      smallPhotos
      currentPrice
      originalPrice
      isNew
      isRecommended
      isMerchantDelivery
      minimumSpend
      productBundles {
        quantity
        product {
          id
          title
          subTitle
          pax
          description
          thumbNail
          smallThumbNail
          photos
          currentPrice
          originalPrice
          isNew
          isRecommended
          isMerchantDelivery
          productType
             productAddons {
                id
                name
                isRequired
                isMultiselect
                minimumSelectItem
                maximumSelectItem
                productAddonOptions {
                  id
                  name
                  price
                  order
                }
          },
          productOutlets {
            id,
            availableQuantity
            outlet {
              isSSTEnabled,
              id
              address1
              state
              maxPax,
              latitude,
              longitude
              city
              postalCode
              name
            }
            collectionTypes {
              type
            }
          }
        }
      }
      productOutlets {
        id,
        availableQuantity
        isAlwaysAvailable,
        menuItemBusinessHours {
          day,
          startTime,
          endTime,
          startDate,
          endDate,
        },
        outlet {
          id,
          name,        
          isSSTEnabled,
          address1,
          thumbNail,
          priceRange,
          latitude,
          longitude
          maxPax,
          state,
          city,
          postalCode,
          isSSTEnabled,
          businessCategories {
            businessCategory {
              name
            }
          },
          reviews {
            id,
            score
          },
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
        collectionTypes {
          type
        }
        productCategories {
          category {
            name
          }
        }
      }
    }
  }


    """;

  static const String GET_PRODUCT_OUTLET_BY_ID = """
 query GetProductOutlet(\$id:String!) {
    ProductOutlet(id:\$id) {
        id
        availableQuantity
        isAlwaysAvailable
        numberOfRoom
        product{
          id
          title
          subTitle
          description
          thumbNail
          smallThumbNail
          pax
          photos
          smallPhotos
          currentPrice
          originalPrice
          isNew
          isRecommended
          isMerchantDelivery
          minimumSpend
          advancePurchaseUnit
          advancePurchaseDuration
          productType,
          productAmenities {
            amenity {
              name
            }
          },
          productAddons {
                id
                name
                isRequired
                isMultiselect
                minimumSelectItem
                maximumSelectItem
                productAddonOptions {
                  id
                  name
                  price
                  order
                }
          },
          productCategories {
            category {
                name
            }
          }
          productBundles{
            quantity
            product {
              id
              title
              subTitle
              pax
              description
              thumbNail
              smallThumbNail
              photos
              currentPrice
              originalPrice
              isNew
              isRecommended
              isMerchantDelivery
              productType
              productAddons {
                id
                name
                isRequired
                isMultiselect
                minimumSelectItem
                maximumSelectItem
                productAddonOptions {
                  id
                  name
                  price
                  order
                }
              }
            }
          }
        }
        outlet{
          id,
          isSSTEnabled,
          thumbNail
          name
          firstNthKM
          firstNthKMDeliveryFee
          deliveryFeePerKM
          priceRange
          latitude
          longitude
          maxPax
          address1
          state
          city
          postalCode
          businessCategories {
            businessCategory {
              name
            }
          },
          reviews {
            id,
            score
          },
          merchant {
              name
          }
          amenities {
            amenity {
              name
            }
          }     
        }
        collectionTypes {
          id
          type
        }
        menuItemBusinessHours {
            day,
            startTime,
            endTime,
            startDate,
            endDate,
        }
      }
 }
    """;

  static const String GET_PRODUCT_OUTLETS_BY_PRODUCT_TYPE = """
    query GetProductOutletsByProductType(\$productType: String!) {
      GetProductOutletsByProductType(productType: \$productType) {
        id
        status
        availableQuantity
        isAlwaysAvailable
        product{
          id
          title
          subTitle
          description
          thumbNail
          smallThumbNail
          pax
          photos
          smallPhotos
          currentPrice
          originalPrice
          isNew
          isRecommended
          isMerchantDelivery
          advancePurchaseUnit
          advancePurchaseDuration
          productType
          productCategories {
              category {
                  name
              }
          }
        }
        outlet{
          isSSTEnabled,
          id,
          name
          address1
          merchant {
              name
          }
        }
        collectionTypes {
            type
        }
        menuItemBusinessHours {
            day,
            startTime,
            endTime,
            startDate,
            endDate,
        }
      }
    }
  """;

  static const String GET_FEATURED_CELEBRATION_PRODUCT_OUTLETS = """
  query GetFeaturedCelebrationProductOutlets(\$selectedServiceType: String!, \$selectedDate: String!,\$pax:Int!, \$userLatitude: Float, \$userLongitude: Float){
    GetFeaturedCelebrationProductOutlets(selectedServiceType:\$selectedServiceType,selectedDate:\$selectedDate,pax:\$pax, userLatitude: \$userLatitude, userLongitude: \$userLongitude ){
        available
        id
        status
        availableQuantity
        isAlwaysAvailable
        product{
          id
          title
          subTitle
          description
          thumbNail
          smallThumbNail
          pax
          photos
          smallPhotos
          currentPrice
          originalPrice
          isNew
          isRecommended
          isMerchantDelivery
          advancePurchaseUnit
          advancePurchaseDuration
          productType
          productCategories {
              category {
                  name
              }
          }
        }
        outlet{
          isSSTEnabled,
          id,
          name
          address1
          merchant {
              name
          }
        }
        collectionTypes {
            type
        }
        menuItemBusinessHours {
            day,
            startTime,
            endTime,
            startDate,
            endDate,
        }
    }
  }
  """;

  static const String GET_PRODUCT_OUTLETS_BY_OUTLET = """
   query GetProductOutletsByOutlet(\$outletId: String!,\$selectedServiceType: String!, \$selectedDate: String!,\$pax:Int) {
    GetProductOutletsByOutlet(outletId:\$outletId,selectedServiceType:\$selectedServiceType,selectedDate:\$selectedDate,pax:\$pax) {
      id
      status
      availableQuantity
      numberOfRoom
      isAlwaysAvailable
      productCategories {
        category {
          id,
          name,
          productType
        }
      },
      product{
        status
        id
        title
        subTitle
        description
        thumbNail
        smallThumbNail
        pax
        photos
        smallPhotos
        currentPrice
        originalPrice
        isNew
        isRecommended
        isMerchantDelivery
        advancePurchaseUnit
        advancePurchaseDuration
        productType
      }
      outlet{
        id,
        name
        address1
        latitude,
        longitude,
        priceRange,
        maxPax
        isSSTEnabled
        merchant {
          id,
          name
        }
        productCategories {
          category {
            id,
            name,
            productType
          },
          order
        }
        reviews {
          id,
          content,
          user {
            id,
            displayName,
            photoUrl
          }
          reviewPhotos,
          createdAt,
          score
        }
        amenities {
          amenity {
            name
          }
        }
        businessCategories {
          businessCategory {
            name
          }
        }
      }
      collectionTypes {
        type
      }
      menuItemBusinessHours {
        day,
        startTime,
        endTime,
        startDate,
        endDate,
      } 
      available
    }
  }

  """;

  static const String GET_ALL_PRODUCT_OUTLETS_BY_OUTLET = """
     query GetAllProductOutletsByOutlet(\$outletId: String!){
     GetAllProductOutletsByOutlet(outletId:\$outletId){
          id
          isAlwaysAvailable
           product{
        status
        id
        title
        subTitle
        description
        thumbNail
        smallThumbNail
        pax
        photos
        smallPhotos
        currentPrice
        originalPrice
        isNew
        isRecommended
        isMerchantDelivery
        advancePurchaseUnit
        advancePurchaseDuration
        productType
        productAddons {
                id
                name
                isRequired
                isMultiselect
                minimumSelectItem
                maximumSelectItem
                productAddonOptions {
                  id
                  name
                  price
                  order
                }
          },
        productOutlets {
            id,
            availableQuantity
            isAlwaysAvailable
            available
            numberOfRoom
          }
       
        
      }
      
          outlet{
              id
              name
              photos
              maxPax
              priceRange
              isSSTEnabled
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
  """;
}
