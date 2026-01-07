import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/page/home/rename_page.dart';
import 'package:munu/tools/common_tool.dart';
import 'package:munu/tools/toast_tool.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';
import 'info_page.dart';
import 'more_page.dart';

class HomeListCell extends StatefulWidget {
  final List<VideoData> lists;
  final ValueSetter<int> clickItem;
  const HomeListCell({super.key, required this.lists, required this.clickItem});

  @override
  State<HomeListCell> createState() => _HomeListCellState();
}

class _HomeListCellState extends State<HomeListCell> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Image.asset(Assets.iconTitle, width: 20, height: 20),
                ),
                Positioned(
                  left: 26,
                  child: Text(
                    'Collection',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Color(0xFF17132C),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: widget.lists.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.clickItem(index);
                  },
                  child: HomeListCellContent(model: widget.lists[index]),
                );
              },
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class HomeListCellContent extends StatefulWidget {
  const HomeListCellContent({super.key, required this.model});
  final VideoData model;

  @override
  State<HomeListCellContent> createState() => _HomeListCellContentState();
}

class _HomeListCellContentState extends State<HomeListCellContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: EdgeInsets.only(left: 16, bottom: 16, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // 垂直下对齐
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            child: widget.model.netMovie == 0
                ? Image.memory(
                    widget.model.img ?? Uint8List.fromList(0 as List<int>),
                    width: 128,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: widget.model.thumbnail,
                    fit: BoxFit.cover,
                    width: 128,
                    height: 72,
                    placeholder: (context, url) =>
                        _setPlaceholder(widget.model.fileType),
                    errorWidget: (context, url, error) =>
                        _setPlaceholder(widget.model.fileType),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.model.name,
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF03011A),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 8),
                Text(
                  replaceDate(widget.model),
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF595959),
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (widget.model.fileType != 2)
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Image.asset(Assets.iconMorebtn, width: 24),
              onPressed: () {
                _clickMore(context, widget.model);
              },
            ),
        ],
      ),
    );
  }

  void _clickMore(BuildContext context, VideoData model) async {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // 点击背景是否关闭
      enableDrag: false,
      builder: (context) => MorePage(model: model),
    ).then((result) async {
      switch (result) {
        case 1:
          showModalBottomSheet(
            context: context,
            isDismissible: false, // 点击背景是否关闭
            enableDrag: false,
            isScrollControlled: true,
            builder: (context) => RenamePage(model: model),
          ).then((idx) {});
        case 2:
          showModalBottomSheet(
            context: context,
            isDismissible: false, // 点击背景是否关闭
            enableDrag: false,
            builder: (context) => InfoPage(model: model),
          );
        case 3:
          final dir = await getApplicationDocumentsDirectory();
          final path = File('${dir.path}/videos/${model.address}');
          if (await path.exists()) {
            try {
              await path.delete();
            } catch (e) {
              print(e.hashCode);
            }
          }
          DataTool.instance.removeVideoData(model);
          ToastTool.show(message: 'Removal Complete', type: ToastType.success);
        default:
          break;
      }
    });
  }

  Widget _setPlaceholder(int type) {
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

  String replaceDate(VideoData model) {
    final duration = Duration(seconds: model.totalTime.toInt());
    final time = CommonTool.instance.formatHMS(duration);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(model.createDate);
    String formattedTime = DateFormat('yyyy/MM/dd').format(dateTime);
    return '$time · ${model.size} · $formattedTime';
  }
}
