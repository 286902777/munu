import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/common/munu_page.dart';
import 'package:munu/page/home/photo_page.dart';
import 'package:munu/tools/http_tool.dart';
import 'package:munu/tools/play_tool.dart';
import 'package:munu/tools/refresh_tool.dart';
import 'package:munu/tools/toast_tool.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../data/file_data.dart';
import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../tools/common_tool.dart';
import 'home_cell.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({
    super.key,
    required this.userId,
    required this.folderId,
    required this.name,
    required this.recommend,
    required this.platform,
    required this.linkId,
  });
  final String userId;
  final String folderId;
  final String name;
  final int recommend;
  final int platform;
  final String linkId;

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  final RefreshController _refreshController = RefreshController();

  final List<VideoData> _dbDatabase = DataTool.instance.items;

  List<VideoData> lists = [];
  int page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNetworkData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }

  Future requestNetworkData() async {
    HttpTool.getRequest(
      ApiKey.folder,
      widget.platform == 0 ? PlatformType.india : PlatformType.middle,
      '/${widget.userId}/${widget.folderId}',
      true,
      para: {'kiaugh': '$page', 'craterous': '20'},
      successHandle: (data) {
        if (data != null) {
          FileData model = fileDataFromJson(data);
          if (model.files.isNotEmpty) {
            replaceDataInfo(model);
            page = page + 1;
          } else {
            _refreshController.loadNoData();
          }
        }
        _refreshController.loadComplete();
      },
      failHandle: (refresh, code, msg) {
        if (refresh) {
          requestNetworkData();
        } else {
          _refreshController.loadFailed();
          ToastTool.show(message: msg, type: ToastType.fail);
        }
      },
    );
  }

  void replaceDataInfo(FileData model) {
    for (FileListData item in model.files) {
      VideoData videoM = VideoData(
        name: item.disPlayName.epithets,
        linkId: widget.linkId,
        movieId: item.id,
        size: CommonTool.instance.countFile(item.fileMeta.size),
        ext: item.fileMeta.extension,
        netMovie: 1,
        createDate: item.updateTime,
        thumbnail: item.fileMeta.thumbnail,
        fileType: item.directory ? 2 : (item.video ? 0 : 1),
        fileCount: item.vidQty,
        userId: widget.userId,
        platform: widget.platform,
        recommend: widget.recommend,
      );
      if (videoM.fileType != 2) {
        var result = _dbDatabase
            .where((mod) => mod.movieId == videoM.movieId)
            .toList();
        if (result.isEmpty) {
          DataTool.instance.insertVideoData(videoM);
        }
      }
      lists.add(videoM);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MunuPage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: Padding(padding: EdgeInsets.only(top: 16), child: listWidget()),
        ),
      ),
    );
  }

  AppBar navbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.iconBack, width: 24),
          ),
        ],
      ),
      title: Text(widget.name, textAlign: TextAlign.center),
      titleTextStyle: const TextStyle(
        letterSpacing: -0.5,
        fontSize: 16,
        color: Color(0xFF03011A),
      ),
    );
  }

  Widget listWidget() {
    return RefreshConfiguration(
      hideFooterWhenNotFull: true,
      child: RefreshTool(
        controller: _refreshController,
        itemNum: 1,
        onLoading: requestNetworkData,
        child: ListView.builder(
          itemCount: lists.length,
          itemBuilder: (context, index) {
            VideoData data = lists[index];
            data.recommend = widget.recommend;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                clickOpenPage(data, lists);
              },
              child: HomeCell(model: data),
            );
          },
        ),
      ),
    );
  }

  void clickOpenPage(VideoData data, List<VideoData> list) async {
    switch (data.fileType) {
      case 0:
        PlayTool.pushPage(data, list, true);
      case 1:
        Get.to(() => PhotoPage(data: data));
      case 2:
        Get.to(
          () => FileListPage(
            userId: data.userId,
            folderId: data.movieId,
            name: data.name,
            recommend: data.recommend,
            platform: data.platform,
            linkId: widget.linkId,
          ),
          preventDuplicates: false,
        );
    }
  }
}
