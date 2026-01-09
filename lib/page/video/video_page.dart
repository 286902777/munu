import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:munu/page/video/video_full_page.dart';
import 'package:munu/page/video/video_list_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../common/admob_native_page.dart';
import '../../common/db_tool.dart';
import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../keys/app_key.dart';
import '../../tools/admob_tool.dart';
import '../../tools/common_tool.dart';
import '../../tools/event_tool.dart';
import '../../tools/http_tool.dart';
import '../../tools/service_tool.dart';
import '../../tools/toast_tool.dart';

enum DragEvent { left, right, drag }

class VideoPage extends StatefulWidget {
  const VideoPage({super.key, required this.data, this.playList});

  final VideoData data;
  final List<VideoData>? playList;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  var isPlay = false.obs;
  var sliderValue = 0.0.obs;
  var changeTime = Duration(seconds: 0).obs;
  var movedTime = Duration(seconds: 0).obs;

  VideoData? model;

  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  List<VideoData>? lists;

  bool autoClick = false;

  bool isDragging = false;
  var start = Duration(milliseconds: 0).obs;
  var total = Duration(milliseconds: 0).obs;

  bool playEventUpload = false;
  bool playSuccess = false;
  var isLoadShow = false.obs;
  var isEnd = false.obs;
  bool isAutoLoadShow = false;
  bool isCurrentPage = true;
  bool isBackPage = false;

  var videoSpeed = 0.obs;
  var isReport = false.obs;
  var isShowTool = false.obs;
  Timer? speedTimer;

  int currentIdx = 0;
  bool newVideoSuccess = false;
  bool reloadPlay = false;
  Timer? _disTimer;
  Timer? _toolTimer;
  bool isUsePause = false;
  bool speedIsLoad = false;

  void _onHorizontalDragStart(DragStartDetails details) async {}
  void _onHorizontalDragUpdate(DragUpdateDetails details) {}
  void _onHorizontalDragEnd(DragEndDetails details) async {}

