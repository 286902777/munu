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
          padding: EdgeInsets.only(left: 16, top: 18, right: 16, bottom: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            color: Color(0xFFF5F5F5),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Do you want to erase the history?',
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
                  Expanded(child: _setBottomBtn(false)),
                  SizedBox(width: 23),
                  Expanded(child: _setBottomBtn(true)),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setBottomBtn(bool sure) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: sure ? Color(0xFF136FF9) : Colors.transparent,
        border: Border.all(
          color: Color(0xFF136FF9), // 边框颜色
          width: sure ? 0 : 1, // 边框宽度
          style: BorderStyle.solid, // 边框样式（可选 dashed 等）
        ),
        borderRadius: BorderRadius.circular(19), // 圆角
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          sure ? 'Ok' : 'Cancel',
          style: TextStyle(
            letterSpacing: -0.5,
            fontSize: 14,
            color: sure ? Colors.white : Color(0xFF136FF9),
          ),
        ),
        onPressed: () {
          Get.back(result: sure);
        },
      ),
    );
  }
}
