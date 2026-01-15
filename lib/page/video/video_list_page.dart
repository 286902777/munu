import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/tools/http_tool.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import '../../data/user_pool_data.dart';
import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../tools/common_tool.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({
    super.key,
    required this.lists,
    required this.selectItem,
    required this.dataItem,
  });
  final List<VideoData> lists;
  final ValueSetter<List<VideoData>> selectItem;
  final ValueSetter<List<VideoData>> dataItem;

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  final ScrollController _controller = ScrollController();
  final RefreshController _refreshController = RefreshController();

  List<VideoData> dataList = <VideoData>[];
  List<VideoData> recommendList = <VideoData>[];

  String? resultUserId;
  int platform = 0;
  bool isRequested = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int index = 0;
    bool isRecom = false;
    for (int i = 0; i < widget.lists.length; i++) {
      if (widget.lists[i].isSelect && widget.lists[i].recommend != 2) {
        index = i;
        if (widget.lists[i].recommend == 1) {
          isRecom = true;
        }
        break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(index * 78 + (isRecom ? 44 : 0));
      }
    });
    widget.lists.forEach((m) {
      dataList.add(m);
    });
    for (VideoData m in dataList) {
      if (m.recommend == 1) {
        recommendList.add(m);
      }
    }
    if (recommendList.isEmpty) {
      try {
        VideoData mod = dataList.firstWhere((m) => m.netMovie == 1);
        _getChannel(mod);
      } catch (_) {}
    } else {
      resultUserId = recommendList.last.userId;
      _loadUserInfo();
    }
  }

  void _getChannel(VideoData mod) async {
    List<Map<String, dynamic>> dbList = await DbTool.instance.getAllUser();
    if (dbList.isNotEmpty) {
      List<UserPoolData> tempUsers = <UserPoolData>[];
      dbList.forEach((mod) {
        UserPoolData user = UserPoolData.fromJson(jsonDecode(mod['info']));
        user.platform = mod['platform'];
        tempUsers.add(user);
      });
      List<UserPoolData> result = tempUsers
          .where((user) => user.platform == mod.platform)
          .toList();
      if (result.isEmpty) {
        return;
      }
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
        mod.platform == 0 ? PlatformType.india : PlatformType.middle,
        para: {
          'faquir': {'thermopile': labelArr},
          'insinking': Platform.isIOS ? 'ios' : 'android',
          'cipherable': mod.userId,
        },
        successHandle: (data) async {
          if (data != null && data is List) {
            int idx = Random().nextInt(data.length);
            resultUserId = data[idx]['cipherable'];
            platform = mod.platform;
            _loadUserInfo();
          }
        },
        failHandle: (refresh, code, msg) {
          if (refresh) {
            _getChannel(mod);
          }
        },
      );
    }
  }

  void _loadUserInfo() async {
    List<String> idsList = <String>[];
    if (recommendList.isNotEmpty) {
      idsList = [
        '${DateTime.now().millisecondsSinceEpoch}',
        recommendList.last.movieId,
      ];
    }
    await HttpTool.recommendPostRequest(
      ApiKey.recommend,
      platform == 0 ? PlatformType.india : PlatformType.middle,
      isRequested ? (idsList.isNotEmpty ? true : false) : false,
      para: {
        'zpn0h3yl2d': resultUserId,
        'gleamingly': {'bawble': idsList},
      },
      successHandle: (data) {
        _refreshController.loadComplete();
        if (data != null && data is Map<String, dynamic>) {
          isRequested = true;
          if (data['eurythmic'] is List && data['eurythmic'].length > 0) {
            bool reCom = false;
            for (VideoData m in dataList) {
              if (m.recommend == 2 ||
                  (m.name == 'Recommend' &&
                      m.movieId.isEmpty &&
                      m.recommend == 0)) {
                reCom = true;
              }
            }
            if (recommendList.isEmpty &&
                data['eurythmic'].length > 0 &&
                reCom == false) {
              dataList.add(VideoData(name: 'Recommend', recommend: 2));
              recommendList.add(VideoData(name: 'Recommend', recommend: 2));
            }
            List<VideoData> tempList = [];
            for (Map<String, dynamic> item in data['eurythmic']) {
              VideoData itemModel = VideoData(
                movieId: item['dividual'],
                name: item['maledict']['obversely'],
                netMovie: 1,
                fileType: item['incr'] ? 0 : 1,
                size: CommonTool.instance.countFile(
                  item['chiot']['spangliest'],
                ),
                ext: item['chiot']['tinglier'],
                createDate: item['yldqjdbtqs'],
                fileCount: item['heuk'],
                recommend: 1,
                thumbnail: item['chiot']['lp8upexhzt'],
                userId: resultUserId ?? '',
                platform: platform,
              );
              tempList.add(itemModel);
            }
            if (recommendList.isNotEmpty &&
                tempList.isNotEmpty &&
                recommendList.last.movieId == tempList.last.movieId) {
              _refreshController.loadNoData();
            } else {
              recommendList.addAll(tempList);
              dataList.addAll(tempList);
            }
          } else {
            _refreshController.loadNoData();
          }
        } else {
          _refreshController.loadNoData();
        }
        if (mounted) {
          setState(() {});
        }
      },
      failHandle: (refresh, code, msg) async {
        if (refresh) {
          _loadUserInfo();
        } else {
          _refreshController.loadFailed();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 40,
            padding: EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    widget.dataItem(dataList);
                    Get.back();
                  },
                  splashColor: Colors.transparent, // 透明水波纹
                  highlightColor: Colors.transparent, // 透明高亮
                  hoverColor: Colors.transparent, // 透明悬停
                  child: Image.asset(Assets.iconCloseAlert, width: 24),
                ),
              ],
            ),
          ),
          Container(
            height: 442,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFFFEF6F2), Color(0xFFFFFEFC)], // 中心到边缘颜色
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 62,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        bottom: 16,
                        child: Image.asset(
                          Assets.iconTitle,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 46,
                        child: Text(
                          'Playlist',
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
                ),
                Expanded(child: cellWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cellWidget() {
    return ListView.builder(
      controller: _controller,
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        if (dataList[index].movieId.isEmpty &&
            dataList[index].name == 'Recommend') {
          return _recommendTitleV();
        }
        return subCell(dataList[index]);
      },
    );
  }

  Widget _recommendTitleV() {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 10,
            child: Image.asset(Assets.iconTitle, width: 20, height: 20),
          ),
          Positioned(
            right: 26,
            top: 8,
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
  }

  Widget subCell(VideoData model) {
    return GestureDetector(
      onTap: () {
        for (VideoData m in dataList) {
          m.isSelect = false;
        }
        model.isSelect = true;
        if (model.recommend == 1) {
          playSource = PlaySource.playlist_recommend;
        } else {
          playSource = PlaySource.playlist_file;
        }
        setState(() {});
        widget.selectItem(dataList);
      },
      child: Container(
        height: 78,
        width: Get.width,
        color: model.isSelect ? Color(0xFFFFEEE4) : Colors.transparent,
        padding: EdgeInsets.only(left: 16, top: 8, right: 14, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 114,
              height: 62,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: model.netMovie == 0
                          ? Image.memory(
                              model.img ?? Uint8List.fromList(0 as List<int>),
                              width: 110,
                              height: 62,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: model.thumbnail,
                              fit: BoxFit.cover,
                              width: 110,
                              height: 62,
                              placeholder: (context, url) =>
                                  setPlaceWidget(model.fileType),
                              errorWidget: (context, url, error) =>
                                  setPlaceWidget(model.fileType),
                            ),
                    ),
                  ),
                  if (model.isSelect)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Image.asset(Assets.playPlayIng, width: 14),
                    ),
                  if (model.recommend == 1)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Image.asset(
                        Assets.channelRecommend,
                        width: 72,
                        height: 18,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 14,
                      color: Color(0xFF17132C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (model.totalTime.toInt() > 0)
                    Text(
                      CommonTool.instance.formatHMS(
                        Duration(seconds: model.totalTime.toInt()),
                      ),
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 12,
                        color: Color(0x8017132C),
                      ),
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget setPlaceWidget(int type) {
    return Container(
      alignment: Alignment.center,
      color: Color(0xFFEDE4E1),
      child: Image.asset(
        Assets.iconVideoBg,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }
}
