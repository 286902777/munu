import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';

class TrackTool {
  static TrackTool instance = TrackTool();

  Future<void> config() async {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      await AppTrackingTransparency.requestTrackingAuthorization();
    });
  }
}
