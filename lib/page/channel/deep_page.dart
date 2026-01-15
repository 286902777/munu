import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/common/munu_page.dart';
import 'package:munu/data/user_pool_data.dart';
import 'package:munu/page/home/photo_page.dart';
import 'package:munu/tools/event_tool.dart';
import 'package:munu/tools/http_tool.dart';
import 'package:munu/tools/play_tool.dart';
import 'package:munu/tools/refresh_tool.dart';
import 'package:munu/tools/service_tool.dart';
import 'package:munu/tools/toast_tool.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/index_data.dart';
import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../keys/app_key.dart';
import '../../tools/common_tool.dart';
import '../home/file_list_page.dart';
import '../home/home_cell.dart';
import 'channel_page.dart';

class DeepPage extends StatefulWidget {
  const DeepPage({super.key, required this.linkId});
  final String linkId;

  @override
  State<DeepPage> createState() => _DeepPageState();
}

class _DeepPageState extends State<DeepPage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();
  final _onOffSet = ValueNotifier<double>(0);

  User? user;
  String userId = '';
  int page = 1;
  int randomPage = 1;
  int pageSize = 20;
  String? randomUserId;

  List<VideoData> allArray = [];
  List<VideoData> hotArray = [];
  List<VideoData> newArray = [];

  var userInfoChange = false.obs;
  var headerChange = false.obs;
  var selectIndex = 0.obs;
  var allChange = false.obs;
  var otherChange = false.obs;

  bool startRequest = true;
  bool loadRecommend = false;
  final PageController _controller = PageController();
  bool noMoreData = false;

  final List<StationState> lists = [
    StationState.video,
    StationState.hot,
    StationState.recently,
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deepLink = '';
    closeDeep = false;
    _scrollController.addListener(() {
      double offset = _scrollController.offset / 64;
      _onOffSet.value = offset;
    });

    eventSource = ServiceEventSource.landPage;
    ServiceTool.instance.addEvent(
      ServiceEventName.viewApp,
      apiPlatform,
      0,
      widget.linkId,
      '',
      '',
    );
    uploadServiceUserInfo();

    if (startRequest) {
      loadNetData();
      startRequest = false;
    }
  }

  Future<void> uploadServiceUserInfo() async {
    bool? newUser = await AppKey.getBool(AppKey.appDeepNewUser);
    if (newUser == null || newUser == false) {
      ServiceTool.instance.addEvent(
        ServiceEventName.downApp,
        apiPlatform,
        0,
        widget.linkId,
        '',
        '',
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    appLinkId = '';
    _refreshController.dispose();
    _scrollController.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  Future loadNetData() async {
    if (loadRecommend) {
      // loadRecommendInfo();
    } else {
      if (noMoreData) {
        _refreshController.loadNoData();
        return;
      }
      await HttpTool.postRequest(
        ApiKey.home,
        apiPlatform,
        para: {
          'jills': page,
          'koan': pageSize,
          'dicarbonic': '',
          'zimme': {'underrule': widget.linkId},
          'matagalpan': 'v2',
        },
        successHandle: (data) async {
          if (data != null) {
            HomeData model = homeDataFromJson(data);
            if (model.user != null && model.user!.id.isNotEmpty && page == 1) {
              userId = model.user?.id ?? '';
              user = model.user;
              userInfoChange.value = true;
              String sss = jsonEncode(model.user!.toJson());
              DbTool.instance.updateUser(
                userId,
                apiPlatform == PlatformType.india ? 0 : 1,
                sss,
              );
              await AppKey.save(AppKey.appUserId, userId);
              await AppKey.save(AppKey.email, model.user?.email);
              bool openDeepInstall =
                  await AppKey.getBool(AppKey.openDeepInstall) ?? false;
              if (openDeepInstall == false) {
                EventTool.instance.install(true);
                AppKey.save(AppKey.openDeepInstall, true);
              }
            }
            // if (model.files.length < pageSize) {
            //   if (model.files.length < 5 && page == 1) {
            //     randomUserId = user?.id;
            //     loadRecommend = true;
            //     loadRecommendInfo();
            //   } else {
            //     await loadUserListInfo(userId);
            //   }
            // }
            if (model.files.isNotEmpty) {
              replaceData(model);
              page = page + 1;
            } else {
              _refreshController.loadNoData();
              noMoreData = true;
            }
          }
          bool isFirst = await AppKey.getBool(AppKey.isFirstLink) ?? false;
          EventTool.instance.eventUpload(EventApi.landPageExpose, {
            EventParaName.value.name: apiPlatform == PlatformType.india
                ? EventParaValue.cash.value
                : EventParaValue.quick.value,
            EventParaName.linkSource.name: isDeepLink
                ? EventParaValue.delayLink.value
                : EventParaValue.link.value,
            EventParaName.isFirstLink.name: !isFirst,
          });
          _refreshController.loadComplete();
        },
        failHandle: (refresh, code, msg) {
          if (refresh) {
            loadNetData();
          } else {
            EventTool.instance.eventUpload(EventApi.landPageFail, {
              EventParaName.value.name: 'request fail',
            });
            _refreshController.loadFailed();
            ToastTool.show(message: msg, type: ToastType.fail);
          }
        },
      );
    }
  }

  void replaceData(HomeData model) {
    for (HomeListData item in model.files) {
      VideoData videoM = VideoData(
        name: item.disPlayName.saponary,
        linkId: widget.linkId,
        movieId: item.id,
        size: CommonTool.instance.countFile(item.fileMeta.size),
        ext: item.fileMeta.extension,
        netMovie: 1,
        createDate: item.updateTime,
        thumbnail: item.fileMeta.thumbnail,
        fileType: item.fileMeta.type == 'FILE' ? (item.video ? 0 : 1) : 2,
        fileCount: item.vidQty,
        userId: userId,
        platform: apiPlatform == PlatformType.india ? 0 : 1,
      );
      allArray.add(videoM);
    }
    allChange.value = true;
    if (mounted) {
      setState(() {});
    }

    if (page == 1) {
      for (HomeListData item in model.top) {
        VideoData videoM = VideoData(
          name: item.disPlayName.saponary,
          linkId: widget.linkId,
          movieId: item.id,
          size: CommonTool.instance.countFile(item.fileMeta.size),
          ext: item.fileMeta.extension,
          netMovie: 1,
          createDate: item.updateTime,
          thumbnail: item.fileMeta.thumbnail,
          fileType: item.fileMeta.type == 'FILE' ? (item.video ? 0 : 1) : 2,
          fileCount: item.vidQty,
          userId: userId,
          platform: apiPlatform == PlatformType.india ? 0 : 1,
        );
        hotArray.add(videoM);
      }
      for (HomeListData item in model.recent) {
        VideoData videoM = VideoData(
          name: item.disPlayName.saponary,
          linkId: widget.linkId,
          movieId: item.id,
          size: CommonTool.instance.countFile(item.fileMeta.size),
          ext: item.fileMeta.extension,
          netMovie: 1,
          createDate: item.updateTime,
          thumbnail: item.fileMeta.thumbnail,
          fileType: item.fileMeta.type == 'FILE' ? (item.video ? 0 : 1) : 2,
          fileCount: item.vidQty,
          userId: userId,
          platform: apiPlatform == PlatformType.india ? 0 : 1,
        );
        newArray.add(videoM);
      }
      otherChange.value = true;
    }
  }

  Future<void> loadUserListInfo(String uId) async {
    await DbTool.instance.getPlatformUser(
      apiPlatform == PlatformType.india ? 0 : 1,
    );
    List<UserPoolData> users = DataTool.instance.users;
    List<Map<String, dynamic>> labelArr = [];
    users.forEach((mod) {
      mod.labels.forEach((label) {
        Map<String, dynamic> dic = {
          'catalyse': label.id,
          '_78tqbkenx': label.labelName,
          'leguleian': label.firstLabelCode,
          'stigmata': label.secondLabelCode,
        };
        labelArr.add(dic);
      });
    });
    await HttpTool.postRequest(
      ApiKey.userPools,
      apiPlatform,
      para: {
        'overmantel': {'gunneries': labelArr},
        'neumatic': Platform.isIOS ? 'ios' : 'android',
        'abongo': uId,
      },
      successHandle: (data) {
        if (data != null && data is List) {
          Random random = Random();
          int randomIdx = random.nextInt(data.length);
          List<dynamic> result = data;
          result.removeWhere((m) => m['abongo'] == userId);
          if (randomIdx < result.length) {
            randomUserId = result[randomIdx]['abongo'];
          } else {
            randomUserId = result.first['abongo'];
          }
          loadRecommend = true;
          loadRecommendInfo();
        }
      },
      failHandle: (refresh, code, msg) {
        if (refresh) {
          loadUserListInfo(uId);
        }
      },
    );
  }

  Future loadRecommendInfo() async {
    await HttpTool.recommendPostRequest(
      ApiKey.home,
      apiPlatform,
      randomPage > 1,
      para: {
        'jills': randomPage,
        'koan': pageSize,
        'dicarbonic': randomUserId,
        'zimme': {'underrule': ''},
        'matagalpan': 'v2',
      },
      successHandle: (data) {
        EasyLoading.dismiss();
        if (data != null) {
          HomeData model = homeDataFromJson(data);
          if (model.files.isNotEmpty) {
            if (randomPage == 1) {
              allArray.add(VideoData(name: 'Recommend'));
            }
            for (HomeListData item in model.files) {
              VideoData videoM = VideoData(
                name: item.disPlayName.saponary,
                movieId: item.id,
                size: CommonTool.instance.countFile(item.fileMeta.size),
                ext: item.fileMeta.extension,
                netMovie: 1,
                createDate: item.updateTime,
                thumbnail: item.fileMeta.thumbnail,
                recommend: 1,
                fileType: item.directory ? 2 : (item.video ? 0 : 1),
                fileCount: item.vidQty,
                userId: randomUserId ?? '',
                platform: apiPlatform == PlatformType.india ? 0 : 1,
              );
              allArray.add(videoM);
              allChange.value = true;
              if (mounted) {
                setState(() {});
              }
            }
            randomPage = randomPage + 1;
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
            noMoreData = true;
          }
        }
      },
      failHandle: (refresh, code, msg) {
        if (refresh) {
          loadRecommendInfo();
        } else {
          _refreshController.loadFailed();
          ToastTool.show(message: msg, type: ToastType.fail);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MunuPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: cusNavbar(),
        body: Obx(
          () => Visibility(
            visible: allChange.value,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 80.0,
                    pinned: false,
                    floating: false,
                    backgroundColor: Colors.transparent,
                    leading: SizedBox(),
                    flexibleSpace: FlexibleSpaceBar(
                      title: headWidget(),
                      expandedTitleScale: 1,
                      titlePadding: EdgeInsetsDirectional.zero,
                    ),
                  ),
                ];
              },
              body: ContentWidget(),
            ),
          ),
        ),
      ),
    );
  }

  AppBar cusNavbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          CupertinoButton(
            onPressed: () {
              isDeepComment = true;
              closeDeep = true;
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.iconBack, width: 24),
          ),
        ],
      ),
      title: ValueListenableBuilder(
        valueListenable: _onOffSet,
        builder: (BuildContext context, offSet, Widget? child) {
          double rate = offSet;
          if (rate > 1) {
            rate = 1;
          }
          return Opacity(
            opacity: rate < 0.5 ? 0 : rate,
            child: GestureDetector(
              onTap: () {
                if (userId.isNotEmpty) {
                  channelSource = ChannelSource.landpage_avtor;
                  Get.to(
                    () => ChannelPage(userId: userId, platform: apiPlatform),
                  );
                }
              },
              child: Container(
                color: Colors.transparent,
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: userInfoChange.value
                              ? user?.picture ?? ''
                              : '',
                          fit: BoxFit.cover,
                          width: 24,
                          height: 24,
                          placeholder: (context, url) => Image.asset(
                            Assets.channelAvatar,
                            width: 24,
                            height: 24,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            Assets.channelAvatar,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          userInfoChange.value ? user?.name ?? '' : '',
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 16,
                            color: Color(0xFF03011A),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(Assets.channelUp, width: 16, height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      // actions: [
      //   SizedBox(width: 10),
      //   GestureDetector(
      //     onTap: () {
      //       vipMethod = VipMethod.click;
      //       vipSource = VipSource.landPage;
      //       Get.to(() => UserVipPage());
      //     },
      //     child: Image.asset(Assets.svipProNav, width: 54, height: 22),
      //   ),
      //   SizedBox(width: 12),
      // ],
    );
  }

  Widget headWidget() {
    return ValueListenableBuilder(
      valueListenable: _onOffSet,
      builder: (BuildContext context, offSet, Widget? child) {
        double rate = offSet;
        if (rate > 1) {
          rate = 1;
        }
        return Opacity(
          opacity: 1 - rate,
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(
              16 + 128 * rate,
              8,
              16 + 128 * rate,
              24,
            ),
            color: Colors.transparent,
            alignment: Alignment.centerLeft,
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  if (userId.isNotEmpty) {
                    channelSource = ChannelSource.landpage_avtor;
                    Get.to(
                      () => ChannelPage(userId: userId, platform: apiPlatform),
                    );
                  }
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(24 - 12 * rate),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: userInfoChange.value
                            ? user?.picture ?? ''
                            : '',
                        fit: BoxFit.cover,
                        width: 48 - 24 * rate,
                        height: 48 - 24 * rate,
                        placeholder: (context, url) => Image.asset(
                          Assets.iconAvatar,
                          width: 48 - 24 * rate,
                          height: 48 - 24 * rate,
                        ),

                        errorWidget: (context, url, error) => Image.asset(
                          Assets.iconAvatar,
                          width: 48 - 24 * rate,
                          height: 48 - 24 * rate,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        userInfoChange.value ? user?.name ?? '' : '',
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontSize: 18,
                          color: Color(0xFF03011A),
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 4),
                    Image.asset(Assets.iconMore, width: 16, height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget ContentWidget() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            color: Colors.white,
          ),
          alignment: Alignment.centerLeft,
          height: 70,
          padding: EdgeInsets.all(18),
          child: Obx(
            () => Wrap(
              direction: Axis.horizontal,
              spacing: 24,
              children: List.generate(
                lists.length,
                (index) => GestureDetector(
                  onTap: () {
                    selectIndex.value = lists[index].idx;
                    _controller.jumpToPage(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      color: selectIndex.value == index
                          ? Color(0xFFFD6B39)
                          : Colors.transparent,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      lists[index].value,
                      style: TextStyle(
                        letterSpacing: -0.5,
                        fontSize: selectIndex.value == index ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        color: selectIndex.value == index
                            ? Color(0xFFFFFFFF)
                            : Color(0xFF4C4C4C),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  allContentWidget(),
                  hotContentWidget(),
                  newContentWidget(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget allContentWidget() {
    return RefreshConfiguration(
      hideFooterWhenNotFull: true,
      child: RefreshTool(
        controller: _refreshController,
        itemNum: 1,
        onLoading: loadNetData,
        child: ListView.builder(
          itemCount: allArray.length,
          itemBuilder: (context, index) {
            if (allArray[index].name == 'Recommend' &&
                allArray[index].movieId.isEmpty) {
              return _recommendTitleView();
            } else {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  playSource = PlaySource.landpage_file;
                  pushPage(allArray[index], allArray);
                },
                child: HomeCell(model: allArray[index]),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _recommendTitleView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (randomUserId != null) {
          Get.to(
            () => ChannelPage(userId: randomUserId!, platform: apiPlatform),
          );
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Image.asset(Assets.iconTitle, width: 20, height: 20),
                  ),
                  Positioned(
                    left: 42,
                    child: Text(
                      'Recommend',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF121212),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),
            Text(
              'More',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF919191),
              ),
            ),
            SizedBox(width: 6),
            Image.asset(Assets.iconMore, width: 12, height: 12),
          ],
        ),
      ),
    );
  }

  Widget hotContentWidget() {
    return Obx(
      () => ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: otherChange.value ? hotArray.length : 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              playSource = PlaySource.landpage_hot;
              pushPage(hotArray[index], hotArray);
            },
            child: HomeCell(model: hotArray[index], isHot: true),
          );
        },
      ),
    );
  }

  Widget newContentWidget() {
    return Obx(
      () => ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: otherChange.value ? newArray.length : 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              playSource = PlaySource.landpage_recently;
              pushPage(newArray[index], newArray);
            },
            child: HomeCell(model: newArray[index]),
          );
        },
      ),
    );
  }

  void pushPage(VideoData model, List<VideoData> list) async {
    switch (model.fileType) {
      case 0:
        if (model.recommend == 1) {
          playSource = PlaySource.landpage_recommend;
        }
        PlayTool.pushPage(model, list, true);
      case 1:
        Get.to(() => PhotoPage(data: model));
      case 2:
        Get.to(
          () => FileListPage(
            userId: model.userId,
            folderId: model.movieId,
            name: model.name,
            recommend: model.recommend,
            platform: model.platform,
            linkId: model.linkId,
          ),
        );
    }
  }
}
