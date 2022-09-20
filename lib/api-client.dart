import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:gem_consumer_app/models/UserAddress.dart';
import 'package:gem_consumer_app/providers/add-to-cart-items.dart';
import 'package:gem_consumer_app/screens/product/product.gql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './configuration.dart';
import 'screens/party/gql/party.gql.dart';
import 'screens/review-basket/gql/basket.gql.dart';
import 'screens/user-address-page/gql/address.gql.dart';

class APIClient {
  /*
  Api client 
   */
  static ValueNotifier<GraphQLClient> get client {
    final HttpLink httpLink = HttpLink(Configuration.APP_API);
    return ValueNotifier(getGraphQLClient(httpLink));
  }

  // static ValueNotifier<GraphQLClient> get authClient {
  //   final HttpLink httpLink = HttpLink(Configuration.AUTH_API);
  //   return ValueNotifier(getGraphQLClient(httpLink));
  // }

  static Future<Map<String, dynamic>?> getOutletInformation(
      String outletId) async {
    ValueNotifier<GraphQLClient> graphQLClient = APIClient.client;

    var params = {
      "outletId": outletId,
    };

    QueryResult result = await graphQLClient.value.query(
      QueryOptions(
        document: gql(ProductGQL.GET_ALL_PRODUCT_OUTLETS_BY_OUTLET),
        variables: params,
        fetchPolicy: FetchPolicy.noCache
      ),
    );

    if (!result.hasException) {
      print('insdi');
      return result.data;
    } else {
      var e = result.exception;
      print(e.toString());
      print('exception in getCode api from server');
      // if (result.exception!.graphqlErrors.isEmpty) {
      //   print('Error in getCode api from server');
      // } else {
      //   return null;
      // }
      return null;
    }
  }

  static Future<List<dynamic>> getEventCategories() async {
    ValueNotifier<GraphQLClient> graphQLClient = APIClient.client;
//auth.currentUser.id,

    // var params = {'userId': userId};
    QueryResult result = await graphQLClient.value.query(
      QueryOptions(
        document: gql(PartyGQL.GET_EVENT_CATEGORIES),
        fetchPolicy: FetchPolicy.noCache,
        //variables: params,
      ),
    );
    if (!result.hasException) {
      if (result.data != null) {
        var eventCategories = result.data!['EventCategories'] as List<dynamic>;
        if (eventCategories.length > 0) {
          eventCategories.sort((a, b) => a['order'].compareTo(b['order']));
        }
        return eventCategories;
      } else {
        return [];
      }
    } else {
      print("Exception: ${result.exception.toString()}");

      return [];
    }
  }

  static Future<Map<String, dynamic>> getCategoryOutlets(double userLat,
      double userLong, String eventCategoryId, int pageNumber) async {
    ValueNotifier<GraphQLClient> graphQLClient = APIClient.client;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var totalCount = preferences.getInt('totalCount');
    pageNumber = pageNumber + 1;
    if (pageNumber == 1) {
      totalCount = null;
    }
    // var variables = {
    //   "userLatitude": userLat,
    //   "userLongitude": userLong,
    //   "eventCategoryId": eventCategoryId,
    //   'pageNumber': pageNumber,
    //   'takeNumber': 1,
    //   'totalCount': totalCount,
    // };
    print(
        ' ${Configuration.numberOfRecordsinCategoryOultetLoading} ::  outletdata');
    QueryResult result = await graphQLClient.value.query(
      QueryOptions(
        document: gql(PartyGQL.GET_VENUE_MERCHANT_OUTLETS_BY_EVENT_CATEGORY),
        fetchPolicy: FetchPolicy.noCache,
        variables: {
          "userLatitude": userLat,
          "userLongitude": userLong,
          "eventCategoryId": eventCategoryId,
          'pageNumber': pageNumber,
          'takeNumber': Configuration.numberOfRecordsinCategoryOultetLoading,
          'totalCount': totalCount,
        },
      ),
    );
    if (!result.hasException) {
      if (result.data != null) {
        if (pageNumber == 1) {
          var totalCount = result
              .data!['getVenueMerchantOutletsByEventCategory']['totalCount'];

          preferences.setInt('totalCount', totalCount);
        }
        var hasNext = result.data!['getVenueMerchantOutletsByEventCategory']
            ['hasNext'] as bool;
        var merchantOutletList =
            result.data!['getVenueMerchantOutletsByEventCategory']
                ['merchantOutlets'] as List<dynamic>;

        var returnData = {
          'hasNext': hasNext,
          'merchantOutletList': merchantOutletList,
        };

        return returnData;
      } else {
        return {
          'hasNext': false,
          'merchantOutletList': [],
        };
      }
    } else {
      print("Exception: ${result.exception.toString()}");

      return {
        'hasNext': false,
        'merchantOutletList': [],
      };
    }
  }

