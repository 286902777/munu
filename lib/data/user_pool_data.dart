class UserPoolData {
  String id;
  String account;
  String name;
  String email;
  String picture;
  int updateDate;
  int platform;
  int recommend;
  List<UserLabel> labels;
  String telegramUrl;
  String bannerPictureUrl;
  String telegramAddress;

  UserPoolData({
    required this.id,
    required this.account,
    required this.name,
    required this.bannerPictureUrl,
    required this.telegramAddress,
    required this.email,
    required this.picture,
    required this.labels,
    required this.telegramUrl,
    this.updateDate = 0,
    this.platform = 0,
    this.recommend = 0,
  });

  factory UserPoolData.fromJson(Map<String, dynamic> json) => UserPoolData(
    id: json["id"] ?? '',
    account: json["account"] ?? '',
    name: json["name"] ?? '',
    telegramUrl: json["telegramUrl"] ?? '',
    bannerPictureUrl: json["bannerPictureUrl"] ?? '',
    telegramAddress: json["telegramAddress"] ?? '',
    email: json["email"] ?? '',
    picture: json["picture"] ?? '',
    labels: List<UserLabel>.from(
      json["labels"].map((x) => UserLabel.fromJson(x)),
    ),

    updateDate: json["updateDate"] ?? 0,
    platform: json["platform"] ?? 0,
    recommend: json["recommend"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "account": account,
    "name": name,
    "telegramAddress": telegramAddress,
    "updateDate": updateDate,
    "platform": platform,
    "email": email,
    "picture": picture,
    "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
    "telegramUrl": telegramUrl,
    "bannerPictureUrl": bannerPictureUrl,
    "recommend": recommend,
  };
}

class UserLabel {
  String id;
  String labelName;
  String secondLabelCode;
  String firstLabelCode;

  UserLabel({
    required this.id,
    required this.firstLabelCode,
    required this.secondLabelCode,
    required this.labelName,
  });

  factory UserLabel.fromJson(Map<String, dynamic> json) => UserLabel(
    secondLabelCode: json["second_label_code"] ?? '',
    id: json["id"] ?? '',
    labelName: json["label_name"] ?? '',
    firstLabelCode: json["first_label_code"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_label_code": firstLabelCode,
    "second_label_code": secondLabelCode,
    "label_name": labelName,
  };
}
