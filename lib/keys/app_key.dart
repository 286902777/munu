import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppKey {
  static const clickCommendStar = 'clickCommendStar';

  static const numCommend = 'numCommend';

  static const appOnlyId = 'appOnlyId';

  static const commendTime = 'commendTime';

  static const commentPlayCount = 'commentPlayCount';

  static const onceInstallApp = 'onceInstallApp';

  static const isFirstLink = 'isFirstLink';

  static const appLinkId = 'appLinkId';

  static const appPlatform = 'ppPlatform';

  static const appUserId = 'appUserId';

  static const appDeepNewUser = 'appDeepNewUser';

  static const appNewUser = 'appNewUser';

  static const showSpeedVideo = 'showSpeedVideo';

  static const showNum = 'showNum';

  static const showRate = 'showRate'; //间隔三个视频

  static const vipAlertShowCount = 'vipAlertShowCount';

  static const vipAlertPlayTime = 'vipAlertPlayTime';

  static const vipAlertTime = 'vipAlertTime';

  static const vipPlayCount = 'vipPlayCount'; //成功展示2次广告后，关闭广告展示弹窗；

  static const isVipUser = 'isVipUser';

  static const vipProductId = 'vipProductId';

  static const appNewUserPlay = 'appNewUserPlay';

  static const appInstall = 'appInstall';

  static const openDeepInstall = 'openDeepInstall';

  static const eventList = 'eventList';

  static const email = 'email';

  static const toDay = 'toDay';

  static const middlePlayCount = 'middlePlayCount';

  static Future<bool> save(String key, dynamic value) async {
    SharedPreferences ns = await SharedPreferences.getInstance();
    if (value is Map) {
      var v = jsonEncode(value);
      return ns.setString(key, v);
    } else if (value is int) {
      return ns.setInt(key, value);
    } else if (value is double) {
      return ns.setDouble(key, value);
    } else if (value is bool) {
      return ns.setBool(key, value);
    } else if (value is String) {
      return ns.setString(key, value);
    } else {
      return ns.setString(key, value.toString());
    }
  }

  static Future<String?> getString(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    String? value = user.getString(key);
    return value;
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    bool? value = user.getBool(key);
    return value;
  }

  static Future<int?> getInt(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    int? value = user.getInt(key);
    return value;
  }

  static Future<double?> getDouble(String key) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    double? value = user.getDouble(key);
    return value;
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    SharedPreferences ns = await SharedPreferences.getInstance();
    String? value = ns.getString(key);
    if (value != null) {
      Map<String, dynamic>? map = jsonDecode(value);
      return map;
    }
    return null;
  }
}
