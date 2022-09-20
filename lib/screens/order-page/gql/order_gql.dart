
class OrderGQL {
  static const GET_ORDER_BY_ORDER_ID_WITH_REVIEW = """
    query GetOrderById(\$id: String!) {
      GetOrderById(id: \$id) {
        id,
        name,
        userId,
        user {
          id,
          displayName,
          photoUrl,
        },
        cancelCutoffTime,
        serviceType,
        taxAmount,
        serviceDateTime,
        isCancelled,
        orderOperations {
            id,
            orderId,
            outletId,
            orderStatus,
            serviceType,
            deliveryAmount,
            deliveryDateTime,
            deliveryAddress,
            isCompletedAt,
            isReviewSubmitted,
            outlet {
              id,
              name,
              businessCategories {
                businessCategory {
                    name
                }
              },
              thumbNail,
              reviews {
                score,
                isHidden
              },
            }
        },
        orderDetails {
            id,
            orderId,
            outletId,
            quantity,
            payableAmount,
            variation,
            specialInstruction,
            product {
              title
          }
        }
      }
    }
  """;

  static const GET_ORDER_DETAIL_BY_ORDER_ID = """
    query GetOrderById(\$id: String!) {
      GetOrderById(id: \$id) {
        id,
        displayOrderId,
        name,
        orderAt,
        cancelCutoffTime,
        serviceType,
        taxAmount,
        serviceDateTime,
        isCancelled,
        orderOperations {
            id,
            orderId,
            outletId,
            orderStatus,
            serviceType,
            deliveryAmount,
            deliveryDateTime,
            deliveryAddress,
            isCompletedAt,
            isReviewSubmitted,
            outlet {
              id,
              name,
            }
        },
        orderDetails {
            id,
            orderId,
            outletId,
            quantity,
            payableAmount,
            isOutOfStock,
            payableSST,
            payableServiceCharge,
            payableServiceChargeRate
            variation,
            specialInstruction,
            product {
              productType,
              title
          }
        }
      }
    }
  """;

  static const GET_ORDER_LIST_BY_USER_ID = """
    query GetOrderByUserId(\$userId: String!) {
      Order(userId: \$userId) {
        id,
        name,
        cancelCutoffTime,
        serviceType,
        taxAmount,
        serviceDateTime,
        isCancelled,
        orderOperations {
            id,
            orderId,
            outletId,
            orderStatus,
            serviceType,
            deliveryAmount,
            deliveryDateTime,
            deliveryAddress,
            isCompletedAt,
            isReviewSubmitted,
        },
        orderDetails {
            orderId,
            outletId,
            payableAmount,
            payableSST,
            payableServiceCharge,
            isOutOfStock
        }
      }
    }
  """;

  static const String UPLOAD_IMAGE = """
    mutation CreateUploadPhotoUrl (\$file: Upload!)  {
      createUploadPhotoUrl(file: \$file) {
          url
      }
    }
  """;

  static const String POST_REVIEW = """
    mutation createUpdateUserReview(\$UserReviewInput: UserReviewInput!, \$orderOperationId: String!){
      createUpdateUserReview(UserReviewInput: \$UserReviewInput, orderOperationId: \$orderOperationId){
          status
      }
  }
  """;

  static const String CANCEL_ORDER = """
    mutation cancelOrder(\$id: String!, \$cancellationRemark: String!) {
    cancelOrder(id: \$id, cancellationRemark: \$cancellationRemark){
        status
      }
    }
  """;
}