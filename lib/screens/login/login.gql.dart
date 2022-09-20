class LoginGQL {
  static const String MOBILE_SIGNIN = """
    mutation PhoneSignIn(\$phoneNumber: String!, \$email: String, \$provider: String, \$userAccountId: String) {
        phoneSignIn(phoneNumber: \$phoneNumber, email: \$email, provider: \$provider, userAccountId: \$userAccountId) {
            status
        }
    }
  """;

  static const String MOBILE_VERIFY = """
mutation PhoneSignInVerifyCode(\$phoneNumber: String!, \$token: String!, \$userAccountId: String, \$provider: String){
    phoneSignInVerifyCode(phoneNumber: \$phoneNumber, token: \$token, userAccountId: \$userAccountId, provider: \$provider){
        a,
        r
    }
}
  """;

  static const String CREATE_FIRST_USER = """
 mutation CreateFirstUser(\$createUser: CreateFirstUserInput!){
    createFirstUser(createUser: \$createUser){
        status
    }
}
  """;

  static const String CHECK_IS_FIRST_USER = """
    query GetUserByPhone(\$phoneNumber: String!){
            GetUserByPhone(phoneNumber: \$phoneNumber){
                id,
                displayName,
                email
            }
        }
  """;

  static const String SET_DEVICE_INFO = """
    mutation SetDeviceInfo(\$deviceInfo: SetDeviceInfoInput!){
      setDeviceInfo(deviceInfo: \$deviceInfo){
        id,
        userId,
        deviceToken,
        phoneModel,
        os,
        additionalInfo
      }
    }
  """;

  static const String GET_NOTIFICATION = """
   query Notifications(\$userId: String!){
          Notifications(userId: \$userId){
              id,
              userId,
              titleKey,
              contentKey,
              readAt,
              createdAt,
              type,
              additionalInfo
          }
    }
  """;

  static const String UDPATE_READ_NOTIFICATION = """
   mutation UpdateNotification(\$id: String!){
          updateNotification(id: \$id){
              status
          }
    }
  """;

  static const String LOGOUT = """
    mutation clearDeviceInfo(\$userId: String!, \$deviceToken: String!){
        clearDeviceInfo(userId: \$userId, deviceToken: \$deviceToken){
          status
        }
    }
  """;

  static const String CHECK_SOCIAL_USER_EXISTED = """
    mutation checkExistSocialUser(\$userAccountId: String!, \$provider: String!){
        checkExistSocialUser(userAccountId: \$userAccountId, provider: \$provider){
          status
        }
    }
  """;

  static const String LOGIN_SOCIAL_USER = """
    mutation socialSignIn(\$userAccountId: String!, \$provider: String!){
        socialSignIn(userAccountId: \$userAccountId, provider: \$provider){
          a,
          r
        }
    }
  """;
}
