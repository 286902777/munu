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
  static String maxiOSConfigKey = 'lens_ios_ads';

  static String maxAndroidConfigKey = 'android_lens_ads';

  static String maxiOSPlusConfigKey = 'lens_ios_plus';

  static String maxiOSThreeConfigKey = 'lens_ios_three';

  static String maxAndroidPlusConfigKey = 'android_lens_plus';

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

  static String clockFileName = 'sim_config';

  static String userVipName = 'premium_config';

  static String userVipInfoName = 'premium_list';

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
        FireConfigKey.userVipProductId: 'Lens_lifetime',
        FireConfigKey.userVipIndex: 0,
        FireConfigKey.userVipHot: true,
        FireConfigKey.userVipSelect: true,
        FireConfigKey.userVipType: 'Permanent',
      },
      {
        FireConfigKey.userVipProductId: 'Lens_year',
        FireConfigKey.userVipIndex: 1,
        FireConfigKey.userVipHot: false,
        FireConfigKey.userVipSelect: false,
        FireConfigKey.userVipType: 'Yearly',
      },
      {
        FireConfigKey.userVipProductId: 'Lens_week',
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
        FireConfigKey.adsIdKey: '0101407bdc3d3eca',
      },
      {
        FireConfigKey.levelKey: 4,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-7475681591463110/7482129416',
      },
      {
        FireConfigKey.levelKey: 3,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '7dffd4ba7fb64de6',
      },
    ],
    AdsSceneType.play.value: [
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '0101407bdc3d3eca',
      },
      {
        FireConfigKey.levelKey: 4,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-7475681591463110/7482129416',
      },
      {
        FireConfigKey.levelKey: 3,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '7dffd4ba7fb64de6',
      },
    ],
    AdsSceneType.channel.value: [
      {
        FireConfigKey.levelKey: 5,
        FireConfigKey.typeKey: AdsType.rewarded.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '0101407bdc3d3eca',
      },
      {
        FireConfigKey.levelKey: 4,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.admob.value,
        FireConfigKey.adsIdKey: 'ca-app-pub-7475681591463110/7482129416',
      },
      {
        FireConfigKey.levelKey: 3,
        FireConfigKey.typeKey: AdsType.interstitial.value,
        FireConfigKey.sourceKey: AdsSourceType.max.value,
        FireConfigKey.adsIdKey: '7dffd4ba7fb64de6',
      },
    ],
    AdsSceneType.middle.value: [],
  };

  static Map adsPlusFile = {
    AdsSceneType.plus.value: [
      // {
      //   FireConfigKey.levelKey: 5,
      //   FireConfigKey.typeKey: AdsType.native.value,
      //   FireConfigKey.sourceKey: AdsSourceType.admob.value,
      //   FireConfigKey.adsIdKey:
      //       'ca-app-pub-3940256099942544/2247696110', // test
      // },
    ],
  };

  static Map adsThreeFile = {
    AdsSceneType.three.value: [
      // {
      //   FireConfigKey.levelKey: 5,
      //   FireConfigKey.typeKey: AdsType.native.value,
      //   FireConfigKey.sourceKey: AdsSourceType.admob.value,
      //   FireConfigKey.adsIdKey:
      //       'ca-app-pub-3940256099942544/2521693316', // test
      //   FireConfigKey.adsTwoIdKey:
      //       'ca-app-pub-3940256099942544/3986624511', // test
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
      String mFile = remote.getString(
        Platform.isIOS
            ? FireConfigKey.maxiOSConfigKey
            : FireConfigKey.maxAndroidConfigKey,
      );
      String pFile = remote.getString(
        Platform.isIOS
            ? FireConfigKey.maxiOSPlusConfigKey
            : FireConfigKey.maxAndroidPlusConfigKey,
      );

      String tFile = remote.getString(FireConfigKey.maxiOSThreeConfigKey);
      if (mFile.isNotEmpty) {
        adsFile = jsonDecode(mFile);
      }

      if (pFile.isNotEmpty) {
        adsPlusFile = jsonDecode(pFile);
      }

      if (tFile.isNotEmpty) {
        adsThreeFile = jsonDecode(tFile);
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
      adsFile[AdsSceneType.three.value] =
          adsThreeFile[AdsSceneType.three.value];

      String simFile = remote.getString(FireConfigKey.clockFileName);
      if (simFile.isNotEmpty) {
        FireBaseTool.clockFile = jsonDecode(simFile);
        isSimCard = FireBaseTool.clockFile['sim'];
        isSimLimit = FireBaseTool.clockFile['sim_Limit'];
        isEmulator = FireBaseTool.clockFile['emulator'];
        isEmulatorLimit = FireBaseTool.clockFile['emulator_Limit'];
        isPad = FireBaseTool.clockFile['pad'];
        isPadLimit = FireBaseTool.clockFile['pad_Limit'];
        isVpn = FireBaseTool.clockFile['vpn'];
        isVpnLimit = FireBaseTool.clockFile['vpn_Limit'];
      }

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
            fetchTimeout: const Duration(seconds: 15),
            minimumFetchInterval: const Duration(minutes: 1),
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

    String maxId = 'GfQnlat0NBNnAweifSxxL5Z5z8ILJg2xAqWoDCTnH1Mp';
    AppLovinMAX.initialize(
      '${maxId}k0HSeVtfFlzIeMTwr7HcIFtdOX6HmJGTsfaUIV_KON',
    );
  }
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
    apiKey: 'AIzaSyDMLKmBXFSRXrT7swFLhMRpeSJaGiMn1h0',
    appId: '1:268941655656:ios:2752e8203170a3399d05dd',
    projectId: 'lens-ios',
    iosBundleId: 'com.lens.videoapp',
    storageBucket: 'lens-ios.firebasestorage.app',
    messagingSenderId: '268941655656',
  );
}
