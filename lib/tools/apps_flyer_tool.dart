import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import '../keys/app_key.dart';
import 'common_tool.dart';
import 'event_tool.dart';

class AppsFlyerTool {
  static AppsFlyerTool instance = AppsFlyerTool();

  final AppsFlyerOptions iosOptions = AppsFlyerOptions(
    afDevKey: 'LGCq2ac2vattczm2ZW3JEa',
    appId: '6758001383',
    showDebug: true,
    timeToWaitForATTUserAuthorization: 15,
    manualStart: true,
  );

  Future<void> addConfig() async {
    late AppsflyerSdk _afSdk = AppsflyerSdk(iosOptions);
    // Deep linking callback
    _afSdk.onDeepLinking((DeepLinkResult dp) async {
      switch (dp.status) {
        case Status.FOUND:
          print(dp.deepLink?.deepLinkValue);
          String? link = dp.deepLink?.deepLinkValue;
          isDeepLink = dp.deepLink?.isDeferred ?? false;
          if (link != null) {
            await readDeepInfo(link);
          }
          break;
        case Status.NOT_FOUND:
          print("deep link not found");
          break;
        case Status.ERROR:
          print("deep link error: ${dp.error}");
          break;
        case Status.PARSE_ERROR:
          print("deep link status parsing error");
          break;
      }
    });

    // Init of AppsFlyer SDK
    await _afSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _afSdk.startSDK(
      onSuccess: () {
        print("onSuccess");
      },
      onError: (code, msg) {
        print("d error");
      },
    );
  }

  Future<void> readDeepInfo(String info) async {
    Uri uri = Uri.parse(info);
    Map<String, String> para = uri.queryParameters;
    String? linkId = para['madhouses'];
    if (linkId != null && linkId.isNotEmpty) {
      deepLink = linkId;
      appLinkId = linkId;
      await AppKey.save(AppKey.appLinkId, linkId);
    }
    String? plat = para['ryw4cypoum'];
    if (plat == PlatformType.india.name) {
      apiPlatform = PlatformType.india;
    } else {
      apiPlatform = PlatformType.middle;
    }
    await AppKey.save(AppKey.appPlatform, plat);
    bool isFirst = await AppKey.getBool('getDeepLink') ?? false;
    EventTool.instance.eventUpload(EventApi.deeplinkOpen, {
      EventParaName.linkSource.name: isDeepLink
          ? EventParaValue.delayLink.value
          : EventParaValue.link.value,
      EventParaName.isFirstLink.name: isFirst,
    });
    pushDeepPageInfo?.call();
  }
}
