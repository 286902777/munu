import 'dart:async';
import 'dart:io';

import 'package:applovin_max/applovin_max.dart' hide NativeAdListener;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:munu/tools/service_tool.dart';
import 'common_tool.dart';
import 'event_tool.dart';
import 'fire_base_tool.dart';

typedef AdsDisplayStateChanged<AdsState> =
    void Function(
      AdsState adsState, {
      AdsType? adsType,
      dynamic ad,
      dynamic twoAd,
      AdsSceneType? sceneType,
    });

enum AdsState { normal, showing, dismissed }

enum AdsSceneType {
  open('open'),
  play('play'),
  channel('channel'),
  middle('middle'),
  plus('plus'),
  three('three');

  final String value;
  const AdsSceneType(this.value);
}

enum AdsSourceType {
  admob('admob'),
  max('max');

  final String value;
  const AdsSourceType(this.value);
}

enum AdsType {
  open('open'),
  interstitial('interstitial'),
  rewarded('rewarded'),
  native('native');

  final String value;
  const AdsType(this.value);
}

class AdmobTool {
  static final AdmobTool instance = AdmobTool();
  int playShowTime = 600;
  int startLoadTime = 7;
  int sameInterval = 60;
  int nativeTime = 7;
  int nativeClick = 50;
  int doubleNativeTime = 7;
  int doubleNativeClick = 50;
  int middlePlayIdx = 5;
  int middlePlayTime = 10;
  int middlePlayCloseTime = 7;
  int middlePlayCloseClick = 50;
  int playMethod = 1;
  String msg = '';
  dynamic doubleNativeAd;

  static AdsSceneType currentScene = AdsSceneType.open;
  static bool showed = false;
  static int? lastDisplayTime;

  ///广告当前请求层级
  static final Map<String, int> adsRequestIdxMap = {
    AdsSceneType.open.value: 0,
    AdsSceneType.play.value: 0,
    AdsSceneType.channel.value: 0,
    AdsSceneType.middle.value: 0,
    AdsSceneType.plus.value: 0,
    AdsSceneType.three.value: 0,
  };

  ///广告缓存，key是AdModuleType，value是AdWithoutView或MaxAd
  static final Map<String, dynamic> adsMap = {
    AdsSceneType.open.value: null,
    AdsSceneType.play.value: null,
    AdsSceneType.channel.value: null,
    AdsSceneType.middle.value: null,
    AdsSceneType.plus.value: null,
    AdsSceneType.three.value: null,
  };

  ///广告被缓存时的时间戳
  static final Map<String, dynamic> adsTimeStampMap = {
    AdsSceneType.open.value: null,
    AdsSceneType.play.value: null,
    AdsSceneType.channel.value: null,
    AdsSceneType.middle.value: null,
    AdsSceneType.plus.value: null,
    AdsSceneType.three.value: null,
  };

  ///计算广告是否过期的timer，目前一个广告有效期是50分钟
  static Timer? adTimer;

  static AdsState adsState = AdsState.normal;

  static AdsSceneType scene = AdsSceneType.open;

