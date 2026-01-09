import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:munu/tools/common_tool.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';

class HomeCell extends StatefulWidget {
  const HomeCell({super.key, required this.model, this.isHot = false});
  final VideoData model;
  final bool isHot;

  @override
  State<HomeCell> createState() => _HomeCellState();
}

class _HomeCellState extends State<HomeCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.only(left: 16, right: 16),
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // 垂直下对齐
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: widget.model.thumbnail.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.model.thumbnail,
                        fit: BoxFit.cover,
                        width: 128,
                        height: 72,
                        placeholder: (context, url) =>
                            _setPlaceholder(widget.model.fileType),
                        errorWidget: (context, url, error) =>
                            _setPlaceholder(widget.model.fileType),
                      )
                    : SizedBox(
                        width: 128,
                        height: 72,
                        child: _setPlaceholder(widget.model.fileType),
                      ),
              ),
              Visibility(
                visible: widget.isHot,
                child: Positioned(
                  top: -4,
                  right: -4,
                  child: Image.asset(Assets.channelHot, width: 34, height: 34),
                ),
              ),
              Visibility(
                visible: widget.model.recommend == 1,
                child: Positioned(
                  right: -4,
                  top: -4,
                  child: Image.asset(Assets.channelHot, width: 34, height: 34),
                ),
              ),
            ],
          ),

          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      changeTimeToString(widget.model),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF595959),
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    Spacer(),
                    if (widget.model.fileType != 2 &&
                        widget.model.netMovie == 0)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // _clickMore(context, widget.model);
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: 48,
                          child: Image.asset(Assets.iconMorebtn, width: 24),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String changeTimeToString(VideoData model) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(model.createDate);
    String formattedTime = DateFormat('yyyy/MM/dd').format(dateTime);
    switch (model.fileType) {
      case 1:
        return formattedTime;
      case 2:
        return '${model.fileCount} videos';
      default:
        int total = model.totalTime.toInt();
        final duration = Duration(milliseconds: total);
        final time = CommonTool.instance.formatHMS(duration);
        String timeStr = '';
        if (total > 0) {
          timeStr = '$time ·';
        }
        return '$timeStr$formattedTime';
    }
  }

  Widget _setPlaceholder(int type) {
    int colorValue = 0xFFEDE4E1;
    String name = Assets.iconVideoBg;
    switch (type) {
      case 1:
        name = Assets.iconPhotoBg;
      case 2:
        name = Assets.iconFileBg;
      default:
        break;
    }
    return Container(
      alignment: Alignment.center,
      color: Color(colorValue),
      child: Image.asset(name, width: 40, height: 40, fit: BoxFit.cover),
    );
  }
}
