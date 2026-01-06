import 'package:flutter/material.dart';

class MunuPage extends StatelessWidget {
  final Widget child;
  const MunuPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('image/icon/munu_bg.webp'),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}
