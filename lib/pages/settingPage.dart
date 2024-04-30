

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blSetting.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:jaruern_mini_pos/settingValues.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class SettingPage extends StatelessWidget{
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingPage();
  }

}

class _SettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }

}

class _SettingPageState extends State<_SettingPage>{

  final List<String> _scanSpeeds = <String>['ปกติ','ช้า','เร็ว'];
  bool indicator_list = false;
  final TextEditingController _vatController = TextEditingController();

  bool update_vat = false;
  bool update_vatin = false;

  @override
  void initState(){
    super.initState();

    LoadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        SaveSetting();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue.shade200,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/setting_gear.png',height: 25,),
              const Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                child: Text('ตั้งค่าการใช้งาน'),
              ),
              GestureDetector(
                  onTap: ()=>SaveSetting(),
                  child: Image.asset('assets/images/close_cross.png',height: 20,)
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            ServiceUI.Indicater(indicator_list),
            Expanded(child: SettingItem()),
          ],
        ),
      ),
    );
  }

  void LoadSetting(){
    try {
      _vatController.text = DeclareValue.sett_vatRate.toString();
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void SaveSetting(){
    try{
      setState(() {
        indicator_list = true;
      });

      double vat = double.tryParse(_vatController.text) ?? 0;
      SettingValues().setVAT(vat);

      List<Map<String, dynamic>> settValues = [];
      if(update_vat) {
        settValues.add({
          'key': 'VAT',
          'value': _vatController.text,
          'dType': 'dou'
        });//vat rate
      }

      if(update_vatin){
        settValues.add({
          'key': 'VATIN',
          'value': DeclareValue.sett_vatInner.toString(),
          'dType': 'str'
        });
      }

      if(settValues.isEmpty) {
        Navigator.pop(context);
      }else{
        CanUpdate2DB(settValues);
      }

    }catch(e){
      debugPrint(e.toString());
    }
  }

  void CanUpdate2DB(List<Map<String, dynamic>> settValues)  {
    try{
      BLSetting(context).setValues(settValues).then((value){
        try {
          debugPrint(value.toString());
          int id = int.tryParse(value!['id'].toString()) ?? 0;
          if (id == 0) {
            DeclareValue().getAllSetting();
            ShowToast(context, 'ปรับปรุงการตั้งค่าแล้ว').Show(
                MessageType.complete);
          } else {
            ShowToast(context, 'ปรับปรุงการตั้งค่าไม่สำเร็จ').Show(
                MessageType.warn);
          }

          indicator_list = false;
        }finally{
          Timer(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget SettingItem(){
    return ListView(
      children: [
        itm_LightOnoff(),
        itm_SpeedScan(),
        const Divider(),
        itm_VatOption(),
        itm_VAT(),
      ],
    );
  }

  Widget itm_VAT(){
    return ListTile(
      leading: SizedBox(
        height: 25,
        width: 25,
        child: Image.asset('assets/images/vat_icon.png'),
      ),
      title: const Text('ภาษีมูลค่าเพิ่ม'),
      subtitle: const Text('ตั้งค่าภาษีมูลค่าเพิ่ม VAT เป็น %'),
      trailing: SizedBox(
        width: 70,
        child: TextField(
          controller: _vatController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(4),
            ThousandsFormatter(allowFraction: true)
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          onChanged: (value){
            if(value.isEmpty){
              _vatController.text = '0';
            }else {
              double pers = double.tryParse(value) ?? 0;
              if (pers > 100) {
                _vatController.text = '100';
              }

              setState(() {
                update_vat = false;
                if(pers!=DeclareValue.sett_vatRate){
                  update_vat = true;
                }
              });

            }
          },
        ),
      ),
      onTap: (){
        if(_vatController.text.isNotEmpty) {
          _vatController.selection = TextSelection(baseOffset: 0, extentOffset:_vatController.text.length);
        }
      },
    );
  }

  Widget itm_LightOnoff(){
    return ListTile(
      leading: SizedBox(
        height: 25,
        width: 25,
        child: Image.asset('assets/images/light_icon.png'),
      ),
      title: const Text('เปิด/ปิดไฟ สแกนบาร์โค๊ต'),
      subtitle: const Text('ตั้งค่าปิดหรือเปิดไฟเมื่อใช้กล้องสแกนบารืโค๊ต'),
      trailing: Switch(
        onChanged: (bool? value){
          setState(() {
            DeclareValue.sett_light_onoff = value!;
          });

          SettingValues().setLightOnOff(value!);
        },
        value: DeclareValue.sett_light_onoff,
      ),
      onTap: () {},
    );
  }

  Widget itm_SpeedScan(){
    return ListTile(
      leading: SizedBox(
        height: 25,
        width: 25,
        child: Image.asset('assets/images/speed_icon.png'),
      ),
      title: const Text('ความเร็วในการสแกน'),
      subtitle: const Text('ตั้งค่าความเร็วในการสแกนบารืโค๊ต'),
      trailing: DropdownButton<String>(
        value: DeclareValue.scanSpeedsValue,
        items: _scanSpeeds
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15,
                  color: Colors.blue,fontWeight: FontWeight.bold),
            ),
          );
        }).toList(), onChanged: (String? value) {
          setState(() {
            DeclareValue.scanSpeedsValue = value!;
            switch(value){
              case 'ช้า': DeclareValue.sett_scanspeed = DeclareValue.scanSpeedNormal+1000 ;break;
              case 'เร็ว': DeclareValue.sett_scanspeed = DeclareValue.scanSpeedNormal-1000;break;
              default:
                DeclareValue.sett_scanspeed = DeclareValue.scanSpeedNormal;break;
            }
          });

          debugPrint(DeclareValue.scanSpeedsValue);
          SettingValues().setScanSpeed(DeclareValue.sett_scanspeed);
      },
      ),
      onTap: () {},
    );
  }

  Widget itm_VatOption(){
    return ListTile(
      leading: SizedBox(
        height: 25,
        width: 25,
        child: Image.asset('assets/images/light_icon.png'),
      ),
      title: const Text('VAT ในราคาสินค้า/บริการ'),
      subtitle: const Text('สินค้า/บริการ รวม VAT แล้วหรือคิดภายหลัง'),
      trailing: Switch(
        onChanged: (bool? value){
          setState(() {
            DeclareValue.sett_vatInner = value!;
          });

          SettingValues().setVatinner(value!);

          setState(() {
            update_vatin = true;
          });
        },
        value: DeclareValue.sett_vatInner,
      ),
      onTap: () {},
    );
  }

}