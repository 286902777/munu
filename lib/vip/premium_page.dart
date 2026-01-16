import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:munu/common/munu_page.dart';
import 'package:munu/tools/event_tool.dart';
import 'package:munu/tools/fire_base_tool.dart';
import 'package:munu/vip/premium_fail_page.dart';
import 'package:munu/vip/premium_tool.dart';

import '../common/web_page.dart';
import '../data/premium_data.dart';
import '../generated/assets.dart';
import '../tools/common_tool.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  PremiumProductData? selectData;

  @override
  void initState() {
    super.initState();
    _loadData();
    premiumDoneBlock = (mod, pay) {
      if (mod.purchaseDetails?.status != PurchaseStatus.canceled &&
          pay == true) {
        if (mod.ok == false) {
          showDialog(context: context, builder: (context) => PremiumFailPage());
        }
      }
    };
    vipType = VipType.page;
    EventTool.instance.eventUpload(EventApi.premiumExpose, {
      EventParaName.type.name: vipType.value, //type
      EventParaName.method.name: vipMethod.value, //method
      EventParaName.source.name: vipSource.value, //source
    });
  }

  void _loadData() async {
    if (PremiumTool.instance.productResultList.value.isEmpty) {
      EasyLoading.show(status: 'loading...');
      await PremiumTool.instance.queryProductInfo();
      EasyLoading.dismiss();
    }
    // List<PremiumProductData> lists = [];
    // PremiumProductData s = PremiumProductData(
    //   productId: 'sd',
    //   title: 'lift',
    //   productInfo: 'productInfo',
    //   price: 29.99,
    //   showPrice: '${'\$'}29.99',
    //   currency: '*',
    //   isSelect: true,
    //   hot: true,
    // );
    // PremiumProductData sx = PremiumProductData(
    //   productId: 'ssd',
    //   title: 'year',
    //   productInfo: 'productInfo',
    //   price: 19.99,
    //   showPrice: '${'\$'}19.99',
    //   currency: '*',
    //   isSelect: false,
    //   hot: false,
    // );
    // PremiumProductData ssx = PremiumProductData(
    //   productId: 'ssd',
    //   title: 'weak',
    //   productInfo: 'productInfo',
    //   price: 2.99,
    //   showPrice: '${'\$'}2.99',
    //   currency: '*',
    //   isSelect: false,
    //   hot: false,
    // );
    // lists.add(s);
    // lists.add(sx);
    // lists.add(ssx);
    //
    // PremiumTool.instance.productResultList.value = lists;
    dynamic fileList = FireBaseTool.userVipFile[FireConfigKey.userVipInfoName];
    if (fileList is List) {
      for (PremiumProductData m
          in PremiumTool.instance.productResultList.value) {
        for (Map<String, dynamic> dic in fileList) {
          if (m.productId == dic[FireConfigKey.userVipProductId]) {
            m.isSelect = dic[FireConfigKey.userVipSelect];
            if (m.isSelect == true) {
              selectData = m;
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MunuPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: addNavbar(),
        body: ValueListenableBuilder(
          valueListenable: PremiumTool.instance.premiumData,
          builder: (BuildContext context, PremiumData vip, Widget? child) {
            return Column(
              children: [
                headWidget(),
                SizedBox(height: 38),
                Expanded(child: _mainView(vip)),
              ],
            );
          },
        ),
        bottomSheet: ValueListenableBuilder(
          valueListenable: PremiumTool.instance.premiumData,
          builder: (BuildContext context, PremiumData vip, Widget? child) {
            if (vip.status == PremiumStatus.none) {
              return _normalBottomView(vip);
            } else {
              return _userBottomView(vip);
            }
          },
        ),
      ),
    );
  }

  AppBar addNavbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.iconBack, width: 24),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            PremiumTool.instance.restore(isClick: true);
          },
          child: Container(
            alignment: Alignment.center,
            width: 48,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(11)),
              color: Color(0xFFFFFFFF),
            ),
            child: Text(
              'Restore',
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF202020),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  Widget headWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Image.asset(Assets.channelPremiumHead, fit: BoxFit.cover),
    );
  }

  Widget _mainView(PremiumData vip) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              bottom: 0,
              child: vip.status == PremiumStatus.none ? _buyView() : _vipView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vipView() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: _cusNameView('Premium benefit'),
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: _subContentView(),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: 0,
                right: 0,
                child: Image.asset(
                  Assets.channelPremiumSuc,
                  fit: BoxFit.cover,
                  // width: Get.width,
                  // height: Get.width * 0.7,
                ),
              ),
              Positioned(
                top: Get.width * 0.4,
                left: 28,
                right: 28,
                child: Center(
                  child: Text(
                    'Congrats! You’ve become a member and are entitled to all the premium perks.',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buyView() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 6),
      child: ValueListenableBuilder(
        valueListenable: PremiumTool.instance.productResultList,
        builder:
            (
              BuildContext context,
              List<PremiumProductData> proList,
              Widget? child,
            ) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cusNameView('Premium benefit'),
                  SizedBox(height: 15),
                  _subContentView(),
                  SizedBox(height: 28),
                  _cusNameView('Premium plan'),
                  Wrap(
                    spacing: 0, // 主轴间距
                    runSpacing: 0, // 换行间距
                    children: List.generate(
                      proList.length,
                      (index) => _productCell(proList[index]),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'The subscription will keep renewing automatically until you decide to cancel, according to the terms and conditions. You have the right to cancel anytime. Just remember to cancel at least 24 hours prior to the renewal to prevent extra charges. Keep in mind that no refunds will be issued if the subscription term has not ended.',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 12,
                      color: Color(0x801A1A1A),
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              );
            },
      ),
    );
  }

  Widget _productCell(PremiumProductData mod) {
    return GestureDetector(
      onTap: () {
        for (PremiumProductData m
            in PremiumTool.instance.productResultList.value) {
          m.isSelect = false;
        }
        mod.isSelect = true;
        selectData = mod;
        if (mounted) {
          setState(() {});
        }
      },
      child: SizedBox(
        height: 80,
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: mod.isSelect ? Color(0xFFF1F6FF) : Color(0xFFF5F8FC),
                  border: Border.all(
                    color: mod.isSelect ? Color(0xFF5597FA) : Color(0xFFE1ECFF),
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 24),
                    Image.asset(
                      mod.isSelect
                          ? Assets.channelPremiumSel
                          : Assets.channelPremiumUnsel,
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          mod.title,
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 10,
                            color: Color(0x801A1A1A),
                          ),
                        ),
                        Text(
                          mod.showPrice,
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF341B03),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (mod.hot)
              Positioned(
                top: 0,
                right: 12,
                child: Image.asset(
                  Assets.channelPremiumHot,
                  width: 70,
                  height: 36,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cusNameView(String name) {
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(Assets.iconTitle, width: 20, height: 20),
          ),
          Positioned(
            left: 26,
            child: Text(
              name,
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subContentView() {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Image.asset(Assets.channelPremiumAd, fit: BoxFit.cover),
              Positioned(
                left: 16,
                child: Text(
                  'Ad - free\n Experience',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 15),
          Stack(
            children: [
              Image.asset(Assets.channelPremiumSpeed, fit: BoxFit.cover),
              Positioned(
                left: 16,
                child: Text(
                  'Speed Up ',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userBottomView(PremiumData vip) {
    String titleInfo = '';
    String titleName = '';
    String time = '';
    if (vip.expiresDate != null && vip.expiresDate! > 0) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(vip.expiresDate!);
      time = DateFormat('yyyy-MM-dd').format(dateTime);
    }
    String price = '';
    if (PremiumTool.instance.productResultList.value.isNotEmpty) {
      for (PremiumProductData m
          in PremiumTool.instance.productResultList.value) {
        if (m.productId == vip.productId) {
          price = m.showPrice;
        }
      }
    }
    if (Platform.isIOS) {
      switch (vip.productId) {
        case 'rme_weekly':
          titleInfo =
              '$price weekly subscription with automatic renewal. Cancel at any time';
          titleName = 'Deadline: $time';
        case 'rme_yearly':
          titleInfo =
              '$price. per year with automatic renewal. You can cancel at any time';
          titleName = 'Deadline: $time';
        default:
          titleInfo = 'Lifetime validity upon purchase, no need for renewal.';
          titleName = 'You have already obtained lifetime membership.';
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 15, 24, 33),
      alignment: Alignment.center,
      // height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            titleInfo,
            style: const TextStyle(
              letterSpacing: -0.5,
              fontSize: 12,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Image.asset(
                    Assets.channelPremiumSuc,
                    width: 260,
                    height: 50,
                  ),
                ),
                Positioned(
                  child: Center(
                    child: Text(
                      titleName,
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   height: 26,
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [
          //         Color(0x0060E7AE),
          //         Color(0xFF60E7AE),
          //         Color(0x0060E7AE),
          //       ], // 中心到边缘颜色
          //       begin: Alignment(-0.5, 0),
          //       end: Alignment(0.5, 0),
          //     ),
          //   ),
          //   child: Text(
          //     titleName,
          //     style: const TextStyle(
          //       letterSpacing: -0.5,
          //       fontSize: 16,
          //       fontWeight: FontWeight.w500,
          //       color: Color(0xFF1A1A1A),
          //     ),
          //   ),
          // ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => (WebPage(name: '', link: 'https://s.com/terms/')),
                  );
                },
                child: Text(
                  '·Terms of service',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xA11A1A1A),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xA11A1A1A),
                    decorationThickness: 1.0,
                  ),
                ),
              ),
              SizedBox(width: 32),
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => (WebPage(name: '', link: 'https://s.com/privacy/')),
                  );
                },
                child: Text(
                  '·Privacy policy',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xA11A1A1A),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xA11A1A1A),
                    decorationThickness: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _normalBottomView(PremiumData vip) {
    String payInfo = '';
    String price = '';
    if (PremiumTool.instance.productResultList.value.isNotEmpty) {
      for (PremiumProductData m
          in PremiumTool.instance.productResultList.value) {
        if (m.productId == selectData?.productId) {
          price = m.showPrice;
        }
      }
    }
    if (Platform.isIOS) {
      switch (selectData?.productId) {
        case 'rme_weekly':
          payInfo =
              '$price weekly subscription with automatic renewal. Cancel at any time';
        case 'rme_yearly':
          payInfo =
              '$price. per year with automatic renewal. You can cancel at any time';
        default:
          payInfo = 'Lifetime validity upon purchase, no need for renewal.';
      }
    }
    return ValueListenableBuilder(
      valueListenable: PremiumTool.instance.productResultList,
      builder:
          (
            BuildContext context,
            List<PremiumProductData> proList,
            Widget? child,
          ) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 15, 24, 33),
              alignment: Alignment.center,
              // height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x08000000),
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    payInfo,
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _openPay();
                    },
                    child: SizedBox(
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Color(0xFF136FF9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: const TextStyle(
                                letterSpacing: -0.5,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                            SizedBox(width: 12),
                            Image.asset(
                              Assets.channelRightArrow,
                              width: 22,
                              height: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => (WebPage(
                              name: '',
                              link: 'https://lensid.com/terms/',
                            )),
                          );
                        },
                        child: Text(
                          '·Terms of service',
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xA11A1A1A),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xA11A1A1A),
                            decorationThickness: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => (WebPage(
                              name: '',
                              link: 'https://lensid.com/privacy/',
                            )),
                          );
                        },
                        child: Text(
                          '·Privacy policy',
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xA11A1A1A),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xA11A1A1A),
                            decorationThickness: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
    );
  }

  void _openPay() async {
    if (selectData == null) {
      return;
    }
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: false,
    );
    await PremiumTool.instance.toGetPay(selectData);
  }
}
