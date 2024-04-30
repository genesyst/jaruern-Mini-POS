

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/Models/mdlItem.dart';
import 'package:jaruern_mini_pos/Models/mdlNewReceript.dart';
import 'package:jaruern_mini_pos/Models/mdlRetGoodsEdit.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceAPI.dart';
import 'package:http/http.dart' as http;
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';

class BLSale{
  late BuildContext context;

  BLSale(BuildContext _context){
    context = _context;
  }

  Future<List<Map<String, dynamic>>> GetSaleProduct(String storeid) async {
    List<String?> params =[storeid];
    String url = await ServiceAPI(context).getUrlWithParam('POS', 'GetSaleProduct',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonMap = json.decode(response.body)['results']
          .cast<Map<String, dynamic>>();
      return Future.value(jsonMap);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เกิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> GetSaleProductOrder(String storeid) async {
    List<String?> params =[storeid];
    String url = await ServiceAPI(context).getUrlWithParam('POS', 'GetSaleProductOrder',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonMap = json.decode(response.body)['results']
          .cast<Map<String, dynamic>>();
      return Future.value(jsonMap);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เกิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<Map<String, dynamic>> NewReceript(mdlNewReceript receipt,List<Map<String, dynamic>> goodsRecripts) async {
    var bodys = {
      'culture': receipt.culture,
      'atdate': receipt.atdate,
      'storeid': receipt.storeid,
      'cash': receipt.cash,
      'vat': receipt.vat,
      'discount' : receipt.discount,
      'remark': receipt.remark,
      'vatRate': receipt.vatRate,
      'taxRate': receipt.taxRate,
      'fullprice': receipt.fullprice,
      'deposit': receipt.deposit,

      'cashType': receipt.cashType,
      'cusCash': receipt.cusCash,
      'cusChange': receipt.cusChange,
      'creditNo': receipt.creditNo,
      'cusCredit': receipt.cusCredit,
      'memberId': receipt.memberId,

      'typeCode': receipt.typeCode,

      'newReceripts': goodsRecripts,
      'refId': receipt.refid ?? '',
    };

    String bodysJson = jsonEncode(bodys);
    debugPrint(bodysJson);

    String url = await ServiceAPI(context).getUrl('POS', 'NewReceript');
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.post(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey),
        body: jsonEncode(bodys)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);

      return Future.value(jsonMap);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เปิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> GetReceiptList(String StoreId,DateTime Atdate,String Code) async {
    String atdateStr = ServiceDateTimeUtils().DateToParam(Atdate);
    List<String?> params =[StoreId,atdateStr,Code];
    String url = await ServiceAPI(context).getUrlWithParam('POS', 'GetReceiptList',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonMap = json.decode(response.body)['results']
          .cast<Map<String, dynamic>>();
      return Future.value(jsonMap);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เกิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> GetReceiptListForRet(String StoreId,int loadIndex,String findVaue) async {
    List<String?> params =[StoreId,loadIndex.toString(),findVaue];
    String url = await ServiceAPI(context).getUrlWithParam('POS', 'GetReceiptListForRet',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonMap = json.decode(response.body)['results']
          .cast<Map<String, dynamic>>();
      return Future.value(jsonMap);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เกิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<Map<String, dynamic>> GetReceipt(String id) async {
    List<String?> params =[id.trim(),DeclareValue.DefaultCulture];
    String url = await ServiceAPI(context).getUrlWithParam('POS', 'GetReceipt',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      return Future.value(jsonMap);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เกิดข้อผิดพลาด').Show(MessageType.error);
    }


    return Future.value(null);
  }

  Future<Map<String, dynamic>> DeleteReceipt(String id,String ReasonNo,String ReasonTxt) async {
    var bodys = {
      'recriptId': id,
      'reasonNo': ReasonNo,
      'reasonTxt': ReasonTxt
    };

    String bodysJson = jsonEncode(bodys);
    debugPrint(bodysJson);

    String url = await ServiceAPI(context).getUrl('POS', 'DeleteReceipt');
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.post(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey),
        body: jsonEncode(bodys)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);

      return Future.value(jsonMap);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เปิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<String> getReceiptQRBarcode(String Barcode,String ReceiptId,int CodeType) async {
    List<String> params = [Barcode,
                              DeclareValue.currentStoreId,
                              ReceiptId,
                              CodeType.toString()
                          ];

    String url = await ServiceAPI(context).getUrlWithParam('POS', 'GetReceiptQRBarcode',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      int id = int.tryParse(jsonMap!['id'].toString()) ?? -1;
      if (id == 0) {
        return Future.value(jsonMap!['url'].toString());
      }
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }

    return Future.value(null);
  }

  Future<List<mdlItem>> GetGoodsReturnType() async {
    List<mdlItem> result = [];
    String url = await ServiceAPI(context).getUrl('POS', 'GetGoodsReturnType');
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      int resId = int.tryParse(jsonMap['id'].toString()) ?? -1;
      if(resId==0){
        var rets = jsonMap['data'].cast<Map<String, dynamic>>();
        for(var ret in rets){
          mdlItem item = mdlItem();
          item.Key = ret['key'].toString();
          item.Text = ret['value'].toString();
          item.Value = int.parse(ret['key'].toString());
          result.add(item);
        }
      }

      return Future.value(result);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เปิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(result);
  }

  Future<List<mdlItem>> GetRefundType() async {
    List<mdlItem> result = [];
    String url = await ServiceAPI(context).getUrl('POS', 'GetRefundType');
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      int resId = int.tryParse(jsonMap['id'].toString()) ?? -1;
      if(resId==0){
        var rets = jsonMap['data'].cast<Map<String, dynamic>>();
        for(var ret in rets){
          mdlItem item = mdlItem();
          item.Key = ret['key'].toString();
          item.Text = ret['value'].toString();
          item.Value = ret['key'].toString();
          result.add(item);
        }
      }

      return Future.value(result);
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เปิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(result);
  }

  Future<String> RenewReceipt(String receiptId,String refundType,String remark,List<mdlRetGoodsEdit> retGoodss) async {
    List<Map<String, dynamic>> goodsRecripts = [];
    for(var retGoods in retGoodss){
      if(retGoods.isSelected){
        goodsRecripts.add({
          'receiptItemId': retGoods.id,
          'reasonCode': retGoods.RetType.toString().padLeft(3, '0'),
          'reasonText': retGoods.reason
        });
      }
    }

    var bodys = {
      'id': receiptId,
      'storeId': DeclareValue.currentStoreId,
      'culture': DeclareValue.DefaultCulture,
      'refundType': refundType,
      'remark': remark,
      'xGoodsReason': goodsRecripts
    };

    String bodysJson = jsonEncode(bodys);
    debugPrint(bodysJson);

    String url = await ServiceAPI(context).getUrl('POS', 'RenewReceipt');
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.post(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey),
        body: jsonEncode(bodys)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);

      int id = int.tryParse(jsonMap!['id'].toString()) ?? -1;
      if (id == 0) {
        return Future.value(jsonMap!['receiptid'].toString());
      }

      return Future.value('');
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เปิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<String> GetReceiptId(String RecriptNo) async {
    List<String?> params =[RecriptNo.trim(),DeclareValue.currentStoreId];
    String url = await ServiceAPI(context).getUrlWithParam('POS', 'GetReceiptId',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);

      int id = int.tryParse(jsonMap!['id'].toString()) ?? -1;
      if (id == 0) {
        return Future.value(jsonMap!['msg'].toString());
      }else{
        debugPrint(jsonMap!['msg'].toString());
      }
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เปิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value('');
  }

}