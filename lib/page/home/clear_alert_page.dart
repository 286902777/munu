import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClearAlertPage extends StatelessWidget {
  const ClearAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28),
          height: 190,
          padding: EdgeInsets.all(18),
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
              Expanded(
                child: Center(
                  child: Text(
                    'Would you like to delete the history records?',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF17132C),
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: addAction(false)),
                  SizedBox(width: 20),
                  Expanded(child: addAction(true)),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget addAction(bool sure) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: sure ? Color(0xFFFD6B39) : Colors.transparent,
        border: Border.all(
          color: Color(0xFFFD6B39), // 边框颜色
          width: sure ? 0 : 1, // 边框宽度
          style: BorderStyle.solid, // 边框样式（可选 dashed 等）
        ),
        borderRadius: BorderRadius.circular(21), // 圆角
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          sure ? 'Confirm' : 'Cancel',
          style: TextStyle(
            letterSpacing: -0.5,
            fontSize: 14,
            color: sure ? Colors.white : Color(0xFFFD6B39),
          ),
        ),
        onPressed: () {
          Get.back(result: sure);
        },
      ),
    );
  }
}
