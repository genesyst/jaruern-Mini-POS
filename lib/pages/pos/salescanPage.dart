
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/Models/mdlReceiptXReason.dart';
import 'package:jaruern_mini_pos/additional/pages/cameraScanBarcode.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/pos/receiptDetailPage.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceScan.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class SaleScanPage extends StatefulWidget{
  const SaleScanPage({Key? key}) : super(key: key);

  @override
  SaleScanPageState createState()=>SaleScanPageState();

}

class SaleScanPageState extends State<SaleScanPage> with AutomaticKeepAliveClientMixin{
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  final TextEditingController _summTextFieldController = TextEditingController(text:'0');

  ServiceScan serviceScan = ServiceScan();
  ServiceSound serviceSound = ServiceSound();

  DateTime _currentDate = DateTime.now();
  String _currentDateStr = '';

  bool indicator = false;
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> data_item = [];

  int summ_pie = 0;
  double summ_cash = 0;
  double summ_dis = 0;

  @override
  void initState(){
    super.initState();

    setState(() {
      _currentDateStr = ServiceDateTimeUtils.SetType(DateYearType.Buddhist)
          .DateToString(_currentDate, Date2String.fullmonth);
    });

    PrepareData();

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(child: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>DialogQuickScan(),
        child: Image.asset('assets/images/barcode_scanner.png',height: 35),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.lightBlue.shade200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 5,),
                  DatePicker(),
                ],
              ),
            ),
          ),
          ServiceUI.Indicater(indicator),
          Expanded(child: ReceiptList()),
        ],
      ),
      bottomNavigationBar: Footer(),
    ),);
  }

  Widget Footer(){
    String pieceValue = NumberFormat("#,##0", "en_US").format(summ_pie);
    String cashValue = NumberFormat("#,##0.00", "en_US").format(summ_cash);
    String disValue = NumberFormat("#,##0.00", "en_US").format(summ_dis);

    if(summ_cash > 10000){
      double sCash = summ_cash / 1000;
      cashValue = '${NumberFormat("#,##0.00", "en_US").format(sCash)}K';
    }

    if(summ_dis > 10000){
      double sDis = summ_dis / 1000;
      disValue = '${NumberFormat("#,##0.00", "en_US").format(sDis)}K';
    }

    cashValue = cashValue.replaceAll('.00', '');
    disValue = disValue.replaceAll('.00', '');

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 60,
            color: Colors.lightBlue.shade200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){},
                    child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                          child: Row(
                            children: [
                              Image.asset('assets/images/goods2.png',height: 22),
                              Text(' $pieceValue',),
                              const SizedBox(width: 5,),
                              Image.asset('assets/images/sale_icon.png',height: 22),
                              Text(' $cashValue',),
                            ],
                          ),
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: (){},
                    child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                          child: Row(
                            children: [
                              Image.asset('assets/images/dis_icon.png',height: 22),
                              Text(' $disValue',),
                            ],
                          ),
                        )
                    ),
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

  Widget DatePicker(){
    return GestureDetector(
      onTap: ()=>DatePick(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/calendar_icon.png',height: 20,),
          const SizedBox(width: 10,),
          Text(_currentDateStr,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
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

          PrepareData();
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget ScanButton(){
    return GestureDetector(
      onTap: ()=>DialogQuickScan(),
        child: Image.asset('assets/images/barcode_scanner.png',height: 40,)
    );
  }

  void DialogQuickScan(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return add_CameraScanBarcodePage(currentDate: _currentDate,);
        }).then((value) {
            debugPrint(value.toString());

            if(value!=null) {
              bool isSaved = bool.tryParse(value['reload'].toString()) ?? false;
              if (isSaved) {
                PrepareData();
              }
            }
    });
  }

  void PrepareData(){
    setState(() {
      indicator = true;
      data_item = [];
    });

    BLSale(context).GetReceiptList(DeclareValue.currentStoreId, _currentDate,'RPT').then((value) {
      debugPrint(value.toString());

      setState(() {
        data = value;

        for (int i = 0; i < data.length; i++) {
          data_item.add(data[i]);
        }

        indicator = false;
      });

      PrepareSumm();

    }).catchError((e){
      debugPrint(e.toString());
      setState(() {
        indicator = false;
      });
    });
  }

  void FilterData(String findText)  {
    setState(() {
      data_item = [];
    });

    if (findText.isEmpty) {
      for (int i = 0; i < data.length; i++) {
        setState(() {
          data_item.add(data[i]);
        });
      }
    } else {
      for (int i = 0; i < data.length; i++) {
        String receiptNo = data[i]['receiptNo'].toString();
        if (receiptNo.toUpperCase().contains(findText)) {
          setState(() {
            data_item.add(data[i]);
          });
        }
      }
    }

    PrepareSumm();

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
    int goodsPie = int.tryParse(item['piece'].toString()) ?? 0;
    double goodsCash = double.tryParse(item['cash'].toString()) ?? 0.00;
    double goodsDis = double.tryParse(item['dis'].toString()) ?? 0.00;

    String pieceValue = NumberFormat("#,##0", "en_US").format(goodsPie);
    String cashValue = NumberFormat("#,##0.00", "en_US").format(goodsCash).replaceAll('.00', '');
    String disValue = NumberFormat("#,##0.00", "en_US").format(goodsDis).replaceAll('.00', '');

    if(goodsCash >= 10000){
      double shotVal = goodsCash / 10000;
      cashValue = NumberFormat("#,##0.00", "en_US").format(shotVal).replaceAll('.00', '');
    }

    String receiptNo = item['receiptNo'];
    receiptNo = '${receiptNo.substring(0,3)}...${receiptNo.substring(receiptNo.length - 5,receiptNo.length)}';

    bool isRefund = bool.parse(item['isRefund'].toString());
    
    return Slidable(
      key: ValueKey(index),

      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (BuildContext context)=> ReceiptDelete(item['id'],index,item['receiptNo']),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'ยกเลิก',
          ),
        ],
      ), child: Ink(
        color: (isRefund)?Colors.yellow.shade400:Colors.transparent,
        child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ServiceUI.ListNumberCircle(index+1, Colors.lightBlue.shade200, Colors.black,15),
                const SizedBox(width: 5,),
                Expanded(child: Text(receiptNo,style: const TextStyle(color: Colors.lightBlue,fontSize: 15),)),
                GestureDetector(
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
                            Visibility(
                              visible: disValue!='0',
                              child: Row(
                                children: [
                                  const SizedBox(width: 5,),
                                  Image.asset('assets/images/dis_icon.png',height: 22),
                                  Text(' $disValue',style: const TextStyle(fontSize: 12),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                )
              ],
            ),
            ),
      ),
    );
  }

  void ReceiptDetail(String id){
    debugPrint(id);

    showDialog(
        context: context,
        builder: (BuildContext context){
          return ReceiptDetailPage(id: id,QuickShow: false,);
        });
  }

  void ReceiptDelete(String id,int itemIndex,String receiptNo){
    debugPrint(id);
    debugPrint(itemIndex.toString());

    showDialog(
        context: context,
        builder: (context){

          var items = DeclareValue.ReceiptXReasons.map((item) {
            return DropdownMenuItem<mdlReceiptXReason>(
              key:  UniqueKey(),
              value: item,
              child: Text(item.Reason),
            );
          }).toList();

          TextEditingController _remarkController = TextEditingController();
          mdlReceiptXReason? XValue = DeclareValue.ReceiptXReasons.first;
          bool XValueProcess = false;

          return AlertDialog(
            title: const Text('เหตุผล'),
            content: StatefulBuilder(
              builder: (context,setState){
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('เหตุผลการลบใบกำกับภาษี')),
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
              },
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
        });
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

  void PrepareSumm(){
    setState(() {
      summ_cash = 0;
      summ_pie = 0;
      summ_dis = 0;
    });

    for(int i = 0;i < data_item.length;i++){
      int pie = int.tryParse(data_item[i]['piece'].toString()) ?? 0;
      double cash = double.tryParse(data_item[i]['cash'].toString()) ?? 0.00;
      double dis = double.tryParse(data_item[i]['dis'].toString()) ?? 0.00;

      setState(() {
        summ_cash += cash;
        summ_pie += pie;
        summ_dis += dis;
      });
    }
  }

}