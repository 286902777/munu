import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../generated/assets.dart';
import '../tools/admob_tool.dart';
import '../tools/common_tool.dart';

class AdmobNativePage extends StatefulWidget {
  const AdmobNativePage({super.key, required this.ad, required this.sceneType});
  final NativeAd ad;
  final AdsSceneType sceneType;

  @override
  State<AdmobNativePage> createState() => _AdmobAdmobNativePageState();
}

class _AdmobAdmobNativePageState extends State<AdmobNativePage> {
  var showTime = true.obs;
  var timeValue = AdmobTool.instance.nativeTime.obs;
  var canClick = true.obs;

  Timer? _timer;

  final GlobalKey _closeKey = GlobalKey();
  final GlobalKey _adKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeValue = AdmobTool.instance.middlePlayCloseTime.obs;
    if (widget.sceneType == AdsSceneType.middle) {
      canClick.value =
          Random().nextInt(100) >= AdmobTool.instance.middlePlayCloseClick;
    } else {
      canClick.value = Random().nextInt(100) >= AdmobTool.instance.nativeClick;
    }
    startTime();
    clickNativeAction = () {
      canClick.value = true;
    };
  }

  void _checkClick(Offset globalPos) {
    final ignoreRenderBox =
        _closeKey.currentContext?.findRenderObject() as RenderBox;
    final parentRenderBox =
        _adKey.currentContext?.findRenderObject() as RenderBox;
    final relativePos = parentRenderBox.globalToLocal(globalPos);
    if (ignoreRenderBox.paintBounds.contains(relativePos)) {
      // 触发逻辑
      canClick.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: widget.sceneType == AdsSceneType.middle
            ? Colors.black
            : Color(0xA6000000), // 关键：设置透明背景
        body: Center(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: AspectRatio(
                aspectRatio: 6 / 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.hardEdge,
                  child: GestureDetector(
                    key: _adKey,
                    onTapDown: (details) => _checkClick(details.globalPosition),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AdWidget(ad: widget.ad),
                        Positioned(
                          left: 4,
                          top: 4,
                          child: Obx(
                            () => Visibility(
                              visible: !showTime.value,
                              child: IgnorePointer(
                                ignoring: !canClick.value,
                                child: GestureDetector(
                                  key: _closeKey,
                                  onTap: () {
                                    Get.back(result: true);
                                  },
                                  child: Image.asset(
                                    Assets.iconCloseAlert,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Obx(
                            () => Visibility(
                              visible: showTime.value,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0x80000000),
                                ),
                                child: Text(
                                  '${timeValue.value}',
                                  style: const TextStyle(
                                    letterSpacing: -0.5,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
          ),
        ),
      ),
    );
  }

  void startTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (timeValue.value > 0) {
        timeValue.value--;
      } else {
        showTime.value = false;
        time.cancel();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.ad.dispose();
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }
}
