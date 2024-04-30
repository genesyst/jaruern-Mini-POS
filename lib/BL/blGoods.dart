

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/BL/blRepository.dart';
import 'package:jaruern_mini_pos/Models/mdlNewGoods.dart';
import 'package:jaruern_mini_pos/Models/mdlParamGetGoods.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceAPI.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceData.dart';
import 'package:jaruern_mini_pos/settingValues.dart';
import 'package:http/http.dart' as http;

class BLGoods extends BLRepository{
  late BuildContext context;

  BLGoods(BuildContext _context){
    context = _context;
  }

  Future<List<Map<String, dynamic>>> getProductType() async {
    try{
      String url = await ServiceAPI(context).getUrl('Goods', 'ProductType');
      debugPrint(url);

      String accKey = await SettingValues().getAuthenToken();
      Uri uri = Uri.parse(url);
      var response = await http.get(uri, headers: BLAuthen().GetAccessHeader(accKey));
      if (response.statusCode == 200) {
        debugPrint(response.body);
        List<Map<String, dynamic>> resultApi = json.decode(response.body).cast<Map<String, dynamic>>();
        return resultApi;
      }else if (response.statusCode == 401) {

      }
    }catch(e){
      throw Exception(e);
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> getProductGroup() async {
    try{
      String url = await ServiceAPI(context).getUrl('Goods', 'ProductGroup');
      debugPrint(url);

      String accKey = await SettingValues().getAuthenToken();
      Uri uri = Uri.parse(url);
      var response = await http.get(uri, headers: BLAuthen().GetAccessHeader(accKey));
      if (response.statusCode == 200) {
        debugPrint(response.body);
        List<Map<String, dynamic>> resultApi = json.decode(response.body).cast<Map<String, dynamic>>();
        return resultApi;
      }
    }catch(e){
      throw Exception(e);
    }

    return Future.value(null);
  }

  Future<Map<String, dynamic>?> setNewGoods(mdlNewGoods Values) async {
    var bodys = {
      'Skubarcode': Values.Skubarcode,
      'Skuqrcode': Values.Skuqrcode,
      'Skucode': Values.Skucode,
      'Skuname': Values.Skuname,
      'Desp': Values.Desp,
      'Skudisplayname': Values.Skudisplayname,
      'Productgroupid': Values.Productgroupid,
      'Producttypeid': Values.Producttypeid,
      'Skusize': Values.Skusize,
    };

    String url = await ServiceAPI(context).getUrl('Goods', 'NewGoods');
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
    }

    return Future.value(null);
  }

  Future<List<Map<String, dynamic>>> getGoodsList(mdlParamGetGoods Value) async {
    List<String> params = [];
    params.add(Value.load_index.toString()); //load_index
    params.add(Value.findvalue);
    params.add(Value.ptype);
    params.add(Value.pgroup);
    params.add(Value.barcode);
    params.add(Value.favorite.toString());

    String url = await ServiceAPI(context).getUrlWithParam(
        'Goods', 'GoodsList', params);
    debugPrint(url);

    try {
      var response = await http.get(
          Uri.parse(url),
          headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey));

      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> resultApi = json.decode(
            response.body)['results'].cast<Map<String, dynamic>>();

        return Future.value(resultApi);
      } else if (response.statusCode == 410) {
        BLAuthen().ReSign(context);
      }
    }catch(e){
      debugPrint(e.toString());
    }

    return Future.value(null);
  }

  Future<Map<String, dynamic>?> getGoods(String id) async {
    List<String> params = [id];
    String url = await ServiceAPI(context).getUrlWithParam('Goods', 'GetGoods',params);
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
    }

    return Future.value(null);
  }

  Future<bool> getSetGoodsFavorite(String id) async {
    List<String> params = [id];
    String url = await ServiceAPI(context).getUrlWithParam('Goods', 'GetSetGoodsFavorite',params);
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    var response = await http.get(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey)
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      if(response.body.toUpperCase()=='SUCCESS'){
        return Future.value(true);
      }
    }else if (response.statusCode == 410) {
      BLAuthen().ReSign(context);
    }

    return Future.value(false);
  }

  Future<List<Map<String, dynamic>>> getUnits(String? id) async {
    List<String?> params = [];
    params.add(id);
    params.add(DeclareValue.DefaultCulture);

    String url = await ServiceAPI(context).getUrlWithParam(
        'Goods', 'GetUnits', params);
    debugPrint(url);

    try{
      var response = await http.get(
          Uri.parse(url),
          headers: BLAuthen().GetAccessHeader(DeclareValue.AccessKey));

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> resultApi = json.decode(
            response.body).cast<Map<String, dynamic>>();

        return Future.value(resultApi);
      } else if (response.statusCode == 410) {
        BLAuthen().ReSign(context);
      }else if (response.statusCode == 400) {
        debugPrint(response.body);
      }
    }catch(e){
      debugPrint(e.toString());
    }

    return Future.value(null);

  }

  Future<Map<String, dynamic>?> SetGoodsImage(File file,String Barcode,String ImgType,String Storeid) async {

    var data = {
      'Barcode': Barcode,
      'ImageType': ImgType,
      'Storeid': Storeid
    };

    String url = await ServiceAPI(context).getUrl('Goods', 'SetGoodsImage');
    debugPrint(url);
    debugPrint(DeclareValue.AccessKey);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request = ServiceData(context).jsonToFormData(request, data);
      request.headers.addAll(
          BLAuthen().GetAccessHeader(DeclareValue.AccessKey));

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath("GFile", file.path));
      }

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      print(responseString);

      Map<String, dynamic> res = json.decode(responseString);
      return Future.value(res);
    }catch(e){
      debugPrint(e.toString());
    }

    return Future.value(null);
  }

  Future<String> getGoodsImageUrl(String Barcode,String ImgType,String Storeid) async {
    List<String> params = [Barcode,ImgType,Storeid];
    String url = await ServiceAPI(context).getUrlWithParam('Goods', 'GetGoodsImage',params);
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

  Future<String> getGoodsImageBarcode(String Barcode) async {
    List<String> params = [Barcode];
    String url = await ServiceAPI(context).getUrlWithParam('Goods', 'GetGoodsBarcode',params);
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

  Future<String> getGoodsImageQRcode(String Barcode,String DataTxt) async {
    List<String> params = [Barcode,DataTxt];
    String url = await ServiceAPI(context).getUrlWithParam('Goods', 'GetGoodsQRcode',params);
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

}