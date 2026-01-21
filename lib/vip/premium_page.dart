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
    List<PremiumProductData> lists = [];
    PremiumProductData s = PremiumProductData(
      productId: preLife,
      title: 'lift',
      productInfo: 'productInfo',
      price: 29.99,
      showPrice: '${'\$'}29.99',
      currency: '*',
      isSelect: true,
      hot: true,
    );
    PremiumProductData sx = PremiumProductData(
      productId: preYear,
      title: 'year',
      productInfo: 'productInfo',
      price: 19.99,
      showPrice: '${'\$'}19.99',
      currency: '*',
      isSelect: false,
      hot: false,
    );
    PremiumProductData ssx = PremiumProductData(
      productId: preWeek,
      title: 'weak',
      productInfo: 'productInfo',
      price: 2.99,
      showPrice: '${'\$'}2.99',
      currency: '*',
      isSelect: false,
      hot: false,
    );
    lists.add(s);
    lists.add(sx);
    lists.add(ssx);

    PremiumTool.instance.productResultList.value = lists;
    // ^ test
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
                SizedBox(height: 22),
                Expanded(child: mainWidget(vip)),
                vip.status == PremiumStatus.none
                    ? _normalBottomView(vip)
                    : _userBottomView(vip),
              ],
            );
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

  Widget mainWidget(PremiumData vip) {
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
              child: vip.status == PremiumStatus.none
                  ? buyWidget()
                  : premiumWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget premiumWidget() {
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
                left: 0,
                bottom: 0,
                child: Image.asset(
                  Assets.channelPremiumSuc,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 150,
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 68),
                  child: Text(
                    'Congrats! You’re now a member – unlock all premium perks!',
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

  Widget buyWidget() {
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
                    'Your subscription auto-renews unless cancelled, per the Terms. You may cancel anytime. Cancel at least 24 hours prior to renewal to avoid extra fees. No refunds will be issued, even for unused portions of the subscription.',
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
                  color: mod.isSelect ? Color(0xFFFDF2EC) : Color(0xFFF7F7F7),
                  border: Border.all(
                    color: mod.isSelect ? Color(0xFF202020) : Color(0x1F202020),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(40),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mod.showPrice,
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF272727),
                        ),
                      ),
                      Text(
                        ' / ',
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF272727),
                        ),
                      ),
                      Text(
                        mod.title,
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF272727),
                        ),
                      ),
                      Spacer(),
                      Image.asset(
                        mod.isSelect
                            ? Assets.channelPremiumSel
                            : Assets.channelPremiumUnsel,
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (mod.hot)
              Positioned(
                top: 0,
                right: 56,
                child: Image.asset(
                  Assets.channelPremiumHot,
                  width: 68,
                  height: 28,
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
    return SizedBox(
      height: 75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Image.asset(Assets.channelPremiumAd, fit: BoxFit.cover),
              Positioned(
                left: 16,
                top: 20,
                child: Text(
                  'Ad - free\nExperience',
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
          Spacer(),
          Stack(
            children: [
              Image.asset(Assets.channelPremiumSpeed, fit: BoxFit.cover),
              Positioned(
                left: 16,
                top: 30,
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
      if (vip.productId == preLife) {
        titleInfo = 'Lifetime validity upon purchase. No renewal needed.';
        titleName = 'Lifetime membership activated.';
      } else if (vip.productId == preYear) {
        titleInfo = '$price/year auto-renew. Cancel anytime.';
        titleName = 'Deadline: $time';
      } else {
        titleInfo = '$price/week auto-renew. Cancel anytime.';
        titleName = 'Deadline: $time';
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
            height: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 0,
                  left: 76,
                  right: 76,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [Color(0x00FFA46B), Color(0x33FD6B39)], // 颜色数组
                        begin: Alignment.topCenter, // 渐变起点
                        end: Alignment.bottomCenter, // 渐变终点
                      ),
                    ),
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
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => (WebPage(name: '', link: appTerms)));
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
                  Get.to(() => (WebPage(name: '', link: appPrivacy)));
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
      if (selectData?.productId == preLife) {
        payInfo = 'Lifetime validity upon purchase. No renewal needed.';
      } else if (selectData?.productId == preYear) {
        payInfo = '$price/year auto-renew. Cancel anytime.';
      } else {
        payInfo = '$price/week auto-renew. Cancel anytime.';
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
              height: 162,
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
                      height: 48,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Color(0xFF060606),
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 40),
                                  Text(
                                    selectData?.showPrice ?? '',
                                    style: const TextStyle(
                                      letterSpacing: -0.5,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '/',
                                    style: const TextStyle(
                                      letterSpacing: -0.5,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    selectData?.title ?? '',
                                    style: const TextStyle(
                                      letterSpacing: -0.5,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    EasyLoading.show(
                                      status: 'loading...',
                                      maskType: EasyLoadingMaskType.clear,
                                      dismissOnTap: false,
                                    );
                                    await PremiumTool.instance.toGetPay(
                                      selectData,
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 102,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFFA46B),
                                          Color(0xFFFD6B39),
                                        ], // 颜色数组
                                        begin: Alignment.centerLeft, // 渐变起点
                                        end: Alignment.centerRight, // 渐变终点
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Next',
                                          style: const TextStyle(
                                            letterSpacing: -0.5,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                        SizedBox(width: 4),
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
                            ],
                          ),
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
                          Get.to(() => (WebPage(name: '', link: appTerms)));
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
                          Get.to(() => (WebPage(name: '', link: appPrivacy)));
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
