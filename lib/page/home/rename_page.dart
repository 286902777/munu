import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/data/video_data.dart';
import 'package:munu/tools/toast_tool.dart';

import '../../generated/assets.dart';

class RenamePage extends StatefulWidget {
  const RenamePage({super.key, required this.model});
  final VideoData model;

  @override
  State<RenamePage> createState() => _RenamePageState();
}

class _RenamePageState extends State<RenamePage> {
  final TextEditingController _controller = TextEditingController();
  var name = ''.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets, // 动态获取键盘遮挡区域
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 40,
              padding: EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    splashColor: Colors.transparent, // 透明水波纹
                    highlightColor: Colors.transparent, // 透明高亮
                    hoverColor: Colors.transparent, // 透明悬停
                    onTap: () {
                      Get.back(result: 0);
                    },
                    child: Image.asset(Assets.iconCloseAlert, width: 24),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 44),
              height: 258,
              padding: EdgeInsets.only(left: 24, right: 24, top: 28),
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
                    height: 48,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 20,
                          child: Text(
                            'Rename',
                            style: const TextStyle(
                              letterSpacing: -0.5,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF141414),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 18),
                  _inputView(),
                  SizedBox(height: 8),
                  _numView(),
                  SizedBox(height: 10),
                  _sureBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputView() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4),
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: TextField(
        autofocus: true,
        maxLength: 100,
        maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
        controller: _controller,
        cursorColor: Color(0xFF17132C), // 光标颜色
        cursorWidth: 2,
        maxLines: 1, // 最大行数
        onChanged: (text) {
          if (text.length > 10) {
            _controller.text = text.substring(0, 10);
            _controller.selection = TextSelection.collapsed(offset: 10);
          }
          name.value = _controller.text;
        },
        style: const TextStyle(
          letterSpacing: -0.5,
          color: Color(0xFF17132C),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: '',
          counterText: '',
          hintStyle: const TextStyle(
            letterSpacing: -0.5,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF17132C),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _numView() {
    return Obx(
      () => Container(
        alignment: Alignment.centerRight,
        height: 26,
        padding: EdgeInsets.only(right: 20),
        child: Text(
          '${_controller.text.length}/100',
          style: TextStyle(
            letterSpacing: -0.5,
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: name.value.length < 100
                ? Color(0xBF17132C)
                : Color(0xBFFF2020),
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget _sureBtn() {
    return Obx(
      () => Container(
        width: 168,
        height: 46,
        decoration: BoxDecoration(
          color: name.value.isNotEmpty ? Color(0xFFFD6B39) : Color(0x80FD6B39),
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
        child: CupertinoButton(
          child: Text(
            'Confirm',
            style: TextStyle(
              letterSpacing: -0.5,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: name.value.isNotEmpty
                  ? Color(0xFFEFEFEF)
                  : Color(0x80EFEFEF),
            ),
          ),
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              var isEx = false;
              for (VideoData m in DataTool.instance.items) {
                if (m.name == _controller.text) {
                  isEx = true;
                  break;
                }
              }
              if (isEx) {
                ToastTool.show(
                  message: 'The file name already exists!',
                  type: ToastType.fail,
                );
              } else {
                widget.model.name = _controller.text;
                DataTool.instance.updateVideoData(widget.model);
                ToastTool.show(message: "Rename successfully!");
                Get.back();
              }
            }
          },
        ),
      ),
    );
  }
}
