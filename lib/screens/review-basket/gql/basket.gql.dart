class BasketGQL {
  static const String VALIDATE_BASKET = """
  mutation validateUserOrder(\$validationInput: ValidationInput!){
    validateUserOrder(validationInput: \$validationInput){
        status
     }
}
  """;

  static const String LOG_PAYMENT_ERROR = """
  mutation createPaymentLog(\$createPaymentLogInput: CreatePaymentLogInput!) {
  createPaymentLog(createPaymentLogInput: \$createPaymentLogInput) {
    status
  }
}
  """;

  static const String CREATE_PAYMENT = """
  mutation createUserOrder(\$createOrderInput: CreateOrderInput!) {
  createUserOrder(createOrderInput: \$createOrderInput) {
    status
  }
}
  """;

  static const String GET_USER_CART_ITEMS = """
  query GetCartItems(\$userId: String!) {
    CartItems(userId: \$userId) {
      id,
      currentDeliveryAddress,
      preOrderId,
      remarks,
      quantity,
      priceWhenAdded,
      collectionType,
      isDeliveredToVenue,
      serviceDateTime,
      latitude,
      longitude,
      merchantSST,
      distance,
      orderName,
      numberOfPax
      productOutlet{
        id,
        isAlwaysAvailable
        status
        product {
          id,
          title
          status
          productType,
          currentPrice,
          originalPrice,
          isMerchantDelivery
        },
        outlet {
          id,
          address1,
          city,
          postalCode,
          state,
          thumbNail,
          maxPax,
          maxDeliveryKM,
          priceRange,
          reviews {
            id,
            score
          },
          name,
          deliveryFeePerKM,
          firstNthKM,
          firstNthKMDeliveryFee,
          maxDeliveryKM,
          latitude,
          longitude,
          status,
          isSSTEnabled,
          collectionTypes {
            terms,
            type,
            maxDeliveryKM,
            firstNthKM,
            firstNthKMDeliveryFee,
            deliveryFeePerKM,
            serviceChargeRate
          }
        },
        menuItemBusinessHours{
          day,
          startTime,
          endTime,
          startDate,
          endDate,
        }
      },
      cartItemDetails {
        id
        cartItemId
        productAddonOptionId
        addOnPriceWhenAdded
        productAddonOption {
          name
          productAddon {
            id
            name
          },
        },
      }
    }
  }
  """;

  static const String GET_USER_CART_ITEM_BY_ID = """
  query GetCartItemsById(\$id: String!) {
    GetCartItemsById(id: \$id) {
      id,
      currentDeliveryAddress,
      preOrderId,
      remarks,
      quantity,
      priceWhenAdded,
      collectionType,
      isDeliveredToVenue,
      serviceDateTime,
      latitude,
      longitude,
      merchantSST,
      distance,
      productOutlet{
        id,
        isAlwaysAvailable,
        availableQuantity,
        status,
        product {
          id
          title
          subTitle
          description
          thumbNail
          pax
          photos
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
          productBundles{
            quantity
            product {
              id
              title
              subTitle
              pax
              description
              thumbNail
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
        },
        outlet {
          id,
          name,
          deliveryFeePerKM,
          firstNthKM,
          firstNthKMDeliveryFee,
          maxDeliveryKM,
          latitude,
          longitude,
          isSSTEnabled,
          collectionTypes {
            terms,
            type,
            maxDeliveryKM,
            firstNthKM,
            firstNthKMDeliveryFee,
            deliveryFeePerKM
          }
        },
        menuItemBusinessHours{
          day,
          startTime,
          endTime,
          startDate,
          endDate,
        }
      },
      cartItemDetails {
        id
        cartItemId
        productAddonOptionId
        addOnPriceWhenAdded
        productAddonOption {
          name
          productAddon {
            id
            name
          },
        },
      }
    }
  }
  """;

  static const String ADD_TO_CART = """
  mutation createUserCart(\$createCartItemInput: CreateCartItemInput!) {
  createUserCart(createCartItemInput: \$createCartItemInput) {
    status
  }
}
  """;

  static const String DELETE_CART_ITEM = """
  mutation deleteCartItem(\$productOutletId: String!,\$userId: String!) {
    deleteCartItem(productOutletId: \$productOutletId,userId: \$userId) {
        status
    }
  }
  """;

  static const String UPDATE_CART_ITEM = """
  mutation updateUserCartItems(\$UpdateCartItemInput: UpdateCartItemInput) {
    updateUserCartItems(UpdateCartItemInput: \$UpdateCartItemInput) {
        status
    }
  }
  """;

  static const String CLEAR_USER_CART_ITEM = """
  mutation ClearUserCartItem(\$userId: String!){
    clearUserCartItem(userId: \$userId){
      status
    }
  }
  """;
}
