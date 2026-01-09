import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munu/common/munu_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/web_page.dart';
import '../../generated/assets.dart';

class SetPage extends StatefulWidget {
  const SetPage({super.key});

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage>
    with AutomaticKeepAliveClientMixin, RouteAware {
  final List<String> listIconArray = [
    Assets.setPrivacy,
    Assets.setTerms,
    Assets.setFeedback,
  ];

  final List<String> listArray = [
    'Feedback',
    'Terms of Service',
    'Privacy Policy',
  ];
  var appName = ''.obs;
  var version = ''.obs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    pageInfo().then((info) {
      appName.value = info.appName;
      version.value = info.version;
    });
  }

  Future<PackageInfo> pageInfo() async {
    PackageInfo page = await PackageInfo.fromPlatform();
    return page;
  }

  @override
  void didPopNext() {}

  @override
  void didPushNext() {}

  void openEmail() async {
    String email = 'xxxx@outlook.com';
    launchUrl(Uri(scheme: 'mailto', path: email));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MunuPage(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Row(
                children: [
                  Image.asset(Assets.iconTitle, width: 20, height: 20),
                  SizedBox(width: 6),
                  Text(
                    'Setting',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                      color: Color(0xFF17132C),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
              SizedBox(height: 33),
              Column(
                children: [
                  Image.asset(Assets.setLogoSet, width: 80, height: 80),
                  SizedBox(height: 8),
                  Obx(
                    () => Text(
                      'v${version.value}',
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0x8017132C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 32),
                  listWidget(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listWidget() {
    return Wrap(
      spacing: 0, // 主轴间距
      runSpacing: 0, // 换行间距
      direction: Axis.vertical,
      children: List.generate(
        listArray.length,
        (index) => InkWell(
          onTap: () {
            setCellWidget(index);
          },
          child: SizedBox(
            height: 56,
            width: Get.width - 32,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(listIconArray[index], width: 24, height: 24),
                SizedBox(width: 16),
                Text(
                  listArray[index],
                  style: TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF17132C),
                  ),
                ),
                Spacer(),
                Image.asset(Assets.setArrow, width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setCellWidget(int index) {
    switch (index) {
      case 0:
        openEmail();
      // MobileAds.instance.openAdInspector((error) {});
      case 1:
        print("ssss");
        Get.to(() => (WebPage(name: '', link: 'https://s/terms/')));
      default:
        Get.to(() => (WebPage(name: '', link: 'https://s.com/privacy/')));
    }
  }
}
