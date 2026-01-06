import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkTool {
  static NetworkTool instance = NetworkTool();

  bool netStatus = false;

  void networkStatus() {
    Connectivity().onConnectivityChanged.listen((result) {
      netStatus = result.first != ConnectivityResult.none;
    });
  }
}
