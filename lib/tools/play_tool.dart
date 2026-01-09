import 'package:get/get.dart';

import '../data/video_data.dart';
import '../page/video/video_page.dart';
import 'common_tool.dart';

class PlayTool {
  static pushPage(VideoData model, List<VideoData> lists, bool recommend) {
    Get.to(() => VideoPage(data: model, playList: lists))?.then((result) {
      if (result != null) {
        vipSource = VipSource.ad;
        showResult(result);
      }
    });
  }

  static showResult(bool result) async {
    //   bool isSVip = await AppKey.getBool(AppKey.isVipUser) ?? false;
    //   if (result && isSVip == false) {
    //     int? showCount = await AppKey.getInt(AppKey.vipAlertShowCount);
    //     if ((showCount ?? 0) < 3) {
    //       int? time = await AppKey.getInt(AppKey.vipAlertTime);
    //       if (time != null && time > 0) {
    //         DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
    //         final day = Duration(days: 1);
    //         if (DateTime.now().difference(date).abs() <= day) {
    //           return;
    //         }
    //       }
    //       int? playTime = await AppKey.getInt(AppKey.vipAlertPlayTime);
    //       if (playTime != null && playTime > 0) {
    //         DateTime hoursDate = DateTime.fromMillisecondsSinceEpoch(playTime);
    //         final hours = Duration(hours: 1);
    //         if (DateTime.now().difference(hoursDate).abs() <= hours) {
    //           return;
    //         }
    //       }
    //
    //       await AppKey.save(
    //         AppKey.vipAlertTime,
    //         DateTime.now().millisecondsSinceEpoch.toInt(),
    //       );
    //       await AppKey.save(AppKey.vipAlertShowCount, (showCount ?? 0) + 1);
    //       vipMethod = VipMethod.auto;
    //       Get.to(() => UserVipPage());
    //     }
    //   }
  }
}
