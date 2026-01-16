import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../generated/assets.dart';

class PremiumFailPage extends StatefulWidget {
  const PremiumFailPage({super.key});

  @override
  State<PremiumFailPage> createState() => _PremiumFailPageState();
}

class _PremiumFailPageState extends State<PremiumFailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Color(0xA6000000),
      child: Container(
        width: 218,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [Color(0xFFFDF1EB), Color(0xFFFFFEFC)], // 颜色数组
            begin: Alignment.topCenter, // 渐变起点
            end: Alignment.bottomCenter, // 渐变终点
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Image.asset(Assets.iconFailToast, width: 20, height: 20),
            SizedBox(height: 16),
            Text(
              'Failure to pay',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF141414),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
