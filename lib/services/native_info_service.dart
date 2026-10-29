import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class NativeInfoService {
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<String> getDeviceSummary() async {
    try {
      if (kIsWeb) return 'Web Browser';
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await _deviceInfo.androidInfo;
        return '${android.model} (Android ${android.version.release})';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = await _deviceInfo.iosInfo;
        return '${ios.utsname.machine} (iOS ${ios.systemVersion})';
      }
    } catch (_) {}
    return 'Mobile Device';
  }
}
