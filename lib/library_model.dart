import 'package:library_system_sqflite/database_helper.dart';

class ShoppingModel {
  int? shopId;
  String? shopName;
  String? items;

  ShoppingModel({this.shopId, this.shopName, this.items});

  ShoppingModel.fromMap(Map<String, dynamic> map) {
    shopId = map['shop_id'];
    shopName = map['shop_name'];
    items = map['items'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.shopId: shopId,
      DatabaseHelper.shopName: shopName,
      DatabaseHelper.items: items,
    };
  }
}
