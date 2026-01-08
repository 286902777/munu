import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key, required this.model});
  final VideoData model;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Map<String, String> lists = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      widget.model.createDate,
    );
    String formattedTime = DateFormat('yyyy/MM/dd').format(dateTime);
    lists = {
      'Size': widget.model.size,
      'Format': widget.model.ext,
      'Path': 'Library',
      'Date': formattedTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 44),
              padding: EdgeInsets.only(left: 24, right: 24, top: 28),
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(36)),
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
                  begin: Alignment.topCenter, // 渐变起点
                  end: Alignment.bottomCenter, // 渐变终点
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Text(
                      'Info',
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF17132C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Color(0x10FB7331),
                    ),
                    child: listView(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 360,
            right: 20,
            child: InkWell(
              onTap: () {
                Get.back(result: 0);
              },
              splashColor: Colors.transparent, // 透明水波纹
              highlightColor: Colors.transparent, // 透明高亮
              hoverColor: Colors.transparent, // 透明悬停
              child: Image.asset(Assets.iconCloseAlert, width: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget listView() {
    return Wrap(
      direction: Axis.vertical,
      children: List.generate(
        lists.length,
        (index) => InkWell(
          onTap: () {
            Get.back(result: index);
          },
          child: Container(
            height: 46,
            width: Get.width,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    lists.keys.toList()[index],
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xB317132C),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    lists.values.toList()[index],
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF17132C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
