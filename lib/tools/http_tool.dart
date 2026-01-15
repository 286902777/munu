import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:munu/tools/toast_tool.dart';

import 'common_tool.dart';

enum HttpState { success, fail, start, end }

enum ApiKey {
  home(
    'hagenia',
    '/v1/quinina/ped_3sk9ej/gestalten',
  ), // /v1/app/open/data  current_page:jills page_size: koan
  folder(
    'ironhard',
    '/v1/bombloads/snottiness/lungfish',
  ), // /v1/app/open/file/{uid}/{dirId} current_page:kiaugh page_size: craterous
  video(
    'abhinaya',
    '/v1/accruals/myst/lecanora',
  ), // 视频资源/v1/app/download/file/{uid}/{fileId}
  userPools(
    'connexivum',
    '/v1/dbmomb72af/kerogens',
  ), //拉取运营推荐数据 HTTP POST /v1/app/push_operation_pools

  recommend(
    'genre',
    '/v1/feces/_xlk1rh_wl',
  ), //app端推荐接口 HTTP POST /v1/app/recommend

  // report('ghnb', '/v1/x/gs'), //app违规举报事件  HTTP POST /v1/app/violate_report
  event('sewans', '/v1/hothouse/method'); //app端事件上报 HTTP POST  /v1/app/events

  final String headName;
  final String address;
  const ApiKey(this.headName, this.address);
}

typedef HttpStateListener =
    void Function(
      String url,
      HttpState state, {
      Map<String, dynamic>? para,
      dynamic result,
      int? code,
      String? msg,
    });

typedef SuccessHandle = void Function(dynamic info);
typedef FailHandle = void Function(bool refresh, int code, String msg);
typedef CompleteHandle = void Function();

class HttpTool extends GetConnect {
  static final HttpTool instance = HttpTool();
  static const contentType = 'application/json';
  static const textPlain = 'text/plain';

  List<String> east = ['https://api.s.com', 'https://api.b.com'];
  List<String> india = ['https://api.xc.com', 'https://api.xs.com'];

  String hostUrl = '';

  void setHost(PlatformType? source) {
    hostUrl = source == PlatformType.india
        ? 'https://api.bx.com'
        : 'https://api.bxs.com';
    httpClient.baseUrl = hostUrl;
    httpClient.maxAuthRetries = 3;
    httpClient.defaultContentType = HttpTool.contentType;
  }

