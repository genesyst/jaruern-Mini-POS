

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/Models/mdlItem.dart';
import 'package:jaruern_mini_pos/Models/mdlRetGoodsEdit.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/pos/receiptDetailPage.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class RetGoodsEditPage extends StatelessWidget{
  final String id;
  const RetGoodsEditPage({super.key,required this.id});

  @override
  Widget build(BuildContext context) => _RetGoodsEditPage(id);
  
}

class _RetGoodsEditPage extends StatefulWidget{
  late String id;
  _RetGoodsEditPage(String _id){
    id = _id;
  }

  @override
  State<StatefulWidget> createState() => _RetGoodsEditPageState(id);

}

class _RetGoodsEditPageState extends State<_RetGoodsEditPage>{
  late String id;
  bool loading = false;
  Map<String, dynamic> receipt_h = {};
  List<mdlRetGoodsEdit> receipt_goods = [];
  int piece = 0;

  TextStyle CaptionTextStyle = const TextStyle(fontSize: 12,color: Colors.black);
  TextStyle CaptionSelTextStyle = const TextStyle(fontSize: 12,color: Colors.redAccent);
  TextStyle DefaultTextStyle = const TextStyle(fontSize: 15,color: Colors.black);
  TextStyle SelTextStyle = const TextStyle(fontSize: 15,color: Colors.redAccent);
  Widget itemDefaultImage = Image.asset('assets/images/delbin_icon.png',width: 35,);
  Widget itemSelectedImage = Image.asset('assets/images/revers_icon.png',width: 35,);

  bool isTimeout = true;
  Widget receiptNotTimeOut = const Text('ไม่เกินกำหนดรับ',style: TextStyle(fontSize: 17,color: Colors.lightBlue),);
  Widget receiptNotTimeOutSymbal = Image.asset('assets/images/ret_true.png',height: 30,);
  Widget receiptTimeOut = const Text('เกินกำหนดรับ',style: TextStyle(fontSize: 17,color: Colors.redAccent),);
  Widget receiptTimeOutSymbal = Image.asset('assets/images/ret_alert.png',height: 30,);

  List<mdlItem> RtItems = [];
  List<DropdownMenuItem<mdlItem>> RetTypesItem = [];

  List<mdlItem> RfItems = [];
  List<DropdownMenuItem<mdlItem>> RefTypesItem = [];

  mdlItem? refTypeValue;
  TextEditingController refundAllTxt = TextEditingController();
  TextEditingController retPieceAllTxt = TextEditingController();
  TextEditingController retRemark = TextEditingController();

  bool summVisible = false;

  _RetGoodsEditPageState(String _id){
    id = _id;
  }

  @override
  void initState() {
    super.initState();

    PrepareRetTypeItems();
    PrePareRefundType();

    PrepareData();
  }

  Future<void> PrepareData() async {
    loading = true;
    try {
      Map<String, dynamic> result = await BLSale(context).GetReceipt(id);
      int resId = int.tryParse(result['id'].toString()) ?? -1;
      if (resId == 0) {
        setState(() {
          receipt_h = result['data'];
          debugPrint(receipt_h.toString());

          CheckValidReceiptDate();

          var goodsList = result['data']['receriptGoods'].cast<Map<String, dynamic>>();
          debugPrint(goodsList.toString());

          for(var g in goodsList){
            piece += int.tryParse(g['piece'].toString()) ?? 0;

            mdlRetGoodsEdit goods_item = mdlRetGoodsEdit();
            goods_item.id = g['id'].toString();
            goods_item.goodsid = g['goodsid'].toString();
            goods_item.goodsName = g['goodsName'].toString();
            goods_item.barcode = g['barcode'].toString();
            goods_item.qrCode = g['qrCode'].toString();
            goods_item.size = g['size'].toString();
            goods_item.piece = int.parse(g['piece'].toString());
            goods_item.salePrice = double.parse(g['salePrice'].toString());
            goods_item.cash = double.parse(g['cash'].toString());
            goods_item.cashType = g['cashType'].toString();
            goods_item.isSelected = false;
            goods_item.reason = '';
            goods_item.RetType = 0;
            receipt_goods.add(goods_item);
          }
        });
      }
    }finally{
      loading = false;
    }
  }

