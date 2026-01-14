import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:munu/common/db_tool.dart';
import 'package:munu/common/launch_page.dart';
import 'package:munu/tools/event_tool.dart';
import 'package:munu/tools/fire_base_tool.dart';
import 'package:munu/tools/network_tool.dart';
import 'package:munu/tools/track_tool.dart';
import 'package:oktoast/oktoast.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final RouteObserver<PageRoute> routeObserver = RouteObserver();

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  Get.put(DataTool());
  TrackTool.instance.config();
  NetworkTool.instance.networkStatus();
  await FireBaseTool.instance.addConfig();
  await EventTool.instance.loadLocalConfig();
  EventTool.instance.postApiEvent();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        title: '',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          appBarTheme: AppBarTheme(
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
              //安卓底部系统导航条
              systemNavigationBarColor: Colors.transparent,
              //安卓底部系统导航条
              systemNavigationBarIconBrightness: Brightness.light,
            ), // 状态栏字体颜色（dark: 白色，light: 黑色）
            backgroundColor: Colors.white,
          ),
        ),
        home: LaunchPage(),
        builder: EasyLoading.init(),
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
