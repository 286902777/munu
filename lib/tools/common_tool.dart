import 'package:munu/data/premium_data.dart';

class CommonTool {
  static CommonTool instance = CommonTool();

  String disPlayTime(Duration duration) {
    bool isNa = duration.isNegative;
    Duration dur = duration.abs();
    String tow(int n) => n.toString().padLeft(2, '0');
    final h = tow(dur.inHours);
    final m = tow(dur.inMinutes.remainder(60));
    final s = tow(dur.inSeconds.remainder(60));
    if (dur.inHours > 0) {
      return '[${isNa ? '-' : '+'}$h:$m:$s]';
    } else {
      return '[${isNa ? '-' : '+'}$m:$s]';
    }
  }

  String countFile(int size) {
    if (size / 1024 < 1) {
      return '${size}B';
    } else if (size / 1024 < 1024) {
      String fileSize = (size / 1024).toStringAsFixed(2);
      return '${fileSize}KB';
    } else if (size / 1024 / 1024 < 1024) {
      String fileSize = (size / 1024 / 1024).toStringAsFixed(2);
      return '${fileSize}MB';
    } else {
      String fileSize = (size / 1024 / 1024 / 1024).toStringAsFixed(2);
      return '${fileSize}GB';
    }
  }

  String formatHMS(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(duration.inHours);
    final m = two(duration.inMinutes.remainder(60));
    final s = two(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '$h:$m:$s';
    } else {
      return '$m:$s';
    }
  }
}

enum PlatformType {
  india('rafe'), // cashsnap
  middle('demophil'); //quickearn

  final String name;
  const PlatformType(this.name);
}

enum ServiceEventSource {
  // midRecommend('mid_recommend'),
  channelPage('FTJraM'),
  landPage('OvfXt'),
  history('ZNqWnZ'),
  playlistRecommend('eSZ');

  final String name;
  const ServiceEventSource(this.name);
}

enum PlaySource {
  landpage_hot('fdyWPVf'),
  landpage_recently('anUbNrI'),
  landpage_file('KapNYgVGRh'),
  landpage_recommend('dlrTGJWLR'),

  channel_hot('OlOW'),
  channel_recently('okUwBqf'),
  channel_file('NCp'),
  channel_recommend('vzIYHAZBU'),

  playlist_file('RLPrVcBtoe'),
  playlist_recommend('eSZ'),
  import('OxHitn'),
  history('ZNqWnZ');

  final String name;
  const PlaySource(this.name);
}

enum ChannelSource {
  landpage_avtor('HKuowNCZ'),
  landpage_recently('anUbNrI'),
  landpage_recommend('dlrTGJWLR'),
  home_channel('cAAkTNosO'),
  channellist('quWjzgn'),

  channelpage_recommend('ugj'),
  channelpage_avtor('mDpIiYxMtk');

  final String name;
  const ChannelSource(this.name);
}

enum AdmobSource {
  coldOpen('jWt'),
  hotOpen('Lbay'),
  coldPlay('bZaPCb'),
  play('AaqXiyxq'),
  playlistNext('UewDgyuwkk'),
  playback('HaZIAQaXpL'),
  playTen('pwpk'),
  channelPage('FTJraM');

  final String name;
  const AdmobSource(this.name);
}

enum VipProduct {
  weekly('FnOlBz'),
  yearly('VZA'),
  lifetime('KdbK');

  final String value;
  const VipProduct(this.value);
}

enum VipType {
  page('PNvvC'),
  popup('GXCgAyUS');

  final String value;
  const VipType(this.value);
}

enum VipMethod {
  auto('EzTdKrJ'),
  click('HvWJqe');

  final String value;
  const VipMethod(this.value);
}

enum VipSource {
  home('fFSJ'),
  playPage('zPSt'),
  channelPage('FTJraM'),
  landPage('OvfXt'),
  ad('xydBpfeMh'),
  accelerate('UXuLatXmy');

  final String value;
  const VipSource(this.value);
}

VipType vipType = VipType.page;
VipMethod vipMethod = VipMethod.auto;
VipProduct vipProduct = VipProduct.lifetime;
VipSource vipSource = VipSource.home;

PlatformType apiPlatform = PlatformType.india;
ServiceEventSource eventSource = ServiceEventSource.landPage;
PlaySource playSource = PlaySource.landpage_hot;
ChannelSource channelSource = ChannelSource.landpage_avtor;
AdmobSource eventAdsSource = AdmobSource.coldOpen;

String appLinkId = '';
String deepLink = '';
String app_Name = 'Lens';
String app_Bunlde_Id = 'com.lens.videoapp';
bool isFullScreen = false;
bool isDeepComment = false;
String playFileId = '';
bool isDeepLink = false;

bool simResult = false;
bool simulatorResult = false;
bool padResult = false;
bool vpnResult = false;

bool closeDeep = false;
bool isSimCard = false;
bool isEmulator = false;
bool isPad = false;
bool isVpn = false;

bool isSimLimit = false;
bool isEmulatorLimit = false;
bool isPadLimit = false;
bool isVpnLimit = false;

String appTerms = 'https://lensvids.com/terms/';

String appPrivacy = 'https://lensvids.com/privacy/';

String preWeek = 'Lens_week';

String preYear = 'Lens_year';

String preLife = 'Lens_lifetime';

Function()? clickNativeAction;

Function(int index)? clickTabItem;

Function()? pushDeepPageInfo;

Function(PremiumData data, bool isPay)? premiumDoneBlock;
