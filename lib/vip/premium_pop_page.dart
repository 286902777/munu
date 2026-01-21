import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:munu/vip/premium_fail_page.dart';
import 'package:munu/vip/premium_tool.dart';
import '../common/web_page.dart';
import '../data/premium_data.dart';
import '../generated/assets.dart';
import '../tools/common_tool.dart';
import '../tools/fire_base_tool.dart';

class PremiumPopPage extends StatefulWidget {
  const PremiumPopPage({super.key});

  @override
  State<PremiumPopPage> createState() => _PremiumPopPageState();
}

class _PremiumPopPageState extends State<PremiumPopPage> {
  List<PremiumProductData> lists = [];
  PremiumProductData? selectData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();
    premiumDoneBlock = (mod, pay) {
      if (mod.purchaseDetails?.status != PurchaseStatus.canceled &&
          pay == true) {
        if (mod.ok == false) {
          showDialog(context: context, builder: (context) => PremiumFailPage());
        } else {
          Get.back();
        }
      }
    };
  }

  void addData() async {
    if (PremiumTool.instance.productResultList.value.isEmpty) {
      await PremiumTool.instance.queryProductInfo();
    }

    PremiumProductData sx = PremiumProductData(
      productId: preYear,
      title: 'year',
      productInfo: 'productInfo',
      price: 19.99,
      showPrice: '${'\$'}19.99',
      currency: '*',
      isSelect: true,
      hot: true,
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
    lists.add(sx);
    lists.add(ssx);
    // ^ test
    for (PremiumProductData m in PremiumTool.instance.productResultList.value) {
      if (m.productId != PremiumIdKey.year.value) {
        lists.add(m);
      }
    }

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xA6000000),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _contentV(),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Image.asset(Assets.iconCloseAlert, width: 24, height: 24),
          ),
        ],
      ),
    );
  }

  Widget _contentV() {
    return ValueListenableBuilder(
      valueListenable: PremiumTool.instance.premiumData,
      builder: (BuildContext context, PremiumData vip, Widget? child) {
        return Container(
          width: 300,
          height: 320,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('image/channel/premium_pop.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 84, 0, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    if (lists.isNotEmpty) _listCell(lists.first),
                    if (lists.length >= 2) _listCell(lists.last),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21),
                          color: Color(0xFF060606),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Positioned(
                              left: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
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
                                  height: 40,
                                  width: 102,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(21),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => (WebPage(name: '', link: appTerms)));
                          },
                          child: Text(
                            'Terms of service',
                            style: const TextStyle(
                              letterSpacing: -0.5,
                              fontSize: 10,
                              color: Color(0xBF1A1A1A),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xBF1A1A1A),
                              decorationThickness: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => (WebPage(name: '', link: appPrivacy)));
                          },
                          child: Text(
                            'Privacy policy',
                            style: const TextStyle(
                              letterSpacing: -0.5,
                              fontSize: 10,
                              color: Color(0xBF1A1A1A),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xBF1A1A1A),
                              decorationThickness: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  //       ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _listCell(PremiumProductData mod) {
    return GestureDetector(
      onTap: () {
        for (PremiumProductData m in lists) {
          m.isSelect = false;
        }
        mod.isSelect = true;
        selectData = mod;
        if (mounted) {
          setState(() {});
        }
      },
      child: SizedBox(
        height: 69,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: mod.isSelect ? Color(0xFFFDF2EC) : Color(0xFFF7F7F7),
                  border: Border.all(
                    color: mod.isSelect ? Color(0xFF202020) : Color(0xFFDCDCDC),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(36),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
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
                top: 2,
                left: 0,
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
}
