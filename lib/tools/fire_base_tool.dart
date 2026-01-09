import 'dart:convert';
import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart'
    show
        FlutterError,
        FlutterErrorDetails,
        TargetPlatform,
        defaultTargetPlatform,
        kDebugMode,
        kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:munu/tools/event_tool.dart';

import '../keys/app_key.dart';
import 'admob_tool.dart';
import 'common_tool.dart';

class FireConfigKey {
  static String maxiOSConfigKey = 'ios_frame_ads';

  static String maxAndroidConfigKey = 'android_frame_ads';

  static String maxiOSPlusConfigKey = 'ios_frame_plus';

  static String maxAndroidPlusConfigKey = 'android_frame_plus';

  static String maxKey =
      'GfQnlat0NBNnAweifSxxL5Z5z8ILJg2xAqWoDCTnH1Mpk0HSeVtfFlzIeMTwr7HcIFtdOX6HmJGTsfaUIV_KON';
  // app打开等待时长
  static String appStartTime = 'appStartTime';
  // 播放多长时间开启广告
  static String playWaitKey = "playWaitKey";
  // 广告间隔时间
  static String adsTimeKey = 'adsTimeKey';
  // 原生广告显示时长
  static String nativeTimeKey = 'nativeTimeKey';
  // 原生广告关闭机率
  static String nativeClickKey = 'nativeClickKey';

  static String playMethod = 'playMethod';

  static String middlePlayKey = 'middlePlayKey';

  static String middlePlayTimeKey = 'middlePlayTimeKey';

  static String middlePlayCloseTime = 'middlePlayCloseTime';

  static String middlePlayCloseClick = 'middlePlayCloseClick';

  static String levelKey = 'frame_Level';

  static String typeKey = 'frame_type';

  static String sourceKey = 'frame_source';

  static String adsIdKey = 'frame_id';

  static String clockFileName = 'clock_config';

  static String userVipName = 'user_vip_config';

  static String userVipInfoName = 'vip_info';

  static String userVipProductId = 'vip_productId';
  static String userVipHot = 'vip_hot';
  static String userVipIndex = 'vip_index';
  static String userVipSelect = 'vip_selected';
  static String userVipType = 'vip_type';
}

class FireBaseTool {
  static final FireBaseTool instance = FireBaseTool();

  static Map userVipFile = {
    FireConfigKey.userVipInfoName: [
      {
        FireConfigKey.userVipProductId: 'rme_lifetime',
        FireConfigKey.userVipIndex: 0,
        FireConfigKey.userVipHot: true,
        FireConfigKey.userVipSelect: true,
        FireConfigKey.userVipType: 'Permanent',
      },
      {
        FireConfigKey.userVipProductId: 'rme_yearly',
        FireConfigKey.userVipIndex: 1,
        FireConfigKey.userVipHot: false,
        FireConfigKey.userVipSelect: false,
        FireConfigKey.userVipType: 'Annually',
      },
      {
        FireConfigKey.userVipProductId: 'rme_weekly',
        FireConfigKey.userVipIndex: 2,
        FireConfigKey.userVipHot: false,
        FireConfigKey.userVipSelect: false,
        FireConfigKey.userVipType: 'Weekly',
      },
    ],
  };

