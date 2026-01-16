import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';

PremiumData premiumDataFromJson(Map<String, dynamic> s) =>
    PremiumData.fromJson(s);

String premiumDataToJson(PremiumData data) => json.encode(data.toJson());

enum PremiumStatus { none, vip }

class PremiumProductData {
  PremiumProductData({
    required this.productId,
    required this.title,
    required this.productInfo,
    required this.price,
    required this.showPrice,
    required this.currency,
    required this.isSelect,
    required this.hot,
  });
  String productId;
  String title;
  String productInfo;
  double price;
  String showPrice;
  String currency;
  bool isSelect;
  bool hot;
}

class PremiumData {
  bool? ok = false;
  String? name;
  String? info;
  String? productId;
  bool? success = false;
  bool? autoRenew = false;
  int? expiresDate = 0;
  PurchaseDetails? purchaseDetails;

  PremiumData({
    this.ok,
    this.name,
    this.info,
    this.productId,
    this.success,
    this.autoRenew,
    this.expiresDate,
    this.purchaseDetails,
  });

  factory PremiumData.fromJson(Map<String, dynamic> json) => PremiumData(
    name: json["name"] ?? '',
    info: json["info"] ?? '',
    productId: json["productId"] ?? '',
    success: json["success"] ?? false,
    ok: json["s"] ?? false,
    autoRenew: json["autoRenew"] ?? false,
    expiresDate: json["expiresDate"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "info": info,
    "productId": productId,
    "success": success,
    "ok": ok,
    "autoRenew": autoRenew,
    "expiresDate": expiresDate,
  };

  get status {
    if (ok ?? false == true) {
      return PremiumStatus.vip;
    }
    return PremiumStatus.none;
  }
}