  ///加载广告
  ///非必要不必调用此方法(除冷启动和需要重新加载广告外（比如admob横竖屏切换后）)，因为缓存里面会有广告，只需要调用showAds即可
  ///注意：只有在请求失败的时候才会传入这个levelIndex，其他时候均不传入
  static Future<Map<String, dynamic>> initAdmobOrMax(
    AdsSceneType sceneType, {
    int? levelIndex,
  }) async {
    // bool isSVip = await AppKey.getBool(AppKey.isVipUser) ?? false;
    // if (UserVipTool.instance.vipData.value.status != VipStatus.none || isSVip) {
    //   return false;
    // }
    if (levelIndex == null) {
      //重置请求index
      levelIndex = 0;
      adsRequestIdxMap[sceneType.value] = 0;
    }

    AdsSourceType adSourceType = AdsSourceType.admob;
    AdsType adType = AdsType.interstitial;

    List adsList = FireBaseTool.adsFile[sceneType.value] ?? [];
    Map? adConfig;
    if (adsList.isNotEmpty) {
      adConfig = adsList[levelIndex];
    }

    if (adConfig != null) {
      if (adConfig[FireConfigKey.sourceKey] == AdsSourceType.admob.value) {
        adSourceType = AdsSourceType.admob;
      } else if (adConfig[FireConfigKey.sourceKey] == AdsSourceType.max.value) {
        adSourceType = AdsSourceType.max;
      }

      if (adConfig[FireConfigKey.typeKey] == AdsType.open.value) {
        adType = AdsType.open;
      } else if (adConfig[FireConfigKey.typeKey] ==
          AdsType.interstitial.value) {
        adType = AdsType.interstitial;
      } else if (adConfig[FireConfigKey.typeKey] == AdsType.rewarded.value) {
        adType = AdsType.rewarded;
      } else if (adConfig[FireConfigKey.typeKey] == AdsType.native.value) {
        adType = AdsType.native;
      }

      //设置广告单元id为远程获取的
      String adsId = adConfig[FireConfigKey.adsIdKey];
      String adsDoubleId = adConfig[FireConfigKey.adsIdKey];
      if (adsId.isEmpty) {
        return {'ad': null, 'doubleAd': null};
      } else {
        if (adSourceType == AdsSourceType.admob) {
          if (adType == AdsType.open) {
            AdsUnitId.admobOpenAdsUnitId = adsId;
          } else if (adType == AdsType.interstitial) {
            AdsUnitId.admobInterstitialAdsUnitId = adsId;
          } else if (adType == AdsType.rewarded) {
            AdsUnitId.admobRewardedAdsUnitId = adsId;
          } else if (adType == AdsType.native) {
            AdsUnitId.admobNativeAdsUnitId = adsId;
            AdsUnitId.admobNativeAdsUnitTwoId = adsDoubleId;
          }
        } else if (adSourceType == AdsSourceType.max) {
          if (adType == AdsType.open) {
            AdsUnitId.maxOpenAdsUnitId = adsId;
          } else if (adType == AdsType.interstitial) {
            AdsUnitId.maxInterstitialAdsUnitId = adsId;
          } else if (adType == AdsType.rewarded) {
            AdsUnitId.maxRewardedAdsUnitId = adsId;
          }
        }
      }
    }
    dynamic admobOrMaxAd;
    dynamic admobDoubleAd;

    if (adSourceType == AdsSourceType.admob) {
      if (adType == AdsType.open) {
        admobOrMaxAd = await _requestAdmobOpenAd(sceneType);
      } else if (adType == AdsType.interstitial) {
        admobOrMaxAd = await _requestAdmobInterstitialAd(sceneType);
      } else if (adType == AdsType.rewarded) {
        admobOrMaxAd = await _requestAdmobRewardedAd(sceneType);
      } else if (adType == AdsType.native) {
        admobOrMaxAd = await _requestNativeAd(sceneType, false);
        if (AdsUnitId.admobNativeAdsUnitTwoId.isNotEmpty) {
          admobDoubleAd = await _requestNativeAd(sceneType, true);
        }
      }
    } else if (adSourceType == AdsSourceType.max) {
      if (adType == AdsType.open) {
        admobOrMaxAd = await _requestMaxOpenAdAd(sceneType);
      } else if (adType == AdsType.interstitial) {
        admobOrMaxAd = await _requestMaxInterstitialAd(sceneType);
      } else if (adType == AdsType.rewarded) {
        admobOrMaxAd = await _requestMaxRewardedAd(sceneType);
      }
    }

    if (admobOrMaxAd == null && admobDoubleAd == null) {
      //如果没有请求到广告，再用下一个广告配置层级请求
      int nextLevelIndex = adsRequestIdxMap[sceneType.value]! + 1;
      if (nextLevelIndex < adsList.length) {
        adsRequestIdxMap[sceneType.value] = nextLevelIndex;
        Map<String, dynamic> adsMap = await initAdmobOrMax(
          sceneType,
          levelIndex: nextLevelIndex,
        );
        admobOrMaxAd = adsMap['ad'];
        admobDoubleAd = adsMap['doubleAd'];
      } else {
        AdmobTool.instance.adRequestFail(sceneType);
        //当从广告配置所有层级拉了一遍广告后还没拉到广告，则最终拉取广告失败，并且重置指针
        adsRequestIdxMap[sceneType.value] = 0;
        // startLoadingOtherAd(sceneType);
      }
    } else {
      EventTool.instance.eventUpload(EventApi.adReqPlacement, {
        EventParaName.value.name: eventAdsSource.name,
      });
      EventTool.instance.eventUpload(EventApi.adReqSuc, {
        EventParaName.value.name: eventAdsSource.name,
        EventParaName.type.name: sceneType == AdsSceneType.plus ? 2 : 1,
      });
      int timeStamp = DateTime.now().millisecondsSinceEpoch;
      adsMap[sceneType.value] = admobOrMaxAd;
      AdmobTool.instance.doubleNativeAd = admobDoubleAd;
      adsTimeStampMap[sceneType.value] = timeStamp;
    }
    _checkAdsValidateTimer();
    return {'ad': admobOrMaxAd, 'doubleAd': admobDoubleAd};
  }

