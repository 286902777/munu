import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../keys/app_key.dart';
import 'common_tool.dart';

enum EventApi {
  homeExpose('iow'),
  homeChannelExpose('ixow'),
  homeHistoryExpose('idxb'),
  landPageExpose('zwb'),
  landPageFail('x23'),
  landPageUploadedExpose('bxs'),

  playStartAll('bxer'),
  playSource('bxwer'),
  playSuc('bxsa'),
  playFail('bxt'),

  adReqPlacement('yasj'),
  adReqSuc('owx'),
  adReqFail('bice'),
  adNeedShow('blos'),
  adShowPlacement('biwxb'),
  adShowFail('iwonls'),
  adClick('bois'),
  historyExpose('boiwjng'),

  deeplinkOpen('oibxb'),
  channelListExpose('oil'),
  channelListClick('los'),
  channelPageExpose('bowkgas'),
  session('session'),
  ads('ads'),
  install('install'),

  premiumExpose('oiwo'),
  premiumSuc('pabsxm'),
  premiumFail('bpoxpbosg'),
  premiumClick('ouowt');

  final String name;
  const EventApi(this.name);
}

enum EventParaName {
  type('oiwjg'),
  value('blxjb'),
  method('bpsujb'),
  sub('lbix'),
  code('powjg'),
  history('pwojh'),
  entrance('lilubsx'),
  linkIdLandPage('iog'),
  linkSource('bix'),
  isFirstLink('a'),
  iPlayerUid('b'),

  source('x');

  final String name;
  const EventParaName(this.name);
}

enum EventParaValue {
  type('oiwjg'),
  sValue('blxjb'),
  method('bpsujb'),
  sub('lbix'),
  code('pabaowjg'),
  noPadding('ss'),
  cash('powxsajg'),
  quick('poawjg'),
  history('pxswojh'),
  list('ssd'),
  recommend('s'),
  delayLink('sdas'),
  link('sdas'),
  entrance('lilubsx'),
  linkIdLandPage('iog'),
  linkSource('bix'),
  isFirstLink('a'),
  iPlayerUid('b'),

  source('x');

  final String value;
  const EventParaValue(this.value);
}

class EventTool extends GetConnect {
  static const contentType = 'application/json';

  static final EventTool instance = EventTool()..onInit();

  List<Map<String, dynamic>> eventList = <Map<String, dynamic>>[];

  List<String> logArr = [];

  @override
  void onInit() async {
    httpClient.baseUrl = 'https://sow.xi/';
    httpClient.maxAuthRetries = 1;
    httpClient.defaultContentType = EventTool.contentType;
  }

  Future<void> loadLocalConfig() async {
    Map<String, dynamic>? data = await AppKey.getMap(AppKey.eventList);
    if (data != null) {
      for (var entry in data.entries) {
        eventList.add(entry.value);
        logArr.add(entry.key);
      }
    }
  }

  Future<String> getDistinctId() async {
    String uniqueId = '';
    if (Platform.isIOS) {
      final storage = FlutterSecureStorage();
      String? unique_Id = await storage.read(key: AppKey.appOnlyId);
      if (unique_Id != null) {
        uniqueId = unique_Id;
      } else {
        uniqueId = Uuid().v4();
        storage.write(key: AppKey.appOnlyId, value: uniqueId);
      }
    }
    return uniqueId;
  }

  Future<Map<String, dynamic>> _addPara(bool isUserId) async {
    String modelInfo = '';
    String brandInfo = '';
    String systemVersion = '';
    String idfv = '';
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      modelInfo = iosInfo.model;
      brandInfo = iosInfo.systemName;
      systemVersion = iosInfo.systemVersion;
      idfv = iosInfo.identifierForVendor ?? '';
    } else {
      final AndroidDeviceInfo andInfo = await DeviceInfoPlugin().androidInfo;
      modelInfo = andInfo.manufacturer;
      brandInfo = andInfo.brand;
      systemVersion = andInfo.version.release;
    }
    Locale locale = window.locale;
    String? linkId;
    String? email;
    String? userId;
    //quick/cash，区分中东/印度平台
    PackageInfo info = await PackageInfo.fromPlatform();
    if (isUserId) {
      linkId = await AppKey.getString(AppKey.appLinkId);
      email = await AppKey.getString(AppKey.email);
      userId = await AppKey.getString(AppKey.appUserId);
    }

