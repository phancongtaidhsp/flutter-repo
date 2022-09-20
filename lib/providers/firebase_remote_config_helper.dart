import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigHelper {
  static late RemoteConfig _remoteConfig;

  Future<void> initializedConfig() async {
    _remoteConfig = RemoteConfig.instance;
    final defaults = <String, dynamic>{
      'gemspot_sst_rate': '0.00',
      'gemspot_consumer_build_number': '1',
    };
    await _remoteConfig.setDefaults(defaults);

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  static String loadConfig(String key) {
    return _remoteConfig.getString(key);
  }
}
