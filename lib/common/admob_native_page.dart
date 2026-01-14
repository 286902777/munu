import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../generated/assets.dart';
import '../tools/admob_tool.dart';
import '../tools/common_tool.dart';

class AdmobNativePage extends StatefulWidget {
  const AdmobNativePage({
    super.key,
    required this.ad,
    required this.doubleAd,
    required this.sceneType,
  });
  final NativeAd ad;
  final NativeAd? doubleAd;
  final AdsSceneType sceneType;

  @override
  State<AdmobNativePage> createState() => _AdmobNativePageState();
}

class _AdmobNativePageState extends State<AdmobNativePage> {
  var showTime = true.obs;
  var timeValue = AdmobTool.instance.nativeTime.obs;
  var canClick = true.obs;
  var upShow = true.obs;

  Timer? _timer;

  final GlobalKey _closeKey = GlobalKey();
  final GlobalKey _adKey = GlobalKey();
  final GlobalKey _doubleKey = GlobalKey();
  final GlobalKey _closeDoubleKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.doubleAd != null) {
      timeValue = AdmobTool.instance.doubleNativeTime.obs;
      canClick.value =
          Random().nextInt(100) >= AdmobTool.instance.doubleNativeClick;
      upShow.value = Random().nextBool();
    } else {
      canClick.value = Random().nextInt(100) >= AdmobTool.instance.nativeClick;
    }
    if (widget.sceneType == AdsSceneType.middle) {
      timeValue = AdmobTool.instance.middlePlayCloseTime.obs;
      canClick.value =
          Random().nextInt(100) >= AdmobTool.instance.middlePlayCloseClick;
    }
    runTime();
    clickNativeAction = () {
      canClick.value = true;
    };
  }

  void _checkClick(Offset globalPos, bool up) {
    if (up) {
      final ignoreRenderBox =
          _closeKey.currentContext?.findRenderObject() as RenderBox;
      final parentRenderBox =
          _adKey.currentContext?.findRenderObject() as RenderBox;
      final relativePos = parentRenderBox.globalToLocal(globalPos);
      if (ignoreRenderBox.paintBounds.contains(relativePos)) {
        // 触发逻辑
        canClick.value = true;
      }
    } else {
      final ignoreRenderBox =
          _closeDoubleKey.currentContext?.findRenderObject() as RenderBox;
      final parentRenderBox =
          _doubleKey.currentContext?.findRenderObject() as RenderBox;
      final relativePos = parentRenderBox.globalToLocal(globalPos);
      if (ignoreRenderBox.paintBounds.contains(relativePos)) {
        // 触发逻辑
        canClick.value = true;
      }
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
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 6 / 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.hardEdge,
                      child: GestureDetector(
                        key: _adKey,
                        onTapDown: (details) =>
                            _checkClick(details.globalPosition, true),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AdWidget(ad: widget.ad),
                            Positioned(
                              left: 4,
                              top: 4,
                              child: Obx(
                                () => Visibility(
                                  visible: !showTime.value && upShow.value,
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
                              right: 4,
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
                  Visibility(
                    visible: widget.doubleAd != null,
                    child: SizedBox(height: 32),
                  ),
                  Visibility(
                    visible: widget.doubleAd != null,
                    child: AspectRatio(
                      aspectRatio: 6 / 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.hardEdge,
                        child: GestureDetector(
                          key: _doubleKey,
                          onTapDown: (details) =>
                              _checkClick(details.globalPosition, false),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AdWidget(ad: widget.doubleAd!),
                              Positioned(
                                left: 4,
                                top: 4,
                                child: Obx(
                                  () => Visibility(
                                    visible: !showTime.value && !upShow.value,
                                    child: IgnorePointer(
                                      ignoring: !canClick.value,
                                      child: GestureDetector(
                                        key: _closeDoubleKey,
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
                            ],
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
    );
  }

  void runTime() {
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
    widget.doubleAd?.dispose();
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }
}
