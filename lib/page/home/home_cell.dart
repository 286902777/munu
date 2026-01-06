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
      padding: EdgeInsets.only(left: 12, right: 16),
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // 垂直下对齐
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
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
              ),
              Visibility(
                visible: widget.isHot,
                child: Positioned(
                  top: -1,
                  left: 4,
                  child: Image.asset(Assets.assetsHot, width: 28, height: 14),
                ),
              ),
              Visibility(
                visible: widget.model.recommend == 1,
                child: Positioned(
                  right: 0,
                  top: 0,
                  child: Image.asset(
                    Assets.assetsRecommend,
                    width: 56,
                    height: 18,
                  ),
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
    int colorValue = 0xFFDDEEEA;
    String name = Assets.assetsVideoBg;
    switch (type) {
      case 1:
        name = Assets.assetsPhotoBg;
        colorValue = 0xFFDDEEEA;
      case 2:
        name = Assets.assetsFolderBg;
        colorValue = 0xFFDDEEEA;
      default:
        break;
    }
    return Container(
      alignment: Alignment.center,
      color: Color(colorValue),
      child: Image.asset(name, width: 62, height: 46, fit: BoxFit.cover),
    );
  }
}
