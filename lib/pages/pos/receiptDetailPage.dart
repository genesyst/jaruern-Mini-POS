

import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/Models/mdlGoodsOrder.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/pages/pos/holdOrderCashPage.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class ReceiptDetailPage extends StatelessWidget{
  final String id;
  final bool QuickShow;

  const ReceiptDetailPage({super.key,required this.id, required this.QuickShow});

  @override
  Widget build(BuildContext context) => _ReceiptDetailPage(id,QuickShow);

}

class _ReceiptDetailPage extends StatefulWidget{
  late String id;
  late bool QuickShow;

  _ReceiptDetailPage(String _id,bool _quickShow){
    id = _id;
    QuickShow = _quickShow;
  }

  @override
  State<StatefulWidget> createState() => _ReceiptDetailPageState(id,QuickShow);

}

class _ReceiptDetailPageState extends State<_ReceiptDetailPage>{
  late String id;
  String Code = 'RPT';

  Map<String, dynamic> receipt_h = {};
  Map<String, dynamic> receipt_h_ref = {};
  List<Map<String, dynamic>> receipt_goods = [];
  List<Map<String, dynamic>> xreceipt_goods = [];

  TextStyle textStyle = const TextStyle(fontSize: 15);
  TextStyle textHStyle = const TextStyle(fontSize: 15,fontWeight: FontWeight.bold);
  TextStyle textFinalStyle = const TextStyle(fontSize: 15,decoration: TextDecoration.underline);

  TextStyle xRefundStyle = const TextStyle(fontSize: 15,fontStyle: FontStyle.italic);
  TextStyle xGoodsStyle = const TextStyle(fontSize: 12,fontStyle: FontStyle.italic);

  bool loading = false;
  String vatin_caption = '';
  int piece = 0;

  String BCodeUrl = '';
  bool QuickShow = false;

  String ReferenceId = '';

  _ReceiptDetailPageState(String _id,bool _quickShow){
    id = _id;
    QuickShow = _quickShow;
  }

  @override
  void initState() {
    super.initState();

    PrepareData();

    setState(() {
      if(DeclareValue.sett_vatInner){
        vatin_caption = '(VAT included)';
      }else{
        vatin_caption = '(VAT not included)';
      }
    });

  }

