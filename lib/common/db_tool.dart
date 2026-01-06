import 'dart:convert';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data/user_pool_data.dart';
import '../data/video_data.dart';

class DbTool extends GetxService {
  static const _dataName = 'app_data.db';
  static const _version = 1;
  static const table = 'data_tb';
  static const user_table = 'user_tb';

  DbTool._privateConstructor();
  static final DbTool instance = DbTool._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  @override
  void onClose() {
    // 关闭数据库连接
    super.onClose();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dataName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          // 执行新增表操作
          await db.execute('''
        CREATE TABLE $user_table (
        kId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        platform INTEGER,
        updateDate INTEGER,
        info TEXT
        )
        ''');
        }
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        vId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        movieId TEXT,
        address TEXT,
        size TEXT,
        ext TEXT,
        movieUrl TEXT,
        img BLOB,
        thumbnail TEXT,
        playTime INTEGER,
        totalTime INTEGER,
        createDate INTEGER,
        updateDate INTEGER,
        fileCount INTEGER, 
        netMovie INTEGER,
        recommend INTEGER,
        fileType INTEGER,
        platform INTEGER,
        isHistory INTEGER,
        userId TEXT,
        linkId TEXT,
        eMail TEXT
      )
    ''');
    await db.execute('''
        CREATE TABLE $user_table (
        kId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        platform INTEGER,
        updateDate INTEGER,
        info TEXT
        )
        ''');
  }

  // CRUD操作
  Future<int> insertData(VideoData model) async {
    final db = await instance.database;
    model.updateDate = DateTime.now().millisecondsSinceEpoch;
    return await db.insert(table, model.toJson());
  }

  Future<int> updateData(VideoData model) async {
    model.updateDate = DateTime.now().millisecondsSinceEpoch;
    final db = await instance.database;
    if (model.netMovie == 0) {
      return await db.update(
        table,
        model.toJson(),
        where: 'vId = ?',
        whereArgs: [model.vId],
      );
    } else {
      return await db.update(
        table,
        model.toJson(),
        where: 'movieId = ?',
        whereArgs: [model.movieId],
      );
    }
  }

  Future<int> deleteData(VideoData model) async {
    final db = await instance.database;
    if (model.netMovie == 0) {
      return await db.delete(table, where: 'vId = ?', whereArgs: [model.vId]);
    } else {
      return await db.delete(
        table,
        where: 'movieId = ?',
        whereArgs: [model.movieId],
      );
    }
  }

  Future<List<VideoData>> getAllDatas() async {
    final db = await instance.database;
    final maps = await db.query(table);
    List<VideoData> items = maps.map((map) => VideoData.fromJson(map)).toList();
    items.sort((a, b) => (b.createDate ?? 0).compareTo(a.createDate ?? 0));
    return items;
  }

  // user_table
  Future<int> insertUser(
    String userId,
    int platform,
    int time,
    String info,
  ) async {
    final db = await instance.database;
    return await db.insert(user_table, {
      'userId': userId,
      'platform': platform,
      'updateDate': time,
      'info': info,
    });
  }

  Future updateUser(String userId, int platform, String info) async {
    final db = await instance.database;
    final users = await getPlatformUser(platform);
    int time = DateTime.now().millisecondsSinceEpoch;

    bool exist = users.any((user) => user['userId'] == userId);
    if (exist) {
      await db.update(
        user_table,
        {
          'userId': userId,
          'platform': platform,
          'updateDate': time,
          'info': info,
        },
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } else {
      insertUser(userId, platform, time, info);
    }
    DataTool.instance.loadUsers();
  }

  Future<List<Map<String, dynamic>>> getPlatformUser(int platform) async {
    final db = await instance.database;
    final maps = await db.query(user_table);
    return maps.where((user) => user['platform'] == platform).toList();
  }

  Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await instance.database;
    final maps = await db.query(user_table);
    List<Map<String, dynamic>> userArr = maps.toList();
    userArr.sort(
      (a, b) => (b['updateDate'] ?? 0).compareTo(a['updateDate'] ?? 0),
    );
    return userArr;
  }
}

class DataTool extends GetxController {
  static DataTool instance = Get.find();
  RxList<VideoData> items = <VideoData>[].obs;
  RxList<VideoData> historyItems = <VideoData>[].obs;
  RxList<UserPoolData> users = <UserPoolData>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await loadVideoDatas(); // 初始化加载数据
    await loadUsers();
  }

  // 加载数据并更新响应式变量
  Future<void> loadVideoDatas() async {
    final data = await DbTool.instance.getAllDatas();
    items.assignAll(data);
    historyItems.assignAll(data.where((m) => m.isHistory == 1));
    historyItems.sort(
      (a, b) => (b.updateDate ?? 0).compareTo(a.updateDate ?? 0),
    );
  }

  Future<void> loadUsers() async {
    final userList = await DbTool.instance.getAllUser();
    List<UserPoolData> tempUsers = <UserPoolData>[];
    for (Map<String, dynamic> data in userList) {
      UserPoolData user = UserPoolData.fromJson(jsonDecode(data['info']));
      user.platform = data['platform'];
      tempUsers.add(user);
    }
    // userList.forEach((mod) {
    //   UserPoolData user = UserPoolData.fromJson(jsonDecode(mod['info']));
    //   user.platform = mod['platform'];
    //   tempUsers.add(user);
    // });
    users.assignAll(tempUsers);
    users.sort((a, b) => (b.updateDate ?? 0).compareTo(a.updateDate ?? 0));
  }

  // 添加新数据并刷新 UI
  Future<void> insertVideoData(VideoData model) async {
    if (model.movieId.isNotEmpty || model.address.isNotEmpty) {
      await DbTool.instance.insertData(model);
      await instance.loadVideoDatas(); // 重新加载数据（或直接操作 items.value）
      update();
    }
  }

  Future<void> updateVideoData(VideoData model) async {
    if (model.movieId.isNotEmpty || model.address.isNotEmpty) {
      await DbTool.instance.updateData(model);
      await instance.loadVideoDatas(); // 重新加载数据（或直接操作 items.value）
      update();
    }
  }

  Future<void> removeVideoData(VideoData model) async {
    await DbTool.instance.deleteData(model);
    await instance.loadVideoDatas(); // 重新加载数据（或直接操作 items.value）
    update();
  }
}
