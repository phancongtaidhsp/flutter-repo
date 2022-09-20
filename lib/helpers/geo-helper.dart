import 'dart:math' show cos, sqrt, sin, atan2;
import 'package:vector_math/vector_math.dart' as vec;

class GeoHelper {
  static double getDistance(startLat, startLong, endLat, endLong) {
    double earthRadius = 6371;
    var dLat = vec.radians(endLat - startLat);
    var dLng = vec.radians(endLong - startLong);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(vec.radians(startLat)) *
            cos(vec.radians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var result = earthRadius * c;
    return result;
  }
}
