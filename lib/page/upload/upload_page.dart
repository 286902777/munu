import 'package:flutter/material.dart';
import 'package:munu/common/munu_page.dart';
import 'package:munu/tools/video_tool.dart';

import '../../generated/assets.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin, RouteAware {
  @override
  bool get wantKeepAlive => true;

  @override
  void didPopNext() {}

  @override
  void didPushNext() {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MunuPage(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Row(
                children: [
                  Image.asset(Assets.iconTitle, width: 20, height: 20),
                  SizedBox(width: 6),
                  Text(
                    'Upload Video',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Color(0xFF141414),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
              SizedBox(height: 12),
              _contentView(0),
              SizedBox(height: 18),
              _contentView(1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentView(int index) {
    return InkWell(
      onTap: () async {
        if (index == 0) {
          VideoTool.instance.openPage(index == 0);
        } else {
          VideoTool.instance.openPage(index == 0);
        }
      },
      child: Container(
        height: 156,
        decoration: BoxDecoration(
          color: Color(0xFFFFEDE8),
          borderRadius: BorderRadius.all(Radius.circular(36)),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 22,
              top: 24,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  index == 0 ? Assets.iconVideoUpload : Assets.iconFileUpload,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            Positioned(
              left: 92,
              top: 41,
              child: Text(
                index == 0 ? 'Video' : 'File',
                style: const TextStyle(
                  letterSpacing: -0.5,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0C0C0C),
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 90,
              right: 130,
              child: Text(
                index == 0
                    ? 'Upload local files upon authorization.'
                    : 'Import from system files.',
                style: const TextStyle(
                  letterSpacing: -0.5,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0x900C0C0C),
                ),
                maxLines: 3,
              ),
            ),
            Positioned(
              right: 24,
              bottom: 28,
              child: Container(
                width: 82,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Import',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFD6B39),
                      ),
                    ),
                    SizedBox(width: 6),
                    Image.asset(Assets.iconUploadArrow, width: 12, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