  void adRequestFail(AdsSceneType sceneType) {
    EventTool.instance.eventUpload(EventApi.adReqPlacement, {
      EventParaName.value.name: eventAdsSource.name,
    });
    EventTool.instance.eventUpload(EventApi.adReqFail, {
      EventParaName.value.name: eventAdsSource.name,
      EventParaName.type.name: sceneType == AdsSceneType.plus ? 2 : 1,
      EventParaName.code.name: AdmobTool.instance.msg,
    });
  }

  static startLoadingPlus(AdsSceneType sceneType) {
    if (adsMap[AdsSceneType.plus.value] == null &&
        adsRequestIdxMap[sceneType.value] == 0) {
      initAdmobOrMax(sceneType);
    }
  }

  static startLoadingThree(AdsSceneType sceneType) {
    if (adsMap[AdsSceneType.three.value] == null &&
        adsRequestIdxMap[sceneType.value] == 0) {
      initAdmobOrMax(sceneType);
    }
  }

  ///缓存中的广告有效期判断timer
  ///当缓存广告时间大于50分钟时需要将其清除，并重新获取
  static _checkAdsValidateTimer() {
    adTimer ??= Timer.periodic(const Duration(minutes: 5), (timer) {
      int nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
      for (var moduleType in AdsSceneType.values) {
        int? adTimeStamp = adsTimeStampMap[moduleType.value];
        if (adTimeStamp != null &&
            ((nowTimeStamp - adTimeStamp) / 60 / 1000) > 50) {
          adsMap[moduleType.value] = null;
          initAdmobOrMax(moduleType);
        }
      }
    });
  }

