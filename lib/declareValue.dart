
import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/BL/blGoods.dart';
import 'package:jaruern_mini_pos/Models/mdlItem.dart';
import 'package:jaruern_mini_pos/Models/mdlReceiptXReason.dart';
import 'package:jaruern_mini_pos/Models/mdlUnit.dart';
import 'package:jaruern_mini_pos/settingValues.dart';


class DeclareValue{
  static String DefaultCulture = 'th';

  static String GuidEmpty = '00000000-0000-0000-0000-000000000000';
  static bool isGMSSupport = false;
  static bool isHMSSupport = false;
  static String redirectMapUrl = 'http://goto.jmmsystem.net/Map.html?point=';
  static String defaultDomain = 'jaruerncore.jmmsystem.net';
  static String register_key = 'ezzewXSSwdgpf9d';
  static String Access_ApiKey = 'dVhxW8VwfI6bOmT92sF+M7YZo5SCvUqSRVByRjAES2N2l7pHdCYgSIboEsZpVgYzShiRU1TPuHMzIIdy1lX';
  static String Ticket_ApiKay = 'DJdQS6jNJoLJz7HKBiYL3ZXFx5DGnkxWjaVGceJ6uCo7c+FOqSPKzEPVaHt86aqCyORvRtMZBJnMaahhUyiwk=';

  //message icon
  static Image message_info_icon = Image.asset('assets/images/info_icon.png',height: 27,);
  static Image message_warn_icon = Image.asset('assets/images/warn_icon.png',height: 27,);
  static Image message_error_icon = Image.asset('assets/images/error_icon.png',height: 27,);
  static Image message_complete_icon = Image.asset('assets/images/comp.png',height: 27,);

  static Image c_custype_img = Image.asset('assets/images/cust.png',height: 27,);
  static Image m_custype_img = Image.asset('assets/images/member_icon.png',height: 27,);
  static Image d_custype_img = Image.asset('assets/images/6337252.png',height: 27,);

  static Image NoImage = Image.asset('assets/images/noimg.jpg',);

  static String email = '';
  static String AccessKey = '';
  static String currentStoreId = '';
  static String currentStoreName = '';

  //setting var
  static bool sett_light_onoff = false;
  static bool sett_vatInner = true;
  static String scanSpeedsValue = 'ปกติ';
  static int scanSpeedNormal = 2000;
  static int sett_scanspeed = scanSpeedNormal;
  static double sett_vatRate = 7;

  static List<String> cash_stts = ['C','D','M'];

  static List<Map<String, dynamic>> SettingData = [];

  static List<mdlUnit> units = [];
  static List<mdlReceiptXReason> ReceiptXReasons = [];
  static List<mdlReceiptXReason> ReceiptXReasons2 = [];

  static double limitImageKBSize = 300.0;

  void getAllSetting(){
    SettingValues().getAuthenToken().then((value)=>{DeclareValue.AccessKey = value});
    SettingValues().getEmail().then((value)=>{DeclareValue.email = value});
    SettingValues().getScanSpeed().then((value)=>{DeclareValue.sett_scanspeed = value ?? scanSpeedNormal});
    SettingValues().getLightOnOff().then((value)=>{DeclareValue.sett_light_onoff = value ?? false});
    SettingValues().getVAT().then((value)=>{DeclareValue.sett_vatRate = value!});
    SettingValues().getVatinner().then((value)=>{DeclareValue.sett_vatInner = value!});
  }

  static void UnitPrepareData(BuildContext context){
    BLGoods(context).getUnits(null).then((value) {
      debugPrint(value.toString());

      for(int i=0;i < value.length;i++){
        mdlUnit unit = mdlUnit();
        unit.id = value[i]['key'].toString();
        unit.unit = value[i]['value'].toString();
        DeclareValue.units.add(unit);
      }
    });
  }

  static void ReasonXPrepareData(BuildContext context,int delType) {
    List<Map<String, dynamic>> Reasons = [];

    if(delType == 1) {
      Reasons = [
        {'Code': '01', 'Reason': 'ข้อมูลสินค้าไม่ถูกต้อง'},
        {'Code': '02', 'Reason': 'ปริมาณสินค้าไม่ถูกต้อง'},
        {'Code': '03', 'Reason': 'จำนวนเงินไม่ถูกต้อง'},
        {'Code': '04', 'Reason': 'ข้อมูลลูกค้าไม่ถูกต้อง'},
        {'Code': '00', 'Reason': 'อื่นๆ โปรดระบุ'},
      ];
    } else if(delType == 2) {
      Reasons = [
        {'Code': 'X1', 'Reason': 'ยกเลิกการซื้อ/ขาย'},
        {'Code': 'X0', 'Reason': 'อื่นๆ โปรดระบุ'},
      ];
    }

    for (var r in Reasons) {
      mdlReceiptXReason value = mdlReceiptXReason();
      value.Code = r['Code'];
      value.Reason = r['Reason'];

      if(delType==1){
        DeclareValue.ReceiptXReasons.add(value);
      }else{
        DeclareValue.ReceiptXReasons2.add(value);
      }
    }
  }
  
  static List<mdlItem> CashPercentRate(){
    List<mdlItem> result = [];
    mdlItem cashPercentItem = mdlItem();
    cashPercentItem.Key = '30';
    cashPercentItem.Text = '(เฉพาะสมาชิก) 30%';
    cashPercentItem.Value = '30';
    result.add(cashPercentItem);

    cashPercentItem = mdlItem();
    cashPercentItem.Key = '50';
    cashPercentItem.Text = '50%';
    cashPercentItem.Value = '50';
    result.add(cashPercentItem);

    cashPercentItem = mdlItem();
    cashPercentItem.Key = '75';
    cashPercentItem.Text = '75%';
    cashPercentItem.Value = '75';
    result.add(cashPercentItem);

    cashPercentItem = mdlItem();
    cashPercentItem.Key = '100';
    cashPercentItem.Text = 'ชำระทั้งหมด';
    cashPercentItem.Value = '100';
    result.add(cashPercentItem);

    return result;
  }

}