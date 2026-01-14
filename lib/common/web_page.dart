import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:munu/common/munu_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../generated/assets.dart';

class WebPage extends StatefulWidget {
  final String name;
  final String link;

  const WebPage({super.key, required this.name, required this.link});
  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = WebViewController();
    _controller.loadRequest(Uri.parse(widget.link));
  }

  @override
  Widget build(BuildContext context) {
    return MunuPage(
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: navbar(),
          body: WebViewWidget(controller: _controller),
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
          SizedBox(width: 16),
          CupertinoButton(
            onPressed: () {
              Get.back();
            },
            padding: EdgeInsets.zero,
            child: Image.asset(Assets.iconBack, width: 24),
          ),
        ],
      ),
    );
  }
}
