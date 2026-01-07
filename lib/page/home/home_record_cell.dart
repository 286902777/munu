import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/page/home/record_page.dart';
import 'package:munu/tools/play_tool.dart';

import '../../generated/assets.dart';
import '../../tools/common_tool.dart';

class HomeRecordCell extends StatefulWidget {
  const HomeRecordCell({super.key});

  @override
  State<HomeRecordCell> createState() => _HomeRecordCellState();
}

class _HomeRecordCellState extends State<HomeRecordCell> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: EdgeInsets.fromLTRB(16, 0, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(Assets.iconTitle, width: 20, height: 20),
                SizedBox(width: 6),
                Text(
                  'Record',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Color(0xFF17132C),
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    playSource = PlaySource.history;
                    Get.to(() => RecordPage());
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
            child: Obx(
              () => Wrap(
                spacing: 16, // 主轴间距
                runSpacing: 0, // 换行间距
                direction: Axis.horizontal,
                children: List.generate(
                  DataTool.instance.historyItems.length,
                  (index) => InkWell(
                    onTap: () {
                      eventSource = ServiceEventSource.history;
                      playSource = PlaySource.history;
                      PlayTool.pushPage(
                        DataTool.instance.historyItems[index],
                        DataTool.instance.historyItems,
                        DataTool.instance.historyItems[index].netMovie != 0,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        color: Color(0xFFEDE4E1),
                        height: 228,
                        width: 178,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DataTool.instance.historyItems[index].netMovie == 0
                                ? Image.memory(
                                    DataTool.instance.historyItems[index].img ??
                                        Uint8List.fromList(0 as List<int>),
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: DataTool
                                        .instance
                                        .historyItems[index]
                                        .thumbnail,
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                    placeholder: (context, url) =>
                                        setPlaceWidget(
                                          DataTool
                                              .instance
                                              .historyItems[index]
                                              .fileType,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        setPlaceWidget(
                                          DataTool
                                              .instance
                                              .historyItems[index]
                                              .fileType,
                                        ),
                                  ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 114,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0x00000000),
                                      Color(0xA6000000),
                                    ], // 中心到边缘颜色
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                height: 18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(9),
                                  ),
                                  color: Color(0x4D000000),
                                ),
                                child: Text(
                                  CommonTool.instance.formatHMS(
                                    Duration(
                                      seconds: DataTool
                                          .instance
                                          .historyItems[index]
                                          .totalTime,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    letterSpacing: -0.5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 12,
                              child: Text(
                                DataTool.instance.historyItems[index].name,
                                style: const TextStyle(
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(
                                minHeight: 4,
                                value:
                                    DataTool
                                            .instance
                                            .historyItems[index]
                                            .totalTime >
                                        0
                                    ? (DataTool
                                              .instance
                                              .historyItems[index]
                                              .playTime /
                                          DataTool
                                              .instance
                                              .historyItems[index]
                                              .totalTime)
                                    : 0,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFD6B39),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 14),
        ],
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
