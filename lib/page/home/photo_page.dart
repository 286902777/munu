import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munu/common/munu_page.dart';

import '../../data/video_data.dart';
import '../../generated/assets.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.data});
  final VideoData data;

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  @override
  Widget build(BuildContext context) {
    return MunuPage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: CachedNetworkImage(
            imageUrl: widget.data.thumbnail,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(),
            errorWidget: (context, url, error) => Container(),
          ),
        ),
      ),
    );
  }

  AppBar navbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 12),
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.iconBack, width: 32),
          ),
        ],
      ),
      title: Text(widget.data.name, textAlign: TextAlign.center),
      titleTextStyle: const TextStyle(
        letterSpacing: -0.5,
        fontSize: 16,
        color: Color(0xFF03011A),
      ),
    );
  }
}
