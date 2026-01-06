import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/common/munu_page.dart';
import 'package:munu/page/home/record_cell.dart';
import 'package:munu/tools/event_tool.dart';
import 'package:munu/tools/track_tool.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';
import '../../tools/common_tool.dart';
import '../../tools/toast_tool.dart';
import 'clear_alert_page.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TrackTool.instance.config();
    eventSource = ServiceEventSource.history;
    EventTool.instance.eventUpload(EventApi.historyExpose, null);
  }

  @override
  Widget build(BuildContext context) {
    return MunuPage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: _listWidget(),
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
      actions: [
        Container(
          width: 92,
          height: 32,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Color(0x40A9CBFF), // 颜色放在 decoration 中
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              _displayAlert();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(Assets.iconDeleteNav, width: 18),
                Text(
                  'Delete All',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _listWidget() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: Get.width,
          height: 44,
          padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                child: Image.asset(Assets.iconTitle, width: 40, height: 14),
              ),
              Positioned(
                left: 0,
                child: Text(
                  'History',
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF17132C),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Obx(
            () => ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: DataTool.instance.historyItems.length,
              itemBuilder: (context, index) {
                return RecordCell(
                  model: DataTool.instance.historyItems[index],
                  onDelete: () {
                    VideoData m = DataTool.instance.historyItems[index];
                    m.playTime = 0;
                    m.isHistory = 0;
                    DataTool.instance.updateVideoData(m);
                    ToastTool.show(
                      message: 'Removal Complete',
                      type: ToastType.success,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _displayAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击背景是否关闭
      builder: (context) => ClearAlertPage(),
    ).then((result) {
      if (result) {
        for (VideoData m in DataTool.instance.historyItems) {
          m.playTime = 0;
          m.isHistory = 0;
          DataTool.instance.updateVideoData(m);
        }
      }
    });
  }
}
