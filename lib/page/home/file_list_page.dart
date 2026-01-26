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
  final _scrollController = ScrollController();

  final _aplah = ValueNotifier<double>(0);
  List<VideoData> lists = [];
  int page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      double aplah = _scrollController.offset / 52;
      _aplah.value = aplah;
    });
    requestNetworkData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    _scrollController.dispose();
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
          body: listWidget(),
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
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.iconBack, width: 24),
          ),
        ],
      ),
      title: ValueListenableBuilder(
        valueListenable: _aplah,
        builder: (BuildContext context, alpah, Widget? child) {
          double op = alpah;
          if (op > 1) {
            op = 1;
          }
          if (op < 0) {
            op = 0;
          }
          return Opacity(
            opacity: op,
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                letterSpacing: -0.5,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF03011A),
              ),
            ),
          );
        },
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
          controller: _scrollController,
          itemCount: lists.isNotEmpty ? lists.length + 1 : 0,
          itemBuilder: (context, index) {
            if (index == 0) {
              return titleWidget();
            } else {
              VideoData data = lists[index - 1];
              data.recommend = widget.recommend;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  clickOpenPage(data, lists);
                },
                child: HomeCell(model: data),
              );
            }
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

  Widget titleWidget() {
    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Image.asset(Assets.iconTitle, width: 20, height: 20),
          SizedBox(width: 6),
          Text(
            widget.name,
            style: const TextStyle(
              letterSpacing: -0.5,
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Color(0xFF141414),
            ),
          ),
        ],
      ),
    );
  }
}
