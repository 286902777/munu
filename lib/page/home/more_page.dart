import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
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
  final List<String> titles = ['Rename', 'Details', 'Delete'];
  final List<String> images = [
    Assets.iconRenameInfo,
    Assets.iconIconInfo,
    Assets.iconDeleteInfo,
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 340,
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
                    child: Container(
                      width: Get.width - 100,
                      padding: EdgeInsets.only(left: 20, right: 80),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
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
            SizedBox(height: 12),
            listWidget(),
          ],
        ),
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
          child: Container(
            height: 72,
            width: Get.width,
            padding: EdgeInsets.only(left: 20, right: 20),
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
