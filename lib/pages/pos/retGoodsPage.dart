

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blGoods.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/Models/mdlReceiptXReason.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/pos/receiptDetailPage.dart';
import 'package:jaruern_mini_pos/pages/pos/retGoodsEditPage.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceScan.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class RetGoodsPage extends StatefulWidget{
  const RetGoodsPage({Key? key}) : super(key: key);

  @override
  RetGoodsPageState createState()=>RetGoodsPageState();

}

class RetGoodsPageState extends State<RetGoodsPage> with AutomaticKeepAliveClientMixin{

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  bool indicator = false;
  String BarcodeScan = '';

  int loadIndex = 0;
  List<Map<String, dynamic>> data =[];
  List<Map<String, dynamic>> data_item =[];

  @override
  void initState(){
    super.initState();


  }

  Future<void> PrepareData(String FindValue) async {
    setState(() {
      data = [];
      data_item = [];
      indicator = true;
    });

    try {
      data = await BLSale(context).GetReceiptListForRet(
          DeclareValue.currentStoreId, loadIndex,FindValue);
    }catch(e){
      debugPrint(e.toString());
    }finally{
      setState(() {
        indicator = false;
      });
    }
  }

  Future<void> FilterData(String FindValue) async {
    await PrepareData(FindValue);

    for (int i = 0; i < data.length; i++) {
      if(FindValue.isEmpty){
        setState(() {
          data_item.add(data[i]);
        });
      }else {
        String id = data[i]['receiptNo'].toString();
        if (id.toUpperCase().contains(FindValue.toUpperCase())) {
          setState(() {
            var d = data[i];
            data_item.add(d);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          try{
            ServiceScan().scanBarcodeNormal().then((value) {
              if(value!='-1') {
                ServiceSound().ScanSound();
                setState(() {
                  BarcodeScan = value;
                });

                ShowToast(context,BarcodeScan).Show(MessageType.info);

                FilterData(BarcodeScan);
              }
            });
          }catch(e){
            throw Exception(e);
          }
        },
        child: Image.asset('assets/images/barcode_scanner.png',height: 35),
      ),
      body: Column(
        children: [
          ServiceUI.Indicater(indicator),
          Expanded(child: ReceiptList()),
        ],
      ),
      bottomNavigationBar: Footer(),
    ),
    );
  }

  Widget Footer(){
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 60,
            color: Colors.lightBlue.shade200,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                      width: 20
                  ),
                  /*Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScanButton(),
                  ),*/
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget ReceiptList(){
    return ListView.separated(
      itemCount: data_item.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context,int index){
        final item = data_item[index];
        return GestureDetector(
          onTap: ()=>{},
          child: ReceiptItem(item,index),
        );
      },separatorBuilder: (BuildContext context, int index) {
      return const Divider();
    },
    );
  }

