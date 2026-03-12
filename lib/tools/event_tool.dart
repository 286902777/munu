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
  homeExpose('QTWLbNJLEi'),
  homeChannelExpose('fwgETUX'),
  homeHistoryExpose('aueCaQXxG'),
  landPageExpose('XgAXuVf'),
  landPageFail('Fnqg'),
  landPageUploadedExpose('EqqRVNG'),

  playStartAll('XYvKbtIOyn'),
  playSource('qUdsms'),
  playSuc('PEysav'),
  playFail('BMHhuZW'),

  adReqPlacement('dRiXNy'),
  adReqSuc('iUdecl'),
  adReqFail('xQgUj'),
  adNeedShow('nWlKwMoQrt'),
  adShowPlacement('xZDX'),
  adShowFail('qso'),
  adClick('iEiqUlEU'),

  historyExpose('cFddAitrG'),

  deeplinkOpen('fME'),
  channelListExpose('VJgOj'),
  channelListClick('TXtz'),
  channelPageExpose('zYMUsFZ'),
  session('session'),
  ads('ads'),
  install('install'),

  premiumExpose('vRjT'),
  premiumSuc('KmNSSMtpnf'),
  premiumFail('UCUbAcJ'),
  premiumVerify('QuguDdiBsf'),
  premiumClick('oqx');

  final String name;
  const EventApi(this.name);
}

enum EventParaName {
  value('bQEzUtS'),
  type('mgY'),
  method('zkLr'),
  source('azLk'),
  entrance('RfrHvQCsxX'),
  sub('GUCb'),
  code('syuxDqMO'),
  history('ytdiwXq'),
  linkIdLandPage('DFIu'),
  linkSource('SxqzCYis'),
  isFirstLink('VrcXWAc'),
  iPlayerUid('mBiEt');

  final String name;
  const EventParaName(this.name);
}

enum EventParaValue {
  sub('JrgYO'),
  noPadding('EfIm'),
  cash('HLFN'),
  quick('gZTt'),
  history('ZNqWnZ'),
  list('lyKRIIL'),
  recommend('iLtBGyEU'),
  delayLink('WdmqFM'),
  link('Qmu'),
  popup('GXCgAyUS'),
  landPageAvtor('HKuowNCZ'),
  page('PNvvC'),
  auto('EzTdKrJ'),
  click('HvWJqe'),
  ad('xydBpfeMh'),
  accelerate('UXuLatXmy'),
  weekly('FnOlBz'),
  yearly('VZA'),
  lifetime('KdbK'),
  playback('HaZIAQaXpL'),
  playTen('pwpk'),
  play('AaqXiyxq'),
  playNext('UewDgyuwkk'),
  coldOpen('jWt'),
  hotOpen('Lbay'),
  playlistFile('RLPrVcBtoe'),
  playlistRecommend('eSZ'),

  home('fFSJ');

  final String value;
  const EventParaValue(this.value);
}

class EventTool extends GetConnect {
  static const contentType = 'application/json';

  static final EventTool instance = EventTool()..onInit();

  @override
  void onInit() async {
    // httpClient.baseUrl = 'https://test-ninth.lensvids.com/bobby/naughty/ritchie';
    httpClient.baseUrl = 'https://ninth.lensvids.com/halifax/xylem';
    httpClient.maxAuthRetries = 1;
    httpClient.defaultContentType = EventTool.contentType;
  }

  Future<void> loadLocalConfig() async {
    Map<String, dynamic>? data = await AppKey.getMap(AppKey.eventList);
    await AppKey.save(AppKey.eventList, {});
    if (data != null) {
      for (var result in data.entries) {
        String s = result.value["weco"]["sheppard"];
        int t = int.tryParse(s) ?? 0;
        bool b = getDaysDifference(DateTime.fromMillisecondsSinceEpoch(t));
        if (b) {
          postRequest(result.value);
        }
      }
    }
  }

