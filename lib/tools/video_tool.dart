import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:munu/tools/toast_tool.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../common/db_tool.dart';
import '../data/video_data.dart';

class VideoTool {
  static final VideoTool instance = VideoTool();
  Future<Duration> countVideoDuration(String path) async {
    final player = Player();
    bool isCompleted = false;
    StreamSubscription? subscription;
    Timer? timeoutTimer;

    Future<Duration> completer() async {
      final completer = Completer<Duration>();
      subscription = player.stream.duration.listen(
        (Duration duration) {
          if (!isCompleted && duration != Duration.zero) {
            isCompleted = true;
            completer.complete(duration);
            _cleanup(subscription, timeoutTimer, player);
          }
        },
        onError: (error) {
          if (!isCompleted) {
            isCompleted = true;
            completer.completeError(error);
            _cleanup(subscription, timeoutTimer, player);
          }
        },
      );

      // 超时处理
      timeoutTimer = Timer(Duration(seconds: 10), () {
        if (!isCompleted) {
          isCompleted = true;
          completer.completeError(TimeoutException('获取视频时长超时'));
          _cleanup(subscription, timeoutTimer, player);
        }
      });

      return completer.future;
    }

    try {
      await player.open(Media(path));
      return await completer();
    } catch (e) {
      if (!isCompleted) {
        isCompleted = true;
        _cleanup(subscription, timeoutTimer, player);
      }
      rethrow;
    }
  }

  void _cleanup(StreamSubscription? subscription, Timer? timer, Player player) {
    subscription?.cancel();
    timer?.cancel();
    player.dispose();
  }

  void openPage(bool photo) async {
    ImagePicker picker = ImagePicker();
    if (photo) {
      var video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null && video.path.isNotEmpty) {
        var imageThumb = await getThumbnail(video.path);
        var size = await countVideoSize(video.path);
        var total = await countVideoDuration(video.path);
        if (imageThumb != null) {
          final result = await _saveVideo(File(video.path));
          if (result != null) {
            VideoData model = VideoData(
              name: video.name,
              img: imageThumb,
              address: result,
              ext: result.split('.').last,
              createDate: DateTime.now().millisecondsSinceEpoch,
              totalTime: total.inSeconds.toInt(),
              size: size,
            );
            DataTool.instance.insertVideoData(model);
          }
        }
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.path != null) {
          var thumbnail = await getThumbnail(file.path!);
          var total = await countVideoDuration(file.path!);
          if (thumbnail != null) {
            final saveResult = await _saveVideo(File(file.path!));
            if (saveResult != null) {
              VideoData model = VideoData(
                name: file.name,
                img: thumbnail,
                address: saveResult,
                ext: saveResult.split('.').last,
                createDate: DateTime.now().millisecondsSinceEpoch,
                totalTime: total.inSeconds.toInt(),
                size: _subFileSize(file.size),
              );
              DataTool.instance.insertVideoData(model);
            }
          }
        }
      }
    }
  }

  Future<String> countVideoSize(String path) async {
    final file = File(path);
    final size = await file.length();
    return _subFileSize(size);
  }

  Future<Uint8List?> getThumbnail(String path) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 200, // 缩略图宽度
      quality: 75, // 质量（0-100）
    );
    return thumbnail;
  }

  // 格式化文件大小（如 12.3 MB）
  String _subFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    final kb = (bytes / 1024).toInt();
    if (kb < 1024) return '${kb.toStringAsFixed(0)}K';
    final mb = (kb / 1024).toInt();
    if (mb < 1024) return '${mb.toStringAsFixed(0)}M';
    final gb = (mb / 1024).toInt();
    return '${gb.toStringAsFixed(0)}G';
  }

  Future<String?> _saveVideo(File video) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final url = video.uri.pathSegments.last;
      final path = File('${dir.path}/videos/$url');
      if (!path.existsSync()) {
        path.createSync(recursive: true);
        path.writeAsBytesSync(video.readAsBytesSync());
        return url;
      } else {
        ToastTool.show(message: 'File already exists!', type: ToastType.fail);
        return null;
      }
    } catch (e) {
      ToastTool.show(message: 'Save failed', type: ToastType.fail);
      return null;
    }
  }
}