  Future<void> PrepareData() async {
    setState(() {
      loading = true;
    });
    try {
      Map<String, dynamic> result = await BLSale(context).GetReceipt(id);
      int resId = int.tryParse(result['id'].toString()) ?? -1;
      if (resId == 0) {
        setState(() {
          receipt_h = result['data'];
          debugPrint('receipt_h==> $receipt_h');

          ReferenceId = receipt_h['refId'] ?? '';
          debugPrint('refId ==> $ReferenceId');

          PrepareReferenceData();

          receipt_goods =
              result['data']['receriptGoods'].cast<Map<String, dynamic>>();
          debugPrint('receipt_goods==> $receipt_goods');

          Code = receipt_h['receiptNo'].toString().substring(0, 3);

          if (receipt_h['xReceiptNo'].toString() != 'null') {
            xreceipt_goods =
                result['data']['xReceriptGoods'].cast<Map<String, dynamic>>();
            debugPrint(xreceipt_goods.toString());
          }

          for (var g in receipt_goods) {
            piece += int.tryParse(g['piece'].toString()) ?? 0;
          }
        });

        LoadBarcode(receipt_h['receiptNo'], receipt_h['id']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> PrepareReferenceData() async {
    try{
      if(ReferenceId.isNotEmpty) {
        Map<String, dynamic> result = await BLSale(context).GetReceipt(
            ReferenceId);
        int resId = int.tryParse(result['id'].toString()) ?? -1;
        if (resId == 0) {
          setState(() {
            receipt_h_ref = result['data'];
            debugPrint('receipt_h_ref==> $receipt_h_ref');
          });
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> LoadBarcode(String barcode,String receiptId) async {
    try{
      String url = await BLSale(context).getReceiptQRBarcode(barcode, receiptId, 2);
      setState(() {
        BCodeUrl = url;
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
      Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: (){},
                  child: Image.asset('assets/images/print_icon.png',height: 30,)
              ),
              Text((Code=='RPT')?'ใบกำกับภาษี(ย่อ)':'ใบสั่งสินค้า',style: textHStyle,),
              GestureDetector(
                  onTap: (){
                    if(QuickShow) {
                      Navigator.pop(context, {'result': 'closed'});
                    }else{
                      Navigator.pop(context);
                    }
                    },
                  child: Image.asset('assets/images/close_cross.png',height: 20,)
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 3, 20, 3),
            child: Column(
              children: [
                ServiceUI.Indicater(loading),
                Content(),
                Footer(),
              ],
            ),
          ),
        ),
        //bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget Content(){
    return Visibility(
      visible: !loading,
      child: Column(
        children: [
          ReceiptHeader1(),
          const Divider(),
          ReceiptHeader2(),
          GoodsList(),
          const Divider(),
          FoodSummary(),
          Member(),
          CreateBy(),
          ReferenceReceipt(),
          Remark(),
          RefundSumm(),
          ReturnGoods(),
          const SizedBox(height: 10,),
          BarcodeDisplay(),
        ],
      ),
    );
  }

  Widget Footer(){
    return Visibility(
      visible: (Code == 'ORD' && QuickShow == false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                    onPressed: ()=>NextProcess(),
                    child: const Text('ถัดไป')
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget ReferenceReceipt(){
    String ReceiptRefNo = '';
    String depositValue = '';
    double deposit = 0.0;
    if(receipt_h_ref.isNotEmpty){
      ReceiptRefNo = receipt_h_ref['receiptNo'].toString();
      deposit = double.tryParse(receipt_h_ref['deposit'].toString()) ?? 0.00;
      depositValue = NumberFormat("#,##0.00", "en_US").format(deposit);
    }

    double cash = double.tryParse(receipt_h['cash'].toString()) ?? 0.00;
    String orderPayStatus = '(ชำระเต็ม)';
    if(cash > 0.0){
      orderPayStatus = '(ส่วนแรก)';
    }

    return Visibility(
      visible: (ReferenceId.isNotEmpty),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ใบสั่งของ$orderPayStatus',style: textStyle,),
              Text(ReceiptRefNo,style: textStyle,),
            ],
          ),
          Visibility(
            visible: deposit > 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ยอดชำระ(มัดจำ)',style: textStyle,),
                Text(depositValue,style: textStyle,),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> NextProcess() async {
    double deposit = double.tryParse(receipt_h['deposit'].toString()) ?? 0.00;

    String title = 'ใบกำกับภาษี';
    String msg = 'ต้องการบันทึกใบกำกับภาษีหรือไม่?';
    if(deposit > 0){
      title = 'ค้างจ่าย';
      msg ='ต้องการชำระเงินส่วนที่ค้างจ่ายหรือไม่?';
    }

    if (await confirm(context,
      title: Text(title),
      content: Text(msg),
      textOK: const Text('ใช่'),
      textCancel: const Text('ยังก่อน'),
    )){
      OrderDepositCash(deposit);
    }

  }

  void OrderDepositCash(double deposit){
    double fullprice = double.tryParse(receipt_h['fullprice'].toString()) ?? 0.00;
    double discount = double.tryParse(receipt_h['discount'].toString()) ?? 0.00;
    String mem = receipt_h['memberId'].toString().toLowerCase();

    DateTime orderDate = ServiceDateTimeUtils.StringDisplay2DateTime(receipt_h['atdate'].toString());

    List<mdlGoodsOrder> goodsOrder=[];
    for(int i=0;i < receipt_goods.length;i++){
      double salePrice = double.tryParse(receipt_goods[i]['salePrice'].toString()) ?? 0.00;
      double cash = double.tryParse(receipt_goods[i]['cash'].toString()) ?? 0.00;
      int piece = int.tryParse(receipt_goods[i]['piece'].toString()) ?? 0;

      mdlGoodsOrder ord = mdlGoodsOrder();
      ord.saleprice = salePrice;
      ord.price = cash;
      ord.piece = piece;
      ord.goodsId = receipt_goods[i]['goodsid'].toString();
      ord.discount = (salePrice * piece) - cash;
      ord.barcode = receipt_goods[i]['barcode'].toString();
      ord.id = receipt_goods[i]['id'].toString();
      ord.amtpiece = 0;
      ord.goodsName = receipt_goods[i]['goodsName'].toString();
      ord.size = receipt_goods[i]['size'].toString();

      goodsOrder.add(ord);
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return HoldOrderCashPage(
            orders: goodsOrder,
            netPay: deposit,
            discount: discount,
            memberId: mem,
            atdate: orderDate,
            orderCommit: true,
            depositOrderId: id,
          );
        }).then((value) {
          if(value!=null) {
            if (value['result'] == 'closed') {
              Navigator.pop(context);
            }
          }
    });
  }

  Widget ReceiptHeader1(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${receipt_h['storeName']}',style: textStyle,),
          ],
        ),
        const SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TAX# ${receipt_h['taxNo'] ?? ''}',style: TextStyle(fontSize: 12),),
            Text(vatin_caption,style: const TextStyle(fontSize: 12),),
          ],
        ),
      ],
    );
  }

  Widget ReceiptHeader2(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${receipt_h['receiptNo']}',style: textHStyle,),
            Visibility(
                visible: receipt_h['xReceiptNo'].toString()!='null',
                child: const Text('#refund',style: TextStyle(fontSize: 15),)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${receipt_h['atdate']}',style: textStyle,),
          ],
        ),
      ],
    );
  }

  Widget FoodSummary(){
    if(Code == 'ORD'){
      return OrderSumm();
    }else{
      return ReceiptSumm();
    }
  }

  Widget ReceiptSumm(){
    double cash = double.tryParse(receipt_h['cash'].toString()) ?? 0.00;
    double change = double.tryParse(receipt_h['cusChange'].toString()) ?? 0.00;
    double discount = double.tryParse(receipt_h['discount'].toString()) ?? 0.00;
    double vat = double.tryParse(receipt_h['vat'].toString()) ?? 0.00;
    double vatRate = double.tryParse(receipt_h['vatRate'].toString()) ?? 0.00;
    double cusCash = double.tryParse(receipt_h['cusCash'].toString()) ?? 0.00;

    double debt = 0.0;

    if(ReferenceId.isNotEmpty){
      if(cash == 0.0){
        cash = double.tryParse(receipt_h_ref['cash'].toString()) ?? 0.00;
        change = double.tryParse(receipt_h_ref['cusChange'].toString()) ?? 0.00;
        discount = double.tryParse(receipt_h_ref['discount'].toString()) ?? 0.00;
        vat = double.tryParse(receipt_h_ref['vat'].toString()) ?? 0.00;
        vatRate = double.tryParse(receipt_h_ref['vatRate'].toString()) ?? 0.00;
        cusCash = double.tryParse(receipt_h_ref['cusCash'].toString()) ?? 0.00;
      }else{
        cash = double.tryParse(receipt_h_ref['fullprice'].toString()) ?? 0.00;
        discount = double.tryParse(receipt_h_ref['discount'].toString()) ?? 0.00;
        double vat1 = double.tryParse(receipt_h['vat'].toString()) ?? 0.00;
        double vat2 = double.tryParse(receipt_h_ref['vat'].toString()) ?? 0.00;
        vat = vat1+vat2;

        double fullprice = double.tryParse(receipt_h_ref['fullprice'].toString()) ?? 0.00;
        double deposit = double.tryParse(receipt_h_ref['deposit'].toString()) ?? 0.00;
        debt = fullprice - deposit;
      }
    }

    String cashValue = NumberFormat("#,##0.00", "en_US").format(cash);
    String changeValue = NumberFormat("#,##0.00", "en_US").format(change);
    String discountValue = NumberFormat("#,##0.00", "en_US").format(discount);
    String vatValue = NumberFormat("#,##0.00", "en_US").format(vat);
    String vatRateValue = NumberFormat("#,##0.00", "en_US").format(vatRate);
    String cusCashValue = NumberFormat("#,##0.00", "en_US").format(cusCash);
    String debtValue = NumberFormat("#,##0.00", "en_US").format(debt);

    String pieValue = NumberFormat("#,##0", "en_US").format(piece);

    final rows = <TableRow>[];
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('ยอดสุทธิ',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(pieValue,style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(cashValue,style: textFinalStyle,),
              ),
            ),
          ),
        ]
    ));
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('ส่วนลด',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(discountValue,style: textStyle,),
              ),
            ),
          ),
        ]
    ));
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('VAT $vatRateValue%',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(vatValue,style: textStyle,),
              ),
            ),
          ),
        ]
    ));

    if(ReferenceId.isNotEmpty && debt > 0.0){
      rows.add(TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text('ยอดค้างจ่าย',style: textStyle,),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('',style: textStyle,),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(debtValue,style: textFinalStyle,),
                ),
              ),
            ),
          ]
      ));
    }

    if(receipt_h['xReceiptNo'].toString()=='null'){
      rows.add(TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text('เงินสด/เครดิต(01)',style: textStyle,),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('',style: textStyle,),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(cusCashValue,style: textFinalStyle,),
                ),
              ),
            ),
          ]
      ));
      rows.add(TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text('เงินทอน',style: textStyle,),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('',style: textStyle,),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(changeValue,style: textFinalStyle,),
                ),
              ),
            ),
          ]
      ));
    }

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FixedColumnWidth(60),
        2: FixedColumnWidth(120),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  Widget OrderSumm(){
    double cash = double.tryParse(receipt_h['cash'].toString()) ?? 0.00;
    double change = double.tryParse(receipt_h['cusChange'].toString()) ?? 0.00;
    double discount = double.tryParse(receipt_h['discount'].toString()) ?? 0.00;
    double vat = double.tryParse(receipt_h['vat'].toString()) ?? 0.00;
    double vatRate = double.tryParse(receipt_h['vatRate'].toString()) ?? 0.00;
    double cusCash = double.tryParse(receipt_h['cusCash'].toString()) ?? 0.00;

    double fullprice = double.tryParse(receipt_h['fullprice'].toString()) ?? 0.00;
    double deposit = double.tryParse(receipt_h['deposit'].toString()) ?? 0.00;

    String cashValue = NumberFormat("#,##0.00", "en_US").format(cash);
    String changeValue = NumberFormat("#,##0.00", "en_US").format(change);
    String discountValue = NumberFormat("#,##0.00", "en_US").format(discount);
    String vatValue = NumberFormat("#,##0.00", "en_US").format(vat);
    String vatRateValue = NumberFormat("#,##0.00", "en_US").format(vatRate);
    String cusCashValue = NumberFormat("#,##0.00", "en_US").format(cusCash);

    String fullpriceValue = NumberFormat("#,##0.00", "en_US").format(fullprice);
    String depositValue = NumberFormat("#,##0.00", "en_US").format(deposit);
    String pieValue = NumberFormat("#,##0", "en_US").format(piece);

    String depositCaption = '(มัดจำ)';
    if(deposit == 0.0){
      depositCaption='(เต็ม)';
    }

    final rows = <TableRow>[];
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('ยอดสุทธิ',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(pieValue,style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text((cash==0.0)?fullpriceValue:cashValue,style: textFinalStyle,),
              ),
            ),
          ),
        ]
    ));
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('ส่วนลด',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(discountValue,style: textStyle,),
              ),
            ),
          ),
        ]
    ));
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('VAT $vatRateValue%',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(vatValue,style: textStyle,),
              ),
            ),
          ),
        ]
    ));
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('ยอดชำระ$depositCaption',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text((deposit==0.0)?fullpriceValue:depositValue,style: textFinalStyle,),
              ),
            ),
          ),
        ]
    ));
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('เงินสด/เครดิต(01)',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(cusCashValue,style: textFinalStyle,),
              ),
            ),
          ),
        ]
    ));
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('เงินทอน',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('',style: textStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(changeValue,style: textFinalStyle,),
              ),
            ),
          ),
        ]
    ));

    return Column(
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FixedColumnWidth(60),
            2: FixedColumnWidth(120),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows,
        ),
        Visibility(
          visible: deposit > 0.0,
          child: Column(
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ค้างจ่าย',style: textHStyle,),
                    Text(depositValue,style: textHStyle,),
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget CreateBy(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('(R)${receipt_h['createDate']}',style: const TextStyle(fontSize: 12),),
            Flexible(child: Text('(C)${receipt_h['createBy']}',style: const TextStyle(fontSize: 12),)),
          ],
        ),
      ],
    );
  }
  
  Widget Remark(){
    return Visibility(
      visible: receipt_h['remark'].toString().isNotEmpty,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                  child: Text('* ${receipt_h['remark']}',style: const TextStyle(fontSize: 12),)),
            ],
          ),
        ],
      ),
    );
  }

  Widget Member(){
    String mem = receipt_h['memberId'].toString().toLowerCase();

    return Visibility(
      visible: (mem == 'null' || mem.isEmpty)? false:true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                  child: Text('(Member)${receipt_h['memberId']}',style: const TextStyle(fontSize: 12),)),
            ],
          ),
        ],
      ),
    );
  }

  Widget RefundSumm(){
    final rows = <TableRow>[];
    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text('ยอดเดิม/เงินคืน',style: xRefundStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('${receipt_h['xReceiptCash']}',style: xRefundStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('${receipt_h['refund']}',style: xRefundStyle,),
              ),
            ),
          ),
        ]
    ));

    return Visibility(
      visible: receipt_h['xReceiptNo'].toString()!='null',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Refund from',style: xRefundStyle,),
              Text('${receipt_h['xReceiptNo']}',style: xRefundStyle,),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ช่องทาง',style: xRefundStyle,),
              Text('${receipt_h['refundType']}',style: xRefundStyle,),
            ],
          ),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FixedColumnWidth(60),
              2: FixedColumnWidth(120),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
          ),
        ],
      ),
    );
  }

  Widget ReturnGoods(){
    return Column(
      children: [
        for(var x in xreceipt_goods)
          ReturnGoodsItem(x),
          const SizedBox(height: 2,),
      ],
    );
  }

  Widget ReturnGoodsItem(Map<String,dynamic> item){
    final rows = <TableRow>[];
    int limitDisplatName = 17;
    String goodsname = item['goodsName'].toString();
    goodsname = goodsname.substring(0,goodsname.length < limitDisplatName ? goodsname.length:limitDisplatName);
    String caption = '[X]$goodsname (${item['size']})';

    int piece = int.tryParse(item['piece'].toString()) ?? 0;
    String pieceValue = NumberFormat("#,##0", "en_US").format(piece);

    double cash = double.tryParse(item['cash'].toString()) ?? 0.00;
    String cashValue = NumberFormat("#,##0.00", "en_US").format(cash);

    rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(caption,style: const TextStyle(fontSize: 12,fontStyle: FontStyle.italic),),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('@$pieceValue',style: xGoodsStyle,),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(cashValue,style: xGoodsStyle,),
              ),
            ),
          ),
        ]
    ));

    return Column(
      children: [
          Table(
          columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(),
          1: FixedColumnWidth(60),
          2: FixedColumnWidth(120),
        },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(child: Text('${item['recode'].toString()} , ${item['rereason'].toString()}',style: xGoodsStyle,)),
            ],
          ),
        ),
      ],
    );
  }

  Widget GoodsList(){
    return Column(
      children: [
        for ( var goods in receipt_goods )
          GoodsItem(goods),
          const SizedBox(height: 5,),
      ],
    );
  }

  Widget GoodsItem(Map<String, dynamic> item){
    int limitDisplatName = 17;
    String goodsname = item['goodsName'].toString();
    goodsname = goodsname.substring(0,goodsname.length < limitDisplatName ? goodsname.length:limitDisplatName);
    String caption = '$goodsname (${item['size']})';
    
    int piece = int.tryParse(item['piece'].toString()) ?? 0;
    String pieceValue = NumberFormat("#,##0", "en_US").format(piece);

    double cash = double.tryParse(item['cash'].toString()) ?? 0.00;
    String cashValue = NumberFormat("#,##0.00", "en_US").format(cash);
    
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: FixedColumnWidth(60),
        2: FixedColumnWidth(120),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(caption,style: const TextStyle(fontSize: 12),),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('@$pieceValue',style: textStyle,),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(cashValue,style: textStyle,),
                  ),
                ),
              ),
            ]
        ),
      ],
    );
  }

  Widget BarcodeDisplay(){
    double width = MediaQuery.of(context).size.width;
    return Visibility(
      visible: BCodeUrl.isNotEmpty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(BCodeUrl,width: width / 2,),
        ],
      ),
    );
  }

}