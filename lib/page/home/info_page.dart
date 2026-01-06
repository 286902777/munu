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
      'Modified': formattedTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          gradient: LinearGradient(
            colors: [Color(0xFFD3E3FC), Color(0xFFF4F4F4)], // 中心到边缘颜色
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 68,
              child: Stack(
                children: [
                  Positioned(
                    top: 22,
                    left: 20,
                    child: Text(
                      'Info',
                      style: const TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF17132C),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        Get.back(result: 0);
                      },
                      child: Image.asset(Assets.iconCloseAlert, width: 24),
                    ),
                  ),
                  Positioned(
                    top: 67,
                    left: 0,
                    right: 0,
                    child: Container(height: 1, color: Color(0x2035267F)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            listView(),
          ],
        ),
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
                Expanded(
                  flex: 1,
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
                Spacer(),
                Expanded(
                  flex: 3,
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
