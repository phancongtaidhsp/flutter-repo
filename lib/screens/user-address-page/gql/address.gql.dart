class AddressGQL {
  static const String CREATE_NEW_ADDRESS = """
  mutation CreateDeliveryAddress(\$createAddress: CreateDeliveryAddressInput!){
    createDeliveryAddress(createAddress: \$createAddress){
        status
    }
}
  """;

  static const String GET_USER_ADDRESSES = """
  query GetUserAddress(\$userId: String!){
    UserAddresses(userId: \$userId){
        id
        name
        address1
        address2
        notes
        state
        city
        postalCode
        longitude
        latitude
        isDefault

    }
}
  """;

  static const String GET_UNREAD_NOTIFICATIONS = """
  query anyUnreadNotification(\$userId: String!){
    anyUnreadNotification(userId: \$userId){
      status
        }
    }
  
  """;

  static const String DELETE_USER_ADDRESS = """
  mutation DeleteDeliveryAddress(\$id: String!){
    deleteDeliveryAddress(id: \$id){
        status
    }
}
  """;

  static const String UPDATE_USER_ADDRESS = """
  mutation CreateDeliveryAddress(\$createAddress: CreateDeliveryAddressInput!){
    createDeliveryAddress(createAddress: \$createAddress){
        status
    }
}
  """;
}
