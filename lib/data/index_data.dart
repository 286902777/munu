import 'dart:convert';

class FileMeta {
  String type;
  String mimeType;
  String extension;
  String thumbnail;
  int size;

  FileMeta({
    required this.type,
    required this.size,
    required this.extension,
    required this.thumbnail,
    required this.mimeType,
  });

  factory FileMeta.fromJson(Map<String, dynamic> json) => FileMeta(
    type: json["pidgized"] ?? '',
    size: json["fardo"] ?? 0,
    thumbnail: json["dragading"] ?? '',
    mimeType: json["ktwzgwpij6"] ?? '',
    extension: json["shitepoke"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "size": size,
    "mime_type": mimeType,
    "extension": extension,
    "thumbnail": thumbnail,
  };
}

class DisPlayName {
  String saponary;
  DisPlayName({required this.saponary});

  factory DisPlayName.fromJson(Map<String, dynamic> json) =>
      DisPlayName(saponary: json["saponary"] ?? '');

  Map<String, dynamic> toJson() => {"saponary": saponary};
}

class Namespace {
  UnscienceData unscience;
  Namespace({required this.unscience});
  // /
  factory Namespace.fromJson(Map<String, dynamic> json) =>
      Namespace(unscience: UnscienceData.fromJson(json["unscience"]));

  Map<String, dynamic> toJson() => {"unscience": unscience.toJson()};
}

class UnscienceData {
  ScumbledData scumbled;
  UnscienceData({required this.scumbled});

  factory UnscienceData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UnscienceData(scumbled: ScumbledData.fromJson({}));
    }
    return UnscienceData(scumbled: ScumbledData.fromJson(json["scumbled"]));
  }

  Map<String, dynamic> toJson() => {"scumbled": scumbled.toJson()};
}

class ScumbledData {
  String id;
  String name;
  Tenant tenant;
  int createTime;

  ScumbledData({
    required this.id,
    required this.tenant,
    required this.createTime,
    required this.name,
  });

  factory ScumbledData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ScumbledData(
        id: '',
        createTime: 0,
        name: '',
        tenant: Tenant.fromJson({}),
      );
    }
    return ScumbledData(
      id: json["firking"] ?? '',
      createTime: json["tensify"] ?? 0,
      name: json["pitchpoll"] ?? '',
      tenant: Tenant.fromJson(json["ratz0rrjis"]),
    );
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime,
    "name": name,
    "tenant": tenant.toJson(),
  };
}

class Tenant {
  String id;
  int createTime;
  String name;
  String accessId;

  Tenant({
    required this.id,
    required this.accessId,
    required this.createTime,
    required this.name,
  });

  factory Tenant.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Tenant(id: '', createTime: 0, name: '', accessId: '');
    }
    return Tenant(
      id: json["firking"] ?? '',
      createTime: json["tensify"] ?? 0,
      name: json["pitchpoll"] ?? '',
      accessId: json["horsepipe"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime,
    "name": name,
    "access_id": accessId,
  };
}

class User {
  String id;
  String account;
  String name;
  String email;
  String picture;
  List<Label> labels;

  User({
    required this.id,
    required this.account,
    required this.name,
    required this.email,
    required this.picture,
    required this.labels,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["firking"] ?? '',
    account: json["8_f6e2bnkd"] ?? '',
    name: json["pitchpoll"] ?? '',

    labels: List<Label>.from(json["wrappers"].map((x) => Label.fromJson(x))),
    email: json["trisula"] ?? '',
    picture: json["bullhorn"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "picture": picture,
    "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
    "account": account,
    "name": name,
    "email": email,
  };
}

class Label {
  String id;
  String firstLabelCode;
  String secondLabelCode;
  String labelName;

  Label({
    required this.id,

    required this.secondLabelCode,
    required this.labelName,
    required this.firstLabelCode,
  });

  factory Label.fromJson(Map<String, dynamic> json) => Label(
    id: json["firking"] ?? '',
    firstLabelCode: json["madoc"] ?? '',
    secondLabelCode: json["deckles"] ?? '',
    labelName: json["doles"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "second_label_code": secondLabelCode,
    "label_name": labelName,
    "first_label_code": firstLabelCode,
  };
}

HomeData homeDataFromJson(Map<String, dynamic> s) => HomeData.fromJson(s);

String homeDataToJson(HomeData data) => json.encode(data.toJson());

class HomeData {
  User? user;
  List<HomeListData> files;
  List<HomeListData> recent;
  List<HomeListData> top;

  HomeData({
    required this.recent,
    required this.top,
    required this.files,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
    "recent": List<dynamic>.from(recent.map((x) => x.toJson())),
    "files": List<dynamic>.from(files.map((x) => x.toJson())),
    "user": user?.toJson(),
    "top": List<dynamic>.from(top.map((x) => x.toJson())),
  };

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    files: List<HomeListData>.from(
      json["rockling"] != null
          ? json["rockling"].map((x) => HomeListData.fromJson(x))
          : [],
    ),
    user: json["soloists"] != null ? User.fromJson(json["soloists"]) : null,
    top: List<HomeListData>.from(
      json["ueqrksvnkl"] != null
          ? json["ueqrksvnkl"].map((x) => HomeListData.fromJson(x))
          : [],
    ),
    recent: List<HomeListData>.from(
      json["vents"] != null
          ? json["vents"].map((x) => HomeListData.fromJson(x))
          : [],
    ),
  );
}

class HomeListData {
  String id;
  int createTime;
  FileMeta fileMeta;
  Namespace namespace;
  DisPlayName disPlayName;
  int vidQty;
  int updateTime;
  bool finished;
  bool invalid;
  bool directory;
  bool video;

  HomeListData({
    required this.id,
    required this.video,
    required this.fileMeta,
    required this.namespace,
    required this.disPlayName,
    required this.invalid,
    required this.directory,
    required this.createTime,
    required this.updateTime,
    required this.finished,
    required this.vidQty,
  });

  factory HomeListData.fromJson(Map<String, dynamic> json) => HomeListData(
    id: json["firking"] ?? '',
    finished: json["iqcaergv4g"] ?? false,
    updateTime: json["safari"] ?? 0,
    fileMeta: FileMeta.fromJson(json["fishier"]),
    namespace: Namespace.fromJson(json["aglaia"]), //aglaia/unscience/scumbled
    createTime: json["tensify"] ?? 0,
    disPlayName: DisPlayName.fromJson(json["prickers"]), //prickers/saponary
    directory: json["strums"] ?? false,
    video: json["dipware"] ?? false,
    vidQty: json["overbade"] ?? 0,
    invalid: json["sandust"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "file_meta": fileMeta.toJson(),
    "namespace": namespace.toJson(),
    "disPlayName": disPlayName.toJson(),
    "invalid": invalid,
    "vid_qty": vidQty,
    "create_time": createTime,
    "update_time": updateTime,
    "finished": finished,
  };
}