  bool getDaysDifference(DateTime date) {
    final nowData = DateTime.now();
    final utcDate1 = DateTime.utc(nowData.year, nowData.month, nowData.day);
    final utcDate2 = DateTime.utc(date.year, date.month, date.day);

    return (utcDate2.difference(utcDate1).inDays).abs() < 3;
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
    para = {
      'sanitate': {
        'zombie': app_Bunlde_Id,
        'madrid': info.version, //应用的版本
        'legatee': locale.languageCode, //system_language
        'year': await getDistinctId(), //distinct_id
      },
      'weco': {
        'peppery': 'mcc',
        'sworn': systemVersion, //操作系统版本号
        'sheppard': '${DateTime.now().millisecondsSinceEpoch}', //日志发生的客户端时间
        'ph.d': 'tientsin', //映射关系: {“activate”: “android”, “tientsin”: “ios”}
        'rapport': idfv, //idfv
        'usurp': modelInfo, //手机型号
        'issuant': brandInfo, //手机厂商，apple、 huawei、oppo
      },
      'nautical': {
        'trusty': 'mcc',
        'bounty': Uuid().v4(), //log_id
      },

      ///自定义后台字段
      'crucible>ofFG': linkId,
      'crucible>QPvmfX': apiPlatform == PlatformType.india
          ? EventParaValue.cash.value
          : EventParaValue.quick.value,
      'crucible>uPHjof': email,
      'crucible>mBiEt': userId,
      'crucible>ebfqe': playFileId,
      'crucible>MBFstUiq': simResult,
      'crucible>cHafBPU': simulatorResult,
      'crucible>JSfoV': vpnResult,
      'crucible>oCIimsCDiG': padResult,
    };
    return para;
  }

  Future<void> postRequest(Map<String, dynamic> para) async {
    String idfv = '';
    String modelInfo = '';
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      modelInfo = iosInfo.model;
      idfv = iosInfo.identifierForVendor ?? '';
    }
    try {
      if (Platform.isIOS) {
        Response response = await EventTool.instance.post(
          '',
          contentType: "application/json",
          para,
          headers: {'rapport': idfv},
          query: {'usurp': modelInfo, 'zombie': app_Bunlde_Id, 'rapport': idfv},
        );
        if (response.statusCode == 200) {
          if (para['vector'] == 'racemose') {
            AppKey.save(AppKey.appInstall, true);
          }
          if (para['vector'] == EventApi.landPageExpose.name) {
            AppKey.save(AppKey.isFirstLink, true);
          }
        } else if (response.statusCode != null) {
          Map<String, dynamic>? data = await AppKey.getMap(AppKey.eventList);
          data?[para['nautical']['bounty']] = para;
          await AppKey.save(AppKey.eventList, data);
        }
      }
    } catch (e) {
      Map<String, dynamic>? data = await AppKey.getMap(AppKey.eventList);
      data?[para['nautical']['bounty']] = para;
      await AppKey.save(AppKey.eventList, data);
      print("${e.hashCode}");
    }
  }

  // install
  Future<void> install(bool isUserId) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    Map<String, dynamic> dict = {
      'vector': 'racemose',
      'hydrate': 'build/${info.buildNumber}', //系统构建版本，Build.ID， 以 build/ 开头
      'jennie': '',
      'disciple': 'go', //映射关系：{“go”: 0, “aerial”: 1}
      'english': 0,
      'negro': 0,
      'sanborn': 0,
      'domesday': 0,
      'wrest': 0,
      'liberty': 0,
    };

    Map<String, dynamic> cusPara = await _addPara(isUserId);
    await postRequest(cusPara..addAll(dict));
  }

  Future<void> session() async {
    Map<String, dynamic> dict = {'irwin': {}};
    Map<String, dynamic> commonPara = await _addPara(true);
    await postRequest(commonPara..addAll(dict));
  }

  Future<void> adsEventUpload(Map<String, dynamic>? para) async {
    Map<String, dynamic> commonPara = await _addPara(true);
    await postRequest(commonPara..addAll(para ?? {}));
  }

  Future<void> eventUpload(EventApi event, Map<String, dynamic>? para) async {
    Map<String, dynamic> commonPara = await _addPara(true);
    await postRequest(
      {'vector': event.name}
        ..addAll(commonPara)
        ..addAll({event.name: para ?? {}}),
    );
  }
}