  static getRequest(
    ApiKey api,
    PlatformType source,
    String? url,
    bool show, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    if (EasyLoading.isShow == false && show == true) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false,
      );
    }
    HttpTool.instance.setHost(source);
    HttpTool.instance.noticeHttpListeners(
      api.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.get(
        '${api.address}$url',
        query: newPara,
        headers: {
          'uxorious': api.headName,
          'Content-Type': HttpTool.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        api,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, api, para: para, failHandle: failHandle);
      EasyLoading.showToast(error.toString());
    }

    if (completeHandle != null) {
      completeHandle();
      HttpTool.instance.noticeHttpListeners(
        api.address,
        HttpState.end,
        para: para,
      );
      EasyLoading.dismiss();
    }
  }

  static postRequest(
    ApiKey api,
    PlatformType source, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    if (EasyLoading.isShow == false && api != ApiKey.userPools) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false,
      );
    }
    HttpTool.instance.setHost(source);
    HttpTool.instance.noticeHttpListeners(
      api.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.post(
        api.address,
        newPara,
        headers: {
          'uxorious': api.headName,
          'Content-Type': HttpTool.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        api,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, api, para: para, failHandle: failHandle);
      ToastTool.show(message: error.toString(), type: ToastType.fail);
    }

    if (completeHandle != null) {
      completeHandle();
      HttpTool.instance.noticeHttpListeners(
        api.address,
        HttpState.end,
        para: para,
      );
    }
  }

  static recommendPostRequest(
    ApiKey api,
    PlatformType source,
    bool show, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    if (EasyLoading.isShow == false && show) {
      EasyLoading.show(status: 'loading...');
    }
    HttpTool.instance.setHost(source);
    HttpTool.instance.noticeHttpListeners(
      api.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.post(
        api.address,
        newPara,
        headers: {
          'uxorious': api.headName,
          'Content-Type': HttpTool.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        api,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, api, para: para, failHandle: failHandle);
      ToastTool.show(message: error.toString(), type: ToastType.fail);
    }

    if (completeHandle != null) {
      completeHandle();
      HttpTool.instance.noticeHttpListeners(
        api.address,
        HttpState.end,
        para: para,
      );
    }
  }

  static eventPostRequest(
    PlatformType source, {
    Map<String, dynamic>? para,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
    CompleteHandle? completeHandle,
  }) async {
    HttpTool.instance.setHost(source);
    HttpTool.instance.noticeHttpListeners(
      ApiKey.event.address,
      HttpState.start,
      para: para,
    );
    try {
      Map<String, dynamic> newPara = {}..addAll(para ?? {});
      Response response = await instance.post(
        ApiKey.event.address,
        {
          'laridae': HttpTool.instance.sshToKey(jsonEncode([newPara])),
        },
        headers: {
          'uxorious': ApiKey.event.headName,
          'Content-Type': HttpTool.contentType,
        },
      );
      _handleResult(
        response.statusCode,
        response.body,
        ApiKey.event,
        para: para,
        successHandle: successHandle,
        failHandle: failHandle,
      );
    } catch (error) {
      _handleError(error, ApiKey.event, para: para, failHandle: failHandle);
    }

    if (completeHandle != null) {
      completeHandle();
      HttpTool.instance.noticeHttpListeners(
        ApiKey.event.address,
        HttpState.end,
        para: para,
      );
    }
  }

  bool fixApiURLAddress(PlatformType? source) {
    if (apiPlatform == PlatformType.india) {
      if (hostUrl == east.last) {
        return false;
      } else {
        hostUrl = india.last;
      }
    } else {
      if (hostUrl == east.last) {
        return false;
      } else {
        hostUrl = east.last;
      }
    }
    httpClient.baseUrl = hostUrl;
    return false;
  }

  static _handleResult(
    int? code,
    dynamic result,
    ApiKey key, {
    Map<String, dynamic>? para,
    PlatformType? source,
    SuccessHandle? successHandle,
    FailHandle? failHandle,
  }) async {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (result != null && code == 200) {
      if (result is String) {
        if (successHandle != null) {
          successHandle(result);
        }
      } else if (result is Map) {
        if (result.keys.isNotEmpty) {
          if (successHandle != null) {
            successHandle(result);
          }
          HttpTool.instance.noticeHttpListeners(
            key.address,
            HttpState.success,
            para: para,
            result: result,
          );
        } else {
          String retMsg = result['msg'] ?? result['detail'] ?? 'No Data';
          if (failHandle != null) {
            bool newApi = HttpTool.instance.fixApiURLAddress(source);
            failHandle(newApi, code ?? -1000, retMsg);
          }
          HttpTool.instance.noticeHttpListeners(
            key.address,
            HttpState.fail,
            code: code,
            msg: retMsg,
          );
        }
      } else if (result is bool) {
        if (successHandle != null) {
          successHandle(result);
        }
      } else if (result is List) {
        if (result.isNotEmpty) {
          if (successHandle != null) {
            successHandle(result);
          }
          HttpTool.instance.noticeHttpListeners(
            key.address,
            HttpState.success,
            para: para,
            result: result,
          );
        } else {
          HttpTool.instance.noticeHttpListeners(
            key.address,
            HttpState.fail,
            code: code,
            msg: '',
          );
        }
      }
    } else {
      String retMsg = 'request failed!';
      if (result != null) {
        retMsg = result['msg'] ?? result['detail'] ?? 'request failed!';
      }
      if (failHandle != null) {
        bool newApi = HttpTool.instance.fixApiURLAddress(source);
        failHandle(newApi, code ?? 404, retMsg);
      }
      HttpTool.instance.noticeHttpListeners(
        key.address,
        HttpState.fail,
        code: code,
        msg: retMsg,
      );
    }
  }

  static _handleError(
    dynamic error,
    ApiKey key, {
    Map<String, dynamic>? para,
    PlatformType? source,
    FailHandle? failHandle,
  }) {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    bool newApi = HttpTool.instance.fixApiURLAddress(source);
    int code = -1000;
    if (failHandle != null) {
      failHandle(newApi, code, error.toString());
    }
    HttpTool.instance.noticeHttpListeners(
      key.address,
      HttpState.fail,
      code: code,
      msg: error.toString(),
    );
  }

  static final Map<String, HttpStateListener> _listenersMap = {};

  static addListener(String key, HttpStateListener listener) {
    _listenersMap[key] = listener;
  }

  static removeListener(String key) {
    _listenersMap.remove(key);
  }

  static removeAllListener() {
    _listenersMap.clear();
    // ValueNotifier
  }

  void noticeHttpListeners(
    String url,
    HttpState httpState, {
    Map<String, dynamic>? para,
    dynamic result,
    int? code,
    String? msg,
  }) {
    _listenersMap.forEach((key, value) {
      value(
        url,
        httpState,
        para: {}..addAll(para ?? {}),
        result: result,
        code: code,
        msg: msg,
      );
    });
  }

  String sshToResult(String videoAddress) {
    String baseStr = 'xT8bwhcjlL8ba9I0wCvSvjWAz6A==';
    final token = Key.fromBase64(baseStr.substring(5));
    // final key = Key.fromBase64('2QRaKUXg8Y/RqBPJJiAyVA==');
    final result = Encrypter(AES(token, mode: AESMode.ecb));
    return result.decrypt64(videoAddress);
  }

  String sshToKey(String data) {
    String baseStr = 'bxlcNodheqTX1HbwVHWJyFGy0Gnt3qKUBgGD';
    // String tokenStr = 'gi29bkCXpPZnxCut7LohE6J1r5tHL75CwBMQU';

    String offStr = 'xQlx2Xk4dLo38c9Z2Q2a';
    final token = Key.fromUtf8(baseStr.substring(4));
    final secret = IV.fromUtf8(offStr.substring(4));

    final res = Encrypter(AES(token, mode: AESMode.cbc));
    final bey = res.encrypt(data, iv: secret);
    return bey.base64;
  }
}
