import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key, required this.model});
  final VideoData model;

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final List<String> titles = ['Rename', 'Info', 'Delete'];
  final List<String> images = [
    Assets.iconRenameInfo,
    Assets.iconIconInfo,
    Assets.iconDeleteInfo,
  ];

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
              height: 334,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(36)),
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
                  begin: Alignment.topCenter, // 渐变起点
                  end: Alignment.bottomCenter, // 渐变终点
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Image.memory(
                            widget.model.img ??
                                Uint8List.fromList(0 as List<int>),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.model.name,
                            style: const TextStyle(
                              letterSpacing: -0.5,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF17132C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  listWidget(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 394,
            right: 20,
            child: InkWell(
              onTap: () {
                Get.back(result: 0);
              },
              child: Image.asset(Assets.iconCloseAlert, width: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget listWidget() {
    return Wrap(
      direction: Axis.vertical,
      children: List.generate(
        titles.length,
        (index) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.back(result: index + 1);
          },
          child: SizedBox(
            height: 72,
            width: Get.width - 88,
            child: Row(
              children: [
                Image.asset(images[index], width: 32),
                SizedBox(width: 12),
                Text(
                  titles[index],
                  style: const TextStyle(
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF17132C),
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
