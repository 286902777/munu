import 'dart:convert';
import 'dart:typed_data';

VideoData VideoDataFromJson(String str) => VideoData.fromJson(json.decode(str));

String VideoDataToJson(VideoData data) => json.encode(data.toJson());

class VideoData {
  int? vId;
  String movieId;
  String name;
  String size;
  String address;
  String ext;
  int fileType;
  String userId;
  String linkId;
  int platform;
  int netMovie;
  int recommend;
  int fileCount;
  String movieUrl;
  int playTime;
  int totalTime;
  int createDate;
  int updateDate;
  String thumbnail;
  String eMail;
  bool isSelect;
  int isHistory; // 是否看过
  Uint8List? img;

  VideoData({
    this.vId,
    this.movieId = '',
    required this.name,
    this.size = '',
    this.address = '',
    this.ext = 'mp4',
    this.movieUrl = '',
    this.playTime = 0,
    this.totalTime = 0,
    this.createDate = 0,
    this.updateDate = 0,
    this.netMovie = 0,
    this.fileType = 0,
    this.recommend = 0,
    this.platform = 0,
    this.fileCount = 0,
    this.isHistory = 0,
    this.thumbnail = '',
    this.userId = '',
    this.linkId = '',
    this.eMail = '',
    this.isSelect = false,
    this.img,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) => VideoData(
    vId: json["vId"] ?? 0,
    movieId: json["movieId"] ?? '',
    name: json["name"],
    size: json["size"] ?? '',
    playTime: json["playTime"] ?? 0,
    totalTime: json["totalTime"] ?? 0,
    createDate: json["createDate"] ?? 0,
    updateDate: json["updateDate"] ?? 0,
    thumbnail: json["thumbnail"] ?? '',
    netMovie: json["netMovie"] ?? 0,
    address: json["address"] ?? '',
    ext: json["ext"] ?? 'mp4',
    movieUrl: json["movieUrl"] ?? '',
    fileType: json["fileType"] ?? 0,
    recommend: json["recommend"] ?? 0,
    userId: json["userId"] ?? '',
    linkId: json["linkId"] ?? '',
    platform: json["platform"] ?? 0,
    fileCount: json["fileCount"] ?? 0,
    eMail: json["eMail"] ?? '',
    isHistory: json["isHistory"] ?? 0,
    img: base64Decode(json['img']),
  );

  Map<String, dynamic> toJson() => {
    "movieId": movieId,
    "name": name,
    "fileType": fileType,
    "recommend": recommend,
    "userId": userId,
    "linkId": linkId,
    "platform": platform,
    "size": size,
    "address": address,
    "ext": ext,
    "movieUrl": movieUrl,
    "playTime": playTime,
    "fileCount": fileCount,
    "totalTime": totalTime,
    "createDate": createDate,
    "updateDate": updateDate,
    "thumbnail": thumbnail,
    "netMovie": netMovie,
    "eMail": eMail,
    "isHistory": isHistory,
    'img': img == null ? '' : base64Encode(img!),
  };
}
