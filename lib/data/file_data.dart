import 'dart:convert';

FileData fileDataFromJson(Map<String, dynamic> s) => FileData.fromJson(s);

String fileDataToJson(FileData data) => json.encode(data.toJson());

class FileData {
  List<FileListData> files;
  FileData({required this.files});

  factory FileData.fromJson(Map<String, dynamic> json) => FileData(
    files: List<FileListData>.from(
      json["pastor"] != null
          ? json["pastor"].map((x) => FileListData.fromJson(x))
          : [],
    ),
  );

  Map<String, dynamic> toJson() => {
    "files": List<dynamic>.from(files.map((x) => x.toJson())),
  };
}

class FileListData {
  String id;
  int createTime;
  int updateTime;
  FolderFileMeta fileMeta;
  FolderNamespace namespace;
  FolderDisPlayName disPlayName;
  bool finished;
  bool invalid;
  bool directory;
  bool video;
  int vidQty;

  FileListData({
    required this.id,
    required this.createTime,
    required this.updateTime,
    required this.finished,
    required this.invalid,
    required this.fileMeta,
    required this.namespace,
    required this.disPlayName,
    required this.directory,
    required this.video,
    required this.vidQty,
  });

  factory FileListData.fromJson(Map<String, dynamic> json) => FileListData(
    id: json["q6cs2hkmtg"] ?? '',
    createTime: json["myoprotein"] ?? 0,
    updateTime: json["wolfhounds"] ?? 0,
    video: json["doctrinist"] ?? false,
    vidQty: json["waxings"] ?? 0,
    finished: json["dalesman"] ?? false,
    invalid: json["metif"] ?? false,
    directory: json["morgan"] ?? false,
    fileMeta: FolderFileMeta.fromJson(json["akey"]),
    namespace: FolderNamespace.fromJson(
      json["immense"],
    ), //tlvv7erulh/territelae
    disPlayName: FolderDisPlayName.fromJson(json["sodomy"]), //fiberizes/uncanny
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime,
    "update_time": updateTime,
    "finished": finished,
    "invalid": invalid,
    "vid_qty": vidQty,
    "file_meta": fileMeta.toJson(),
    "namespace": namespace.toJson(),
    "disPlayName": disPlayName.toJson(),
  };
}

class FolderFileMeta {
  String mimeType;
  String extension;
  String type;
  int size;
  String thumbnail;

  FolderFileMeta({
    required this.size,
    required this.mimeType,
    required this.type,
    required this.extension,
    required this.thumbnail,
  });

  factory FolderFileMeta.fromJson(Map<String, dynamic> json) => FolderFileMeta(
    type: json["abubble"] ?? '',
    extension: json["u"] ?? '',
    thumbnail: json["byronics"] ?? '',
    size: json["jabot"] ?? 0,
    mimeType: json["oxtail"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "extension": extension,
    "thumbnail": thumbnail,
    "size": size,
    "mime_type": mimeType,
  };
}

class FolderDisPlayName {
  String ritchey;
  FolderDisPlayName({required this.ritchey});

  factory FolderDisPlayName.fromJson(Map<String, dynamic> json) =>
      FolderDisPlayName(ritchey: json["ritchey"] ?? '');

  Map<String, dynamic> toJson() => {"ritchey": ritchey};
}

class FolderNamespace {
  Teachers teachers;
  FolderNamespace({required this.teachers});

  factory FolderNamespace.fromJson(Map<String, dynamic> json) =>
      FolderNamespace(teachers: Teachers.fromJson(json["teachers"]));

  Map<String, dynamic> toJson() => {"teachers": teachers.toJson()};
}

class Inducts {
  String id;
  int createTime;
  String name;

  Inducts({required this.id, required this.createTime, required this.name});

  factory Inducts.fromJson(Map<String, dynamic> json) => Inducts(
    id: json["q6cs2hkmtg"] ?? '',
    createTime: json["myoprotein"] ?? 0,
    name: json["fewer"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime,
    "name": name,
  };
}

class Teachers {
  Inducts inducts;
  int createTime;
  String name;
  String id;

  Teachers({
    required this.inducts,
    required this.createTime,
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    "inducts": inducts.toJson(),
    "id": id,
    "create_time": createTime,
    "name": name,
  };
  factory Teachers.fromJson(Map<String, dynamic> json) => Teachers(
    inducts: Inducts.fromJson(json["inducts"]),
    id: json["q6cs2hkmtg"] ?? '',
    createTime: json["myoprotein"] ?? 0,
    name: json["fewer"] ?? '',
  );
}
