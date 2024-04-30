

import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/numberPad.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

class ReceiptCashPage extends StatelessWidget{
  final double allpay;
  const ReceiptCashPage({super.key,required this.allpay});

  @override
  Widget build(BuildContext context) =>_ReceiptCashPage(allpay);

}

class _ReceiptCashPage extends StatefulWidget{
  late double allpay ;

  _ReceiptCashPage(double _allpay){
    allpay = _allpay;
  }

  @override
  State<StatefulWidget> createState() => _ReceiptCashPageState(allpay);

}

class _ReceiptCashPageState extends State<_ReceiptCashPage>{
  late double allpay ;
  String pay = '0';

  final TextEditingController _cuscashController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();
  final TextEditingController _creditnoController = TextEditingController();

  int cashTypeIndex = 1;
  Image credit = Image.asset('assets/images/credit.png',height: 40,);
  Image cashMoney = Image.asset('assets/images/cuscash.png',height: 40,);
  Color chargColorText = Colors.black;


  _ReceiptCashPageState(double _allpay){
    allpay = _allpay;
    double decimalPoint = allpay - allpay.toInt();
    debugPrint(decimalPoint.toString());

    if(decimalPoint > 0){
      double satang = decimalPoint / 0.25;
      allpay = allpay.toInt() + (satang.ceil() * 0.25);
    }

    pay = NumberFormat("#,##0.00", "en_US").format(allpay);
  }

  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose() {
    _cuscashController.dispose();
    _changeController.dispose();
    _creditnoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.lightBlue.shade200,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              CashType(),
              const SizedBox(height: 5,),
              Visibility(
                  visible: (cashTypeIndex == 2),
                  child: CreditNo()),
              NetPay(),
              CusCash(),
              Visibility(
                  visible: (cashTypeIndex == 1),
                  child: Change()),
              NumberPad(context, _cuscashController,_changeController,allpay
                  ,Colors.lightBlue.shade500,Colors.black).CashPad(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: ()=>DoCash(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Image.asset('assets/images/true_icon.jpg',height: 45,),
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> DoCash() async {
    try{
      double cuscash = double.tryParse(
          _cuscashController.text.replaceAll(',', '')) ?? 0.00;
      if (allpay > cuscash) {
        ShowToast.Gravity(context, 'จำนวนเงินไม่สามารถชำระค่าสินค้าได้',
            ToastGravity.CENTER).Show(MessageType.warn);
      } else {
        if (await confirm(context,
          title: const Text('ชำระค่าสินค้า'),
          content: const Text('ต้องการบันทึกใบกำกับภาษีหรือไม่?'),
          textOK: const Text('ใช่'),
          textCancel: const Text('ยังก่อน'),
        )) {
          ServiceSound().CashSound();
          double cuschange = double.tryParse(
              _changeController.text.replaceAll(',', '')) ?? 0.00;
          Map<String, dynamic> data = {
            'custype': cashTypeIndex,
            'cuscash': (cashTypeIndex == 1) ? cuscash : 0,
            'cuschange': (cashTypeIndex == 1) ? cuschange : 0,
            'creaditno': _creditnoController.text,
            'cuscredit': (cashTypeIndex == 2) ? cuscash : 0
          };

          Navigator.pop(context, data);
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget CashType(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
            onTap: (){
              setState(() {
                cashTypeIndex = 1;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Row(
                children: [
                  cashMoney,
                  const Text('เงินสด'),
                ],
              ),
            )
        ),
        GestureDetector(
            onTap: (){
              setState(() {
                cashTypeIndex = 2;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Row(
                children: [
                  credit,
                  const Text('เครดิต'),
                ],
              ),
            )
        ),
      ],
    );
  }
  
  Widget NetPay(){
    return Card(
        elevation: 5,
        color: Colors.lightBlue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/summ.png',height: 30,),
              Text(pay,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
            ],
          ),
        ));
  }

  Widget CashTypeIcon(){
    switch(cashTypeIndex){
      case 2: return Image.asset('assets/images/credit.png',height: 30,);break;
      default:
        return Image.asset('assets/images/cuscash.png',height: 30,);break;
    }
  }

  Widget CusCash(){
    return Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CashTypeIcon(),
              const SizedBox(width: 50,),
              Expanded(child: TextField(
                controller: _cuscashController,
                readOnly: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  ThousandsFormatter(allowFraction: true)
                ],
                decoration: const InputDecoration(
                  hintText: 'จำนวนเงินชำระ',
                ),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 17),
              )
              ),
            ],
          ),
        ));
  }

  Widget Change(){
    return Card(
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/cash_change.png',height: 30,),
              const SizedBox(width: 100,),
              Expanded(child: TextField(
                controller: _changeController,
                readOnly: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  ThousandsFormatter(allowFraction: true)
                ],
                decoration: const InputDecoration(
                  hintText: 'เงินทอน',
                ),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 17,color: chargColorText),
              )
              ),
            ],
          ),
        ));
  }

  Widget CreditNo(){
    return Card(
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/credit_no_icon.png',height: 30,),
              const SizedBox(width: 50,),
              Expanded(child: TextField(
                controller: _creditnoController,
                readOnly: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-z A-Z 0-9]')),
                ],
                decoration: const InputDecoration(
                  hintText: 'เลขที่/รหัสเครดิต',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
                onChanged: (value){
                  _creditnoController.value = TextEditingValue(
                    text: value.toUpperCase(),
                    selection: _creditnoController.selection
                  );
                },
              )
              ),
            ],
          ),
        ));
  }

}