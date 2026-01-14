import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/common/munu_page.dart';
import 'package:munu/tools/event_tool.dart';
import 'package:munu/tools/http_tool.dart';

import '../../data/user_pool_data.dart';
import '../../generated/assets.dart';
import '../../tools/common_tool.dart';
import 'channel_page.dart';

class ChannelDetailPage extends StatefulWidget {
  const ChannelDetailPage({super.key});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  PlatformType userPlatform = PlatformType.india;
  var show = false.obs;
  List<UserPoolData> allUsers = <UserPoolData>[];
  List<Map<String, dynamic>> recommends = <Map<String, dynamic>>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserInfo();
    EventTool.instance.eventUpload(EventApi.channelListExpose, null);
  }

  Future<void> loadUserInfo() async {
    DataTool.instance.loadUsers();
    allUsers = DataTool.instance.users;
    String userId = allUsers.first.id;
    int platform = allUsers.first.platform;
    userPlatform = platform == 0 ? PlatformType.india : PlatformType.middle;
    List<UserPoolData> result = allUsers
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
      platform == 0 ? PlatformType.india : PlatformType.middle,
      para: {
        'faquir': {'thermopile': labelArr},
        'insinking': Platform.isIOS ? 'ios' : 'android',
        'cipherable': userId,
      },
      successHandle: (data) {
        if (data != null && data is List) {
          data.forEach((m) {
            if (m is Map<String, dynamic>) {
              recommends.add(m);
            }
          });
          if (mounted) {
            setState(() {});
          }
        }
      },
      failHandle: (refresh, code, msg) {
        if (refresh) {
          loadUserInfo();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MunuPage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: cusNavbar(),
          body: Padding(
            padding: EdgeInsets.only(top: 12, left: 12, right: 12),
            child: channelListWidget(),
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
          SizedBox(width: 12),
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.iconBack, width: 32),
          ),
        ],
      ),
    );
  }

  Widget channelListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 46,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                bottom: 21,
                child: Image.asset(Assets.iconTitle, width: 20, height: 20),
              ),
              Positioned(
                left: 42,
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
        ),
        Expanded(child: contentWidget()),
      ],
    );
  }

  Widget contentWidget() {
    return ListView.builder(
      itemCount: recommends.isNotEmpty ? (recommends.length + 2) : 1,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _channelView();
          case 1:
            return Container(
              alignment: Alignment.centerLeft,
              height: 46,
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    bottom: 11,
                    child: Image.asset(Assets.iconTitle, width: 20, height: 20),
                  ),
                  Positioned(
                    left: 42,
                    top: 10,
                    child: Text(
                      'Recommend',
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF17132C),
                      ),
                    ),
                  ),
                ],
              ),
            );
          default:
            return _recommendView(recommends[index - 2]);
        }
      },
    );
  }

  Widget _channelView() {
    double space = (Get.width - 24 - 54 * 5) * 0.25;
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: space, // 主轴间距
            runSpacing: 16, // 换行间距
            direction: Axis.horizontal,
            children: List.generate(
              show.value
                  ? allUsers.length
                  : (allUsers.length < 10 ? allUsers.length : 10),
              (index) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  channelSource = ChannelSource.channellist;
                  EventTool.instance.eventUpload(EventApi.channelListClick, {
                    EventParaName.value.name: EventParaValue.history.value,
                    EventParaName.entrance.name: EventParaValue.list.value,
                  });
                  Get.to(
                    () => ChannelPage(
                      userId: allUsers[index].id,
                      platform: allUsers[index].platform == 0
                          ? PlatformType.india
                          : PlatformType.middle,
                    ),
                  );
                },
                child: SizedBox(
                  width: 54,
                  height: 96,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(27)),
                        child: SizedBox(
                          height: 54,
                          width: 54,
                          child: CachedNetworkImage(
                            imageUrl: allUsers[index].picture,
                            fit: BoxFit.cover,
                            width: 54,
                            height: 54,
                            placeholder: (context, url) => Image.asset(
                              Assets.channelAvatar,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              Assets.channelAvatar,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        allUsers[index].name,
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
          Visibility(
            visible: allUsers.length > 10,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                show.value = !show.value;
              },
              child: SizedBox(
                height: 32,
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        show.value ? 'Close' : 'See All',
                        style: const TextStyle(
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Color(0xFF919191),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(
                        show.value ? Assets.channelUp : Assets.channelDown,
                        width: 16,
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _recommendView(Map<String, dynamic> map) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        channelSource = ChannelSource.channelpage_recommend;
        EventTool.instance.eventUpload(EventApi.channelListClick, {
          EventParaName.value.name: EventParaValue.history.value,
          EventParaName.entrance.name: EventParaValue.recommend.value,
        });
        Get.to(
          () => ChannelPage(userId: map['cipherable'], platform: userPlatform),
        );
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(27)),
                child: SizedBox(
                  height: 54,
                  width: 54,
                  child: CachedNetworkImage(
                    imageUrl: map['auxology'],
                    fit: BoxFit.cover,
                    width: 54,
                    height: 54,
                    placeholder: (context, url) => Image.asset(
                      Assets.channelAvatar,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.channelAvatar,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                map['jordanite'],
                style: const TextStyle(
                  letterSpacing: -0.5,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF03011A),
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