  static Future<UserAddress?> getAddress(
    String userId,
  ) async {
    ValueNotifier<GraphQLClient> graphQLClient = APIClient.client;
//auth.currentUser.id,

    var params = {'userId': userId};
    QueryResult result = await graphQLClient.value.query(
      QueryOptions(
        document: gql(AddressGQL.GET_USER_ADDRESSES),
        variables: params,
        fetchPolicy: FetchPolicy.noCache
      ),
    );
    UserAddress? deliveryLocation;

    if (!result.hasException) {
      // print('data found');
      Map<String, dynamic>? defaultAddress;
      List tempList = List.from(result.data!["UserAddresses"]);
      if (tempList.length > 0) {
        if (tempList.map((e) => e["isDefault"]).contains(true)) {
          defaultAddress =
              tempList.firstWhere((element) => element["isDefault"] == true);
          if (defaultAddress != null) {
            deliveryLocation = UserAddress(
                id: defaultAddress["id"],
                name: defaultAddress["name"],
                address1: defaultAddress["address1"],
                address2: defaultAddress["address2"],
                notes: defaultAddress["notes"],
                state: defaultAddress["state"],
                city: defaultAddress["city"],
                postalCode: defaultAddress["postalCode"],
                longitude: defaultAddress["longitude"],
                latitude: defaultAddress["latitude"],
                isDefault: defaultAddress["isDefault"]);
            return deliveryLocation;
          } else {
            return null;
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      var e = result.exception;
      print(e.toString());
      print('exception in getCode api from server');
      if (result.exception!.graphqlErrors.isEmpty) {
        print('Error in getCode api from server');
      } else {
        var errorMessage =
            result.exception!.graphqlErrors[0].message.toString();
        if (errorMessage == 'ACCOUNT_EXISTED') {
          return null;
        }
        //print('$errorMessage Error Message');
        //ACCOUNT_EXISTED
      }

      return null;
    }
  }

  static GraphQLClient getGraphQLClient(Link httpLink) => GraphQLClient(
        link: getAuthLink().concat(httpLink),
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(store: HiveStore()),
      );

  static AuthLink getAuthLink() {
    return AuthLink(
      getToken: () async {
        var box = await Hive.openBox('tokens');
        try {
          final accessToken = box.get('at');
          final refreshToken = box.get('rt');
          final tempToken = box.get('temp_token');
          String? token = (accessToken != '' && accessToken != null)
              ? accessToken
              : tempToken;

          if (accessToken != null && refreshToken != null) {
            DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
            DateTime today = DateTime.now();

            if (expirationDate.difference(today).inMinutes < 1) {
              //refresh token
              token = await generateNewToken(refreshToken);
              print('@refresh');
            }
          } else if (refreshToken != null && refreshToken != '') {
            token = await generateNewToken(refreshToken);
          } else if (tempToken != null && refreshToken == null) {
            if (token != null) {
              DateTime expirationDate = JwtDecoder.getExpirationDate(token);
              DateTime today = DateTime.now();

              if (expirationDate.difference(today).inMinutes < 1) {
                token = await generateTempToken();
              }
            }
          } else if (tempToken == null && refreshToken == null) {
            token = await generateTempToken();
          }
          //print('@token, $token');
          return token;
        } catch (e) {
          print('@@error in client ${e.toString()}');
          box.delete('rt');
          box.delete('at');
          return null;
        }
      },
    );
  }

  static Future<String?> generateNewToken(String refreshToken) async {
    var box = await Hive.openBox('tokens');
    var client = http.Client();
    Map<String, dynamic> map = {
      'query': '''mutation RefreshAccessToken{refreshAccessToken{a}}''',
    };
    var response = await client.post(Uri.parse(Configuration.AUTH_API),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken'
        },
        body: jsonEncode(map));

    if (response.statusCode != 200) {
      box.delete('rt');
      box.delete('at');
      return null;
    }

    final result = jsonDecode(response.body);
    final newAccessToken = result["data"]['refreshAccessToken'] != null
        ? result["data"]['refreshAccessToken']['a']
        : null;
    if (newAccessToken != null || newAccessToken != '') {
      box.put('at', newAccessToken);
      return newAccessToken;
    } else {
      box.delete('rt');
      box.delete('at');
      return null;
    }
  }

  static Future<String?> generateTempToken() async {
    var box = await Hive.openBox('tokens');
    var client = http.Client();
    Map<String, dynamic> map = {
      'query': '''mutation GenerateTempToken{generateTempToken{token}}''',
    };

    var response = await client.post(Uri.parse(Configuration.AUTH_API),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(map));

    if (response.statusCode != 200) {
      box.delete('temp_token');
      return null;
    }

    final result = jsonDecode(response.body);
    final newAccessToken = result["data"]['generateTempToken'] != null
        ? result["data"]['generateTempToken']['token']
        : null;
    if (newAccessToken != null || newAccessToken != '') {
      box.put('temp_token', newAccessToken);
      return newAccessToken;
    } else {
      box.delete('temp_token');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUnreadNotifications(
    String userId,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var notificationCounter = preferences.getInt('notificationCounter');
    if (notificationCounter == null || notificationCounter == 0) {
      return null;
    } else {
      return {
        'counter': notificationCounter,
      };
    }
    //if notification stops working we can still use this function
    // ValueNotifier<GraphQLClient> graphQLClient = APIClient.client;
    // var params = {'userId': userId};
    // QueryResult result = await graphQLClient.value.query(
    //   QueryOptions(
    //     document: gql(AddressGQL.GET_UNREAD_NOTIFICATIONS),
    //     variables: params,
    //   ),
    // );
    // if (!result.hasException) {
    //   print('data found ${result.data}');
    //   var status = result.data!['anyUnreadNotification']['status'];
    //   if (status == 'Yes') {
    //     return {
    //       'counter': '1',
    //     };
    //   } else {
    //     return null;
    //   }
    // } else {
    //   print(result.exception.toString());
    //   return null;
    // }
  }

  static Future<QueryResult> checkUserCurrentCart(
    String userId,
  ) async {
    ValueNotifier<GraphQLClient> graphQLClient = APIClient.client;
    QueryResult result = await graphQLClient.value.query(
      QueryOptions(
        document: gql(BasketGQL.GET_USER_CART_ITEMS),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    return result;
  }
}
