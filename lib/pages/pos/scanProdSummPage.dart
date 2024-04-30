

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/Models/mdlNewReceript.dart';
import 'package:jaruern_mini_pos/declareTemp.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/pages/pos/receiptCashPage.dart';
import 'package:jaruern_mini_pos/plug-in/showSnack.dart';
import 'package:jaruern_mini_pos/localLib/posWidget.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

import '../../defineType.dart';

class ScanProdSummPage extends StatelessWidget{
  final DateTime currentDate;
  final String memberid;
  const ScanProdSummPage({super.key,required this.currentDate,required this.memberid});

  @override
  Widget build(BuildContext context) => _ScanProdSummPage(currentDate,memberid);

}

class _ScanProdSummPage extends StatefulWidget{
  late DateTime _currentDate;
  late String _memberid;

  _ScanProdSummPage(DateTime currentDate,String memberid){
    _currentDate = currentDate;
    _memberid = memberid;
  }

  @override
  State<StatefulWidget> createState() => _ScanProdSummPageState(_currentDate,_memberid);

}

class _ScanProdSummPageState extends State<_ScanProdSummPage>{
  late Timer _timer;
  late DateTime _currentDate;
  TimeOfDay _currentTime = TimeOfDay.now();

  String _currentDateStr = '';
  String _currentTimeStr = '';

  List<Map<String, dynamic>> DataItem = [];

  bool indicator_list = false;

  final _searchEditController = TextEditingController();
  int _search_length = 0;

  String title = 'ใบเสร็จ';
  String remarkcap = 'หมายเหตุ';
  String recript_remark = 'หมายเหตุ';

  int summ_pie = 0;
  double summ_cash_net = 0.00;
  double summ_cash = 0.00;
  double summ_dis = 0.00;
  double summ_pay = 0.00;
  double summ_vat = 0.00;

  bool saving = false;

  String _memberid = '';
  Color normalColor = Colors.lightBlue.shade200;
  Color memberColor = Colors.lightGreen.shade400;

  final TextEditingController _remarkController = TextEditingController();
  TextStyle style_sumcash = const TextStyle(fontSize: 17);

  _ScanProdSummPageState(DateTime currentDate,String memberid){
    _currentDate = currentDate;
    _memberid = memberid;
  }

