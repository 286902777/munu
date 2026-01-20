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
        kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:munu/tools/event_tool.dart';

import '../keys/app_key.dart';
import 'admob_tool.dart';
import 'common_tool.dart';

class FireConfigKey {
  static String maxiOSConfigKey = 'ios_lens_ads';

  static String maxAndroidConfigKey = 'android_lens_ads';

  static String maxiOSPlusConfigKey = 'ios_lens_plus';

  static String maxAndroidPlusConfigKey = 'android_lens_plus';

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
  // 原生广告显示时长
  static String doubleNativeTimeKey = 'doubleNativeTimeKey';
  // 原生广告关闭机率
  static String doubleNativeClickKey = 'doubleNativeClickKey';

  static String playMethod = 'playMethod';

  static String middlePlayKey = 'middlePlayKey';

  static String middlePlayTimeKey = 'middlePlayTimeKey';

  static String middlePlayCloseTime = 'middlePlayCloseTime';

  static String middlePlayCloseClick = 'middlePlayCloseClick';

  static String levelKey = 'lens_Level';

  static String typeKey = 'lens_type';

  static String sourceKey = 'lens_source';

  static String adsIdKey = 'lens_id';

  static String adsTwoIdKey = 'lens_tid';

  static String clockFileName = 'clock_config';

  static String userVipName = 'user_premium_config';

  static String userVipInfoName = 'premium_info';

  static String userVipProductId = 'premium_productId';
  static String userVipHot = 'premium_hot';
  static String userVipIndex = 'premium_index';
  static String userVipSelect = 'premium_selected';
  static String userVipType = 'premium_type';
}

class FireBaseTool {
  static final FireBaseTool instance = FireBaseTool();

  static Map userVipFile = {
    FireConfigKey.userVipInfoName: [
      {
        FireConfigKey.userVipProductId: 'lens_lifetime',
        FireConfigKey.userVipIndex: 0,
        FireConfigKey.userVipHot: true,
        FireConfigKey.userVipSelect: true,
        FireConfigKey.userVipType: 'Permanent',
      },
      {
        FireConfigKey.userVipProductId: 'lens_yearly',
        FireConfigKey.userVipIndex: 1,
        FireConfigKey.userVipHot: false,
        FireConfigKey.userVipSelect: false,
        FireConfigKey.userVipType: 'Annually',
      },
      {
        FireConfigKey.userVipProductId: 'lens_weekly',
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
    FireConfigKey.doubleNativeTimeKey: 7,
    FireConfigKey.doubleNativeClickKey: 50,
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
        FireConfigKey.adsIdKey: '04c3fc232300d56b4',
      },
    ],
    AdsSceneType.play.value: [
      {
        FireConfigKey.levelKey: 7,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '04c12300d56b4',
      },
    ],
    AdsSceneType.channel.value: [
      {
        FireConfigKey.levelKey: 6,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '04123418b00d56b4',
      },
    ],
    AdsSceneType.middle.value: [],
  };

  static Map adsPlusFile = {
    AdsSceneType.plus.value: [
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.native.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-1124317440652519/7831645754',
      },
    ],
  };

  static Map adsThreeFile = {
    AdsSceneType.three.value: [],
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

    final AppsFlyerOptions afiOS = AppsFlyerOptions(
      afDevKey: 'LGCq2ac2vattczm2ZW3JEa',
      appId: '6758001383',
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
      manualStart: true,
    );

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
      if (adsFile[FireConfigKey.doubleNativeTimeKey] != null) {
        AdmobTool.instance.doubleNativeTime =
            adsFile[FireConfigKey.doubleNativeTimeKey].toInt();
      }
      if (adsFile[FireConfigKey.doubleNativeClickKey] != null) {
        AdmobTool.instance.doubleNativeClick =
            adsFile[FireConfigKey.doubleNativeClickKey].toInt();
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
        dynamic adsArrs = FireBaseTool.adsFile[type.value];
        if (adsArrs is List) {
          adsArrs.sort((x, y) {
            return (y[FireConfigKey.levelKey]).compareTo(
              x[FireConfigKey.levelKey],
            );
          });
        }
      }

      for (AdsSceneType type in AdsSceneType.values) {
        dynamic adsArrs = FireBaseTool.adsPlusFile[type.value];
        if (adsArrs is List) {
          adsArrs.sort((x, y) {
            return (y[FireConfigKey.levelKey]).compareTo(
              x[FireConfigKey.levelKey],
            );
          });
        }
      }

      for (AdsSceneType type in AdsSceneType.values) {
        dynamic adsArrs = FireBaseTool.adsThreeFile[type.value];
        if (adsArrs is List) {
          adsArrs.sort((x, y) {
            return (y[FireConfigKey.levelKey]).compareTo(
              x[FireConfigKey.levelKey],
            );
          });
        }
      }

      adsFile[AdsSceneType.plus.value] = adsPlusFile[AdsSceneType.plus.value];
      adsFile[AdsSceneType.three.value] = adsThreeFile[AdsSceneType.three.value];

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

    late AppsflyerSdk _afSdk = AppsflyerSdk(afiOS);

    // Deep linking callback
    _afSdk.onDeepLinking((DeepLinkResult dp) async {
      switch (dp.status) {
        case Status.FOUND:
          print(dp.deepLink?.deepLinkValue);
          String? link = dp.deepLink?.deepLinkValue;
          isDeepLink = dp.deepLink?.isDeferred ?? false;
          if (link != null) {
            await readDeepInfo(link);
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
    await _afSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _afSdk.startSDK(
      onSuccess: () {
        print("onSuccess");
      },
      onError: (code, msg) {
        print("d error");
      },
    );
  }
}

Future<void> readDeepInfo(String info) async {
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
    apiPlatform = PlatformType.middle;
  }
  await AppKey.save(AppKey.appPlatform, plat);
  bool isFirst = await AppKey.getBool('getDeepLink') ?? false;
  EventTool.instance.eventUpload(EventApi.deeplinkOpen, {
    EventParaName.linkSource.name: isDeepLink
        ? EventParaValue.delayLink.value
        : EventParaValue.link.value,
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

  // static const FirebaseOptions android = FirebaseOptions(
  //   apiKey: 'sdfssaas',
  //   appId: '1:sdfassdgfasdf',
  //   projectId: 'xxabssaasx',
  //   storageBucket: 'sdfaffsdfa.app',
  //   messagingSenderId: '138415123',
  // );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ixsx124124sislU',
    appId: '1:522459418:ios:b360724235225b96e863',
    projectId: 'lens-ios-734dd',
    iosBundleId: 'com.lens.videoapp',
    storageBucket: 'lens-ios-754dd.firebaxge.app',
    messagingSenderId: '1429418',
  );
}
