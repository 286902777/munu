import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../data/premium_data.dart';
import '../keys/app_key.dart';
import '../tools/common_tool.dart';
import '../tools/event_tool.dart';
import '../tools/fire_base_tool.dart';

enum PremiumIdKey {
  weak('lens_weekly'),
  year('lens_yearly'),
  life('lens_lifetime');

  final String value;
  const PremiumIdKey(this.value);
}

class PremiumTool with ChangeNotifier {
  static final PremiumTool instance = PremiumTool._internal();
  PremiumIdKey idKey = PremiumIdKey.weak;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  final ValueNotifier<PremiumData> premiumData = ValueNotifier(PremiumData());
  final ValueNotifier<List<PremiumProductData>> productResultList =
      ValueNotifier([]);

  List<ProductDetails> _productList = [];
  List<PurchaseDetails> _purchaseList = [];

  bool isStore = false;
  bool isPay = false;

  factory PremiumTool() {
    return instance;
  }

  PremiumTool._internal() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        EasyLoading.dismiss();
        _subscription.cancel();
      },
      onError: (error) {
        EasyLoading.dismiss();
        premiumDoneBlock?.call(PremiumData(), isStore == false);
      },
    );

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          InAppPurchase.instance
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(VipPaymentQueueDelegate());
    } else {
      getAndroidProductInfo().ignore();
    }
  }

  Future<List<ProductDetails>> getAndroidProductInfo() async {
    try {
      if (!(await InAppPurchase.instance.isAvailable())) {
        return [];
      }
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails({
            PremiumIdKey.weak.value,
            PremiumIdKey.year.value,
            PremiumIdKey.life.value,
          });
      if (response.notFoundIDs.isNotEmpty) {
        return [];
      }
      _productList = response.productDetails;
      if (_productList.isNotEmpty) {
        _productList.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        List<PremiumProductData> newProductList = [];

        for (Map<String, dynamic> file
            in FireBaseTool.userVipFile[FireConfigKey.userVipInfoName]) {
          for (ProductDetails m in _productList) {
            String productId = file[FireConfigKey.userVipProductId];
            if (productId == m.id) {
              PremiumProductData model = PremiumProductData(
                productId: m.id,
                title: file[FireConfigKey.userVipType],
                productInfo: '',
                price: m.rawPrice,
                showPrice: m.price,
                currency: m.currencySymbol,
                isSelect: file[FireConfigKey.userVipSelect],
                hot: file[FireConfigKey.userVipHot],
              );
              newProductList.add(model);
            }
          }
        }
        productResultList.value = newProductList;
      }
      return _productList;
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subscription.cancel();
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    EasyLoading.dismiss();
    _purchaseList = purchaseDetailsList;

    purchaseDetailsList.sort(
      (a, b) => (int.tryParse(b.transactionDate ?? '') ?? 0).compareTo(
        int.tryParse(a.transactionDate ?? '') ?? 0,
      ),
    );
    if (purchaseDetailsList.isNotEmpty) {
      PurchaseDetails purchaseDetails = purchaseDetailsList.first;
      if (purchaseDetails.status != PurchaseStatus.pending) {
        PremiumProductData? productInfo;
        if (productResultList.value.isNotEmpty &&
            purchaseDetails.productID.isNotEmpty) {
          productInfo = productResultList.value.firstWhere(
            (element) => element.productId == purchaseDetails.productID,
          );
        }
        PremiumData model = PremiumData(
          purchaseDetails: purchaseDetails,
          name: productInfo?.title,
        );
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          //如果苹果返回成功之后去验证票据
          if (Platform.isIOS) {
            model = await _verifyPurchase(purchaseDetails);
            // } else {
            //   model = await _verifyAndroidPurchase(purchaseDetails);
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          //被取消，重置vip信息
          model = premiumData.value;
          model.purchaseDetails = purchaseDetails;
          EventTool.instance.eventUpload(EventApi.premiumFail, {
            EventParaName.value.name: vipProduct.value,
          });
        }
        if (purchaseDetails.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchaseDetails);
        }
        //通知监听者
        _noticePurchaseStatusListener(model);
        await clearFailedPurchases();
      }
    } else {
      _noticePurchaseStatusListener(PremiumData());
    }
  }

  Future<void> queryProductInfo() async {
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    if (isAvailable == false) {
      return;
    }
    List<String> productIds = [];
    if (FireBaseTool.userVipFile.isNotEmpty) {
      for (Map<String, dynamic> m
          in FireBaseTool.userVipFile[FireConfigKey.userVipInfoName]) {
        productIds.add(m[FireConfigKey.userVipProductId]);
      }
    } else {
      productIds = [
        PremiumIdKey.weak.value,
        PremiumIdKey.year.value,
        PremiumIdKey.life.value,
      ];
    }
    final ProductDetailsResponse productDetailResponse = await InAppPurchase
        .instance
        .queryProductDetails(productIds.toSet());
    _productList = productDetailResponse.productDetails;

    if (_productList.isNotEmpty) {
      _productList.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      List<PremiumProductData> newProductList = [];

      for (Map<String, dynamic> file
          in FireBaseTool.userVipFile[FireConfigKey.userVipInfoName]) {
        for (ProductDetails m in _productList) {
          if (file[FireConfigKey.userVipProductId] == m.id) {
            PremiumProductData model = PremiumProductData(
              productId: m.id,
              title: file[FireConfigKey.userVipType],
              productInfo: '',
              price: m.rawPrice,
              showPrice: m.price,
              currency: m.currencySymbol,
              isSelect: file[FireConfigKey.userVipSelect],
              hot: file[FireConfigKey.userVipHot],
            );
            newProductList.add(model);
          }
        }
      }
      productResultList.value = newProductList;
    }
  }

  ///走自己后端验证票据
  Future<PremiumData> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    PremiumProductData? productInfo;
    SKRequestMaker().startRefreshReceiptRequest();
    String receipt = await SKReceiptManager.retrieveReceiptData();

    if (receipt.isEmpty) {
      receipt = purchaseDetails.verificationData.serverVerificationData;
    }
    if (receipt.isEmpty) {
      premiumDoneBlock?.call(PremiumData(), isStore == false);
      return PremiumData();
    }
    if (isStore == false) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false,
      );
    }
    if (productResultList.value.isNotEmpty) {
      productInfo = productResultList.value.firstWhere(
        (element) => element.productId == purchaseDetails.productID,
      );
    }

    String url =
        'https://ss.tism'; // https://rme.frameplayvid.com/v1/ios/receipt-verifier
    final storage = FlutterSecureStorage();
    String? uniqueId = await storage.read(key: 'unique_id');
    String uuId = '';
    if (uniqueId != null) {
      uuId = uniqueId;
    } else {
      uuId = Uuid().v4();
      storage.write(key: 'unique_id', value: uuId);
    }
    Map params = {};
    // params['device_id'] = uuId;
    // params['package_name'] = (await PackageInfo.fromPlatform()).packageName;
    // params['product_id'] = purchaseDetails.productID;
    // params['receipt_base64_data'] =
    // purchaseDetails.verificationData.serverVerificationData;
    params['s'] = uuId;
    params['b'] = (await PackageInfo.fromPlatform()).packageName;
    params['sb'] = purchaseDetails.productID;
    params['sd'] = receipt;
    Response response = await GetConnect().post(
      url,
      params,
      contentType: 'application/json',
      headers: {'humbly': 'unitooth', 'Host': 'rme.frameplayvid.com'},
    );
    dynamic responseBody = response.body;

    if (responseBody is Map) {
      dynamic entity = responseBody['moles']; //entity
      if (entity is Map<String, dynamic>) {
        PremiumData model = PremiumData.fromJson(entity);
        model.success = true;
        model.purchaseDetails = purchaseDetails;
        model.name = productInfo?.title;
        model.productId = purchaseDetails.productID;

        if (Platform.isIOS) {
          List pendingRenewalInfo =
              entity['gmsko6t1ir'] ?? []; //pending_renewal_info
          if (pendingRenewalInfo.isNotEmpty) {
            model.autoRenew =
                (pendingRenewalInfo[0]['peavie']) == '1'; //auto_renew_status
          }

          List latestReceiptInfo =
              entity['adversed'] ?? []; //latest_receipt_info
          if (latestReceiptInfo.isNotEmpty) {
            model.expiresDate = latestReceiptInfo[0]['bilby']; //expires_date_ms
          }
        }
        await AppKey.save(AppKey.isVipUser, model.ok);
        await AppKey.save(AppKey.vipProductId, model.productId);
        if (model.ok == true && isPay == true) {
          String userId = await AppKey.getString(AppKey.appUserId) ?? '';
          EventTool.instance.eventUpload(EventApi.premiumSuc, {
            EventParaName.value.name: vipProduct.value,
            EventParaName.type.name: vipType.value, //type
            EventParaName.method.name: vipMethod.value, //method
            EventParaName.source.name: vipSource.value, //source
            EventParaName.iPlayerUid.name: userId,
          });
          isPay = false;
        }
        await AppKey.save(AppKey.isVipUser, model.ok);
        premiumDoneBlock?.call(model, isStore == false);
        EasyLoading.dismiss();
        return model;
      } else {
        isPay = false;
        await AppKey.save(AppKey.isVipUser, false);
        premiumDoneBlock?.call(
          PremiumData(purchaseDetails: purchaseDetails),
          isStore == false,
        );
        EasyLoading.dismiss();
        return PremiumData(purchaseDetails: purchaseDetails);
      }
    } else {
      isPay = false;
      await AppKey.save(AppKey.isVipUser, false);
      premiumDoneBlock?.call(
        PremiumData(purchaseDetails: purchaseDetails),
        isStore == false,
      );
      EasyLoading.dismiss();
      return PremiumData(purchaseDetails: purchaseDetails);
    }
  }

  Future<PremiumData> toGetPay(PremiumProductData? selectModel) async {
    Completer<PremiumData> completer = Completer();
    isStore = false;
    isPay = true;

    ///完结以前的订单
    await clearFailedPurchases();

    String? sProductId = '';
    if (selectModel != null) {
      sProductId = selectModel.productId;
    } else {
      sProductId = productResultList.value
          .firstWhere((m) => m.isSelect == true)
          .productId;
    }
    if (Platform.isIOS) {
      // 周：weekly_kreel：2.99
      // 年：annual_kreel：19.99
      // 终身：lifetime_kreel：29.99
      switch (sProductId) {
        case 'lens_weekly':
          vipProduct = VipProduct.weekly;
        case 'lens_yearly':
          vipProduct = VipProduct.yearly;
        case 'lens_lifetime':
          vipProduct = VipProduct.lifetime;
        default:
          break;
      }
    }

    String? userId = await AppKey.getString(AppKey.appUserId);
    EventTool.instance.eventUpload(EventApi.premiumClick, {
      EventParaName.value.name: vipProduct.value,
      EventParaName.type.name: vipType.value, //type
      EventParaName.method.name: vipMethod.value, //method
      EventParaName.source.name: vipSource.value, //source
      EventParaName.iPlayerUid.name: userId,
    });

    ProductDetails currentProductDetails = _productList.firstWhere(
      (element) => element.id == sProductId,
    );

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: currentProductDetails,
    );

    //开始购买
    try {
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (e) {
      EasyLoading.dismiss();
      if (e is PlatformException) {
        if (e.code.contains('cancelled')) {
          String msg = e.details;
          if (msg.contains('lens_weekly')) {
            vipProduct = VipProduct.weekly;
          }
          if (msg.contains('lens_yearly')) {
            vipProduct = VipProduct.yearly;
          }
          if (msg.contains('lens_lifetime')) {
            vipProduct = VipProduct.lifetime;
          }
          EventTool.instance.eventUpload(EventApi.premiumFail, {
            EventParaName.value.name: vipProduct.value,
          });
        }
      }
      if (completer.isCompleted == false) {
        completer.complete(PremiumData());
      }
    }

    return completer.future;
  }

  ///恢复之前的购买
  Future restore({bool? appStart = false, bool? isClick = false}) async {
    isStore = true;
    isPay = false;
    if (appStart == false) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false,
      );
    }
    // InAppPurchase.instance.restorePurchases();
    PremiumProductData? productInfo;
    SKRequestMaker().startRefreshReceiptRequest();
    String receipt = await SKReceiptManager.retrieveReceiptData();
    String productId = await AppKey.getString(AppKey.vipProductId) ?? '';
    if (productResultList.value.isNotEmpty && productId.isNotEmpty) {
      productInfo = productResultList.value.firstWhere(
        (element) => element.productId == productId,
      );
    }

    String url = 'https://rme.frameplayvid.com/horsecar/skwmvb8osg/rantism';
    final storage = FlutterSecureStorage();
    String? uniqueId = await storage.read(key: 'unique_id');
    String uuId = '';
    if (uniqueId != null) {
      uuId = uniqueId;
    } else {
      uuId = Uuid().v4();
      storage.write(key: 'unique_id', value: uuId);
    }
    Map params = {};
    params['catalin'] = uuId;
    params['hamates'] = (await PackageInfo.fromPlatform()).packageName;
    params['indivinity'] = productId;
    params['polyptych'] = receipt;
    Response response = await GetConnect().post(
      url,
      params,
      contentType: 'application/json',
      headers: {'humbly': 'unitooth', 'Host': 'rme.frameplayvid.com'},
    );
    dynamic responseBody = response.body;

    if (responseBody is Map) {
      dynamic entity = responseBody['moles']; //entity
      if (entity is Map<String, dynamic>) {
        PremiumData model = PremiumData.fromJson(entity);
        model.success = true;
        model.name = productInfo?.title;
        model.productId = productId;

        if (Platform.isIOS) {
          List pendingRenewalInfo =
              entity['gmsko6t1ir'] ?? []; //pending_renewal_info
          if (pendingRenewalInfo.isNotEmpty) {
            model.autoRenew =
                (pendingRenewalInfo[0]['peavie']) == '1'; //auto_renew_status
          }

          List latestReceiptInfo =
              entity['adversed'] ?? []; //latest_receipt_info
          if (latestReceiptInfo.isNotEmpty) {
            model.expiresDate = latestReceiptInfo[0]['bilby']; //expires_date_ms
          }
        }
        await AppKey.save(AppKey.isVipUser, model.ok);
        await AppKey.save(AppKey.vipProductId, model.productId);
        // if (model.ok == true) {
        //   print('premium_suc');
        // String userId = await AppKey.getString(AppKey.appUserId) ?? '';
        // EventTool.instance.eventUpload(EventApi.premiumSuc, {
        //   EventParaName.value.name: vipProduct.value,
        //   EventParaName.type.name: vipType.value, //type
        //   EventParaName.method.name: vipMethod.value, //method
        //   EventParaName.source.name: vipSource.value, //source
        //   EventParaName.iPlayerUid.name: userId,
        // });
        // }
        EasyLoading.dismiss();
        await AppKey.save(AppKey.isVipUser, model.ok);
        premiumDoneBlock?.call(model, isStore == false);
        _noticePurchaseStatusListener(model);
        return model;
      } else {
        EasyLoading.dismiss();
        await AppKey.save(AppKey.isVipUser, false);
        _noticePurchaseStatusListener(PremiumData());
        premiumDoneBlock?.call(PremiumData(), isStore == false);
      }
    } else {
      EasyLoading.dismiss();
      await AppKey.save(AppKey.isVipUser, false);
      _noticePurchaseStatusListener(PremiumData());
      premiumDoneBlock?.call(PremiumData(), isStore == false);
    }
  }

  Future<void> clearFailedPurchases() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final wrapper = SKPaymentQueueWrapper();
      final transactions = await wrapper.transactions();
      for (final transaction in transactions) {
        await wrapper.finishTransaction(transaction);
      }
    }
    //完成订单状态
    for (var element in _purchaseList) {
      if (element.status != PurchaseStatus.pending) {
        if (element.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(element);
        }
      }
    }
  }

  ///订单状态监听-----------------------------------------

  void _noticePurchaseStatusListener(PremiumData data) {
    EasyLoading.dismiss();
    PremiumTool.instance.premiumData.value = data;
    PremiumTool.instance.premiumData.notifyListeners();
  }
}

class VipPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