  @override
  void initState(){
    super.initState();

    debugPrint(DeclareTemp.sale_recript.toString());

    _searchEditController.addListener(() {
      setState(() => _search_length = _searchEditController.text.length);
    });

    setState(() {
      _currentDateStr = ServiceDateTimeUtils.SetType(DateYearType.Buddhist)
          .DateToString(_currentDate, Date2String.fullmonth);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = TimeOfDay.now();
        _currentTimeStr = ServiceDateTimeUtils.Parant(context).TimeToString(_currentTime,true);
      });
    });

    Filter('');
    PrepareSumm();

  }

  @override
  void dispose() {
    _searchEditController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return Future.value(true);
      },
      child: SafeArea(child: Scaffold(
        appBar: AppBar(
          backgroundColor: _memberid.isEmpty? normalColor:memberColor,
          title: SearchBoxBar(),
          automaticallyImplyLeading: true,
          actions: [
            Row(
              children: [
                Visibility(
                  visible: !saving,
                  child: GestureDetector(
                      onTap: ()=>SaveRecript(),
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
        body: Column(
          children: [
            Divider(height: 1,color: Colors.lightBlue.shade400,),
            Visibility(
                visible: !saving,
                child: SetReceiptTime()),
            ServiceUI.Indicater(indicator_list),
            Visibility(
                visible: !saving,
                child: Expanded(child: SaleListView(context))),
          ],
        ),
        bottomNavigationBar: Visibility(
            visible: !saving,
            child: Footer()),
      ),
      ),
    );
  }

  Future<void> SaveRecript() async {
    try{
      var cash_result = await showDialog(context: context,
          builder: (BuildContext context){
            return  ReceiptCashPage(allpay: summ_cash_net,);
          });

      if(cash_result!=null){
        Save(cash_result);
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> Save(Map<String,dynamic> CusCash) async {
    setState(() {
      saving = true;
      indicator_list = true;
    });

    int custype = int.tryParse(CusCash['custype'].toString()) ?? 0;
    double cuscash = double.tryParse(CusCash['cuscash'].toString()) ?? 0.00;
    double cuschg = double.tryParse(CusCash['cuschange'].toString()) ?? 0.00;
    double cuscredit = double.tryParse(CusCash['cuscredit'].toString()) ?? 0.00;

    if(custype == 0){
      return;
    }

    String timeParam = '-${_currentTime.hour}-${_currentTime.minute}-00';

    mdlNewReceript newReceript = mdlNewReceript();
    newReceript.culture = DeclareValue.DefaultCulture;
    newReceript.atdate = ServiceDateTimeUtils().DateToParam(_currentDate)+timeParam ;
    newReceript.storeid = DeclareValue.currentStoreId;
    newReceript.cash = summ_cash_net;
    newReceript.vat = summ_vat;
    newReceript.discount = summ_dis;
    newReceript.fullprice = summ_cash_net;
    newReceript.deposit = 0.0;
    //cus cash
    newReceript.cashType = custype;
    newReceript.cusCash = cuscash;
    newReceript.cusChange = cuschg;
    newReceript.creditNo = CusCash['creaditno'].toString();
    newReceript.cusCredit = cuscredit;
    newReceript.memberId = _memberid;

    newReceript.refid = '';

    newReceript.typeCode = 'RPT';

    if(recript_remark==remarkcap){
      newReceript.remark = '';
    }else {
      newReceript.remark = recript_remark;
    }
    newReceript.vatRate = DeclareValue.sett_vatRate;
    newReceript.taxRate = 0;

    List<Map<String, dynamic>> goodsValues = [];
    for(int i=0;i < DeclareTemp.sale_recript.length;i++){
      try {
        Map<String, dynamic> item = DeclareTemp.sale_recript[i];
        goodsValues.add({
          'goodsid': item['goodsid'],
          'piece': item['pie'],
          'salePrice': item['net_pay'],
          'cash': item['cash'],
          'cashType': item['custype'],
        });
      }catch(e){
        debugPrint(e.toString());
      }
    }

    BLSale(context).NewReceript(newReceript, goodsValues).then((res) {
      debugPrint(res.toString());

      int id = int.tryParse(res['id'].toString()) ?? -1;
      if(id == 0){
        ShowToast(context,'บันทึกใบเสร็จแล้ว').Show(MessageType.complete);

        setState(() {
          DeclareTemp.sale_recript = [];
          DataItem = [];
        });

        Map<String, dynamic> resData= {'saved': true};
        Navigator.pop(context,resData);
      }else{
        ShowToast(context,'ไม่สามารถบันทึกใบเสร็จได้').Show(MessageType.error);
      }
    }).catchError((e){
      debugPrint(e.toString());

      setState(() {
        saving = false;
        indicator_list = false;
      });
    });
  }

  Widget SearchBoxBar(){
    return TextField(
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
      onChanged: (text)=>Filter(text),
    );
  }

  void Filter(String text){
    try {
      setState(() {
        DataItem.clear();
      });

      if(text.isEmpty){
        for (int i = 0; i < DeclareTemp.sale_recript.length; i++) {
          setState(() {
            DataItem.add(DeclareTemp.sale_recript[i]);
          });
        }
      }else{
        for (int i = 0; i < DeclareTemp.sale_recript.length; i++) {
          String code = DeclareTemp.sale_recript[i]['barcode'].toString().toUpperCase();
          String goodsname = DeclareTemp.sale_recript[i]['goodsname'].toString().toUpperCase();
          if (code.contains(text.toUpperCase()) ||
              goodsname.contains(text.toUpperCase())) {
            setState(() {
              DataItem.add(DeclareTemp.sale_recript[i]);
            });
          }
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget? SearchBoxBtn(){
    if(_search_length > 0){
      return IconButton(
        onPressed: _searchEditController.clear,
        icon: const Icon(Icons.clear),
      );
    }else{
      return null;
    }
  }

  Widget SaleListView(BuildContext context){
    return ListView.separated(
          itemCount: DataItem.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context,int index){
            final item = DataItem[index];
            return GestureDetector(
              onTap: ()=>{},
              child: ListItem(item,index),
            );
          }, separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
    );
  }

  Widget ListItem(Map<String,dynamic> item,int index){
    double cash = double.tryParse(item['cash'].toString()) ?? 0.00;
    String cashValue = NumberFormat("#,##0.00", "en_US").format(cash);

    double cashPeru = double.tryParse(item['cash_peru'].toString()) ?? 0.00;
    String cashPeruValue = NumberFormat("#,##0.00", "en_US").format(cashPeru);

    int pie = int.tryParse(item['pie'].toString()) ?? 0;
    String pieValue = NumberFormat("#,##0", "en_US").format(pie);
    
    return Slidable(
      key: ValueKey(index),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        // A pane can dismiss the Slidable.
        //dismissible: DismissiblePane(onDismissed: () {}),

        children: [
          SlidableAction(
            onPressed: (BuildContext context){
              RemoveItem(index);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'เอาออก',
          ),
        ],
      ), child: ListTile(
          title: Row(
            children: [
              ServiceUI.ListNumberCircle(index+1, Colors.lightBlue.shade200, Colors.black, 12),
              const SizedBox(width: 5,),
              Expanded(child: Text(item['goodsname'])),
            ],
          ),
          subtitle: Column(
            children: [
              Table(
                //border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(30),
                  1: FixedColumnWidth(60),
                  2: FixedColumnWidth(100),
                  3: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: PosWidget.SymbolRate(item['custype']),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.lightBlue.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: AutoSizeText(pieValue),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.lightBlue.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: AutoSizeText(cashPeruValue),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.lightBlue.shade400,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: AutoSizeText(cashValue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(item['barcode'],)
                ],
              ),
            ],
          ),
      ),
    );
  }

  void RemoveItem(int index){
    try{
      String itemId = DataItem[index]['id'].toString().toUpperCase();
      for(int i=0;i < DeclareTemp.sale_recript.length;i++){
        String id = DeclareTemp.sale_recript[i]['id'].toString().toUpperCase();
        if(itemId == id){
          setState(() {
            DeclareTemp.sale_recript.removeAt(i);
            DataItem.removeAt(index);
          });

          PrepareSumm();
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget Footer(){
    return Container(
      color: normalColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SummWidget(),
          ],
        ),
      ),
    );
  }

  Widget SetReceiptTime(){
    return Container(
      color: Colors.lightBlue.shade200,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
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
      onTap: () async {
        if (await confirm(context,
        title: const Text('กำหนดวัน เวลา'),
        content: const Text('ต้องการแก้ไขเวลาใช่หรือไม่?'),
        textOK: const Text('ใช่'),
        textCancel: const Text('ไม่ใช่'),
        )) {
          TimePick();
        }
      },
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
      _timer.cancel();

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
      onTap: () async {
        if (await confirm(context,
        title: const Text('กำหนดวัน เวลา'),
        content: const Text('ต้องการแก้ไขวันที่ใช่หรือไม่?'),
        textOK: const Text('ใช่'),
        textCancel: const Text('ไม่ใช่'),
        )) {
          DatePick();
        }
      },
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

  Widget AddRemark(){
    return GestureDetector(
      onTap: ()=>RemarkDialog(),
      child: Row(
        children: [
          const SizedBox(width: 5,),
          Image.asset('assets/images/remark_icon.png',height: 25,),
          const SizedBox(width: 5,),
          Flexible(child: Text(remarkcap)),
          const SizedBox(width: 10,),
        ],
      ),
    );
  }

  void RemarkDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(remarkcap),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: Text('ระบุหมายเหตุของรายการ(ถ้ามี)')),
                      ],
                    ),
                  ),
                  TextField(
                    maxLines: 3,
                    controller: _remarkController,
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: (){
                        setState(() {
                          remarkcap = remarkcap.replaceAll('*', '');
                          if(_remarkController.text.isNotEmpty) {
                            recript_remark = _remarkController.text;
                            ShowSnack(context,recript_remark).Show(MessageType.info);

                            remarkcap = '$remarkcap*';
                          }else{
                            recript_remark = '';
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Image.asset('assets/images/true_icon.jpg',height: 40,)
                  ),
                ],
              ),
            ],
          );
        });
  }

  Widget SummWidget(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SummCash(),
        const SizedBox(height: 3,),
        SummPay(),
        const SizedBox(height: 3,),
        SummVat(),
      ],
    );
  }

  Widget SummPay(){
    String sPayValue = NumberFormat("#,##0.00", "en_US").format(summ_pay);
    String sDisValue = NumberFormat("#,##0.00", "en_US").format(summ_dis);

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(0),
        1: FixedColumnWidth(30),
        2: FlexColumnWidth(),
        3: FixedColumnWidth(30),
        4: FlexColumnWidth(),
      },
      children: [
        TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(

                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset('assets/images/sale_icon.png',height: 27,),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.white38,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: AutoSizeText(sPayValue),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset('assets/images/dis_icon.png',height: 27,),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.white38,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: AutoSizeText('- $sDisValue',style: const TextStyle(color: Colors.red),),
                  ),
                ),
              ),
            ]
        ),
      ],
    );
  }

  Widget SummVat(){
    String sVatValue = NumberFormat("#,##0.00", "en_US").format(summ_vat);

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FixedColumnWidth(30),
        2: FixedColumnWidth(60),
        3: FlexColumnWidth(),
      },
      children: [
        TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  child: AddRemark(),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(

                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: AutoSizeText('VAT ${DeclareValue.sett_vatRate}%'),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.white38,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: AutoSizeText('$sVatValue',style: const TextStyle(color: Colors.red),),
                  ),
                ),
              ),
            ]
        ),
      ],
    );
  }

  Widget SummCash(){
    String sCashValue = NumberFormat("#,##0.00", "en_US").format(summ_cash_net);
    String sPieValue = NumberFormat("#,##0", "en_US").format(summ_pie);

    return Table(
      //border: TableBorder.all(),
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(30),
        1: FixedColumnWidth(60),
        2: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Image.asset('assets/images/summ.png',height: 27,),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                color: Colors.lightBlue.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: AutoSizeText(sPieValue),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                color: Colors.lightBlue.shade400,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: AutoSizeText(sCashValue,style: style_sumcash,),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void PrepareSumm(){
    setState(() {
      summ_pie = 0;
      summ_cash = 0.00;
      summ_dis = 0.00;
      summ_pay = 0.00;
      summ_vat = 0.00;
      summ_cash_net = 0.00;
    });

    try{
      for(int i=0;i < DeclareTemp.sale_recript.length;i++){
        int sPie = int.tryParse(DeclareTemp.sale_recript[i]['pie'].toString()) ?? 0;
        double sCash = double.tryParse(DeclareTemp.sale_recript[i]['cash'].toString()) ?? 0.00;
        double sPay = double.tryParse(DeclareTemp.sale_recript[i]['net_pay'].toString()) ?? 0.00;
        double sDis = double.tryParse(DeclareTemp.sale_recript[i]['net_discount'].toString()) ?? 0.00;

        setState(() {
          summ_pie+=sPie;
          summ_cash+=sCash;
          summ_dis+=sDis;
          summ_pay+=sPay;

          if(DeclareValue.sett_vatInner){
            summ_vat+= sCash * (DeclareValue.sett_vatRate / 100);
          }
        });
      }

      setState(() {
        if(DeclareValue.sett_vatInner){
          summ_cash_net = summ_cash;
        }else{
          summ_cash_net = (summ_cash * (100 + DeclareValue.sett_vatRate)) / 100;
          summ_vat = summ_cash_net - summ_cash;
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

}
