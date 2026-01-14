import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../generated/assets.dart';

enum ToastType { none, success, fail }

class ToastTool {
  static void show({
    required String message,
    ToastPosition position = ToastPosition.center,
    ToastType type = ToastType.none,
    Color textColor = Colors.white,
    double fontSize = 14,
    double radius = 18,
    Color bgColor = const Color(0xFF595959),
    Duration duration = const Duration(seconds: 2),
  }) {
    showToastWidget(
      dismissOtherToast: true,
      handleTouch: true,
      FractionallySizedBox(
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 310), // 设置最大宽度为310
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.all(Radius.circular(radius)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: type != ToastType.none,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          type == ToastType.success
                              ? Assets.iconSuccessToast
                              : Assets.iconFailToast,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