  void _appendConfigTimer(DragEvent type) {
    _disTimer?.cancel();
    _disTimer = Timer(Duration(seconds: 2), () {
      switch (type) {
        case DragEvent.left:
          _backEvent.reverse();
        case DragEvent.right:
          _forwardEvent.reverse();
        default:
          _progressPromptEvent.reverse();
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details) async {
    if (details.globalPosition.dx < (Get.width * 0.5)) {
      ///左边触摸
      _gestureStartScreenBrightness.value =
          await ScreenBrightness().application;
      _brightnessEvent.forward();
    } else {
      ///右边触摸
      _gestureStartVolume.value = await VolumeController.instance.getVolume();
      _volumeEvent.forward();
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) async {
    if (details.globalPosition.dx < (Get.width * 0.5)) {
      ///左边触摸调整亮度
      _gestureStartScreenBrightness.value -=
          details.delta.dy / (Get.height * 0.5);
      if (_gestureStartScreenBrightness.value > 1) {
        _gestureStartScreenBrightness.value = 1;
      } else if (_gestureStartScreenBrightness.value < 0) {
        _gestureStartScreenBrightness.value = 0;
      }
      await ScreenBrightness().setApplicationScreenBrightness(
        _gestureStartScreenBrightness.value,
      );
    } else {
      ///右边触摸调整音量
      _gestureStartVolume.value -= details.delta.dy / (Get.height * 0.5);
      if (_gestureStartVolume.value > 1) {
        _gestureStartVolume.value = 1;
      } else if (_gestureStartVolume.value < 0) {
        _gestureStartVolume.value = 0;
      }
      VolumeController.instance.setVolume(_gestureStartVolume.value);
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) async {
    _volumeEvent.reverse();
    _brightnessEvent.reverse();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    WidgetsBinding.instance.addObserver(this);
    VolumeController.instance.showSystemUI = false;
    model = widget.data;
    lists = widget.playList?.where((item) => item.fileType == 0).toList();
    if (lists != null) {
      for (int i = 0; i < lists!.length; i++) {
        if (lists![i] == model) {
          currentIdx = i;
          break;
        }
      }
    }
    _initMovie();
    player.stream.completed.listen((bool completed) async {
      if (completed == true) {
        model?.playTime = 0;
        model?.isHistory = 1;
        int tot = total.value.inSeconds.toInt();
        if (model != null && tot > 1) {
          model?.totalTime = tot;
          DataTool.instance.updateVideoData(model!);
        }
        isPlay.value = false;
        if (model != lists?.last) {
          _goNextEvent(true);
          isEnd.value = false;
        } else {
          isEnd.value = true;
          await player.pause();
        }
      }
    });
    player.stream.playing.listen((bool playing) {
      isPlay.value = playing;
    });

    player.stream.buffering.listen((bool buffer) {
      print(buffer);
      if (speedIsLoad) {
        if (buffer) {
          _disPlaySpeedView();
        } else {
          _removeSpeed();
        }
      }
    });

    player.stream.videoParams.listen((VideoParams para) {
      int w = para.w ?? 0;
      int h = para.h ?? 0;
      if (w > 0 && h > 0) {
        speedIsLoad = true;
        _removeSpeed();
      }
    });
    player.stream.position.listen((Duration position) async {
      if (position.inSeconds == 0) {
        return;
      }
      if (AdmobTool.adsState == AdsState.showing) {
        await player.pause();
      }

      start.value = position;
      if (total.value.inMicroseconds.toDouble() > 0) {
        sliderValue.value =
            start.value.inMilliseconds.toDouble() /
            total.value.inMilliseconds.toDouble();
      } else {
        sliderValue.value = 0;
      }
      if (newVideoSuccess == false) {
        uploadPlayEvent();
        EventTool.instance.eventUpload(EventApi.playStartAll, {
          EventParaName.source.name: playSource.name,
        });
        if (autoClick == false) {
          EventTool.instance.eventUpload(EventApi.playSource, {
            EventParaName.value.name: playSource.name,
          });
        }
        EventTool.instance.eventUpload(EventApi.playSuc, null);
        int plays = await AppKey.getInt(AppKey.commentPlayCount) ?? 0;
        await AppKey.save(AppKey.commentPlayCount, plays + 1);
        int middlePlayCount = await AppKey.getInt(AppKey.middlePlayCount) ?? 0;
        await AppKey.save(AppKey.middlePlayCount, middlePlayCount + 1);
        newVideoSuccess = true;
      }
      if (position.inSeconds.toInt() > total.value.inSeconds.toInt() * 0.3 &&
          total.value.inSeconds.toInt() >= 15) {
        if (isAutoLoadShow == false) {
          _isShowSpeedView(model!);
        }
      }
      if (AdmobTool.instance.playMethod == 1) {
        if (position.inSeconds.toInt() > AdmobTool.instance.middlePlayTime) {
          int middlePlayCount =
              await AppKey.getInt(AppKey.middlePlayCount) ?? 0;
          if (middlePlayCount == AdmobTool.instance.middlePlayIdx) {
            eventAdsSource = AdmobSource.play;
            if (isCurrentPage && AdmobTool.adsState != AdsState.showing) {
              bool suc = await AdmobTool.showAdsScreen(AdsSceneType.middle);
              if (suc) {
                await AppKey.save(AppKey.middlePlayCount, 0);
                await player.pause();
              }
            }
          }
        }
      } else {
        if (position.inSeconds.toInt() > 1 &&
            position.inSeconds.toInt() % AdmobTool.instance.playShowTime == 0) {
          eventAdsSource = AdmobSource.playTen;
          if (isCurrentPage) {
            bool suc = await AdmobTool.showAdsScreen(AdsSceneType.play);
            if (suc) {
              player.pause();
            }
          }
        }
      }
    });
    player.stream.duration.listen((Duration duration) {
      total.value = duration;
    });
    player.stream.error.listen((String error) {
      if (error.contains('Failed to open') == false) {
        return;
      }
      // _removeSpeed();
      EventTool.instance.eventUpload(EventApi.playFail, {
        EventParaName.value.name: error,
      });
      ToastTool.show(message: 'video load failed!', type: ToastType.fail);
      playEventUpload = true;
      _goNextEvent(true);
    });
    eventAdsSource = AdmobSource.play;
    AdmobTool.addListener(hashCode.toString(), (
      state, {
      adsType,
      ad,
      sceneType,
    }) async {
      if (isCurrentPage == false) {
        return;
      }
      if (state == AdsState.showing && AdmobTool.scene == AdsSceneType.middle) {
        if (adsType == AdsType.native) {
          showDialog(
            context: context,
            builder: (context) => AdmobNativePage(
              ad: ad,
              sceneType: sceneType ?? AdsSceneType.middle,
            ),
          ).then((result) async {
            AdmobTool.instance.nativeDismiss(
              AdsState.dismissed,
              adsType: AdsType.native,
              ad: ad,
              sceneType: sceneType ?? AdsSceneType.middle,
            );
          });
        }
      }
      if (state == AdsState.showing && AdmobTool.scene == AdsSceneType.play) {
        String linkId = '';
        String platform = await AppKey.getString(AppKey.appPlatform) ?? '';
        PlatformType currentPlat = PlatformType.india;
        if (model != null) {
          if (model!.platform == 0) {
            currentPlat = PlatformType.india;
          } else {
            currentPlat = PlatformType.east;
          }
          if (platform == currentPlat.name) {
            linkId = model!.linkId;
          }
        }

        ServiceTool.instance.getAdsValue(
          model?.netMovie == 0
              ? ServiceEventName.appAdvProfit
              : ServiceEventName.advProfit,
          model?.platform == 0 ? PlatformType.india : PlatformType.east,
          ad,
          linkId,
          model?.userId ?? '',
          model?.movieId ?? '',
        );
        if (adsType == AdsType.native) {
          showDialog(
            context: context,
            builder: (context) => AdmobNativePage(
              ad: ad,
              sceneType: sceneType ?? AdsSceneType.play,
            ),
          ).then((result) async {
            AdmobTool.instance.nativeDismiss(
              AdsState.dismissed,
              adsType: AdsType.native,
              ad: ad,
              sceneType: sceneType ?? AdsSceneType.play,
            );
          });
        }
      }

      if (state == AdsState.dismissed && AdmobTool.scene == AdsSceneType.play) {
        if (sceneType == AdsSceneType.plus || adsType == AdsType.rewarded) {
          if (isBackPage) {
            Get.back(result: true);
          } else {
            _showAlertVipView();
          }
        } else {
          showPlusAds();
        }
      }
    });
  }

  void showPlusAds() async {
    bool s = await AdmobTool.showAdsScreen(AdsSceneType.plus);
    if (s == false) {
      vipSource = VipSource.ad;
      if (isBackPage) {
        Get.back(result: true);
      } else {
        _showAlertVipView();
      }
    }
  }

  @override
  void dispose() async {
    super.dispose();
    // _removeSpeed();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    isFullScreen = false;
    WakelockPlus.disable();
    await player.dispose();
    _brightnessEvent.dispose();
    _volumeEvent.dispose();
    _backEvent.dispose();
    _forwardEvent.dispose();
    _progressPromptEvent.dispose();
    _disTimer?.cancel();
    speedTimer?.cancel();
    AdmobTool.removeListener(hashCode.toString());
    WidgetsBinding.instance.removeObserver(this);
    VolumeController.instance.showSystemUI = true;
  }

  Future<void> _initMovie() async {
    playSuccess = false;
    newVideoSuccess = false;
    playFileId = model?.movieId ?? '';
    isReport.value = model?.netMovie != 0;
    if (isBackPage) {
      return;
    }
    if (isCurrentPage) {
      await AdmobTool.showAdsScreen(AdsSceneType.play);
    }

    isAutoLoadShow = false;
    if (lists != null) {
      for (VideoData m in lists!) {
        m.isSelect = false;
        if (m.netMovie == 0) {
          if (m.vId != null && m.vId == model?.vId) {
            m.isSelect = true;
          }
        } else {
          if (m.movieId == model?.movieId) {
            m.isSelect = true;
          }
        }
      }
    }
    await player.pause();
    isPlayIndexEnd();

    playEventUpload = false;
    if (model?.netMovie == 0) {
      await _configPlayer();
    } else {
      if (model != null && model!.movieUrl.isNotEmpty) {
        await _configPlayer();
      } else {
        await requestVideoAddress();
      }
    }
  }

  Future<void> _configPlayer() async {
    if (model == null) {
      return;
    }
    reloadPlay = true;
    isAutoLoadShow = false;
    speedIsLoad = false;
    if (isLoadShow.value == false) {
      isLoadShow.value = true;
      _disPlaySpeedView();
    }
    if (model?.netMovie == 0) {
      final dir = await getApplicationDocumentsDirectory();
      if (model!.playTime > 0) {
        player.open(
          Media(
            '${dir.path}/videos/${model?.address}',
            start: Duration(seconds: model!.playTime),
          ),
          play: false,
        );
      } else {
        player.open(Media('${dir.path}/videos/${model?.address}'), play: false);
      }
    } else {
      if (model!.playTime > 0) {
        player.open(
          Media(model!.movieUrl, start: Duration(seconds: model!.playTime)),
          play: false,
        );
      } else {
        player.open(Media(model!.movieUrl), play: false);
      }
    }
    if (AdmobTool.adsState != AdsState.showing) {
      await player.play();
    }
  }

  void uploadPlayEvent() async {
    if (model?.netMovie == 0) {
      ServiceTool.instance.addEvent(
        ServiceEventName.appPlayVideo,
        model?.platform == 0 ? PlatformType.india : PlatformType.east,
        0,
        '',
        '',
        '',
      );
    } else {
      ServiceTool.instance.addEvent(
        ServiceEventName.playVideo,
        model?.platform == 0 ? PlatformType.india : PlatformType.east,
        0,
        model?.linkId ?? '',
        model?.userId ?? '',
        model?.movieId ?? '',
      );
    }
    bool? newUserPlay = await AppKey.getBool(AppKey.appNewUserPlay);
    if (newUserPlay == null || newUserPlay == false) {
      ServiceTool.instance.addEvent(
        ServiceEventName.newUserActiveByPlayVideo,
        model?.platform == 0 ? PlatformType.india : PlatformType.east,
        0,
        model?.linkId ?? '',
        model?.userId ?? '',
        model?.movieId ?? '',
      );
      AppKey.save(AppKey.appNewUserPlay, true);
    }
  }

  Future<void> requestVideoAddress() async {
    await HttpTool.getRequest(
      ApiKey.video,
      model?.platform == 0 ? PlatformType.india : PlatformType.east,
      '/${model?.userId}/${model?.movieId}',
      false,
      para: {},
      successHandle: (data) async {
        if (data is String) {
          final videoAddress = HttpTool.instance.sshToResult(data);
          model?.movieUrl = videoAddress;
          if (model != null) {
            var result = DataTool.instance.items
                .where((item) => item.movieId == model!.movieId)
                .toList();
            if (result.isEmpty) {
              DataTool.instance.insertVideoData(model!);
            } else {
              DataTool.instance.updateVideoData(model!);
            }
          }
          if (model != null && model!.movieUrl.isNotEmpty) {
            await _configPlayer();
          } else {
            _goNextEvent(true);
            ToastTool.show(message: 'request failed!', type: ToastType.fail);
          }
        } else {
          _goNextEvent(true);
          ToastTool.show(message: 'request failed!', type: ToastType.fail);
        }
      },
      failHandle: (refresh, code, msg) async {
        if (refresh) {
          await requestVideoAddress();
        } else {
          _goNextEvent(true);
          ToastTool.show(message: 'request failed!', type: ToastType.fail);
        }
      },
    );
  }

  void savePlayTime() {
    if (model != null) {
      model?.playTime = start.value.inSeconds.toInt();
      int tot = total.value.inSeconds.toInt();
      if (model != null && tot >= 1) {
        model?.totalTime = tot;
        model?.isHistory = 1;
        DataTool.instance.updateVideoData(model!);
      }
    }
  }

  void screenOrientationAction() {
    isFullScreen = !isFullScreen;
    SystemChrome.setPreferredOrientations([
      isFullScreen
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return PopScope(
          canPop: false,
          child: Container(
            width: isFullScreen ? Get.height : Get.width,
            height: isFullScreen ? Get.width : Get.height,
            color: Colors.black,
            child: Stack(
              children: [
                // Center(child: Video(controller: controller, controls: null)), //remove activeStroy
                Center(child: Video(controller: controller)),
                videoWidget(),
                // _appendSpeedWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  void showVideoListWidget() {
    displayTool(true);
    if (isFullScreen) {
      showDialog(
        context: context,
        builder: (context) => VideoFullPage(
          lists: lists ?? [],
          selectItem: (dataList) {
            lists?.assignAll(dataList);
            model = lists?.firstWhere((m) => m.isSelect == true);
            autoClick = false;
            _initMovie();
          },
          dataItem: (dataList) {
            lists?.assignAll(dataList);
            isPlayIndexEnd();
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        // 点击背景是否关闭
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isScrollControlled: true,
        builder: (context) => VideoListPage(
          lists: lists ?? [],
          selectItem: (dataList) {
            savePlayTime();
            lists?.assignAll(dataList);
            model = lists?.firstWhere((m) => m.isSelect == true);
            autoClick = false;
            _initMovie();
          },
          dataItem: (dataList) {
            lists?.assignAll(dataList);
            isPlayIndexEnd();
          },
        ),
      );
    }
  }

  void isPlayIndexEnd() {
    if (lists != null && lists!.last.isSelect == true) {
      isEnd.value = true;
    } else {
      isEnd.value = false;
    }
  }

  void _goNextEvent(bool isAuto) {
    displayTool(true);
    sliderValue.value = 0;
    start.value = Duration(milliseconds: 0);
    autoClick = isAuto;
    eventAdsSource = AdmobSource.playlistNext;
    if (isAuto == false) {
      savePlayTime();
    }

    if (lists != null && lists!.isNotEmpty) {
      for (int i = 0; i < lists!.length; i++) {
        if (lists![i].isSelect) {
          if (i < (lists!.length - 1) &&
              (lists![i + 1].name != 'Recommend' ||
                  lists![i + 1].movieId.isNotEmpty ||
                  lists![i + 1].address.isNotEmpty)) {
            model = lists![i + 1];
            _initMovie();
            break;
          } else {
            if (i < (lists!.length - 2) &&
                (lists![i + 2].name != 'Recommend' ||
                    lists![i + 2].movieId.isNotEmpty ||
                    lists![i + 2].address.isNotEmpty)) {
              model = lists![i + 2];
              _initMovie();
              break;
            }
          }
        }
      }
    }
  }

  // Video_Control
  Widget videoWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () => Container(
                color: isShowTool.value
                    ? Color(0x55000000)
                    : Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    displayTool(false);
                  },
                  onDoubleTapDown: (TapDownDetails details) async {
                    if (newVideoSuccess == true) {
                      return;
                    }
                    final x = details.globalPosition.dx; // 全局X坐标
                    if (x < Get.width / 3) {
                      if ((start.value - Duration(seconds: 10)) >=
                          Duration(seconds: 0)) {
                        fixVideoValue(start.value - Duration(seconds: 10));
                        _forwardEvent.reverse();
                        _backEvent.forward();
                        _appendConfigTimer(DragEvent.left);
                      }
                    } else if (x < Get.width / 3 * 2 && x > Get.width / 3) {
                      await player.playOrPause();
                    } else {
                      if ((start.value + Duration(seconds: 10)) <=
                          total.value) {
                        fixVideoValue(start.value + Duration(seconds: 10));
                        _backEvent.reverse();
                        _forwardEvent.forward();
                        _appendConfigTimer(DragEvent.right);
                      }
                    }
                  },
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  onVerticalDragStart: _onVerticalDragStart,
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                ),
              ),
            ),

            Obx(
              () => Visibility(
                visible: isShowTool.value,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [topFirstWidget(), Spacer(), lastBottomWidget()],
                  ),
                ),
              ),
            ),

            ///几个操作提示器
            addBrightView(),
            addVolumeView(),
            addBackView(),
            addForwardView(),
            showDateInfoView(),
          ],
        );
      },
    );
  }

  Widget topFirstWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Container(
          width: Get.width,
          height: 44,
          padding: EdgeInsets.only(left: 12, top: 14, bottom: 4, right: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                sizeStyle: CupertinoButtonSize.small,
                padding: EdgeInsets.zero,
                child: Image.asset(Assets.playPlayBack, width: 24),
                onPressed: () async {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
                  savePlayTime();
                  eventAdsSource = AdmobSource.playback;
                  isBackPage = true;
                  if (isFullScreen) {
                    screenOrientationAction();
                  } else {
                    Get.back(); // 和下面冲突
                  }
                  bool suc = await AdmobTool.showAdsScreen(AdsSceneType.play);
                  if (suc == false) {
                    Get.back();
                  }
                },
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  model?.name ?? '',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFFFFFFF),
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(width: 8),
              // GestureDetector(
              //   onTap: () {
              //     vipSource = VipSource.VideoPage;
              //     _pushVipPage();
              //   },
              //   child: Image.asset(Assets.svipProNav, width: 54, height: 22),
              // ),
              SizedBox(width: orientation == Orientation.portrait ? 12 : 20),
            ],
          ),
        );
      },
    );
  }

  Widget lastBottomWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      width: Get.width,
      height: 76,
      padding: EdgeInsets.only(left: 12, top: 0, right: 12, bottom: 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => CupertinoButton(
                  padding: EdgeInsets.zero,
                  sizeStyle: CupertinoButtonSize.small,
                  onPressed: isAutoLoadShow ? null : _clickPlayAction,
                  child: Image.asset(
                    isPlay.value ? Assets.playPlay : Assets.playPause,
                    width: 32,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Obx(
                () => CupertinoButton(
                  padding: EdgeInsets.zero,
                  sizeStyle: CupertinoButtonSize.small,
                  onPressed: isEnd.value
                      ? null
                      : () {
                          _goNextEvent(false);
                        },
                  child: Image.asset(
                    isEnd.value ? Assets.playPlayUnNext : Assets.playPlayNext,
                    width: 32,
                  ),
                ),
              ),
              Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                sizeStyle: CupertinoButtonSize.small,
                child: Image.asset(Assets.playPlayList, width: 32),
                onPressed: () {
                  showVideoListWidget();
                },
              ),
              SizedBox(width: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                sizeStyle: CupertinoButtonSize.small,
                child: Image.asset(Assets.playPlayFull, width: 32),
                onPressed: () {
                  displayTool(true);
                  screenOrientationAction();
                },
              ),
            ],
          ),
          SizedBox(height: 19),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  CommonTool.instance.formatHMS(start.value),
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 10),
              _sliderView(),
              SizedBox(height: 10),
              Text(
                total.value.inSeconds.toInt() == 0
                    ? '00:00'
                    : CommonTool.instance.formatHMS(total.value),
                style: const TextStyle(
                  letterSpacing: -0.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                  decoration: TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clickPlayAction() async {
    displayTool(true);
    if (isPlay.value) {
      isUsePause = true;
      await player.pause();
    } else {
      isUsePause = false;
      await player.play();
    }
  }

  Widget _sliderView() {
    return Flexible(
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4, // 设置轨道高度
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 7, // 设置滑块半径
          ),
          thumbColor: Colors.white,
          overlayShape: RoundSliderOverlayShape(
            overlayRadius: 8, // 设置点击时的涟漪效果半径
          ),
        ),
        child: Obx(
          () => Slider(
            activeColor: Color(0xFFFD6B39),
            secondaryActiveColor: Color(0x4DFD6B39),
            thumbColor: Colors.white,
            inactiveColor: Color(0xFFBBBBBB),
            value: sliderValue.value,
            min: 0,
            max: 1,
            onChanged: (value) {
              // sliderValue.value = value;
            },
            onChangeStart: (value) async {
              if (newVideoSuccess == false) {
                return;
              }
              isShowTool.value = true;
              displayTool(true);
              await player.pause();
              isDragging = true;
            },
            onChangeEnd: (value) async {
              if (newVideoSuccess == false) {
                return;
              }
              displayTool(true);
              isDragging = false;
              if (value.isNaN) {
                sliderValue.value = 0.0;
              } else {
                sliderValue.value = value;
              }
              changeTime.value = total.value * value - start.value;
              movedTime.value = total.value * value;
              fixVideoValue(total.value * value);
              _progressPromptEvent.forward();
              _appendConfigTimer(DragEvent.drag);
              if (isLoadShow.value == false) {
                isLoadShow.value = true;
              }
              await player.play();
              // _removeSpeed();
            },
          ),
        ),
      ),
    );
  }

  void fixVideoValue(Duration position) async {
    if (isBackPage || AdmobTool.adsState == AdsState.showing) {
      return;
    }
    if (position.inSeconds >= 0) {
      await player.seek(position);
    }
  }

  Widget addBrightView() {
    return Positioned(
      left: 0,
      right: 0,
      top: isFullScreen ? 110 : 200,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1.0).animate(_brightnessEvent),
        child: IgnorePointer(
          child: Container(
            alignment: Alignment.center,
            child: Container(
              width: 220,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 34),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
                  begin: Alignment.topCenter, // 渐变起点
                  end: Alignment.bottomCenter, // 渐变终点
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(Assets.playBrightness, width: 16),
                  SizedBox(width: 8),
                  Flexible(
                    child: ValueListenableBuilder(
                      valueListenable: _gestureStartScreenBrightness,
                      builder: (_, screenBrightness, __) {
                        return ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          child: LinearProgressIndicator(
                            value: screenBrightness,
                            backgroundColor: Color(0x48FD6B39),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFD6B39),
                            ),
                          ),
                        );
                      },
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

  Widget addVolumeView() {
    return Positioned(
      left: 0,
      right: 0,
      top: isFullScreen ? 110 : 200,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1.0).animate(_volumeEvent),
        child: IgnorePointer(
          child: Container(
            alignment: Alignment.center,
            child: Container(
              width: 220,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 34),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
                  begin: Alignment.topCenter, // 渐变起点
                  end: Alignment.bottomCenter, // 渐变终点
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(Assets.playVoice, width: 16),
                  SizedBox(width: 8),
                  Flexible(
                    child: ValueListenableBuilder(
                      valueListenable: _gestureStartVolume,
                      builder: (_, volume, __) {
                        return ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          child: LinearProgressIndicator(
                            value: volume,
                            backgroundColor: Color(0x48FD6B39),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFD6B39),
                            ),
                          ),
                        );
                      },
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

  Widget addBackView() {
    return Positioned(
      left: 0,
      right: 0,
      top: isFullScreen ? 110 : 200,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1.0).animate(_backEvent),
        child: IgnorePointer(
          child: Container(
            alignment: Alignment.center,
            child: Container(
              width: 220,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
                  begin: Alignment.topCenter, // 渐变起点
                  end: Alignment.bottomCenter, // 渐变终点
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(Assets.playForward, width: 16),
                  const SizedBox(width: 14),
                  const Flexible(
                    child: Text(
                      'Rewind 10s',
                      style: TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF141414),
                        decoration: TextDecoration.none,
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

  Widget addForwardView() {
    return Positioned(
      left: 0,
      right: 0,
      top: isFullScreen ? 110 : 200,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1.0).animate(_forwardEvent),
        child: IgnorePointer(
          child: Container(
            alignment: Alignment.center,
            child: Container(
              width: 220,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
                  begin: Alignment.topCenter, // 渐变起点
                  end: Alignment.bottomCenter, // 渐变终点
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(Assets.playRewind, width: 16),
                  const SizedBox(width: 14),
                  const Flexible(
                    child: Text(
                      'Forward 10s',
                      style: TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF141414),
                        decoration: TextDecoration.none,
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

  Widget showDateInfoView() {
    return Positioned(
      left: 0,
      right: 0,
      top: isFullScreen ? 110 : 200,
      child: Center(
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1.0,
          ).animate(_progressPromptEvent),
          child: IgnorePointer(
            child: Container(
              width: 220,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
                  begin: Alignment.topCenter, // 渐变起点
                  end: Alignment.bottomCenter, // 渐变终点
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      CommonTool.instance.formatHMS(movedTime.value),
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        color: Color(0xFF141414),
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      changeTime.value.inSeconds > 0
                          ? '[+${CommonTool.instance.formatHMS(changeTime.value)}]'
                          : '[-${CommonTool.instance.formatHMS(durationAbs(changeTime.value))}]',
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        color: Color(0xFF141414),
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Duration durationAbs(Duration duration) {
    return duration.isNegative ? -duration : duration;
  }

  // Widget _appendSpeedWidget() {
  //   return Obx(
  //     () => Visibility(
  //       visible: isLoadShow.value,
  //       child: Center(
  //         child: ValueListenableBuilder(
  //           valueListenable: UserVipTool.instance.vipData,
  //           builder: (BuildContext context, VipData vip, Widget? child) {
  //             return Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 SizedBox(
  //                   width: 24,
  //                   height: 24,
  //                   child: CircularProgressIndicator(
  //                     color: Colors.white,
  //                     strokeWidth: 2,
  //                   ),
  //                 ),
  //                 SizedBox(height: 24),
  //                 if (vip.status == VipStatus.none)
  //                   Obx(
  //                     () => Text(
  //                       'Current line congestion… ${videoSpeed.value}kb/s',
  //                       style: const TextStyle(
  //                         letterSpacing: -0.5,
  //                         fontSize: 14,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                 if (vip.status == VipStatus.none) SizedBox(height: 12),
  //                 vip.status == VipStatus.none
  //                     ? _userSpeedView()
  //                     : _vipSpeedView(),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _userSpeedView() {
  //   return SizedBox(
  //     width: 262,
  //     height: 38,
  //     child: GestureDetector(
  //       onTap: () {
  //         vipSource = VipSource.accelerate;
  //         _pushVipPage();
  //       },
  //       child: Container(
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           color: Color(0xFFD4E4FF),
  //         ),
  //         child: Stack(
  //           children: [
  //             Positioned(
  //               top: 3,
  //               left: 23,
  //               child: Image.asset(Assets.svipSvipSpeed, width: 32, height: 32),
  //             ),
  //             Positioned(
  //               top: 10,
  //               left: 63,
  //               child: Text(
  //                 'Exclusive acceleration line',
  //                 style: const TextStyle(
  //                   letterSpacing: -0.5,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                   color: Color(0xFF1B1B1B),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _vipSpeedView() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFD4E4FF),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Text(
          'Loading extremely fast…',
          style: const TextStyle(
            letterSpacing: -0.5,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF202020),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _disPlaySpeedView() {
    if (model != null && model!.netMovie == 1) {
      if (isLoadShow.value == true) {
        speedTimer = Timer.periodic(const Duration(seconds: 2), (_) {
          videoSpeed.value = Random().nextInt(80);
        });
      }

      if (isAutoLoadShow) {
        Future.delayed(Duration(seconds: 6), () async {
          isAutoLoadShow = false;
          isLoadShow.value = false;
          speedTimer?.cancel();
          if (isCurrentPage) {
            if (isPlay.value == false) {
              await player.play();
            }
          }
        });
      }
    }
  }

  void _removeSpeed() async {
    if (isLoadShow.value) {
      isAutoLoadShow = false;
      isLoadShow.value = false;
      speedTimer?.cancel();
      if (isCurrentPage) {
        await player.play();
      }
    }
  }

  void _pushVipPage() async {
    vipMethod = VipMethod.click;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await player.pause();
    isCurrentPage = false;
    // Get.to(() => UserVipPage())?.then((_) async {
    //   isCurrentPage = true;
    // });
  }

  void _showAlertVipView() async {
    bool isSVip = await AppKey.getBool(AppKey.isVipUser) ?? false;
    if (isSVip) {
      return;
    }
    int? vipPlayCount = await AppKey.getInt(AppKey.vipPlayCount);
    if ((vipPlayCount ?? 0) < 1) {
      await AppKey.save(AppKey.vipPlayCount, 1);
      return;
    }
    int? showCount = await AppKey.getInt(AppKey.vipAlertShowCount);
    if ((showCount ?? 0) >= 3) {
      return;
    }
    bool day = await isShowedVipAlert();
    if (day) {
      return;
    }

    await AppKey.save(AppKey.vipPlayCount, vipPlayCount ?? 0 + 1);
    await AppKey.save(
      AppKey.vipAlertPlayTime,
      DateTime.now().millisecondsSinceEpoch.toInt(),
    );
    await AppKey.save(AppKey.vipAlertShowCount, (showCount ?? 0) + 1);
    isCurrentPage = false;
    vipSource = VipSource.ad;
    vipMethod = VipMethod.auto;
    vipType = VipType.popup;
    EventTool.instance.eventUpload(EventApi.premiumExpose, {
      EventParaName.type.name: vipType.value, //type
      EventParaName.method.name: vipMethod.value, //method
      EventParaName.source.name: vipSource.value,
    });
    if (isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      isFullScreen = false;
    }
    // Future.delayed(Duration(milliseconds: 500), () {
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertUserVipPage(),
    //   ).then((_) async {
    //     isCurrentPage = true;
    //   });
    // });
  }

  void _isShowSpeedView(VideoData model) async {
    // if (UserVipTool.instance.vipData.value.status == VipStatus.vip) {
    //   return;
    // }
    if (model.netMovie == 0) {
      return;
    }
    Map<String, dynamic>? showDict;
    bool isToDay = await isSameDay();
    if (isToDay == false) {
      await AppKey.save(
        AppKey.toDay,
        DateTime.now().millisecondsSinceEpoch.toInt(),
      );
      await AppKey.save(AppKey.showSpeedVideo, {
        '$model.movieId': '$model.movieUrl',
      });
      await AppKey.save(AppKey.showNum, 0);
      showSpeed();
    } else {
      int? showNum = await AppKey.getInt(AppKey.showNum);
      if ((showNum ?? 0) >= 5) {
        return;
      }

      showDict = await AppKey.getMap(AppKey.showSpeedVideo);
      if (showDict != null) {
        for (String key in showDict.keys) {
          if (key == model.movieId) {
            return;
          }
        }
      }
      int? showRate = await AppKey.getInt(AppKey.showRate);
      if ((showRate ?? 0) < 3) {
        await AppKey.save(AppKey.showRate, (showRate ?? 0) + 1);
      } else {
        await AppKey.save(AppKey.showRate, 0);
        return;
      }
      await AppKey.save(AppKey.showNum, (showNum ?? 0) + 1);
      showDict?[model.movieId] = model.movieUrl;
      await AppKey.save(AppKey.showSpeedVideo, showDict);
      showSpeed();
    }
  }

  void showSpeed() async {
    isAutoLoadShow = true;
    isLoadShow.value = true;
    await player.pause();
    _disPlaySpeedView();
  }

  Future<bool> isSameDay() async {
    int? time = await AppKey.getInt(AppKey.toDay);
    if (time != null && time > 0) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
      final oneDay = Duration(days: 1);
      return (DateTime.now().difference(date).abs() < oneDay);
    } else {
      return false;
    }
  }

  Future<bool> isShowedVipAlert() async {
    int? time = await AppKey.getInt(AppKey.vipAlertPlayTime);
    if (time != null && time > 0) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
      final day = Duration(days: 1);
      return (DateTime.now().difference(date).abs() < day);
    } else {
      int? aTime = await AppKey.getInt(AppKey.vipAlertTime);
      if (aTime != null && aTime > 0) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(aTime);
        final hours = Duration(hours: 1);
        if (DateTime.now().difference(date).abs() <= hours) {
          return true;
        }
      }
      return false;
    }
  }

  /// 倒退10s提示器动画
  late final AnimationController _backEvent = AnimationController(
    duration: const Duration(seconds: 0),
    reverseDuration: const Duration(milliseconds: 500),
    vsync: this,
  );

  /// 前进10s提示器动画
  late final AnimationController _forwardEvent = AnimationController(
    duration: const Duration(seconds: 0),
    reverseDuration: const Duration(milliseconds: 500),
    vsync: this,
  );

  late final AnimationController _progressPromptEvent = AnimationController(
    duration: const Duration(seconds: 0),
    reverseDuration: const Duration(milliseconds: 500),
    vsync: this,
  );

  //记录屏幕亮度
  final ValueNotifier<double> _gestureStartScreenBrightness = ValueNotifier(0);

  //记录系统音量
  final ValueNotifier<double> _gestureStartVolume = ValueNotifier(0);

  /// 亮度提示器动画
  late final AnimationController _brightnessEvent = AnimationController(
    duration: const Duration(seconds: 0),
    reverseDuration: const Duration(milliseconds: 500),
    vsync: this,
  );

  /// 音量提示器动画
  late final AnimationController _volumeEvent = AnimationController(
    duration: const Duration(seconds: 0),
    reverseDuration: const Duration(milliseconds: 500),
    vsync: this,
  );

  void displayTool(bool forever) {
    if (forever == false) {
      isShowTool.value = !isShowTool.value;
    }
    if (isShowTool.value) {
      _toolTimer?.cancel();
      _toolTimer = Timer(Duration(seconds: 5), () {
        isShowTool.value = false;
      });
    }
  }
}
