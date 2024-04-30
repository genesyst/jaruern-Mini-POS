

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/Models/mdlStockInCard.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceAPI.dart';
import 'package:http/http.dart' as http;
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';

class BLStock{
  late BuildContext context;

  BLStock(BuildContext _context){
    context = _context;
  }

  Future<Map<String, dynamic>?> setStockIn(
      mdlStockInCard stockInCard,
      List<Map<String, dynamic>> StockInGoods) async {

    var bodys = {
      'Atdate': stockInCard.Atdate,
      'Storeid': stockInCard.Storeid,
      'Remark': stockInCard.Remark ?? '',
      'Tag': '',
      'Culture': stockInCard.Culture,
      'StockInGoods' : StockInGoods
    };

    String bodysJson = jsonEncode(bodys);
    debugPrint(bodysJson);

    String url = await ServiceAPI(context).getUrl('Stock', 'NewStockInCard');
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

  Future<Map<String, dynamic>?> delStockIn(String id) async {
    try{
      var bodys = {
        'CardId': id,
      };

      String bodysJson = jsonEncode(bodys);
      debugPrint(bodysJson);

      String url = await ServiceAPI(context).getUrl('Stock', 'DeleteStkInCards');
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

    }catch(e){
      debugPrint(e.toString());
    }

    return Future.value(null);
  }

  Future<Map<String, dynamic>> getGoodsLastPrice(String goodsid,String? storeid) async {

    List<String?> params =[goodsid,storeid];
    String url = await ServiceAPI(context).getUrlWithParam('Stock', 'GetStockLastPricesRefer',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);

      int msgIndex = int.parse(jsonMap['id'].toString());
      if(msgIndex==0){
        debugPrint(jsonMap['data'].toString());
        return Future.value(jsonMap['data']);
      }else{
        debugPrint(jsonMap['msg'].toString());
      }

    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }else if (response.statusCode == 400) {
      debugPrint(response.body);
      ShowToast(context,'เกิดข้อผิดพลาด').Show(MessageType.error);
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> GetStockCards(int loadIndex,String storeid,DateTime? atdate) async {
    try {
      String atDateParam = '';
      if (atdate != null) {
        atDateParam = ServiceDateTimeUtils().DateToParam(atdate);
      }

      List<String?> params = [];
      params.add(loadIndex.toString()); //load_index
      params.add(storeid);
      params.add(atDateParam);
      params.add(DeclareValue.DefaultCulture);

      String url = await ServiceAPI(context).getUrlWithParam(
          'Stock', 'GetStockCards', params);
      debugPrint(url);

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
    }catch(e){
      debugPrint(e.toString());
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> GetStockGoods(int loadIndex,String storeid,DateTime? atdate) async {
    try{
      String atDateParam = '';
      if(atdate!=null){
        atDateParam = ServiceDateTimeUtils().DateToParam(atdate);
      }

      List<String?> params = [];
      params.add(loadIndex.toString()); //load_index
      params.add(storeid);
      params.add(atDateParam);
      params.add(DeclareValue.DefaultCulture);

      String url = await ServiceAPI(context).getUrlWithParam(
          'Stock', 'GetStockGoods', params);
      debugPrint(url);

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

    }catch(e){
      debugPrint(e.toString());
    }
    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> GetStockCardsDetail(String CardNo,String storeid) async{
    try{
      List<String?> params = [];
      params.add(CardNo); //load_index
      params.add(storeid);

      String url = await ServiceAPI(context).getUrlWithParam(
          'Stock', 'GetStockCardsDetail', params);
      debugPrint(url);

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
    }catch(e){
      debugPrint(e.toString());
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> GetStockBalance(DateTime? atdate,String storeid) async {
    try{
      String atDateParam = '';
      if(atdate!=null){
        atDateParam = ServiceDateTimeUtils().DateToParam(atdate);
      }

      List<String?> params = [];
      params.add(atDateParam);
      params.add(storeid);

      String url = await ServiceAPI(context).getUrlWithParam(
          'Stock', 'GetStockBalance', params);
      debugPrint(url);

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

    }catch(e){
      debugPrint(e.toString());
    }

    return Future.value(null);
  }

}