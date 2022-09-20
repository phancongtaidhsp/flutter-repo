
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get filename {
    if(kReleaseMode) {
      return '.env.production';
    }

    return '.env';
  }

  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'DEV';
  }

  static bool get isProductEnvironment {
    return dotenv.env['ENVIRONMENT'] == 'DEV' ? false : true;
  }

  static String get appVersion {
    return dotenv.env['APP_VERSION'] ?? '';
  }
}