  static Map adsFile = {
    FireConfigKey.appStartTime: 7,
    FireConfigKey.adsTimeKey: 60,
    FireConfigKey.nativeTimeKey: 7,
    FireConfigKey.nativeClickKey: 80,
    FireConfigKey.playWaitKey: 600,
    FireConfigKey.playMethod: 0,
    FireConfigKey.middlePlayKey: 5,
    FireConfigKey.middlePlayTimeKey: 10,
    FireConfigKey.middlePlayCloseTime: 7,
    FireConfigKey.middlePlayCloseClick: 80,
    AdsSceneType.open.value: [
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '04c3fcf8b00d56b4',
      },
      {
        FireConfigKey.levelKey: 4,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-1124317440652519/9555844867',
      },
      {
        FireConfigKey.levelKey: 2,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '3b3b3f6e3fad773b',
      },
    ],
    AdsSceneType.play.value: [
      {
        FireConfigKey.levelKey: 7,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '04c3fcf8b00d56b4',
      },
      {
        FireConfigKey.levelKey: 4,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-1124317440652519/9555844867',
      },
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '3b3b3f6e3fad773b',
      },
    ],
    AdsSceneType.channel.value: [
      {
        FireConfigKey.levelKey: 6,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '04c3fcf8b00d56b4',
      },
      {
        FireConfigKey.levelKey: 4,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-1124317440652519/9555844867',
      },
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '3b3b3f6e3fad773b',
      },
    ],
    // AdsSceneType.middle.value: [
    //   {
    //     FireConfigKey.levelKey: 5,
    //     FireConfigKey.typeKey: AdsType.native.value,
    //     FireConfigKey.sourceKey: AdsSourceType.admob.value,
    //     FireConfigKey.adsIdKey: 'ca-app-pub-1124317440652519/7831645754',
    //   },
    // ],
  };

  static Map adsPlusFile = {
    AdsSceneType.plus.value: [
      // {
      //   FireConfigKey.levelKey: 5,
      //   FireConfigKey.typeKey: AdsType.native.value,
      //   FireConfigKey.sourceKey: AdsSourceType.admob.value,
      //   FireConfigKey.adsIdKey: 'ca-app-pub-1124317440652519/7831645754',
      // },
    ],
  };
  static Map clockFile = {};
  static late FirebaseAnalyticsObserver observer;

  Future<void> addConfig() async {
    await Firebase.initializeApp(options: DefaultOptions.currentPlatform);
    FirebaseAnalytics analytic = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: analytic);

    FirebaseRemoteConfig remote = FirebaseRemoteConfig.instance;
    await remote.setDefaults(
      Platform.isIOS
          ? {FireConfigKey.maxiOSConfigKey: jsonEncode(adsFile)}
          : {FireConfigKey.maxAndroidConfigKey: jsonEncode(adsFile)},
    );

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordError(
        details,
        details.stack,
        fatal: true,
      );
    };

    updateRemoteSet() async {
      String mfile = remote.getString(
        Platform.isIOS
            ? FireConfigKey.maxiOSConfigKey
            : FireConfigKey.maxAndroidConfigKey,
      );
      String pfile = remote.getString(
        Platform.isIOS
            ? FireConfigKey.maxiOSPlusConfigKey
            : FireConfigKey.maxAndroidPlusConfigKey,
      );
      String cflie = remote.getString(FireConfigKey.clockFileName);
      if (mfile.isNotEmpty) {
        adsFile = jsonDecode(mfile);
      }

      if (pfile.isNotEmpty) {
        adsPlusFile = jsonDecode(pfile);
      }

      if (adsFile[FireConfigKey.playWaitKey] != null) {
        AdmobTool.instance.playShowTime = adsFile[FireConfigKey.playWaitKey]
            .toInt();
      }
      if (adsFile[FireConfigKey.adsTimeKey] != null) {
        AdmobTool.instance.sameInterval = adsFile[FireConfigKey.adsTimeKey]
            .toInt();
      }
      if (adsFile[FireConfigKey.nativeTimeKey] != null) {
        AdmobTool.instance.nativeTime = adsFile[FireConfigKey.nativeTimeKey]
            .toInt();
      }
      if (adsFile[FireConfigKey.nativeClickKey] != null) {
        AdmobTool.instance.nativeClick = adsFile[FireConfigKey.nativeClickKey]
            .toInt();
      }
      if (adsFile[FireConfigKey.appStartTime] != null) {
        AdmobTool.instance.startLoadTime = adsFile[FireConfigKey.appStartTime]
            .toInt();
      }
      if (adsFile[FireConfigKey.playMethod] != null) {
        AdmobTool.instance.playMethod = adsFile[FireConfigKey.playMethod]
            .toInt();
      }
      if (adsFile[FireConfigKey.middlePlayKey] != null) {
        AdmobTool.instance.middlePlayIdx = adsFile[FireConfigKey.middlePlayKey]
            .toInt();
      }

      if (adsFile[FireConfigKey.middlePlayTimeKey] != null) {
        AdmobTool.instance.middlePlayTime =
            adsFile[FireConfigKey.middlePlayTimeKey].toInt();
      }

      if (adsFile[FireConfigKey.middlePlayCloseTime] != null) {
        AdmobTool.instance.middlePlayCloseTime =
            adsFile[FireConfigKey.middlePlayCloseTime].toInt();
      }

      if (adsFile[FireConfigKey.middlePlayCloseClick] != null) {
        AdmobTool.instance.middlePlayCloseClick =
            adsFile[FireConfigKey.middlePlayCloseClick].toInt();
      }

      for (AdsSceneType type in AdsSceneType.values) {
        dynamic adsList = FireBaseTool.adsFile[type.value];
        if (adsList is List) {
          adsList.sort((x, y) {
            return (y[FireConfigKey.levelKey]).compareTo(
              x[FireConfigKey.levelKey],
            );
          });
        }
      }

      for (AdsSceneType type in AdsSceneType.values) {
        dynamic adsList = FireBaseTool.adsPlusFile[type.value];
        if (adsList is List) {
          adsList.sort((x, y) {
            return (y[FireConfigKey.levelKey]).compareTo(
              x[FireConfigKey.levelKey],
            );
          });
        }
      }

      adsFile[AdsSceneType.plus.value] = adsPlusFile[AdsSceneType.plus.value];
      // if (cflie.isNotEmpty) {
      //   FireBaseTool.clockFile = jsonDecode(cflie);
      //   isSimCard = FireBaseTool.clockFile['sim'];
      //   isSimLimit = FireBaseTool.clockFile['simlimit'];
      //   isEmulator = FireBaseTool.clockFile['emulator'];
      //   isEmulatorLimit = FireBaseTool.clockFile['emulatorlimit'];
      //   isPad = FireBaseTool.clockFile['pad'];
      //   isPadLimit = FireBaseTool.clockFile['padlimit'];
      //   isVpn = FireBaseTool.clockFile['vpn'];
      //   isVpnLimit = FireBaseTool.clockFile['vpnlimit'];
      // }

      if ((remote.getString(FireConfigKey.userVipName)).isNotEmpty) {
        userVipFile = jsonDecode(remote.getString(FireConfigKey.userVipName));
        dynamic priceList =
            FireBaseTool.userVipFile[FireConfigKey.userVipInfoName];
        if (priceList is List) {
          priceList.sort((a, b) {
            return (a[FireConfigKey.userVipIndex]).compareTo(
              b[FireConfigKey.userVipIndex],
            );
          });
        }
      }
    }

    remote
        .setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(minutes: 1),
            minimumFetchInterval: const Duration(hours: 24),
          ),
        )
        .then((value) async {
          //第一次拉取配置
          try {
            await remote.fetchAndActivate();
          } catch (error) {
            print(error);
          }
          updateRemoteSet();
        });
    //监听配置更新
    remote.onConfigUpdated.listen((event) async {
      await remote.activate();
      updateRemoteSet();
    });

    MobileAds.instance.initialize();

    AppLovinMAX.initialize(FireConfigKey.maxKey);

    final AppsFlyerOptions afiOS = AppsFlyerOptions(
      afDevKey: 'vJ6Sax2yK58yGZamTRTZZj',
      appId: '6755174122',
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
      manualStart: true,
    );

    late AppsflyerSdk _appsflyerSdk = AppsflyerSdk(afiOS);

    // Deep linking callback
    _appsflyerSdk.onDeepLinking((DeepLinkResult dp) async {
      switch (dp.status) {
        case Status.FOUND:
          print(dp.deepLink?.deepLinkValue);
          String? link = dp.deepLink?.deepLinkValue;
          isDeepLink = dp.deepLink?.isDeferred ?? false;
          if (link != null) {
            await getDeepDetails(link);
          }
          break;
        case Status.NOT_FOUND:
          print("deep link not found");
          break;
        case Status.ERROR:
          print("deep link error: ${dp.error}");
          break;
        case Status.PARSE_ERROR:
          print("deep link status parsing error");
          break;
      }
    });

    // Init of AppsFlyer SDK
    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _appsflyerSdk.startSDK(
      onSuccess: () {
        print("onSuccess");
      },
      onError: (code, msg) {
        print("d error");
      },
    );
  }
}