  ///显示广告
  ///返回是否显示成功
  static Future<bool> showAdsScreen(AdsSceneType sceneType) async {
    // //如果是vip则不展示广告
    // bool isSVip = await AppKey.getBool(AppKey.isVipUser) ?? false;
    // if (UserVipTool.instance.vipData.value.status != VipStatus.none || isSVip) {
    //   return false;
    // }

    if (sceneType != AdsSceneType.plus) {
      AdmobTool.startLoadingPlus(AdsSceneType.plus);
    }
    if (sceneType != AdsSceneType.three) {
      AdmobTool.startLoadingThree(AdsSceneType.three);
    }
    //正在展示则直接返回
    if (adsState == AdsState.showing) {
      return false;
    }
    //检查广告时间
    if (sceneType == AdsSceneType.middle) {
      AdmobTool.scene = sceneType;
    } else {
      if (sceneType != AdsSceneType.plus || sceneType != AdsSceneType.three) {
        AdmobTool.scene = sceneType;
        bool isOk = await _checkDisplayTime();
        if (isOk == false) {
          return false;
        }
      }
    }
    currentScene = sceneType;
    dynamic ad = adsMap[sceneType.value];
    if (ad != null) {
      EventTool.instance.eventUpload(EventApi.adNeedShow, {
        EventParaName.value.name: eventAdsSource.name,
        EventParaName.type.name: sceneType == AdsSceneType.plus ? 2 : 1,
      });
      if (ad is AppOpenAd) {
        ad.show();
      } else if (ad is InterstitialAd) {
        ad.show();
      } else if (ad is RewardedAd) {
        ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {});
      } else if (ad is NativeAd) {
        _noticeListeners(
          AdsState.showing,
          adsType: AdsType.native,
          ad: ad,
          doubleAd: AdmobTool.instance.doubleNativeAd,
          sceneType: currentScene,
        );
      } else if (ad is MaxAd) {
        bool isReady = false;
        if (ad.adUnitId == AdsUnitId.maxOpenAdsUnitId) {
          isReady = (await AppLovinMAX.isAppOpenAdReady(ad.adUnitId)) ?? false;
          if (isReady) {
            AppLovinMAX.showAppOpenAd(ad.adUnitId);
          }
        } else if (ad.adUnitId == AdsUnitId.maxInterstitialAdsUnitId) {
          isReady =
              (await AppLovinMAX.isInterstitialReady(ad.adUnitId)) ?? false;
          if (isReady) {
            AppLovinMAX.showInterstitial(ad.adUnitId);
          }
        } else if (ad.adUnitId == AdsUnitId.maxRewardedAdsUnitId) {
          isReady = (await AppLovinMAX.isRewardedAdReady(ad.adUnitId)) ?? false;
          if (isReady) {
            AppLovinMAX.showRewardedAd(ad.adUnitId);
          }
        }
        if (isReady == false) {
          //移出不能显示的广告
          adsMap[sceneType.value] = null;
          //并加载新广告
          initAdmobOrMax(sceneType);
          return false;
        }
      }

      //显示完移出广告
      //广告在显示的时候不能马上去加载下一个广告，
      //不然这个马上加载的广告show不出来，要在这个广告dismiss后再加载。
      // loadAd(moduleType);
      return true;
    } else {
      if (sceneType == AdsSceneType.plus) {
        resetDisplayTime();
      }
      // AdmobTool.instance.showFailUpload(sceneType, 'UHdCR');
      if (sceneType != AdsSceneType.middle) {
        EventTool.instance.eventUpload(EventApi.adNeedShow, {
          EventParaName.value.name: eventAdsSource.name,
          EventParaName.type.name: sceneType == AdsSceneType.plus ? 2 : 1,
        });
        EventTool.instance.eventUpload(EventApi.adShowFail, {
          EventParaName.value.name: eventAdsSource.name,
          EventParaName.type.name: sceneType == AdsSceneType.plus ? 2 : 1,
          EventParaName.code.name: EventParaValue.noPadding.value,
        });
      }

      ///No padding
      //如果没有就去加载广告
      initAdmobOrMax(sceneType);
      if (sceneType != AdsSceneType.plus && sceneType != AdsSceneType.middle) {
        showAdsScreen(AdsSceneType.plus);
        return false;
      }
      return false;
    }
  }

  void showFailUpload(AdsSceneType sceneType, String msg) {
    EventTool.instance.eventUpload(EventApi.adShowFail, {
      EventParaName.value.name: eventAdsSource.name,
      EventParaName.type.name: sceneType == AdsSceneType.plus ? 2 : 1,
      EventParaName.code.name: msg,
    });
  }

  void admobMaxUploadTba(
    String adId,
    String platform,
    String type,
    String numId,
    String place,
    double value,
  ) {
    if (Platform.isIOS) {
      EventTool.instance.adsEventUpload({
        'describe': {
          'susanne': type, //广告网络，广告真实的填充平台
          'mutandis': numId,
          'helga': platform, //广告SDK，admob，max等
          'hackle': adId, //广告位id
          'prone': place, //广告类型，插屏，原生，banner，激励视频等
          'laminar': value, //预估收入
          'mailmen': 'USD',
        },
      });
    }
  }

  ///加载 Admob的开屏广告
  static Future<AppOpenAd?> _requestAdmobOpenAd(AdsSceneType sceneType) async {
    Completer<AppOpenAd?> completer = Completer<AppOpenAd?>();
    AppOpenAd.load(
      adUnitId: AdsUnitId.admobOpenAdsUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {
              _noticeListeners(
                AdsState.showing,
                adsType: AdsType.open,
                ad: ad,
                sceneType: currentScene,
              );
              ad.onPaidEvent =
                  (Ad ad, double value, PrecisionType precision, String code) {
                    AdmobTool.instance.admobMaxUploadTba(
                      ad.adUnitId,
                      'admob',
                      ad.responseInfo?.mediationAdapterClassName ?? '',
                      ad.responseInfo?.responseId ?? '',
                      'open',
                      value,
                    );
                  };
            },
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {},
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              AdmobTool.instance.showFailUpload(sceneType, err.message);
              ad.dispose();
              _noticeListeners(
                AdsState.dismissed,
                adsType: AdsType.open,
                ad: ad,
                sceneType: currentScene,
              );
              initAdmobOrMax(currentScene);
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
              _noticeListeners(
                AdsState.dismissed,
                adsType: AdsType.open,
                ad: ad,
                sceneType: currentScene,
              );
              initAdmobOrMax(currentScene);
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {
              EventTool.instance.eventUpload(EventApi.adClick, {
                EventParaName.value.name: eventAdsSource.name,
              });
            },
          );

          // Keep a reference to the ad so you can show it later.
          completer.complete(ad);
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          AdmobTool.instance.msg = error.message;
          completer.complete();
        },
      ),
    );
    return completer.future;
  }

  ///加载 Admob的插屏广告
  static Future<InterstitialAd?> _requestAdmobInterstitialAd(
    AdsSceneType sceneType,
  ) async {
    Completer<InterstitialAd?> completer = Completer<InterstitialAd?>();
    InterstitialAd.load(
      adUnitId: AdsUnitId.admobInterstitialAdsUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {
              _noticeListeners(
                AdsState.showing,
                adsType: AdsType.interstitial,
                ad: ad,
                sceneType: currentScene,
              );
              ad.onPaidEvent =
                  (Ad ad, double value, PrecisionType precision, String code) {
                    AdmobTool.instance.admobMaxUploadTba(
                      ad.adUnitId,
                      'admob',
                      ad.responseInfo?.mediationAdapterClassName ?? '',
                      ad.responseInfo?.responseId ?? '',
                      'interstitial',
                      value,
                    );
                  };
            },
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {},
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              AdmobTool.instance.showFailUpload(sceneType, err.message);
              ad.dispose();
              _noticeListeners(
                AdsState.dismissed,
                adsType: AdsType.interstitial,
                ad: ad,
                sceneType: currentScene,
              );
              initAdmobOrMax(currentScene);
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
              _noticeListeners(
                AdsState.dismissed,
                adsType: AdsType.interstitial,
                ad: ad,
                sceneType: currentScene,
              );
              initAdmobOrMax(currentScene);
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {
              EventTool.instance.eventUpload(EventApi.adClick, {
                EventParaName.value.name: eventAdsSource.name,
              });
            },
          );

          // Keep a reference to the ad so you can show it later.
          completer.complete(ad);
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          AdmobTool.instance.msg = error.message;
          completer.complete();
        },
      ),
    );
    return completer.future;
  }

  ///加载 Admob的激励广告
  static Future<RewardedAd?> _requestAdmobRewardedAd(AdsSceneType sceneType) {
    Completer<RewardedAd?> completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: AdsUnitId.admobRewardedAdsUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {
              _noticeListeners(
                AdsState.showing,
                adsType: AdsType.rewarded,
                ad: ad,
                sceneType: currentScene,
              );
              ad.onPaidEvent =
                  (Ad ad, double value, PrecisionType precision, String code) {
                    AdmobTool.instance.admobMaxUploadTba(
                      ad.adUnitId,
                      'admob',
                      ad.responseInfo?.mediationAdapterClassName ?? '',
                      ad.responseInfo?.responseId ?? '',
                      'rewarded',
                      value,
                    );
                  };
            },
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {},
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              AdmobTool.instance.showFailUpload(sceneType, err.message);
              ad.dispose();
              _noticeListeners(
                AdsState.dismissed,
                adsType: AdsType.rewarded,
                ad: ad,
                sceneType: currentScene,
              );
              initAdmobOrMax(currentScene);
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
              _noticeListeners(
                AdsState.dismissed,
                adsType: AdsType.rewarded,
                ad: ad,
                sceneType: currentScene,
              );
              initAdmobOrMax(currentScene);
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {
              EventTool.instance.eventUpload(EventApi.adClick, {
                EventParaName.value.name: eventAdsSource.name,
              });
            },
          );

          // Keep a reference to the ad so you can show it later.
          completer.complete(ad);
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          AdmobTool.instance.msg = error.message;
          completer.complete();
        },
      ),
    );
    return completer.future;
  }

  static Future<NativeAd?> _requestNativeAd(
    AdsSceneType sceneType,
    bool isDoubleAd,
  ) {
    Completer<NativeAd?> completer = Completer<NativeAd?>();
    NativeAd(
      adUnitId: isDoubleAd
          ? AdsUnitId.admobNativeAdsUnitTwoId
          : AdsUnitId.admobNativeAdsUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          completer.complete(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          AdmobTool.instance.msg = error.message;
          completer.complete();
        },
        // Called when a click is recorded for a NativeAd.
        onAdClicked: (ad) {
          EventTool.instance.eventUpload(EventApi.adClick, {
            EventParaName.value.name: eventAdsSource.name,
          });
          clickNativeAction?.call();
        },
        // For iOS only. Called before dismissing a full screen view
        onAdWillDismissScreen: (ad) {},
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          ServiceTool.instance.addEvent(
            ServiceTool.instance.ad_event,
            ServiceTool.instance.ad_source,
            valueMicros,
            ServiceTool.instance.ad_linkId,
            ServiceTool.instance.ad_userId,
            ServiceTool.instance.ad_fileId,
          );
          AdmobTool.instance.admobMaxUploadTba(
            ad.adUnitId,
            'admob',
            ad.responseInfo?.mediationAdapterClassName ?? '',
            ad.responseInfo?.responseId ?? '',
            'native',
            valueMicros,
          );
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    ).load();
    return completer.future;
  }

  ///加载MAX的开屏广告
  static Future<MaxAd?> _requestMaxOpenAdAd(AdsSceneType sceneType) async {
    Completer<MaxAd?> completer = Completer<MaxAd?>();
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (MaxAd ad) {
          completer.complete(ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          AdmobTool.instance.msg = error.message;
          completer.complete();
        },
        onAdDisplayedCallback: (ad) {
          _noticeListeners(
            AdsState.showing,
            adsType: AdsType.open,
            ad: ad,
            sceneType: currentScene,
          );
          AdmobTool.instance.admobMaxUploadTba(
            ad.adUnitId,
            'max',
            ad.networkName,
            ad.adFormat,
            'open',
            ad.revenue * 1000000,
          );
        },
        onAdDisplayFailedCallback: (ad, error) {
          AdmobTool.instance.showFailUpload(sceneType, error.message);
          _noticeListeners(
            AdsState.dismissed,
            adsType: AdsType.open,
            ad: ad,
            sceneType: currentScene,
          );
          initAdmobOrMax(currentScene);
        },
        onAdClickedCallback: (ad) {
          EventTool.instance.eventUpload(EventApi.adClick, {
            EventParaName.value.name: eventAdsSource.name,
          });
        },
        onAdHiddenCallback: (ad) {
          _noticeListeners(
            AdsState.dismissed,
            adsType: AdsType.open,
            ad: ad,
            sceneType: currentScene,
          );
          initAdmobOrMax(currentScene);
        },
      ),
    );

    // Load the first interstitial
    AppLovinMAX.loadAppOpenAd(AdsUnitId.maxOpenAdsUnitId);
    return completer.future;
  }

  ///加载MAX的插屏广告
  static Future<MaxAd?> _requestMaxInterstitialAd(
    AdsSceneType sceneType,
  ) async {
    Completer<MaxAd?> completer = Completer<MaxAd?>();
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (MaxAd ad) {
          completer.complete(ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          print('myads:failed:${adUnitId}');
          AdmobTool.instance.msg = error.message;
          completer.complete();
        },
        onAdDisplayedCallback: (ad) {
          _noticeListeners(
            AdsState.showing,
            adsType: AdsType.interstitial,
            ad: ad,
            sceneType: currentScene,
          );
          AdmobTool.instance.admobMaxUploadTba(
            ad.adUnitId,
            'max',
            ad.networkPlacement,
            ad.adFormat,
            'interstitial',
            ad.revenue * 1000000,
          );
        },
        onAdDisplayFailedCallback: (ad, error) {
          AdmobTool.instance.showFailUpload(sceneType, error.message);
          _noticeListeners(
            AdsState.dismissed,
            adsType: AdsType.interstitial,
            ad: ad,
            sceneType: currentScene,
          );
          initAdmobOrMax(currentScene);
        },
        onAdClickedCallback: (ad) {
          EventTool.instance.eventUpload(EventApi.adClick, {
            EventParaName.value.name: eventAdsSource.name,
          });
        },
        onAdHiddenCallback: (ad) {
          _noticeListeners(
            AdsState.dismissed,
            adsType: AdsType.interstitial,
            ad: ad,
            sceneType: currentScene,
          );
          initAdmobOrMax(currentScene);
        },
      ),
    );

    // Load the first interstitial
    print(AdsUnitId.maxInterstitialAdsUnitId);
    AppLovinMAX.loadInterstitial(AdsUnitId.maxInterstitialAdsUnitId);
    return completer.future;
  }

  ///加载MAX的激励广告
  static Future<MaxAd?> _requestMaxRewardedAd(AdsSceneType sceneType) async {
    Completer<MaxAd?> completer = Completer<MaxAd?>();
    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (ad) {
          // Rewarded ad is ready to show. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) now returns 'true'
          completer.complete(ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          AdmobTool.instance.msg = error.message;
          completer.complete();
        },
        onAdDisplayedCallback: (ad) {
          _noticeListeners(
            AdsState.showing,
            adsType: AdsType.rewarded,
            ad: ad,
            sceneType: currentScene,
          );
          AdmobTool.instance.admobMaxUploadTba(
            ad.adUnitId,
            'max',
            ad.networkPlacement,
            ad.adFormat,
            'rewarded',
            ad.revenue * 1000000,
          );
        },
        onAdDisplayFailedCallback: (ad, error) {
          adsState = AdsState.normal;
          AdmobTool.instance.showFailUpload(sceneType, error.message);
          _noticeListeners(
            AdsState.dismissed,
            adsType: AdsType.rewarded,
            ad: ad,
            sceneType: currentScene,
          );
          initAdmobOrMax(currentScene);
        },
        onAdClickedCallback: (ad) {
          EventTool.instance.eventUpload(EventApi.adClick, {
            EventParaName.value.name: eventAdsSource.name,
          });
        },
        onAdHiddenCallback: (ad) {
          _noticeListeners(
            AdsState.dismissed,
            adsType: AdsType.rewarded,
            ad: ad,
            sceneType: currentScene,
          );
          initAdmobOrMax(currentScene);
        },
        onAdReceivedRewardCallback: (ad, reward) {},
      ),
    );
    AppLovinMAX.loadRewardedAd(AdsUnitId.maxRewardedAdsUnitId);
    return completer.future;
  }

  ///验证两条广告显示时间
  static Future<bool> _checkDisplayTime() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int interval = timestamp - (lastDisplayTime ?? 0);
    double intervalSeconds = interval / 1000;
    int adSecondsInterval = int.parse(
      FireBaseTool.adsFile[FireConfigKey.adsTimeKey].toString(),
    );
    print('*******${intervalSeconds - adSecondsInterval}');
    return intervalSeconds > adSecondsInterval;
  }

  ///广告显示状态监听start-----------------------------
  static final Map<String, AdsDisplayStateChanged> _listenersMap = {};

  static addListener(String key, AdsDisplayStateChanged listener) {
    _listenersMap[key] = listener;
  }

  static removeListener(String key) {
    _listenersMap.remove(key);
  }

  static removeAllListener() {
    _listenersMap.clear();
    // ValueNotifier
  }

  void nativeDismiss(
    AdsState state, {
    AdsType? adsType,
    dynamic ad,
    dynamic doubleAd,
    required AdsSceneType sceneType,
  }) {
    _noticeListeners(
      AdsState.dismissed,
      adsType: adsType,
      ad: ad,
      doubleAd: doubleAd,
      sceneType: currentScene,
    );
    AdmobTool.initAdmobOrMax(currentScene);
  }

  static _noticeListeners(
    AdsState state, {
    AdsType? adsType,
    dynamic ad,
    dynamic doubleAd,
    AdsSceneType? sceneType,
  }) {
    if (state == AdsState.showing && adsState == AdsState.showing) {
      return;
    }
    adsState = state;
    if (state == AdsState.dismissed) {
      if (sceneType == AdsSceneType.plus || sceneType == AdsSceneType.three) {
        resetDisplayTime();
      }
      if (doubleAd != null) {
        AdmobTool.instance.doubleNativeAd = null;
      }
      adsMap[sceneType?.value ?? AdsSceneType.open.value] = null;
    } else {
      EventTool.instance.eventUpload(EventApi.adShowPlacement, {
        EventParaName.value.name: eventAdsSource.name,
        EventParaName.type.name: sceneType == AdsSceneType.plus ? 2 : 1,
      });
      showed = true;
    }
    _listenersMap.forEach((key, value) {
      value(
        state,
        adsType: adsType,
        ad: ad,
        twoAd: doubleAd,
        sceneType: sceneType,
      );
    });
  }

  static resetDisplayTime() {
    if (showed == false) {
      return;
    }
    lastDisplayTime = DateTime.now().millisecondsSinceEpoch;
  }
}

class AdsUnitId {
  static String admobOpenAdsUnitId = '';
  static String admobInterstitialAdsUnitId = '';
  static String admobRewardedAdsUnitId = '';
  static String admobNativeAdsUnitId = '';
  static String admobNativeAdsUnitTwoId = '';

  static String maxOpenAdsUnitId = '';
  static String maxInterstitialAdsUnitId = '';
  static String maxRewardedAdsUnitId = '';
}