  Widget ReceiptItem(Map<String,dynamic> item,int index){


    String receiptNo = item['receiptNo'];

    return Slidable(
      key: ValueKey(index),

      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (BuildContext context)=> ReceiptRET(item['id'],index),
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
            icon: Icons.refresh,
            label: 'คืนสินค้า',
          ),
          SlidableAction(
            onPressed: (BuildContext context)=> ReceiptDelete(item['id'],index,receiptNo),
            backgroundColor: const Color(0xFFE10E0E),
            foregroundColor: Colors.white,
            icon: Icons.remove_circle,
            label: 'ยกเลิก',
          ),
        ],
      ), child: ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ServiceUI.ListNumberCircle(index+1, Colors.lightBlue.shade200, Colors.black,15),
                const SizedBox(width: 5,),
                Expanded(child: Text(receiptNo,style: const TextStyle(color: Colors.lightBlue,fontSize: 15),)),
              ],
            ),
          ),
          Row(
            children: [
              ItemSumm(item),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget ItemSumm(Map<String,dynamic> item){
    int goodsPie = int.tryParse(item['piece'].toString()) ?? 0;
    double goodsCash = double.tryParse(item['cash'].toString()) ?? 0.00;
    //double goodsDis = double.tryParse(item['dis'].toString()) ?? 0.00;

    String pieceValue = NumberFormat("#,##0", "en_US").format(goodsPie);
    String cashValue = NumberFormat("#,##0.00", "en_US").format(goodsCash).replaceAll('.00', '');
    //String disValue = NumberFormat("#,##0.00", "en_US").format(goodsDis);

    if(goodsCash >= 10000){
      double shotVal = goodsCash / 10000;
      cashValue = NumberFormat("#,##0.00", "en_US").format(shotVal).replaceAll('.00', '');
    }

    return GestureDetector(
      onTap: ()=> ReceiptDetail(item['id']),
      child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
            child: Row(
              children: [
                Image.asset('assets/images/goods2.png',height: 22),
                Text(' $pieceValue',style: const TextStyle(fontSize: 12),),
                const SizedBox(width: 5,),
                Image.asset('assets/images/sale_icon.png',height: 22),
                Text(' $cashValue',style: const TextStyle(fontSize: 12),),
                //const SizedBox(width: 5,),
                //Image.asset('assets/images/dis_icon.png',height: 22),
                //Text(' $disValue',style: const TextStyle(fontSize: 12),),
              ],
            ),
          )
      ),
    );
  }

  void ReceiptRET(String id,int itemIndex){
    debugPrint(id);

    showDialog(
        context: context,
        builder: (BuildContext context){
          return RetGoodsEditPage(id: id,);
        });
  }

  void ReceiptDelete(String id,int itemIndex,String receiptNo){
    debugPrint(id);
    debugPrint(itemIndex.toString());

    showDialog(
      context: context,
        builder: (context){

          var items = DeclareValue.ReceiptXReasons2.map((item) {
            return DropdownMenuItem<mdlReceiptXReason>(
              key:  UniqueKey(),
              value: item,
              child: Text(item.Reason),
            );
          }).toList();

          TextEditingController _remarkController = TextEditingController();
          mdlReceiptXReason? XValue = DeclareValue.ReceiptXReasons2.first;
          bool XValueProcess = false;

          return AlertDialog(
            title: const Text('เหตุผล',style: TextStyle(fontSize: 15),),
          content: StatefulBuilder(
          builder: (context,setState){
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text('เหตุผลการยกเลิกใบกำกับภาษี')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text('เลขที่ $receiptNo',style: const TextStyle(color: Colors.lightBlue),)),
                    ],
                  ),
                  Row(
                    children: [
                      DropdownButton<mdlReceiptXReason>(
                        items: items,
                        value: XValue,
                        onChanged: (mdlReceiptXReason? value) {
                          setState(() {
                            XValue = value;
                            debugPrint(XValue!.Code.toString());
                          });
                        },
                      ),
                    ],
                  ),
                  TextField(
                    maxLines: 2,
                    controller: _remarkController,
                  ),
                ],
              ),
            );
          }
          ),
            actions: [
              ServiceUI.Indicater(XValueProcess),
              Visibility(
                visible: !XValueProcess,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: (){
                          if(_remarkController.text.isEmpty){
                            ShowToast(context,'กรุณาระบุเหตุในการยกเลิก').Show(MessageType.warn);
                          }else{
                            setState(() {
                              XValueProcess = true;
                            });

                            SetReceiptDelete(itemIndex,id,XValue!.Code,_remarkController.text).then((value){
                              setState(() {
                                XValueProcess = false;
                              });
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: Image.asset('assets/images/true_icon.jpg',height: 40,)
                    ),
                    GestureDetector(
                        onTap: ()=>Navigator.pop(context),
                        child: Image.asset('assets/images/close_cross.png',height: 27,)
                    ),
                  ],
                ),
              ),
            ],
          );
        }
    );
  }

  Future<void> SetReceiptDelete(int itemIndex,String id,String ReasonNo,String ReasonTxt) async {
    try{
      var res = await BLSale(context).DeleteReceipt(id, ReasonNo, ReasonTxt);
      if(res!=null){
        int resId = int.tryParse(res['id'].toString()) ?? -1;
        if(resId == 0){
          data_item.removeAt(itemIndex);

          for(var d in data){
            String dataId = d['id'].toString();
            if(id.toUpperCase() == dataId.toUpperCase()){
              setState(() {
                if(data.remove(d)){
                  ShowToast(context,'ยกเลิกใบเสร็จแล้ว').Show(MessageType.complete);
                }
              });

              break;
            }
          }

        }else{
          ShowToast(context,'ไม่สามารถยกเลิกใบเสร็จได้').Show(MessageType.error);
          debugPrint(res['msg'].toString());
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void ReceiptDetail(String id){
    debugPrint(id);

    showDialog(
        context: context,
        builder: (BuildContext context){
          return ReceiptDetailPage(id: id, QuickShow: false,);
        });
  }

  Widget ScanButton(){
    return GestureDetector(
        onTap: (){
          try{
            ServiceScan().scanBarcodeNormal().then((value) {
              if(value!='-1') {
                ServiceSound().ScanSound();
                setState(() {
                  BarcodeScan = value;
                });

                ShowToast(context,BarcodeScan).Show(MessageType.info);

                FilterData(BarcodeScan);
              }
            });
          }catch(e){
            throw Exception(e);
          }
        },
        child: Image.asset('assets/images/barcode_scanner.png',height: 40,)
    );
  }

}