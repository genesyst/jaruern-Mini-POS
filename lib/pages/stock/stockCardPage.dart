

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jaruern_mini_pos/BL/blStock.dart';
import 'package:jaruern_mini_pos/Models/mdlStockInCard.dart';
import 'package:jaruern_mini_pos/declareTemp.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/showSnack.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class StockCardPage extends StatelessWidget{
  const StockCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StockCardPage();
  }

}

class _StockCardPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _StockCardPageState();
  }

}

class _StockCardPageState extends State<_StockCardPage>{

  bool indicator_list = false;
  List<Map<String,dynamic>> data = [];

  var _currentDate = DateTime.now();
  String _currentDateStr = '';
  String card_remark = 'หมายเหตุ';
  String remarkcap = 'หมายเหตุ';

  bool isSaved = false;

  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState(){
    super.initState();

    setState(() {
      _currentDateStr = ServiceDateTimeUtils.SetType(DateYearType.Buddhist)
          .DateToString(_currentDate, Date2String.fullmonth);

      data = DeclareTemp.stockin_card;
      debugPrint(data.toString());
    });

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/goods3.png',height: 25,),
            const Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: Text('รายการรับสินค้าเข้า',style: TextStyle(fontSize: 17),),
            ),
            GestureDetector(
                onTap: ()=>{Navigator.pop(context)},
                child: Image.asset('assets/images/close_cross.png',height: 20,)
            ),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body:Column(
          children: [
            Container(
              color: Colors.lightBlue.shade200,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: ()=>DatePick(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/calendar_icon.png',height: 30,),
                          const SizedBox(width: 10,),
                          Text(_currentDateStr,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ServiceUI.Indicater(indicator_list),
            Expanded(child: StockGoodsListView(context)),
          ],
        ),
      bottomNavigationBar: Footer(),
      ),
    );
  }

  Future<void> DatePick() async {
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

  Widget Footer(){
    return Visibility(
      visible: data.isNotEmpty,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.lightBlue.shade200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: ()=>RemarkDialog(),
                    child: Row(
                      children: [
                        const SizedBox(width: 5,),
                        Image.asset('assets/images/remark_icon.png',height: 25,),
                        const SizedBox(width: 5,),
                        Text(remarkcap),
                        const SizedBox(width: 10,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Visibility(
                    visible: !isSaved,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilledButton.tonal(
                            onPressed: ()=>ClearList(),
                            child: const Text('ล้าง')
                        ),
                        FilledButton(
                            onPressed: ()=>AddStock(),
                            child: Text('ทำรับเข้า (${data.length})')
                        ),
                      ],
                    ),
                  ),
                  ServiceUI.Indicater(isSaved),
                ],
              ),
            ),
          ),
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
                            card_remark = _remarkController.text;
                            ShowSnack(context,card_remark).Show(MessageType.info);

                            remarkcap = '$remarkcap*';
                          }else{
                            card_remark = '';
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

  Future<void> AddStock() async {
    try{
      if (await confirm(context,
          title: const Text('รับสินค้า'),
          content: Text('ต้องการบันทึกรับเข้า ${DeclareTemp.stockin_card.length} รายการ หรือไม่?'),
          textOK: const Text('ใช่'),
          textCancel: const Text('ยังก่อน'),
          )) {

        setState(() {
          isSaved = true;
        });

        mdlStockInCard card = mdlStockInCard();
        card.Atdate = ServiceDateTimeUtils().DateToParam(_currentDate);
        card.Culture = DeclareValue.DefaultCulture;
        card.Tag = '';
        if(card_remark!=remarkcap){
          card.Remark = card_remark;
        }else{
          card.Remark = '';
        }

        card.Storeid = DeclareValue.currentStoreId;

        List<Map<String, dynamic>> stkGoods = PrepareStockGoods();

        BLStock(context).setStockIn(card, stkGoods).then((value){
          debugPrint(value.toString());

          try {
            int msgIndex = int.parse(value!['id'].toString());
            String msg = value['msg'].toString();
            if (msgIndex == 0) {
              DeclareTemp.stockin_card = [];
              data = [];
              ShowToast(
                  context, 'รับเข้าสินค้าเรียบร้อย\nสต๊อกการ์ดเลขที่ $msg')
                  .Show(MessageType.info);
              Navigator.pop(context,{'added':true});
            } else {
              ShowToast(
                  context, 'ผิดพลาดไม่สามารถบันทึกสต๊อกการ์ดได้ ($msgIndex)')
                  .Show(MessageType.error);
            }
          }finally{
            setState(() {
              isSaved = false;
            });
          }
        }).onError((error, stackTrace){
          setState(() {
            isSaved = false;
          });
        });
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  List<Map<String, dynamic>> PrepareStockGoods(){
    List<Map<String, dynamic>> stockGoods = [];
    for(var goods_item in DeclareTemp.stockin_card){
      stockGoods.add({
        'Goodid': goods_item['goodsid'],
        'Saleprice': goods_item['saleprice'],
        'Discount': goods_item['discount'],
        'Memberprice': goods_item['member'],
        'Cost': goods_item['cost'],
        'Remark': goods_item['remark'] ?? '',
        'Tag': '',
        'Piece': goods_item['piece'].toString().replaceAll(',', ''),
        'Unitid': goods_item['unitid']
      });
    }

    return stockGoods;
  }

  Future<void> ClearList() async {
    if (await confirm(context,
    title: const Text('รับสินค้า'),
    content: Text('คุณกำลังทำรายการรับเข้า ${data.length} รายการ ต้องการยกเลิกรายการทั้งหมดหรือไม่?'),
    textOK: const Text('ใช่'),
    textCancel: const Text('ยังก่อน'),
    )){
      DeclareTemp.stockin_card = [];
      setState(() {
        data = DeclareTemp.stockin_card;
      });
    }
  }

  Widget StockGoodsListView(BuildContext context){
    return ListView.separated(
      itemCount: data.length,
      shrinkWrap: true,
        itemBuilder: (BuildContext context,int index){
          final item = data[index];
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
              DeclareTemp.StockRemove(item['barcode']);
              setState(() {
                data = DeclareTemp.stockin_card;
              });
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'เอาออก',
          ),
        ],
      ), child: ListTile(
            title: Text(item['goodsname'],style: const TextStyle(color: Colors.brown),),
            subtitle: Column(
              children: [
                const SizedBox(height: 7,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['barcode']),
                    Row(
                      children: [
                        Image.asset('assets/images/size_icon.png',height: 25,),
                        Text(item['size']),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 7,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/sale_icon.png',width: 20,),
                          Text(item['saleprice'].toString()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/dis_icon.png',width: 20,),
                          Text(item['discount'].toString()!='null'? item['discount'].toString():''),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/member_icon.png',width: 20,),
                          Text(item['member'].toString()!='null'? item['member'].toString():''),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/cost_icon.png',width: 20,),
                          Text(item['cost'].toString()!='null'? item['cost'].toString():''),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('จำนวนรับ'),
                    const SizedBox(width: 7,),
                    Text(item['piece'],style: const TextStyle(color:Colors.blue,fontWeight: FontWeight.bold,fontSize: 17),),
                    const SizedBox(width: 7,),
                    Text(item['unitname']),
                  ],
                ),
              ],
            ),
        ),
    );
  }

}