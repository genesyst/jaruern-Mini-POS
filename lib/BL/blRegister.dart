

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/BL/blRepository.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceAPI.dart';
import 'package:http/http.dart' as http;

class BLRegister extends BLRepository {
  late BuildContext context;

  BLRegister(BuildContext _context){
    context = _context;
  }

  Future<Map<String, dynamic>> NewRegister(String email,String empcode,String password
                                      ,String storeId,String storeName) async {
    var bodys = {
      'id': '',
      'email': email,
      'empCode': empcode,
      'password': password,
      'storeId': storeId,
      'storeName': storeName
    };

    String url = await ServiceAPI(context).getUrl('UserRegister', 'NewRegister');
    debugPrint(url);

    var response = await http.post(
        Uri.parse(url),
        headers: BLAuthen().GetAccessHeader(''),
        body: jsonEncode(bodys)
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      debugPrint(jsonMap['value']);

      return Future.value(jsonMap);
    }

    return Future.value(null);
  }
}