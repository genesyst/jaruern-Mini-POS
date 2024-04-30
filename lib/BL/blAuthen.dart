

import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/BL/blRepository.dart';
import 'package:jaruern_mini_pos/Models/mdlResultMsg.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceAPI.dart';
import 'package:http/http.dart' as http;
import 'package:jaruern_mini_pos/settingValues.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BLAuthen extends BLRepository{

  final TextEditingController _passwordController = TextEditingController();

  Map<String, String> GetAccessHeader(String accessKey){
    if(accessKey.isEmpty){
      accessKey = DeclareValue.register_key;
    }
    return {
      "Content-Type": "application/json",
      'XApiKey': DeclareValue.Access_ApiKey,
      'access': accessKey,
      'Cache-Control':'no-cache',
      'Cache-Control':'no-store',
      'Cache-Control':'max-age-0',
      'Pragma':'no-cache',
      'Expires':'0',
    };
  }

  Map<String, String> GetTicketHeader(String email,String password){
    String basicEncode = base64Encode(utf8.encode('$email:$password'));
    return {
      HttpHeaders.authorizationHeader: 'Basic $basicEncode',
      "Content-Type": "application/json",
      'XApiKey': DeclareValue.Ticket_ApiKay,
      'Cache-Control':'no-cache',
      'Cache-Control':'no-store',
      'Cache-Control':'max-age-0',
      'Pragma':'no-cache',
      'Expires':'0',
    };
  }

  Future<mdlResultMsg> GetTokenTicket(BuildContext context,String email,String password) async {
    try{
      String url = await ServiceAPI(context).getUrl('AccessToken', 'GetToken');
      debugPrint(url);

      Uri uri = Uri.parse(url);
      var header = GetTicketHeader(email,password);
      var response = await http.get(uri, headers: header);

      mdlResultMsg result = mdlResultMsg();
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = json.decode(response.body);
        result.id = int.parse(jsonMap['id'].toString());
        result.msg = jsonMap['msg'];
      }else{
        result.id = -1;
        result.msg = response.body;
      }
      return Future.value(result);
    }catch(e){
      throw Exception(e);
    }
  }

  Future<bool> VerifyAccessToken(BuildContext context,String AccessToken) async {
    bool Res = false;
    try{
      String url = await ServiceAPI(context).getUrl('Authen', 'VerifyAccessToken');
      debugPrint(url);

      Uri uri = Uri.parse(url);
      var header = GetAccessHeader(AccessToken);
      var response = await http.get(uri, headers: header);

      if (response.statusCode == 200) {
        Res = true;
      }else if (response.statusCode == 401){
        Res = false;
      }
    }catch(e){
      throw Exception(e);
    }

    return Future.value(Res);
  }

  Future<void> TicketRegister(String token) async {
    try{
      List<String> authenData = token.split('@');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', authenData[0]);
      await prefs.setString('token', authenData[1]);
    }catch(e){
      throw Exception(e);
    }
  }

  Future<void> ReSign(BuildContext context){
    String titleMsg = 'ยืนยันตัวตน';
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(titleMsg),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AutoSizeText(DeclareValue.email,style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'รหัสผ่าน',
                  ),
                ),
              ],
            ),
            actions: [
              MaterialButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: (){
                    if(_passwordController.text.isNotEmpty) {
                      BLAuthen().GetTokenTicket(context,
                          DeclareValue.email, _passwordController.text).then((
                          value) {
                        switch (value.id) {
                          case 0:
                            TicketRegister(value.msg).then((val) {
                              SettingValues().getAuthenToken().then((token) {
                                DeclareValue.AccessKey = token;
                                Navigator.pop(context);
                              });
                            });
                            break;
                          case 1:
                            ServiceMsgDialogCustom.showErrorDialog(
                                context, titleMsg,
                                'ไม่สามารถขอรหัสยืนยันตัวตนจากระบบได้');
                            break;
                          case 2:
                            ServiceMsgDialogCustom.showErrorDialog(
                                context, titleMsg,
                                'พบปัญหาการขอรหัสยืนยันตัวตน');
                            break;
                          case -1:
                            if (value.msg.toLowerCase() ==
                                'user not activate') {
                              ServiceMsgDialogCustom.showErrorDialog(
                                  context, titleMsg,
                                  'ไม่พบผู้ใช้งาน\nหรือกรุณาตรวจสอบการยืนยันตัวตน');
                            }
                            break;
                        }
                      });
                    }
                  },
                  child: const Text('ตกลง')
              )
            ],
          );
        });
  }

}