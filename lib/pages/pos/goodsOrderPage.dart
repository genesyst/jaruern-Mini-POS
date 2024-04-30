

import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/Models/mdlGoodsOrder.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/pos/holdOrderCashPage.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceScan.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:vibration/vibration.dart';

class GoodsOrderPage extends StatelessWidget{
  const GoodsOrderPage({super.key});

  @override
  _GoodsOrderPage build(BuildContext context) => _GoodsOrderPage();
}

class _GoodsOrderPage extends StatefulWidget{

  @override
  _GoodsOrderPageState createState()=> _GoodsOrderPageState();
}

class _GoodsOrderPageState extends State<_GoodsOrderPage>{

  int _search_length = 0;
  final TextEditingController _searchEditController = TextEditingController();

  late DateTime _currentDate;
  TimeOfDay _currentTime = TimeOfDay.now();

  String _currentDateStr = '';
  String _currentTimeStr = '';

  bool loading = false;
  List<Map<String,dynamic>> data = [];
  List<Map<String,dynamic>> dataItems = [];
  List<mdlGoodsOrder> dataItemSelected = [];
  String BarcodeScan = '';

  double summ_cash = 0;
  int summ_pie = 0;
  double summ_dis = 0;

  String memberid = 'เลขสมาชิก';
  String cash_status = 'C';
  bool isMember = false;
  bool askMemberValidate = false;
  int havePieValue = 0;

  _GoodsOrderPageState(){
    _currentDate = DateTime.now();
  }

