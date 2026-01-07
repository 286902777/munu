import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:munu/common/munu_page.dart';
import 'package:munu/data/user_pool_data.dart';
import 'package:munu/page/channel/channel_detail_page.dart';
import 'package:munu/page/home/home_record_cell.dart';
import 'package:munu/tools/event_tool.dart';
import 'package:munu/tools/http_tool.dart';
import 'package:munu/tools/network_tool.dart';
import 'package:munu/tools/play_tool.dart';
import 'package:munu/tools/service_tool.dart';
import 'package:munu/tools/track_tool.dart';

import '../../common/db_tool.dart';
import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../keys/app_key.dart';
import '../../main.dart';
import '../../tools/common_tool.dart';
import '../channel/channel_page.dart';
import 'home_list_cell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, RouteAware {
  var isNetwork = false.obs;

  List<UserPoolData> userLists = <UserPoolData>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    requestChannelData();
    indexServiceEvent();
    super.didPopNext();
  }

  @override
  void didPop() {
    super.didPop();
  }

  @override
  void didPushNext() {
    super.didPushNext();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    TrackTool.instance.config();
    isNetwork.value = NetworkTool.instance.netStatus;
    requestChannelData();
    indexServiceEvent();
    uploadOpenApp();
  }

  uploadOpenApp() async {
    bool? newUser = await AppKey.getBool(AppKey.appNewUser);
    if (newUser == null || newUser == false) {
      ServiceTool.instance.addEvent(
        ServiceEventName.downloadAppFirstTimeOpen,
        apiPlatform,
        0,
        '',
        '',
        '',
      );
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> requestChannelData() async {
    userLists.assignAll(DataTool.instance.users);
    if (userLists.isNotEmpty) {
      String userId = userLists.first.id;
      int platform = userLists.first.platform;
      List<UserPoolData> result = userLists
          .where((user) => user.platform == platform)
          .toList();
      List<Map<String, dynamic>> labelArr = [];
      result.forEach((mod) {
        mod.labels.forEach((label) {
          Map<String, dynamic> dic = {
            'angered': label.id,
            'coachable': label.labelName,
            'paradisian': label.firstLabelCode,
            'shunts': label.secondLabelCode,
          };
          labelArr.add(dic);
        });
      });
      await HttpTool.postRequest(
        ApiKey.userPools,
        platform == 0 ? PlatformType.india : PlatformType.east,
        para: {
          'faquir': {'thermopile': labelArr},
          'insinking': Platform.isIOS ? 'ios' : 'android',
          'cipherable': userId,
        },
        successHandle: (data) {
          if (data != null && data is List) {
            List<UserPoolData> tempUser = <UserPoolData>[];
            data.forEach((m) {
              if (m is Map<String, dynamic>) {
                UserPoolData pool = UserPoolData(
                  id: m['cipherable'],
                  account: '',
                  name: m['jordanite'],
                  email: '',
                  picture: m['auxology'],
                  labels: [],
                  telegramUrl: '',
                  bannerPictureUrl: '',
                  telegramAddress: '',
                  platform: platform,
                );
                tempUser.add(pool);
              }
            });
            insertChannelData(tempUser);
          }
        },
        failHandle: (refresh, code, msg) {
          if (refresh) {
            requestChannelData();
          }
        },
      );
    }
  }

  void insertChannelData(List<UserPoolData> list) async {
    List<UserPoolData> tempList = <UserPoolData>[];
    await DataTool.instance.loadUsers();
    List<UserPoolData> users = DataTool.instance.users;

    for (UserPoolData item in list) {
      List<UserPoolData> exits = users.where((m) => m.id == item.id).toList();
      if (exits.isEmpty) {
        tempList.add(item);
      }
    }

    if (tempList.isEmpty) {
      return;
    }

    if (users.length > 2) {
      for (int i = 0; i < users.length; i++) {
        if (i % 2 == 0 && i > 0) {
          int idx = Random().nextInt(tempList.length);
          UserPoolData pool = tempList[idx];
          pool.recommend = 1;
          tempList.removeAt(idx);
          userLists.insert(i, pool);
        }
      }
    } else {
      int idx = Random().nextInt(tempList.length);
      UserPoolData pool = tempList[idx];
      pool.recommend = 1;
      userLists.add(pool);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MunuPage(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 32,
              left: 0,
              right: 0,
              bottom: 0,
              child: Obx(
                () => isNetwork.value
                    ? (DataTool.instance.items
                                  .where((item) => item.netMovie == 0)
                                  .toList()
                                  .isNotEmpty ||
                              DataTool.instance.historyItems.isNotEmpty ||
                              DataTool.instance.users.isNotEmpty
                          ? _contentView()
                          : _importWidget())
                    : _emptyWidget(),
              ),
            ),
            // Positioned(
            //   top: 9,
            //   right: 12,
            //   child: GestureDetector(
            //     onTap: () {
            //       vipMethod = VipMethod.click;
            //       vipSource = VipSource.home;
            //       Get.to(() => UserVipPage());
            //     },
            //     child: Image.asset(Assets.svipProNav, width: 54, height: 22),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _contentView() {
    List<VideoData> dbLists = DataTool.instance.items
        .where((item) => item.netMovie == 0)
        .toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Visibility(
          visible: DataTool.instance.historyItems.isNotEmpty,
          child: HomeRecordCell(),
        ),
        Visibility(visible: userLists.isNotEmpty, child: _channelContentView()),
        Visibility(
          visible: dbLists.isNotEmpty,
          child: HomeListCell(
            lists: dbLists,
            clickItem: (index) {
              List<VideoData> lists = dbLists;
              for (int i = 0; i < lists.length; i++) {
                if (i == index) {
                  playSource = PlaySource.import;
                  PlayTool.pushPage(lists[i], lists, false);
                  break;
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _channelContentView() {
    return SizedBox(
      height: 158,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Image.asset(
                        Assets.iconTitle,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Positioned(
                      left: 26,
                      child: Text(
                        'Channel',
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Color(0xFF17132C),
                        ),
                      ),
                    ),
                  ],
                ),

                InkWell(
                  onTap: () {
                    Get.to(() => ChannelDetailPage());
                  },
                  child: Row(
                    children: [
                      Text(
                        'More',
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Color(0xFF919191),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(Assets.iconMore, width: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 12),
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 16, // 主轴间距
              runSpacing: 0, // 换行间距
              direction: Axis.horizontal,
              children: List.generate(
                userLists.length,
                (index) => GestureDetector(
                  onTap: () {
                    eventSource = ServiceEventSource.channelPage;
                    channelSource = ChannelSource.home_channel;
                    if (userLists.length > index) {
                      EventTool.instance
                          .eventUpload(EventApi.channellistClick, {
                            EventParaName.value.name:
                                userLists[index].recommend == 0
                                ? 'IqYl'
                                : 'oAkJkCeuEa',
                            EventParaName.entrance.name: 'ayiqpkj',
                          });
                    }
                    Get.to(
                      () => ChannelPage(
                        userId: userLists[index].id,
                        platform: userLists[index].platform == 0
                            ? PlatformType.india
                            : PlatformType.east,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(36)),
                          child: SizedBox(
                            height: 72,
                            width: 72,
                            child: CachedNetworkImage(
                              imageUrl: userLists[index].picture,
                              fit: BoxFit.cover,
                              width: 72,
                              height: 72,
                              placeholder: (context, url) => Image.asset(
                                Assets.iconAvatar,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                Assets.iconAvatar,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          userLists[index].name,
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF03011A),
                            overflow: TextOverflow.ellipsis,
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _importWidget() {
    return Column(
      children: [
        SizedBox(height: 8),
        Row(
          children: [
            SizedBox(width: 16),
            Image.asset(Assets.iconTitle, width: 20, height: 20),
            SizedBox(width: 6),
            Text(
              'Collection',
              style: const TextStyle(
                letterSpacing: -0.5,
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: Color(0xFF17132C),
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(Assets.iconNoContent, width: 120, height: 120),
                  SizedBox(height: 4),
                  Text(
                    'No files uploaded yet.',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF17132C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    child: Container(
                      width: 132,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFFD6B39),
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: Text(
                        'Open',
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () {
                      clickTabItem?.call(1);
                      // Get.to(DeepPage(linkId: '1989159724607737858'));
                      TrackTool.instance.config();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyWidget() {
    return Column(
      children: [
        SizedBox(height: 8),

        Row(
          children: [
            SizedBox(width: 16),
            Image.asset(Assets.iconTitle, width: 20, height: 20),
            SizedBox(width: 6),
            Text(
              'Collection',
              style: const TextStyle(
                letterSpacing: -0.5,
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: Color(0xFF17132C),
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(Assets.iconNoNetwork, width: 120, height: 120),
                  SizedBox(height: 4),
                  Text(
                    'No internet. Retry, please.',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF17132C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void indexServiceEvent() async {
    if (DataTool.instance.users.isNotEmpty) {
      EventTool.instance.eventUpload(EventApi.homeChannelExpose, {
        EventParaName.sub.name: DataTool.instance.users.length,
      });
    }
    if (DataTool.instance.historyItems.isNotEmpty) {
      EventTool.instance.eventUpload(EventApi.homeHistoryExpose, {
        EventParaName.history.name: DataTool.instance.historyItems.length,
      });
    }
    EventTool.instance.eventUpload(EventApi.homeExpose, null);
  }
}
