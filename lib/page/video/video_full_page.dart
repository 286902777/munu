import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/tools/http_tool.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../data/user_pool_data.dart';
import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../tools/common_tool.dart';

class VideoFullPage extends StatefulWidget {
  const VideoFullPage({
    super.key,
    required this.lists,
    required this.selectItem,
    required this.dataItem,
  });

  final List<VideoData> lists;
  final ValueSetter<List<VideoData>> selectItem;
  final ValueSetter<List<VideoData>> dataItem;

  @override
  State<VideoFullPage> createState() => _VideoFullPageState();
}

class _VideoFullPageState extends State<VideoFullPage> {
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
    bool isRadom = false;
    for (int i = 0; i < widget.lists.length; i++) {
      if (widget.lists[i].isSelect && widget.lists[i].recommend != 2) {
        index = i;
        if (widget.lists[i].recommend == 1) {
          isRadom = true;
        }
        break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(index * 78 + (isRadom ? 44 : 0));
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

  Future<void> _getChannel(VideoData mod) async {
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
        mod.platform == 0 ? PlatformType.india : PlatformType.east,
        para: {
          'faquir': {'thermopile': labelArr},
          'insinking': Platform.isIOS ? 'ios' : 'android',
          'cipherable': mod.userId,
        },
        successHandle: (data) {
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

  Future<void> _loadUserInfo() async {
    List<String> idsList = <String>[];
    if (recommendList.isNotEmpty) {
      idsList = [
        '${DateTime.now().millisecondsSinceEpoch}',
        recommendList.last.movieId,
      ];
    }
    await HttpTool.recommendPostRequest(
      ApiKey.playRecommend,
      platform == 0 ? PlatformType.india : PlatformType.east,
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
        setState(() {});
      },
      failHandle: (refresh, code, msg) {
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
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              alignment: Alignment.centerRight,
              width: 375,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x00CADFFF), Color(0xFA3E5E8E)], // 中心到边缘颜色
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 20,
                          bottom: 16,
                          child: Image.asset(
                            Assets.iconTitle,
                            width: 40,
                            height: 14,
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Text(
                            'Playlist',
                            style: const TextStyle(
                              letterSpacing: -0.5,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _listView()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listView() {
    return ListView.builder(
      controller: _controller,
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        if (dataList[index].movieId.isEmpty &&
            dataList[index].name == 'Recommend') {
          return _recommendHeader();
        }
        return _listCell(dataList[index]);
      },
    );
  }

  Widget _recommendHeader() {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 10,
            child: Image.asset(Assets.iconTitle, width: 40, height: 14),
          ),
          Positioned(
            left: 0,
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

  Widget _listCell(VideoData model) {
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
        color: model.isSelect ? Color(0x40FFFFFF) : Colors.transparent,
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
                      borderRadius: BorderRadius.all(Radius.circular(4)),
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
                      bottom: 6,
                      right: 6,
                      child: Image.asset(
                        Assets.playPlayIng,
                        width: 14,
                        height: 14,
                      ),
                    ),
                  // if (model.recommend == 1)
                  //   Positioned(
                  //     top: 2,
                  //     right: 2,
                  //     child: Image.asset(
                  //       Assets.homeCellRecommend,
                  //       width: 56,
                  //       height: 18,
                  //     ),
                  //   ),
                ],
              ),
            ),
            SizedBox(width: 10),
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
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  if (model.totalTime.toInt() > 0)
                    Text(
                      CommonTool.instance.formatHMS(
                        Duration(seconds: model.totalTime.toInt()),
                      ),
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 12,
                        color: Color(0x80FFFFFF),
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
        width: 62,
        height: 46,
        fit: BoxFit.cover,
      ),
    );
  }
}
