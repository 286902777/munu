import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:munu/page/set/set_page.dart';
import 'package:munu/page/upload/upload_page.dart';
import 'package:munu/tools/event_tool.dart';
import 'package:munu/tools/play_tool.dart';
import 'package:munu/tools/service_tool.dart';

import '../generated/assets.dart';
import '../page/channel/deep_page.dart';
import '../page/home/home_page.dart';
import '../tools/admob_tool.dart';
import '../tools/common_tool.dart';
import 'admob_native_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});
  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage>
    with WidgetsBindingObserver, RouteAware {
  final PageController _tabPageController = PageController();
  int _currentTabIdx = 0;

  @override
  void initState() {
    super.initState();
    listenAppState();
    clickTabItem = (i) {
      _tabPageController.jumpToPage(i);
      setState(() {
        _currentTabIdx = i;
      });
    };

    pushDeepPageInfo = () {
      openDeepPage();
    };

    WidgetsBinding.instance.addObserver(this);
    AdmobTool.addListener(hashCode.toString(), (
      state, {
      adsType,
      ad,
      twoAd,
      sceneType,
    }) async {
      if (state == AdsState.showing && AdmobTool.scene == AdsSceneType.open) {
        ServiceTool.instance.getAdsValue(
          ServiceEventName.advProfit,
          apiPlatform,
          ad,
          '',
          '',
          '',
        );
        if (twoAd != null) {
          ServiceTool.instance.getAdsValue(
            ServiceEventName.advProfit,
            apiPlatform,
            twoAd,
            '',
            '',
            '',
          );
        }
        if (adsType == AdsType.native) {
          Get.to(
            () => AdmobNativePage(
              ad: ad,
              doubleAd: twoAd,
              sceneType: sceneType ?? AdsSceneType.open,
            ),
          )?.then((result) {
            AdmobTool.instance.nativeDismiss(
              AdsState.dismissed,
              adsType: AdsType.native,
              ad: ad,
              doubleAd: twoAd,
              sceneType: sceneType ?? AdsSceneType.open,
            );
          });
        }
      }
      if (state == AdsState.dismissed && AdmobTool.scene == AdsSceneType.open) {
        if (sceneType == AdsSceneType.plus || sceneType == AdsSceneType.three) {
          openDeepPage();
        } else {
          loadPlusAds(adsType ?? AdsType.interstitial);
        }
      }
    });
    Future.delayed(Duration(milliseconds: 500), () {
      openDeepPage();
    });
  }

  void loadPlusAds(AdsType type) async {
    if (type == AdsType.rewarded) {
      bool s = await AdmobTool.showAdsScreen(AdsSceneType.three);
      if (s == false) {
        openDeepPage();
      }
    } else {
      bool s = await AdmobTool.showAdsScreen(AdsSceneType.plus);
      if (s == false) {
        openDeepPage();
      }
    }
  }

  Future<bool> checkClock(String linkId) async {
    // bool openSimDeep = true;
    // bool openSimulatorDeep = true;
    // bool openVpnDeep = true;
    // bool openPadDeep = true;
    //
    // if (linkId.isEmpty) {
    //   return false;
    // }
    // bool simHas = await ClockUtils.isSimCard();
    // if (isSimCard) {
    //   if (simHas) {
    //     openSimDeep = !isSimLimit;
    //   } else {
    //     openSimDeep = isSimLimit;
    //   }
    // }
    //
    // bool simHasulator = await ClockUtils.isEmulator();
    // if (isEmulator) {
    //   if (simHasulator) {
    //     openSimulatorDeep = !isEmulatorLimit;
    //   } else {
    //     openSimulatorDeep = isEmulatorLimit;
    //   }
    // }
    //
    // bool hasPad = ClockUtils.isPad;
    // if (isPad) {
    //   if (hasPad) {
    //     openPadDeep = !isPadLimit;
    //   } else {
    //     openPadDeep = isPadLimit;
    //   }
    // }
    //
    // bool hasVpn = await ClockUtils.isVpn();
    // if (isVpn) {
    //   if (hasVpn) {
    //     openVpnDeep = !isVpnLimit;
    //   } else {
    //     openVpnDeep = isVpnLimit;
    //   }
    // }
    //
    // if (openSimDeep && openSimulatorDeep && openVpnDeep && openPadDeep) {
    //   return true;
    // } else {
    //   return false;
    // }
    return true; // remove
  }

  void openSelectIndex(int index) {
    _tabPageController.jumpToPage(index);
    setState(() {
      _currentTabIdx = index;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    AdmobTool.removeListener(hashCode.toString());
  }

  void listenAppState() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.listen((state) async {
      if (state == AppState.foreground &&
          AdmobTool.adsState != AdsState.showing) {
        eventAdsSource = AdmobSource.hotOpen;
        await AdmobTool.showAdsScreen(AdsSceneType.open);
      }
    });
  }

  void openDeepPage() async {
    if (deepLink.isNotEmpty) {
      bool open = await checkClock(deepLink);
      if (open == false) {
        return;
      }
      Get.offAll(() => TabPage());
      Get.to(() => DeepPage(linkId: deepLink))?.then((_) {
        if (closeDeep == true) {
          vipSource = VipSource.home;
          PlayTool.showPrimunmPage(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: PageView(
          controller: _tabPageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [HomePage(), UploadPage(), SetPage()],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent, // 禁用水波纹颜色
            highlightColor: Colors.transparent,
            dividerColor: Colors.transparent,
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                // 外部阴影
                BoxShadow(
                  color: Color(0x1F000000),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, -3),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            clipBehavior: Clip.antiAlias,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              currentIndex: _currentTabIdx,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.transparent,
              unselectedItemColor: Colors.transparent,
              enableFeedback: false,
              onTap: (index) {
                openSelectIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  label: "0",
                  icon: TabBarItems(Assets.tabHome, '', false),
                  activeIcon: TabBarItems(Assets.tabHomeSel, 'Home', true),
                ),
                BottomNavigationBarItem(
                  label: "1",
                  icon: TabBarItems(Assets.tabUpload, '', false),
                  activeIcon: TabBarItems(Assets.tabUploadSel, 'Add', true),
                ),
                BottomNavigationBarItem(
                  label: "2",
                  icon: TabBarItems(Assets.tabSet, '', false),
                  activeIcon: TabBarItems(Assets.tabSetSel, 'Setting', true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabBarItems extends StatelessWidget {
  final String name;
  final String title;
  final bool isSelected;
  const TabBarItems(this.name, this.title, this.isSelected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: isSelected,
          child: Container(
            width: 24,
            height: 4,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: Color(0xFFFD6B39),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: isSelected ? 80 : 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFD6B39) : Color(0x0DFD6B39),
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(name, width: 24, height: 24),
              Visibility(visible: isSelected, child: SizedBox(width: 4)),
              Visibility(
                visible: isSelected,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
