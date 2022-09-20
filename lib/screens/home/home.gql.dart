class HomeGQL {
  static const String GET_BANNER = """
  query GetBanner {
    banners {
      id,
      photoUrl,
      area,
      isActive,
      actionType,
      redirectUrl
    }
  }
  """;
}
