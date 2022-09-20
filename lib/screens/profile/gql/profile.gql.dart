class ProfileGQL {
  static const GET_USER_INFO = """
    query GetUserInfo(\$userId: String!) {
      currentUser(userId: \$userId) {
        id,
        displayName,
        title,
        email,
        photoUrl,
        dateOfBirth,
        phone,
        specialDays {
          id,
          name,
          date,
          reminderInterval,
          reminderIntervalUnit
        },
        preferences {
          id,
          itemName,
          itemId,
          preferenceType
        }
      }
    }
  """;

  static const String GET_ALL_CUISINES = """
  query{
    Cuisines{
        id,
        name,
        thumbNail
    }
  }
  """;

  static const String GET_ALL_SPECIAL_DIETS = """
  query{
    SpecialDiets{
        id,
        name
    }
  }
  """;

  static const String GET_ALL_HOSPITALITY_PREFERENCES = """
  query{
    Amenities{
        id,
        name,
        thumbNail
    }
  }
  """;

  static const String ADD_SPECIAL_DAY = """
  mutation CreateSpecialDay (\$createSpecialDay: CreateSpecialDayInput!)  {
    createSpecialDay(createSpecialDay: \$createSpecialDay) {
        status
    }
  }
  """;

  static const String RESEND_EMAIL = """
mutation{
    resendVerificationEmail{
        status
    }
}
  """;


 static const String GET_VERIFIED = """
  query{
    SpecialDiets{
        id,
        name
    }
  }
  """;

  static const String DELETE_SPECIAL_DAY = """
  mutation deleteSpecialDay(\$id: String!) {
    deleteSpecialDay(id: \$id) {
        status  
    }
  }
  """;

  static const String ADD_OR_EDIT_FAVORITE_CUISINE = """
  mutation favouriteCuisines(\$userId: String!, \$cuisineIds: [String!]) {
    favouriteCuisines(userId: \$userId, cuisineIds: \$cuisineIds){
        status
    }
  }
  """;

  static const String ADD_OR_EDIT_DIETARY = """
  mutation favouriteDiets(\$userId: String!, \$dietIds: [String!]) {
    favouriteDiets(userId: \$userId, dietIds: \$dietIds){
        status
    }
  }
  """;

  static const String ADD_OR_EDIT_HOSPITALITY = """
  mutation favouriteHospitals(\$userId: String!, \$hospitalIds: [String!]) {
    favouriteHospitals(userId: \$userId, hospitalIds: \$hospitalIds){
        status
    }
  }
  """;

  static const String UPDATE_USER_INFO = """
  mutation UpdateProfile(\$updateProfile: UpdateProfileInput!){
    updateProfile(updateProfile: \$updateProfile){
        status
    }
  }
  """;

  static const String UPDATE_USER_AVATAR = """
  mutation CreateUpdateUserProfilePhoto(\$id: String!, \$file: Upload!, \$index: Int!) {
    createUpdateUserProfilePhoto(id: \$id, file: \$file, index: \$index) {
      photoUrl
    }
  }
  """;

    static const GET_EMAIL_VERIFICATION = """
    query GetEmailVerificationStatus(\$userId: String!) {
      GetEmailVerificationStatus(userId: \$userId) {
        verificationStatus
      }
    }
  """;
}
