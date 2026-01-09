enum PlatformType {
  india('a'), // cashsnap
  east('b'); //quickearn

  final String name;
  const PlatformType(this.name);
}

enum ServiceEventSource {
  // midRecommend('mid_recommend'),
  channelPage('d'),
  landPage('c'),
  history('sf'),
  playlistRecommend('bx');

  final String name;
  const ServiceEventSource(this.name);
}

enum PlaySource {
  landpage_hot('sd'),
  landpage_recently('sfr'),
  landpage_file('bx'),
  landpage_recommend('ser'),

  channel_hot('fmjBy'),
  channel_recently('uuv'),
  channel_file('bc'),
  channel_recommend('bxbd'),

  playlist_file('xerzx'),
  playlist_recommend('elSsM'),
  import('bweta'),
  history('123x34');

  final String name;
  const PlaySource(this.name);
}

enum ChannelSource {
  landpage_avtor('bs'),
  landpage_recently('xd'),
  landpage_recommend('gsa'),
  home_channel('bxds '),
  channellist('asd'),

  channelpage_recommend('bsar'),
  channelpage_avtor('bxer');

  final String name;
  const ChannelSource(this.name);
}

enum AdmobSource {
  coldOpen('a'),
  hotOpen('b'),
  coldPlay('c'),
  play('d'),
  playlistNext('e'),
  playback('xsd'),
  playTen('f'),
  channelPage('sfa');

  final String name;
  const AdmobSource(this.name);
}

enum VipProduct {
  weekly('bs'),
  yearly('sdf'),
  lifetime('bxa');

  final String value;
  const VipProduct(this.value);
}

enum VipType {
  page('bawe'),
  popup('tes');

  final String value;
  const VipType(this.value);
}

enum VipMethod {
  auto('xb'),
  click('te');

  final String value;
  const VipMethod(this.value);
}

enum VipSource {
  home('bx'),
  playPage('sgs'),
  channelPage('ax'),
  landPage('he'),
  ad('jf'),
  accelerate('ur');

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
String app_Name = 'Test';
String app_Bunlde_Id = 'com.am';
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

Function()? clickNativeAction;

Function(int index)? clickTabItem;

Function()? pushDeepPageInfo;

// Function(VipData mod, bool isPay)? vipDoneBlock;

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
