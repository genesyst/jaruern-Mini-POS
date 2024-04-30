

import 'dart:io';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/Models/mdlGoodsOrder.dart';
import 'package:jaruern_mini_pos/Models/mdlItem.dart';
import 'package:jaruern_mini_pos/Models/mdlNewReceript.dart';
import 'package:jaruern_mini_pos/declareTemp.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/pos/receiptDetailPage.dart';
import 'package:jaruern_mini_pos/plug-in/numberPad.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

class HoldOrderCashPage extends StatelessWidget{
  final List<mdlGoodsOrder> orders;
  final double netPay;
  final double discount;
  final String memberId;
  final DateTime atdate;
  final bool orderCommit;
  final String depositOrderId;
  const HoldOrderCashPage({super.key,
                            required this.orders,
                            required this.netPay,
                            required this.discount,
                            required this.memberId,
                            required this.atdate,
                            required this.orderCommit,
                            required this.depositOrderId
  });

  @override
  Widget build(BuildContext context) => _HoldOrderCashPage(orders,netPay,
                          discount,memberId,atdate,
                          orderCommit,depositOrderId);

}

class _HoldOrderCashPage extends StatefulWidget{
  late List<mdlGoodsOrder> orders;
  late double netPay;
  late double discount;
  late String memberId;
  late DateTime atdate;
  late bool orderCommit;
  late String depositOrderId;

  _HoldOrderCashPage(List<mdlGoodsOrder> _order,double _netpay,double _discount,
                        String _memberId,DateTime _atdate,bool _orderCommit,String _depositOrderId){
    orders = _order;
    netPay = _netpay;
    memberId = _memberId;
    discount = _discount;
    atdate = _atdate;
    orderCommit = _orderCommit;
    depositOrderId = _depositOrderId;
  }

  @override
  State<StatefulWidget> createState() => _HoldOrderCashPageState(orders,netPay,
                                                discount,memberId,atdate,
                                                orderCommit,depositOrderId);

}

class _HoldOrderCashPageState extends State<_HoldOrderCashPage>{
  late List<mdlGoodsOrder> orders;
  late DateTime orderDate;
  late String orderDateParam;

  final TextEditingController _cuscashController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();

  Image credit = Image.asset('assets/images/credit.png',height: 40,);
  Image cashMoney = Image.asset('assets/images/cuscash.png',height: 40,);
  Color chargColorText = Colors.black;

  double allpay = 0;
  double allpayRate = 0;
  double discount = 0;
  String memberId = '';

  List<mdlItem> cashPercent = [];
  List<DropdownMenuItem<mdlItem>> cashPercentItem = [];
  mdlItem? cashPercentValue;

  bool indicator = false;
  bool orderCommit = false;

  String depositeOrderId = '';

  _HoldOrderCashPageState(List<mdlGoodsOrder> _order,
                                  double netpay,double _discount,
                                  String _memberId,DateTime _atdate,
                                  bool _orderCommit,String _depositOrderId
      ){
    orders = _order;
    allpay = netpay;
    allpayRate = allpay;
    memberId = _memberId;
    discount = _discount;
    orderDate = _atdate;
    orderCommit = _orderCommit;
    depositeOrderId = _depositOrderId.trim();

  }


  @override
  void initState() {
    super.initState();

    String timeParam = '-${orderDate.hour}-${orderDate.minute}-00';

    setState(() {
      cashPercent = DeclareValue.CashPercentRate();
      cashPercentValue = cashPercent.last;

      orderDateParam = ServiceDateTimeUtils().DateToParam(orderDate)+timeParam;
    });

    if(depositeOrderId.isNotEmpty){
      if(allpay == 0.0){
        DateTime currentNow = DateTime.now();
        timeParam = '-${currentNow.hour}-${currentNow.minute}-00';
        setState(() {
          orderDateParam = ServiceDateTimeUtils().DateToParam(currentNow)+timeParam;
        });

        SaveOrderReceipt('RPT');
      }else{
        setState(() {
          discount = 0.0;
        });
      }
    }

  }