  @override
  void initState() {
    super.initState();

    _searchEditController.addListener(() {
      setState(() => _search_length = _searchEditController.text.length);
    });

    setState(() {
      _currentDateStr = ServiceDateTimeUtils.SetType(DateYearType.Buddhist)
          .DateToString(_currentDate, Date2String.fullmonth);
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentTime = TimeOfDay.now();
        _currentTimeStr = ServiceDateTimeUtils.Parant(context).TimeToString(_currentTime,true);

      });
    });

    Filter(false);
  }

  Future<void> Filter(bool Scanning) async {
    try{
      setState(() {
        loading = true;
        dataItems = [];
      });

      if(data.isEmpty) {
        var goodsList = await BLSale(context).GetSaleProductOrder(
            DeclareValue.currentStoreId);
        debugPrint(goodsList.toString());

        setState(() {
          data = goodsList;
        });
      }

      if(Scanning){
        if(BarcodeScan.isNotEmpty){
          var fil = data.where((e) => e['skuBarcode'].toString().toUpperCase().contains(BarcodeScan)).first;

          setState(() {
            dataItems.add(fil);
          });
        }else {
          setState(() {
            dataItems = data;
          });
        }
      }else {
        String filterTxt = _searchEditController.text.trim().toUpperCase();
        if (filterTxt.isNotEmpty) {
          var fil = data.where((e) =>
          e['skuBarcode'].toString().toUpperCase().contains(filterTxt) ||
              e['skucode'].toString().toUpperCase().contains(filterTxt) ||
              e['skuname'].toString().toUpperCase().contains(filterTxt)
          ).toList();

          setState(() {
            dataItems = fil;
          });
        } else {
          setState(() {
            dataItems = data;
          });
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade200,
        automaticallyImplyLeading: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SearchBoxBar(),
            GestureDetector(
                onTap: ()=> Scanbarcode(),
                child: Image.asset('assets/images/barcode_scanner.png',height: 20,)
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SetOrderTime(),
          ServiceUI.Indicater(loading),
          Expanded(child: GoodsList()),
        ],
      ),
      bottomNavigationBar: Footer(),
    ));
  }

  Widget Footer(){
    SummSelectHaveGoodsPie();

    String pieceValue = NumberFormat("#,##0", "en_US").format(summ_pie);
    String cashValue = NumberFormat("#,##0.00", "en_US").format(summ_cash);
    String disValue = NumberFormat("#,##0.00", "en_US").format(summ_dis);

    if(summ_cash > 10000){
      double sCash = summ_cash / 1000;
      cashValue = '${NumberFormat("#,##0.00", "en_US").format(sCash)}K';
    }

    if(summ_dis > 10000){
      double sDis = summ_dis / 1000;
      cashValue = '${NumberFormat("#,##0.00", "en_US").format(sDis)}K';
    }

    return Visibility(
      visible: havePieValue > 0,
      child: Container(
        color: Colors.lightBlue.shade200,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: ()=> SetMemberNumber(),
                    onLongPress: (){
                      if(isMember) {
                        Vibration.vibrate(duration: 100);
                        setState(() {
                          isMember = false;
                          memberid = 'เลขสมาชิก';

                          cash_status = 'C';
                        });

                        ShowToast(context,'ยกเลิกเลขสมาชิกแล้ว').Show(MessageType.info);
                        ReItem2MemberPrice();
                      }
                    },
                    child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                          child: Row(
                            children: [
                              Image.asset('assets/images/memcard.png',height: 22),
                              const SizedBox(width: 5,),
                              Text(memberid,),
                            ],
                          ),
                        )
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                        child: Row(
                          children: [
                            Image.asset('assets/images/goods2.png',height: 22),
                            Text(' $pieceValue',),
                            const SizedBox(width: 5,),
                            Image.asset('assets/images/sale_icon.png',height: 22),
                            Text(' ${cashValue.replaceAll('.00', '')}',),
                            const SizedBox(width: 5,),
                            Image.asset('assets/images/dis_icon.png',height: 22),
                            Text(' ${disValue.replaceAll('.00', '')}',),
                          ],
                        ),
                      )
                  ),
                  FilledButton(
                      onPressed: ()=>AddGoodsOrder(),
                      child: const Text('ถัดไป')
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget SetOrderTime(){
    return Container(
      color: Colors.lightBlue.shade200,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DatePicker(),
            const SizedBox(width: 5,),
            TimePicker(),
          ],
        ),
      ),
    );
  }

  Widget TimePicker(){
    return GestureDetector(
      onTap: () =>TimePick(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/clock_icon.png',height: 20,),
          const SizedBox(width: 5,),
          Text(_currentTimeStr,style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Future<void> TimePick() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _currentTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      String formattedTime = ServiceDateTimeUtils.Parant(context).TimeToString(newTime,true);
      setState(() {
        _currentTime = newTime;
        _currentTimeStr = formattedTime;
        debugPrint(_currentTime.toString());
      });
    }
  }

  Widget DatePicker(){
    return GestureDetector(
      onTap: () =>DatePick(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/calendar_icon.png',height: 20,),
          const SizedBox(width: 10,),
          Text(_currentDateStr,style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  DatePick() {
    try {
      ServiceUI.Style(Colors.lightBlue.shade200, DeclareValue.DefaultCulture)
          .DatePicker(context,_currentDate).then((value){
        if(value!=null){
          setState(() {
            _currentDate = value;
            _currentDateStr = ServiceDateTimeUtils.SetType(DateYearType.Buddhist)
                .DateToString(_currentDate, Date2String.fullmonth);

          });
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void SetMemberNumber(){
    try{
      ServiceScan().scanBarcodeNormal().then((value) {
        if(value!='-1') {
          ServiceSound().ScanSound();

          setState(() {
            memberid = value;
            isMember = true;
            cash_status = 'M';
          });
        }else{
          setState(() {
            memberid = 'เลขสมาชิก';
            isMember = false;
          });
        }

        ReItem2MemberPrice();
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> AddGoodsOrder() async {
    if(!isMember && !askMemberValidate) {
      setState(() {
        askMemberValidate = true;
      });

      if (await confirm(context,
        title: const Text('สั่ง/จองสินค้า'),
        content: Text(
            'ลูกค้าเป็นสมาชิกหรือไม่? ถ้าเป็นกรุณาระบุรหัสสมาชิกก่อน'),
        textOK: const Text('ไม่ใช่สมาชิก'),
        textCancel: const Text('ตรวจสอบอีกครั้ง'),
      )) {
        CashOrderPage();
      }
    }else{
      CashOrderPage();
    }

  }

  void CashOrderPage(){
    String _memberId = '';
    if(isMember){
      _memberId = memberid;
    }

    DateTime orderDate = DateTime(_currentDate.year,
                                      _currentDate.month,
                                      _currentDate.day,
                                      _currentTime.hour,
                                      _currentTime.minute,0);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return HoldOrderCashPage(
                orders: dataItemSelected,
                netPay: summ_cash,
                discount: summ_dis,
                memberId: _memberId,
                atdate: orderDate,
                orderCommit: false,
                depositOrderId: '',
          );
        }).then((value) {

      if(value['result']=='closed'){
        Navigator.pop(context);
      }

    });
  }

  Widget Detail(Map<String,dynamic> item){
    mdlGoodsOrder? itemSel = IsSelectItem(item);

    TextEditingController _PriceItemController = TextEditingController();
    TextEditingController _PieceItemController = TextEditingController();

    if(itemSel!=null) {
      String priceValue = NumberFormat("#,##0.00", "en_US").format(itemSel.price);
      _PriceItemController.text = priceValue;

      String pieseValue = NumberFormat("#,##0", "en_US").format(itemSel.piece);
      _PieceItemController.text = pieseValue;
    }

    String SkuName = item['skuname'].toString();
    int amtInStock = int.tryParse(item['amt_Pie'].toString()) ?? 0;

    double goodsPrice = double.tryParse(item['price'].toString()) ?? 0;
    double goodsDiscount = 0;
    if(isMember){
      double memPrice = double.tryParse(item['member'].toString()) ?? 0;
      if(memPrice > 0){
        goodsDiscount = goodsPrice - memPrice;
        goodsPrice = memPrice;
      }
    }

    return Visibility(
      visible: itemSel!=null,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _PieceItemController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsFormatter(allowFraction: true)
                          ],
                          decoration: const InputDecoration(
                            hintText: 'จำนวน',
                          ),
                          style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),
                          onTap: (){
                            _PieceItemController.selection = TextSelection(baseOffset: 0, extentOffset: _PieceItemController.text.length);
                          },
                          onChanged: (text){
                            if(_PieceItemController.text.isEmpty){
                              _PriceItemController.text = '0.00';
                            }else {
                              int pie = int.parse(text);
                              if(pie > 0) {
                                double summPrice = pie * goodsPrice;
                                _PriceItemController.text =
                                    NumberFormat("#,##0.00", "en_US").format(
                                        summPrice);
                              }
                            }
                          },
                          onSubmitted: (text){
                            if(_PieceItemController.text.isNotEmpty){
                              int pie = int.parse(text);
                              if(pie > amtInStock){
                                pie = amtInStock;
                                _PieceItemController.text = amtInStock.toString();

                                ShowToast(context,'สินค้า \n$SkuName \nมีเหลือไม่เพียงพอ').Show(MessageType.warn);
                              }

                              debugPrint('Discount $goodsDiscount');
                              UpdateSelectItem(item, pie, goodsPrice,goodsDiscount);
                            }else{
                              RemoveSelectItem(item);
                            }

                            SummSelectHaveGoodsPie();
                          },
                        ),
                      ),
                      const SizedBox(width: 20,),
                      Flexible(
                        child: TextField(
                          controller: _PriceItemController,
                          readOnly: true,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                              hintText: 'ราคารวม'
                          ),
                        ),
                      ),
                      const SizedBox(width: 20,),
                      GestureDetector(
                        onTap: ()=> RemoveSelectItem(item),
                        child: Image.asset('assets/images/close_cross.png',height: 20,),
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget GoodsList(){
    return ListView.separated(
      itemCount: dataItems.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context,int index){
        final item = dataItems[index];
        return Column(
          children: [
            GoodsItem(item,index),
          ],
        );
      },separatorBuilder: (BuildContext context, int index) {
      return const Divider();
    },
    );
  }

  Widget GoodsItem(Map<String,dynamic> item,int index){
    return Slidable(
      key: ValueKey(index),

      child: Ink(
      color: IsSelectItem(item)!=null?Colors.yellow.shade200: Colors.transparent,
      child: ListTile(
        onTap: (){
          AddSelectItem(item);
        },
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: Text(item['skuname'].toString(),style: const TextStyle(fontSize: 15),)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['skuBarcode'].toString(),style: const TextStyle(fontSize: 15),),
                Row(
                  children: [
                    Image.asset('assets/images/size_icon.png',height: 20,),
                    Text(item['skuSize'].toString(),style: const TextStyle(fontSize: 12),),
                  ],
                ),
              ],
            ),
          ],
        ),
        subtitle: Detail(item),
      ),
    ),
    );
  }

  void AddSelectItem(Map<String,dynamic> item){
    try {
      mdlGoodsOrder? isSel = IsSelectItem(item);
      if(isSel!=null){
        return;
      }

      mdlGoodsOrder newVal = mdlGoodsOrder();
      newVal.id = item['id'].toString();
      newVal.goodsName = item['skuname'].toString();
      newVal.barcode = item['skuBarcode'].toString();
      newVal.size = item['skuSize'].toString();
      newVal.amtpiece = int.parse(item['amt_Pie'].toString());
      newVal.piece = 0;
      newVal.price = 0;
      newVal.goodsId = item['goodsId'].toString();
      newVal.saleprice = double.parse(item['price'].toString());

      setState(() {
        dataItemSelected.add(newVal);
      });
    }finally{
      if(dataItemSelected.isNotEmpty){
        debugPrint(dataItemSelected.length.toString());
      }
    }

  }

  void UpdateSelectItem(Map<String,dynamic> item,int pie,double price,double discount){
    mdlGoodsOrder? isSel = IsSelectItem(item);
    if(isSel==null){
      return;
    }

    String id = item['id'].toString();
    String barcode = item['skuBarcode'].toString();

    for(var selected in dataItemSelected){
      if(selected.id.toUpperCase() == id.toUpperCase() &&
          selected.barcode.toUpperCase() == barcode.toUpperCase()){
          selected.piece = pie;
          selected.price = pie * price;
          selected.discount = pie * discount;

          debugPrint('${selected.goodsName} -> ${selected.piece} -> ${selected.discount}');

          break;
      }
    }
  }

  void RemoveSelectItem(Map<String,dynamic> item){
    try {
      for (var d in dataItemSelected) {
        String id = item['id'].toString().toUpperCase();
        if (id == d.id.toUpperCase()) {
          setState(() {
            dataItemSelected.remove(d);
          });

          break;
        }
      }
    }finally{
      if(dataItemSelected.isNotEmpty){
        debugPrint(dataItemSelected.length.toString());
      }
    }
  }

  mdlGoodsOrder? IsSelectItem(Map<String,dynamic> item){
    for(var d in dataItemSelected){
      String id = item['id'].toString().toUpperCase();
      if(id == d.id.toUpperCase()){
        return d;
      }
    }

    return null;
  }

  void SummSelectHaveGoodsPie(){
    int pies = 0;
    double prices = 0;
    double disc = 0;
    for(var item in dataItemSelected){
      pies += item.piece;
      prices += item.price;
      disc += item.discount;
    }

    setState(() {
      havePieValue = pies;
      summ_pie = pies;
      summ_cash = prices;
      summ_dis = disc;
    });
  }

  void ReItem2MemberPrice(){
    for (var item in dataItemSelected) {
      var goods = data
          .where((e) => e['id'] == item.id && e['goodsId']==item.goodsId && e['skuBarcode']==item.barcode)
          .first;
      if(goods.isNotEmpty){
        double price = double.parse(goods['price'].toString());
        double mem = double.parse(goods['member'].toString());
        double dis = price - mem;

        if(isMember) {
          if(mem > 0.0) {
            item.price = mem * item.piece;
            item.discount = dis * item.piece;
          }
        }else{
          item.price = price * item.piece;
          item.discount = 0;
        }
      }
    }
  }

  void Scanbarcode(){
    try{
      ServiceScan().scanBarcodeNormal().then((value) {
        if(value!='-1') {
          ServiceSound().ScanSound();
          setState(() {
            BarcodeScan = value;
          });

          if(BarcodeScan.isNotEmpty){
            _searchEditController.text = '';
          }

          ShowToast(context,BarcodeScan).Show(MessageType.info);

          Filter(true);
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  Widget SearchBoxBar(){
    return Flexible(
      child: TextField(
        controller: _searchEditController,
        decoration: InputDecoration(
          hintText: 'ค้นหา',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
          suffixIcon: SearchBoxBtn(),
        ),
        onChanged: (text)=>Filter(false),
      ),
    );
  }

  Widget? SearchBoxBtn(){
    if(_search_length > 0){
      return IconButton(
        onPressed: (){
          _searchEditController.text = '';

        },
        icon: const Icon(Icons.clear),
      );
    }else{
      return null;/*IconButton(
        onPressed: _searchEditController.clear,
        icon: Icon(Icons.search),
      );*/
    }
  }

}