    Map<String, dynamic> para = {};
    para = {'s': "ba"};
    //   'cove': {
    //     'token': locale.languageCode, //system_language
    //     'quilt': await getDistinctId(), //distinct_id
    //     'offend': idfv, //idfv
    //     'hasten': app_Bunlde_Id,
    //     'pellucid': modelInfo, //手机型号
    //   },
    //   'pursuant': {
    //     'peppery': 'mcc',
    //     'kellogg': info.version, //应用的版本
    //     'efface': systemVersion, //操作系统版本号
    //     'subtlety': Uuid().v4(), //log_id
    //     'neat': '${DateTime.now().millisecondsSinceEpoch}', //日志发生的客户端时间
    //     'blunder': brandInfo, //手机厂商，apple、 huawei、oppo
    //     'coates':
    //         'usa', //映射关系: {“stowage”: “android”, “usa”: “ios”, “sung”: “web”, “gawk”: “macos”, “armhole”: “windows”}
    //   },
    //
    //   'springe': {
    //     ///自定义后台字段
    //     'ufFIwN': linkId,
    //     'ueCbDyO': apiPlatform == PlatformType.india
    //         ? 'cSCCcAmHL'
    //         : 'LlEFAXhIW',
    //     'kDbSpBhz': email,
    //     'GqPtJl': userId,
    //     'yWadcl': playFileId,
    //     'IdPV': simResult,
    //     'XruUbmtsYH': simulatorResult,
    //     'FkykQLsMIl': padResult,
    //     'AISgdNtG': vpnResult,
    //   },
    // };
    return para;
  }

  Future<void> postRequest(
    EventApi api, {
    required Map<String, dynamic> para,
  }) async {
    // if (Platform.isIOS) {
    //   bool has = false;
    //   for (Map<String, dynamic> m in eventList) {
    //     if (m.keys.contains('a')) {
    //       has = m['a']['b'] == para['a']['b'];
    //       break;
    //     }
    //   }
    //   if (has == false) {
    //     eventList.add(para);
    //     logArr.add(para['a']['b']);
    //     Map<String, dynamic> saveData = {};
    //     for (Map<String, dynamic> m in eventList) {
    //       if (m.keys.contains('a')) {
    //         saveData[m['a']['b']] = m;
    //         break;
    //       }
    //     }
    //     await AppKey.save(AppKey.eventList, saveData);
    //     postApiEvent();
    //   } else {
    //     print('-------${para['a']['b']}');
    //     postApiEvent();
    //   }
    // } else {
    //   bool has = eventList.any(
    //     (m) => m['dramatic']['knurl'] == para['dramatic']['knurl'],
    //   );
    //   if (has == false) {
    //     eventList.add(para);
    //     logArr.add(para['dramatic']['knurl']);
    //     Map<String, dynamic> saveData = {};
    //     eventList.forEach((m) {
    //       saveData[m['dramatic']['knurl']] = m;
    //     });
    //     await AppKey.save(AppKey.eventList, saveData);
    //     uploadTbaEvent();
    //   } else {
    //     print('-------${para['dramatic']['knurl']}');
    //     uploadTbaEvent();
    //   }
    // }
  }

  void postApiEvent() async {
    // if (EventTool.instance.eventList.isNotEmpty) {
    //   Locale locale = window.locale;
    //   try {
    //     Map<String, dynamic> para = EventTool.instance.eventList.first;
    //     if (Platform.isIOS) {
    //       Response response = await EventTool.instance.post(
    //         '',
    //         contentType: "application/json",
    //         para,
    //         // headers: {'emeritus': 'tacoma'},
    //         query: {
    //           'quilt': await getDistinctId(), //distinct_id
    //           'coates': 'usa',
    //           'token': locale.languageCode,
    //         },
    //       );
    //       if (response.statusCode == 200) {
    //         EventTool.instance.eventList.removeWhere(
    //           (m) => m['pursuant']['subtlety'] == para['pursuant']['subtlety'],
    //         );
    //         Map<String, dynamic> saveData = {};
    //         EventTool.instance.eventList.forEach((m) {
    //           saveData[m['pursuant']['subtlety']] = m;
    //         });
    //         if (para['saddle'] != null) {
    //           AppKey.save(AppKey.appInstall, true);
    //         }
    //         if (para['humane'] == EventApi.landpageExpose.name) {
    //           AppKey.save(AppKey.isFirstLink, true);
    //         }
    //         await AppKey.save(AppKey.eventList, saveData);
    //       } else if (response.statusCode != null) {
    //         print(response.status.code);
    //       }
    //     }
    //     postApiEvent();
    //   } catch (e) {
    //     print("${e.hashCode}");
    //   }
    // }
  }

  // install
  Future<void> install(bool isUserId) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    Map<String, dynamic> dict = {
      // 'demand': 'build/${info.buildNumber}', //系统构建版本，Build.ID， 以 build/ 开头
      // 'deadwood': '',
      // 'sixteen': 'saga', //映射关系：{“executor”: 0, “consul”: 1}
      // 'aback': 0,
      // 'bookcase': 0,
      // 'tack': 0,
      // 'stare': 0,
      // 'itt': 0,
      // 'fungible': 0,
      's': 1,
    };

    Map<String, dynamic> commonPara = await _addPara(isUserId);
    await postRequest(EventApi.install, para: commonPara..addAll({'bs': dict}));
  }

  Future<void> session() async {
    Map<String, dynamic> dict = {'ba': 'ny'};
    Map<String, dynamic> commonPara = await _addPara(true);
    await postRequest(EventApi.session, para: commonPara..addAll(dict));
  }

  Future<void> adsEventUpload(Map<String, dynamic>? para) async {
    Map<String, dynamic> commonPara = await _addPara(true);
    await postRequest(EventApi.ads, para: commonPara..addAll(para ?? {}));
  }

  Future<void> eventUpload(EventApi event, Map<String, dynamic>? para) async {
    Map<String, dynamic> commonPara = await _addPara(true);
    if (para == null) {
      await postRequest(event, para: {'ba': event.name}..addAll(commonPara));
    } else {
      // Map<String, dynamic> dict = {
      //   for (var entry in para.entries) 'outlawry<${entry.key}': entry.value,
      // };
      await postRequest(
        event,
        para: {'lsx': event.name}
          ..addAll(commonPara)
          ..addAll({'ba': para}),
      );
    }
  }
}
