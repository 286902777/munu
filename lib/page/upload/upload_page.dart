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
          padding: EdgeInsets.only(left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Stack(
                children: [
                  Positioned(
                    left: 0,
                    bottom: 4,
                    child: Image.asset(Assets.iconTitle, width: 40, height: 14),
                  ),
                  Text(
                    'Add Video',
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                      color: Color(0xFF17132C),
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
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 24,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEBF2FE),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          index == 0 ? 'Video' : 'File',
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0C0C0C),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          index == 0
                              ? 'Authorize first, then upload local files.'
                              : 'Import from system folders.',
                          style: const TextStyle(
                            letterSpacing: -0.5,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0x900C0C0C),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Image.asset(
                    index == 0 ? Assets.iconVideoUpload : Assets.iconFileUpload,
                    width: 180,
                    height: 180,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
