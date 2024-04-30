

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/Models/mdlParamGetStore.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceAPI.dart';
import 'package:jaruern_mini_pos/settingValues.dart';
import 'blRepository.dart';
import 'package:http/http.dart' as http;

class BLStore extends BLRepository{
  late BuildContext context;

  BLStore(BuildContext _context){
    context = _context;
  }

  Future<String> getStoreList(mdlParamGetStore Value) async {
    try {
      List<String> params = [];
      params.add(Value.load_index.toString()); //load_index
      params.add(Value.storegroup); //storegroup
      params.add(Value.storetype); //storetype
      params.add(Value.filter); //filter
      params.add(Value.location); //location
      String url = await ServiceAPI(context).getUrlWithParam(
          'Store', 'StoreList', params);
      debugPrint(url);

      String accKey = await SettingValues().getAuthenToken();
      Uri uri = Uri.parse(url);
      var response = await http.get(uri, headers: BLAuthen().GetAccessHeader(accKey));
      if (response.statusCode == 200) {
        //debugPrint(response.body);
        return Future.value(response.body);
      }
    }catch(e){
      throw Exception(e);
    }

    return Future.value('');
  }

  Future<Map<String, dynamic>> AddStore(String storecode,String storename) async {
    try{
      var bodys = {
        'key':storecode,
        'value':storename};

      String url = await ServiceAPI(context).getUrl('Store', 'NewStore');
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
    }catch(e){
      throw Exception(e);
    }

    return Future.value(null);
  }

  Future<String> getMyStore(Position? position) async {
    try{
      List<String> params = [];
      params.add(position!.latitude.toString());
      params.add(position.longitude.toString());

      String url = await ServiceAPI(context).getUrlWithParam('Store', 'MyStore', params);
      debugPrint(url);

      String accKey = await SettingValues().getAuthenToken();
      Uri uri = Uri.parse(url);
      var response = await http.get(uri, headers: BLAuthen().GetAccessHeader(accKey));
      if (response.statusCode == 200) {
        return Future.value(response.body);
      }
    }catch(e){
      throw Exception(e);
    }

    return Future.value('');
  }

}