  Future<void> PrePareRefundType() async {
    try{
      var res = await BLSale(context).GetRefundType();
      setState(() {
        RfItems = res;
      });

      RefTypesItem = RfItems.map((item) {
        return DropdownMenuItem<mdlItem>(
          key:  UniqueKey(),
          value: item,
          child: Text(item.Text),
        );
      }).toList();
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> PrepareRetTypeItems() async {
    try{
      var res = await BLSale(context).GetGoodsReturnType();
      setState(() {
        RtItems = res;
      });

      RetTypesItem = RtItems.map((item) {
        return DropdownMenuItem<mdlItem>(
          key:  UniqueKey(),
          value: item,
          child: Text(item.Text),
        );
      }).toList();
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void CheckValidReceiptDate(){
    try{
      DateTime now = DateTime.now();

      List<String> atdate = receipt_h['atdate'].toString().split(' ');
      List<String> dates = atdate[0].split('/');
      List<String> times = atdate[1].split(':');

      int recYear = int.parse(dates[2]);
      if(recYear > now.year){
        int diffYear = recYear - now.year;
        if(diffYear > 500){
          recYear = recYear - 543;
        }
      }

      String date4Conv = recYear.toString()+"-"+dates[1]+'-'+dates[0]+' '+times[0]+':'+times[1]+':00';
      DateTime reciptDate = DateTime.parse(date4Conv);

      Duration difference = now.difference(reciptDate);
      int days = difference.inDays;
      int hours = difference.inHours % 24;
      debugPrint('$days/$hours');


      setState(() {
        if(days > 7){
          isTimeout = true;
        }else{
          isTimeout = false;
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                isTimeout? receiptTimeOutSymbal: receiptNotTimeOutSymbal,
                const SizedBox(width: 10,),
                isTimeout? receiptTimeOut: receiptNotTimeOut,
              ],
            ),
            GestureDetector(
                onTap: ()=>{Navigator.pop(context)},
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
              const Divider(),
              ServiceUI.Indicater(loading),
              Content(),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget Content(){
    return Column(
      children: [
        Visibility(
          visible: !loading,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/images/warn_icon.png',height: 28,),
              const SizedBox(width: 10,),
              const Expanded(
                child: Text('การคืนสินค้าและคืนเงินใช้ได้กับสินค้าที่รวม VAT เท่านั้น',
                  style: TextStyle(color: Colors.redAccent,fontSize: 12),),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        Header(),
        const SizedBox(height: 10,),
        GoodsList(),
        const SizedBox(height: 10,),
        ReturnImplement(),
        const SizedBox(height: 10,),
        Visibility(
          visible: summVisible,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: ()=>RenewReceipt(),
                  icon: Image.asset('assets/images/goods_keep.png',height: 40,),
                  label: const Text('บันทึกและออกใบกำกับภาษีใหม่',style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent.shade200),
                  padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                    (states) {return const EdgeInsets.all(8.0);},
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40,),
      ],
    );
  }

  Future<void> RenewReceipt() async {
    try{
      for(var rg in receipt_goods){
        if(rg.isSelected){
          if(rg.RetType == 0){
            ServiceMsgDialogCustom.showWarnDialog(context, 'คืนสินค้า', 'ระบุเหตุที่คืนสินค้าไม่สมบูรณ์');
            return;
          }
        }
      }

      if(refTypeValue==null){
        ServiceMsgDialogCustom.showWarnDialog(context, 'คืนสินค้า', 'กรุณาระบุช่องทางคืนเงิน');
        return;
      }

      String newReceiptId = await BLSale(context).RenewReceipt(
          id,
          refTypeValue!.Value.toString(),
          retRemark.text,
          receipt_goods
      );

      if(newReceiptId.isNotEmpty){
        ShowToast(context, 'คืนสินค้าและออกใบกำกับภาษีใหม่แล้ว').Show(MessageType.complete);
        showDialog(
            context: context,
            builder: (BuildContext context){
              return ReceiptDetailPage(id: newReceiptId,QuickShow: false,);
            }).then((value) => Navigator.pop(context));
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget Header(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${receipt_h['receiptNo'] ?? ''}',style: const TextStyle(fontSize: 15,color: Colors.lightBlue),),
            Text('${receipt_h['atdate'] ?? ''}',style: const TextStyle(fontSize: 15,color: Colors.lightBlue),),
          ],
        ),
      ],
    );
  }

  Widget GoodsList(){
    return Column(
      children: [
        for (int i=0;i < receipt_goods.length;i++ )
          GoodsItem(receipt_goods[i],i),
        const SizedBox(height: 5,),
      ],
    );
  }

  Widget GoodsItem(mdlRetGoodsEdit item,int index){
    int limitDisplatName = 17;
    String goodsname = item.goodsName;
    goodsname = goodsname.substring(0,goodsname.length < limitDisplatName ? goodsname.length:limitDisplatName);
    String caption = '$goodsname (${item.size})';

    int piece = item.piece;
    String pieceValue = NumberFormat("#,##0", "en_US").format(piece);

    double cash = item.cash;
    String cashValue = NumberFormat("#,##0.00", "en_US").format(cash);

    if(isTimeout){
      return Column(
        children: [
          Table(
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
                          child: Text(caption,style: (item.isSelected)?CaptionSelTextStyle:CaptionTextStyle,),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text('@$pieceValue',style: (item.isSelected)?SelTextStyle:DefaultTextStyle,),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(cashValue,style: (item.isSelected)?SelTextStyle:DefaultTextStyle,),
                        ),
                      ),
                    ),
                  ]
              ),
            ],
          ),
          const Divider(),
        ],
      );
    }else{
      return Column(
        children: [
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(35),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(60),
              3: FixedColumnWidth(120),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: GestureDetector(
                          onTap: (){
                            setState(() {
                              if(item.isSelected){
                                item.isSelected = false;
                              }else{
                                item.isSelected = true;
                              }
                            });

                            RefundSumm();
                          },
                          child: (item.isSelected)?itemSelectedImage: itemDefaultImage
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(caption,style: (item.isSelected)?CaptionSelTextStyle:CaptionTextStyle,),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text('@$pieceValue',style: (item.isSelected)?SelTextStyle:DefaultTextStyle,),
                        ),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(cashValue,style: (item.isSelected)?SelTextStyle:DefaultTextStyle,),
                        ),
                      ),
                    ),
                  ]
              ),
            ],
          ),
          Visibility(
            visible: item.isSelected,
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(35),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Text(''),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: RetGoodsReasonForm(item),
                    ),
                  ]
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      );
    }
  }

  Widget RetGoodsReasonForm(mdlRetGoodsEdit item){
    TextEditingController reasonTxt = TextEditingController();
    reasonTxt.text = item.reason;

    mdlItem? retValue;
    for(var rett in RtItems){
      if(item.RetType == int.parse(rett.Value.toString())){
        retValue = rett;
        break;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('เหตุผลที่คืน',style: TextStyle(fontSize: 15),),
            DropdownButton<mdlItem>(
              items: RetTypesItem,
              value: retValue,
              onChanged: (mdlItem? selItem) {
                item.RetType = int.parse(selItem!.Value.toString());
                debugPrint(item.RetType.toString());

                for(var rett in RtItems){
                  if(item.RetType == int.parse(rett.Value.toString())){
                    setState(() {
                      retValue = rett;
                    });

                    break;
                  }
                }
              },
            ),
          ],
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: 'รายละเอียด(ถ้ามี)',
          ),
          controller: reasonTxt,
          onSubmitted: (value){
            item.reason = value;
          },
        ),
      ],
    );
  }

  Widget ReturnImplement(){
    summVisible = false;
    for(var rg in receipt_goods){
      if(rg.isSelected){
        summVisible = true;
        break;
      }
    }

    return Visibility(
      visible: summVisible,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/goods.png',height: 25,),
                      const SizedBox(width: 5,),
                      const Text('คืนสินค้า(ชิ้น)',style: TextStyle(fontSize: 15,color: Colors.lightBlue),),
                    ],
                  ),
                  const SizedBox(width: 40,),
                  Flexible(
                    child: TextField(
                      controller: retPieceAllTxt,
                      readOnly: true,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/money.png',height: 25,),
                      const SizedBox(width: 5,),
                      const Text('คืนเงิน(บาท)',style: TextStyle(fontSize: 15,color: Colors.lightBlue),),
                    ],
                  ),
                  const SizedBox(width: 40,),
                  Flexible(
                    child: TextField(
                      controller: refundAllTxt,
                      readOnly: true,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/cash_change.png',height: 25,),
                      const SizedBox(width: 5,),
                      const Text('ช่องทางคืนเงิน',style: TextStyle(fontSize: 15,color: Colors.lightBlue),),
                    ],
                  ),
                  DropdownButton<mdlItem>(
                    items: RefTypesItem,
                    value: refTypeValue,
                    onChanged: (mdlItem? selItem) {
                      debugPrint(selItem!.Text.toString());

                      setState(() {
                        refTypeValue = selItem;
                      });

                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset('assets/images/remark_icon.png',height: 25,),
                  const SizedBox(width: 5,),
                  Flexible(
                    child: TextField(
                      controller: retRemark,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'หมายเหตุ'
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void RefundSumm(){
    try{
      double refund = 0;
      int ret = 0;
      for(var item in receipt_goods){
        if(item.isSelected){
          refund += item.cash;
          ret += item.piece;
        }
      }

      String returnValue = NumberFormat("#,##0", "en_US").format(ret);
      String refundValue = NumberFormat("#,##0.00", "en_US").format(refund);
      refundAllTxt.text = refundValue;
      retPieceAllTxt.text = returnValue;
    }catch(e){
      debugPrint(e.toString());
    }
  }
  
}