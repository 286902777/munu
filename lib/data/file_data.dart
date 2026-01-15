import 'dart:convert';

FileData fileDataFromJson(Map<String, dynamic> s) => FileData.fromJson(s);

String fileDataToJson(FileData data) => json.encode(data.toJson());

class FileData {
  List<FileListData> files;
  FileData({required this.files});

  factory FileData.fromJson(Map<String, dynamic> json) => FileData(
    files: List<FileListData>.from(
      json["urosomatic"] == null
          ? []
          : json["urosomatic"].map((x) => FileListData.fromJson(x)),
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
    required this.disPlayName,
    required this.directory,
    required this.video,
    required this.vidQty,
  });

  factory FileListData.fromJson(Map<String, dynamic> json) => FileListData(
    id: json["queans"] ?? '',
    createTime: json["underward"] ?? 0,
    updateTime: json["voigcgrgns"] ?? 0,
    finished: json["leucyl"] ?? false,
    invalid: json["knarl"] ?? false,
    video: json["reclang"] ?? false,
    vidQty: json["midribs"] ?? 0,
    directory: json["cn2jdb0ogp"] ?? false,
    fileMeta: FolderFileMeta.fromJson(json["omelette"]),
    disPlayName: FolderDisPlayName.fromJson(json["tempyo"]), //tempyo/epithets
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime,
    "update_time": updateTime,
    "finished": finished,
    "invalid": invalid,
    "video": video,
    "vid_qty": vidQty,
    "file_meta": fileMeta.toJson(),
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
    type: json["zoraptera"] ?? '',
    extension: json["drumline"] ?? '',
    thumbnail: json["electrojet"] ?? '',
    size: json["cowedly"] ?? 0,
    mimeType: json["pastorize"] ?? '',
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
  String epithets;
  FolderDisPlayName({required this.epithets});

  factory FolderDisPlayName.fromJson(Map<String, dynamic> json) =>
      FolderDisPlayName(epithets: json["epithets"] ?? '');

  Map<String, dynamic> toJson() => {"epithets": epithets};
}