Future<void> getDeepDetails(String info) async {
  Uri uri = Uri.parse(info);
  Map<String, String> para = uri.queryParameters;
  String? linkId = para['levanto'];
  if (linkId != null && linkId.isNotEmpty) {
    deepLink = linkId;
    appLinkId = linkId;
    await AppKey.save(AppKey.appLinkId, linkId);
  }
  String? plat = para['tumefying'];
  if (plat == PlatformType.india.name) {
    apiPlatform = PlatformType.india;
  } else {
    apiPlatform = PlatformType.east;
  }
  await AppKey.save(AppKey.appPlatform, plat);
  bool isFirst = await AppKey.getBool('getDeepLink') ?? false;
  EventTool.instance.eventUpload(EventApi.deeplinkOpen, {
    EventParaName.linkSource.name: isDeepLink ? 'HuN' : 'ExzSkQi',
    EventParaName.isFirstLink.name: isFirst,
  });
  pushDeepPageInfo?.call();
}

class DefaultOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      // case TargetPlatform.android:
      //   return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'sdfsaas',
    appId: '1:sdfasfasdf',
    projectId: 'xxabaasx',
    storageBucket: 'sdfasdfa.app',
    messagingSenderId: '1483151234',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ixislU',
    appId: '1:425765129418:ios:b360724df8e7db5b96e863',
    projectId: 'frame-ios-734dd',
    iosBundleId: 'com.frame.lumistream',
    storageBucket: 'frame-ios-734dd.firebasestorage.app',
    messagingSenderId: '42589235759418',
  );
}

class AdsUnitId {
  static String admobOpenAdsUnitId = '';
  static String admobInterstitialAdsUnitId = '';
  static String admobRewardedAdsUnitId = '';
  static String admobNativeAdsUnitId = '';

  static String maxOpenAdsUnitId = '';
  static String maxInterstitialAdsUnitId = '';
  static String maxRewardedAdsUnitId = '';
}
