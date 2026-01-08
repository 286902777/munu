import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:frame/admob_max/admob_max_tool.dart';
// import 'package:frame/event/back_event_manager.dart';
// import 'package:frame/vip_page/user_vip_tool.dart';
import 'package:get/get.dart';
import 'package:munu/common/tab_page.dart';

import '../generated/assets.dart';
import '../keys/app_key.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});
  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  Timer? _timer;
  double startTime = 7.0;
  double totalTime = 7.0;
  // double startTime = AdmobMaxTool.instance.startLoadTime.toDouble();
  // double totalTime = AdmobMaxTool.instance.startLoadTime.toDouble();
  var progress = 0.0.obs;
  bool isSetRoot = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startCountTime();
    // googleGMP();
    AppKey.save(AppKey.middlePlayCount, 0);
    // EventManager.instance.session();
    // AdmobMaxTool.addListener(hashCode.toString(), (
    //     state, {
    //       adsType,
    //       ad,
    //       sceneType,
    //     }) async {
    //   if (isSetRoot == true) {
    //     return;
    //   }
    //   if (state == AdsState.showing) {
    //     String linkId = await AppKey.getString(AppKey.appLinkId) ?? '';
    //     BackEventManager.instance.getAdsValue(
    //       BackEventName.advProfit,
    //       apiPlatform,
    //       ad,
    //       linkId,
    //       '',
    //       '',
    //     );
    //     if (adsType == AdsType.native) {
    //       _timer?.cancel();
    //       showDialog(
    //         context: context,
    //         builder: (context) =>
    //             NativePage(ad: ad, sceneType: sceneType ?? AdsSceneType.open),
    //       ).then((result) {
    //         AdmobMaxTool.instance.nativeDismiss(
    //           AdsState.dismissed,
    //           adsType: AdsType.native,
    //           ad: ad,
    //           sceneType: sceneType ?? AdsSceneType.open,
    //         );
    //       });
    //     }
    //   }
    //   if (state == AdsState.dismissed) {
    //     if (sceneType == AdsSceneType.plus || adsType == AdsType.rewarded) {
    //       reSetRootPage();
    //     } else {
    //       showPlusAds();
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('image/icon/munu_bg.webp'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 220),
                Image.asset(Assets.setLaunchLogo, width: 48, height: 48),
                SizedBox(height: 12),
                Text(
                  'Lens',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF17132C),
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                Text(
                  'resource loading…',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 14,
                    color: Color(0xFF17132C),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    child: Obx(
                      () => LinearProgressIndicator(
                        value: progress.value,
                        backgroundColor: Color(0x4DFF5C24),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF5C24),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void startCountTime() async {
    // bool noStart = await UserInfo.getBool(UserInfo.onceInstallApp) ?? false;
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (startTime > 0) {
        progress.value = (totalTime - startTime) / totalTime;
        setState(() {
          startTime = startTime - 0.1;
        });
      } else {
        // if (AdmobMaxTool.adsState != AdsState.showing) {
        reRootPage();
        // }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void reRootPage() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    if (isSetRoot) {
      return;
    }
    isSetRoot = true;
    // AdmobMaxTool.removeListener(hashCode.toString());
    Get.offAll(() => TabPage());
  }

  // void isRequestAdInfo() async {
  //   bool isVip = await AppKey.getBool(AppKey.isVipUser) ?? false;
  //   if (isVip == false) {
  //     requestAds();
  //   }
  //   UserVipTool.instance.restore(appStart: true);
  //   if (UserVipTool.instance.productResultList.value.isEmpty) {
  //     await UserVipTool.instance.queryProductInfo();
  //   }
  // }
  //
  // void requestAds() async {
  //   await AdmobMaxTool.initAdmobOrMax(AdsSceneType.open);
  //   AdmobMaxTool.initAdmobOrMax(AdsSceneType.play);
  //   AdmobMaxTool.initAdmobOrMax(AdsSceneType.middle);
  //   AdmobMaxTool.initAdmobOrMax(AdsSceneType.channel);
  //   bool noStart = await AppKey.getBool(AppKey.onceInstallApp) ?? false;
  //   if (noStart == true) {
  //     if (isSetRoot == false) {
  //       bool success = await AdmobMaxTool.showAdsScreen(AdsSceneType.open);
  //       if (success == false) {
  //         showPlusAds();
  //       }
  //     }
  //   } else {
  //     await AppKey.save(AppKey.onceInstallApp, true);
  //   }
  // }
  //
  // void showPlusAds() async {
  //   bool suc = await AdmobMaxTool.showAdsScreen(AdsSceneType.plus);
  //   if (suc == false) {
  //     reSetRootPage();
  //   }
  // }
  //
  // Future<bool> isPrivacyOptionsRequired() async {
  //   return await ConsentInformation.instance
  //       .getPrivacyOptionsRequirementStatus() ==
  //       PrivacyOptionsRequirementStatus.required;
  // }
  //
  // void googleGMP() async {
  //   bool install = await AppKey.getBool(AppKey.onceInstallApp) ?? false;
  //   bool requ = await isPrivacyOptionsRequired();
  //   if (requ == false) {
  //     // ConsentInformation.instance.reset();
  //     // ConsentDebugSettings debugSettings = ConsentDebugSettings(
  //     //   debugGeography: DebugGeography.debugGeographyEea,
  //     //   testIdentifiers: ["61F857D9-E17F-4327-A20D-80039873F64B"],
  //     // );
  //     //
  //     // ConsentRequestParameters params = ConsentRequestParameters(
  //     //   consentDebugSettings: debugSettings,
  //     // );
  //
  //     final params = ConsentRequestParameters();
  //
  //     // Request an update to consent information on every app launch.
  //     ConsentInformation.instance.requestConsentInfoUpdate(
  //       params,
  //           () async {
  //         ConsentForm.loadAndShowConsentFormIfRequired((
  //             loadAndShowError,
  //             ) async {
  //           if (loadAndShowError != null) {
  //             if (install == false) {
  //               reSetRootPage();
  //             } else {
  //               isRequestAdInfo();
  //             }
  //             await AppKey.save(AppKey.onceInstallApp, true);
  //           } else {
  //             final status = await ConsentInformation.instance
  //                 .getConsentStatus();
  //             final config = RequestConfiguration(
  //               // 对于欧盟用户未同意的情况
  //               tagForUnderAgeOfConsent: status == ConsentStatus.required
  //                   ? TagForUnderAgeOfConsent.yes
  //                   : null,
  //             );
  //             MobileAds.instance.updateRequestConfiguration(config);
  //             if (install == false) {
  //               reSetRootPage();
  //             } else {
  //               isRequestAdInfo();
  //             }
  //             await AppKey.save(AppKey.onceInstallApp, true);
  //           }
  //         });
  //       },
  //           (FormError error) {
  //         print('=--=-=-=-=-=-=-$error.message');
  //         isRequestAdInfo();
  //       },
  //     );
  //   } else {
  //     isRequestAdInfo();
  //   }
  // }
}
