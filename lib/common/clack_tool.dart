import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:sim_reader/sim_reader.dart';
import 'package:vpn_detector/vpn_detector.dart';

class ClackTool {
  static bool get isPad {
    final mediaQuery = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );
    final size = mediaQuery.size;
    return size.shortestSide >= 600;
  }

  static Future<bool> isVpn() async {
    final status = await VpnDetector().isVpnActive();
    return status == VpnStatus.active;
  }

  static Future<bool> isEmulator() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      } else {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isSimCard() async {
    final hasSim = await SimReader.hasSimCard();
    return hasSim;
  }
}