  @override
  void dispose() {
    _cuscashController.dispose();
    _changeController.dispose();

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
              CashOption(),
              NetPay(),
              CusCash(),
              Change(),
              NumberPad(context, _cuscashController,_changeController,allpayRate
                  ,Colors.lightBlue.shade500,Colors.black).CashPad(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ServiceUI.Indicater(indicator),
                  Visibility(
                    visible: !indicator,
                    child: GestureDetector(
                        onTap: ()=>DoCash(),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Image.asset('assets/images/true_icon.jpg',height: 45,),
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget CashOption(){
    cashPercentItem = cashPercent.map((item) {
      return DropdownMenuItem<mdlItem>(
        key:  UniqueKey(),
        value: item,
        child: Center(child: Text(item.Text)),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('อัตราชำระ',style: TextStyle(fontSize: 15),),
          IgnorePointer(
            ignoring: orderCommit,
            child: DropdownButton<mdlItem>(
              items: cashPercentItem,
              value: cashPercentValue,
              onChanged: (mdlItem? selItem)=>SetCashRate(selItem),
            ),
          ),
        ],
      ),
    );
  }

  void SetCashRate(mdlItem? selItem){
    int value = int.parse(selItem!.Value.toString());
    if(value == 30){
      if(memberId.isEmpty){
        ShowToast(context,'อัตราชำระใช้กับสมาชิกเท่านั้น').Show(MessageType.error);
        return;
      }
    }

    _cuscashController.text = '';
    _changeController.text = '';

    double pers = allpay / 100.00;

    setState(() {
      cashPercentValue = selItem;
      allpayRate = pers * value;
    });
  }

  Widget NetPay(){
    String allpayValue = NumberFormat("#,##0.00", "en_US").format(allpayRate);
    return Card(
        elevation: 5,
        color: Colors.lightBlue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/summ.png',height: 30,),
              Text(allpayValue,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
            ],
          ),
        ));
  }

  Widget CusCash(){
    return Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset('assets/images/cuscash.png',height: 30,),
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

  Future<void> DoCash() async {
    try {
      if(_changeController.text.isNotEmpty) {
        double changeVal = double.parse(_changeController.text);
        if(changeVal < 0.00){
          ShowToast.Gravity(context, 'จำนวนเงินไม่สามารถชำระค่าสินค้าได้',
              ToastGravity.CENTER).Show(MessageType.warn);
        }else {
          if(orderCommit){
            if (await confirm(context,
              title: const Text('รับสินค้า'),
              content: const Text('ต้องการบันทึกใบกำกับภาษีการสั่งสินค้าหรือไม่?'),
              textOK: const Text('ใช่'),
              textCancel: const Text('ยังก่อน'),
            )) {
              SaveOrderReceipt('RPT');
            }
          }else {
            if (await confirm(context,
              title: const Text('สั่งสินค้า'),
              content: const Text('ต้องการบันทึกใบสั่งสินค้าหรือไม่?'),
              textOK: const Text('ใช่'),
              textCancel: const Text('ยังก่อน'),
            )) {
              SaveOrderReceipt('ORD');
            }
          }
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void SaveOrderReceipt(String Code){
    setState(() {
      indicator = true;
    });

    double cuscash = double.tryParse(_cuscashController.text) ?? 0.00;
    double cuschg = double.tryParse(_changeController.text) ?? 0.00;
    double summ_vat = 0.00;
    String cashType = 'C';

    if(DeclareValue.sett_vatInner){
        summ_vat = (allpayRate / 100) * DeclareValue.sett_vatRate;
    }

    if(memberId.isNotEmpty){
      cashType = 'M';
    }



    try{
      mdlNewReceript OrderReceript = mdlNewReceript();
      OrderReceript.culture = DeclareValue.DefaultCulture;
      OrderReceript.atdate =  orderDateParam;
      OrderReceript.storeid = DeclareValue.currentStoreId;
      OrderReceript.cash = 0;
      OrderReceript.vat = summ_vat;
      OrderReceript.discount = discount;
      OrderReceript.fullprice = allpay;
      OrderReceript.deposit = 0;

      if(allpayRate < allpay){
        OrderReceript.deposit = allpayRate;
      }else if(allpayRate == allpay){
        OrderReceript.cash = allpayRate;
      }

      //cus cash
      OrderReceript.cashType = 1;
      OrderReceript.cusCash = cuscash;
      OrderReceript.cusChange = cuschg;
      OrderReceript.creditNo = '';
      OrderReceript.cusCredit = 0;
      OrderReceript.memberId = memberId;

      OrderReceript.typeCode = Code;
      OrderReceript.remark = '';
      OrderReceript.vatRate = DeclareValue.sett_vatRate;
      OrderReceript.taxRate = 0;

      OrderReceript.refid = '';
      if(depositeOrderId.isNotEmpty){
        OrderReceript.refid = depositeOrderId;
      }

      List<Map<String, dynamic>> goodsValues = [];

      for(var ord in orders){
        try {
          goodsValues.add({
            'goodsid': ord.goodsId,
            'piece': ord.piece,
            'salePrice': ord.saleprice,
            'cash': ord.price,
            'cashType': cashType,
          });
        }catch(e){
          debugPrint(e.toString());
        }
      }

      BLSale(context).NewReceript(OrderReceript, goodsValues).then((res) {
        debugPrint(res.toString());

        ServiceSound().CashSound();

        int id = int.tryParse(res['id'].toString()) ?? -1;
        String msg = res['msg'].toString();
        if(id == 0){
          ShowToast(context,'บันทึกใบเสร็จแล้ว').Show(MessageType.complete);
          String orderId = msg;
          OpenOrderSlip(orderId);
        }else{
          ShowToast(context,'ไม่สามารถบันทึกใบเสร็จได้').Show(MessageType.error);
        }
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        setState(() {
          indicator = false;
        });
      });
    }catch(e){
      debugPrint(e.toString());
    }finally{
      setState(() {
        indicator = false;
      });
    }
  }

  void OpenOrderSlip(String orderId){
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) =>
                ReceiptDetailPage(id: orderId, QuickShow: true,)))
        .then((value) {
      if (value['result'] == 'closed') {
        Navigator.pop(context, {'result': 'closed'});
      }
    });
  }


}