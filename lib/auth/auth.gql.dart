class AuthGQL {
  static const String GENERATE_TEMP_TOKEN = """
  mutation{
    generateTempToken{
        token
    }
  }
  """;
}
