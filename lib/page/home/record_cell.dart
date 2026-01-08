import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:munu/common/db_tool.dart';

import 'package:munu/data/video_data.dart';
import 'package:munu/tools/common_tool.dart';

import '../../generated/assets.dart';
import '../../tools/play_tool.dart';

class RecordCell extends StatefulWidget {
  const RecordCell({super.key, required this.model, required this.onDelete});
  final VideoData model;
  final VoidCallback onDelete;
  @override
  State<RecordCell> createState() => _RecordCellState();
}

class _RecordCellState extends State<RecordCell> {
  @override
  void initState() {
    super.initState();
  }

  void _onDismiss() {
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        dragDismissible: false,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              color: Color(0xFFFF3B1F),
            ),
            alignment: Alignment.center,
            width: 68,
            height: 72,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _onDismiss,
              child: Image.asset(Assets.iconDeleteCell, width: 24),
            ),
          ),
        ],
      ),
      child: _contentView(),
    );
  }

  Widget _contentView() {
    return InkWell(
      onTap: () {
        PlayTool.pushPage(
          widget.model,
          DataTool.instance.historyItems,
          widget.model.netMovie != 0,
        );
      },
      splashColor: Colors.transparent, // 透明水波纹
      highlightColor: Colors.transparent, // 透明高亮
      hoverColor: Colors.transparent, // 透明悬停
      child: Container(
        height: 88,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end, // 垂直下对齐
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: widget.model.netMovie == 0
                      ? Image.memory(
                          widget.model.img ??
                              Uint8List.fromList(0 as List<int>),
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
                              setPlaceWidget(widget.model.fileType),
                          errorWidget: (context, url, error) =>
                              setPlaceWidget(widget.model.fileType),
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
                SizedBox(width: 12),
              ],
            ),
          ],
        ),
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
