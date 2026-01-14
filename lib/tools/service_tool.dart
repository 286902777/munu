import 'dart:io';
import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:applovin_max/applovin_max.dart' hide NativeAdListener;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:munu/tools/http_tool.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../keys/app_key.dart';
import 'common_tool.dart';

enum ServiceEventName {
  advProfit('b'),
  playVideo('bs'),
  viewApp('zbas'),
  downApp('xsdgasdga'),
  appAdvProfit('wera'),
  appPlayVideo('sg'),
  newUserActiveByPlayVideo('sgew'),
  downloadAppFirstTimeOpen('bxb');

  final String name;
  const ServiceEventName(this.name);
}

class ServiceTool {
  static final ServiceTool instance = ServiceTool();
  static final String uuId = Uuid().v1();

  ServiceEventName ad_event = ServiceEventName.advProfit;
  PlatformType ad_source = PlatformType.india;
  double ad_value = 0.0;
  String ad_linkId = '';
  String ad_userId = '';
  String ad_fileId = '';

  void addEvent(
    ServiceEventName event,
    PlatformType source,
    double value,
    String linkId,
    String userId,
    String fileId,
  ) async {
    String unique_id = '';

    if (Platform.isIOS) {
      final storage = FlutterSecureStorage();
      String? uniqueId = await storage.read(key: AppKey.appOnlyId);
      if (uniqueId != null) {
        unique_id = uniqueId;
      } else {
        unique_id = Uuid().v4();
        storage.write(key: AppKey.appOnlyId, value: unique_id);
      }
    }
    PackageInfo info = await PackageInfo.fromPlatform();
    String deviceVersion = '';
    String deviceModel = '';
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceVersion = iosInfo.systemVersion;
      deviceModel = iosInfo.modelName;
    } else {
      final andInfo = await deviceInfo.androidInfo;
      deviceVersion = andInfo.version.release;
      deviceModel = andInfo.model;
    }

    try {
      HttpTool.eventPostRequest(
        source,
        para: {
          'ba': 's',

          // 'updater': {'corsac': app_Bunlde_Id},
          // 'enlinkment': 'ios',
          // 'interhyal': Uuid().v1(), //log_id
          // 'leftists': linkId,
          // 'tortricid': userId,
          // 'ogtiern': value,
          // 'skirting': 'USD',
          // 'dictyonine': event.name,
          // 'vvi5bscptl': {'aphra': eventSource.name},
          // 'outclasses': unique_id,
          //
          // /// unique_id
          // 'richeted': info.version,
          // 'euryscope': deviceVersion,
          // '1emejsbrma': {
          //   'handy': {'cowbell': deviceModel},
          // }, ////1emejsbrma/handy/cowbell
          // 'nontitle': window.locale.languageCode,
          // 'turbanwise': DateTime.now().millisecondsSinceEpoch,
          // 'gsmmdbxvzj': fileId,
        },
        successHandle: (data) {
          if (data != null) {
            if (event == ServiceEventName.downApp) {
              AppKey.save(AppKey.appDeepNewUser, true);
            }
            if (event == ServiceEventName.downloadAppFirstTimeOpen) {
              AppKey.save(AppKey.appNewUser, true);
            }
          }
        },
        failHandle: (refresh, code, msg) {
          if (refresh) {
            addEvent(event, source, value, linkId, userId, fileId);
          }
        },
      );
    } catch (e) {
      print('${e.toString()}');
    }
  }

  void getAdsValue(
    ServiceEventName event,
    PlatformType source,
    dynamic ad,
    String linkId,
    String userId,
    String fileId,
  ) {
    if (ad is MaxAd) {
      addEvent(event, source, ad.revenue * 1000000, linkId, userId, fileId);
    }
    if (ad is AdWithoutView) {
      ad.onPaidEvent =
          (Ad ad, double value, PrecisionType precision, String code) {
            addEvent(event, source, value, linkId, userId, fileId);
          };
    }
    if (ad is NativeAd) {
      ServiceTool.instance.ad_event = event;
      ServiceTool.instance.ad_source = source;
      ServiceTool.instance.ad_linkId = linkId;
      ServiceTool.instance.ad_userId = userId;
      ServiceTool.instance.ad_fileId = fileId;
    }
  }
}
