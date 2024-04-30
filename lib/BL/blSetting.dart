

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceAPI.dart';
import 'package:http/http.dart' as http;

class BLSetting{
  late BuildContext context;

  BLSetting(BuildContext _context){
    context = _context;
  }

  Future<List<Map<String, dynamic>>> getValues() async{
    List<String> params = [DeclareValue.currentStoreId];
    String url = await ServiceAPI(context).getUrlWithParam('Setting', 'GetValues',params);
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
        List<Map<String, dynamic>> data = json.decode(response.body)['data'].cast<Map<String, dynamic>>();
        debugPrint(data.toString());
        return Future.value(data);
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

  Future<Map<String, dynamic>?> setValues(List<Map<String, dynamic>> KeyValues) async {
    var bodys = {
      'storeId': DeclareValue.currentStoreId,
      'settValues' : KeyValues
    };

    String bodysJson = jsonEncode(bodys);
    debugPrint(bodysJson);

    String url = await ServiceAPI(context).getUrl('Setting', 'SetValues');
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
}