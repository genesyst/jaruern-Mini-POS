

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blStock.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/goodsPage.dart';
import 'package:jaruern_mini_pos/pages/stock/stockCardDetailPage.dart';
import 'package:jaruern_mini_pos/pages/stock/stockPage.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';


class StockInPage extends StatefulWidget{
  const StockInPage({Key? key}) : super(key: key);

  @override
  StockInPageState createState()=>StockInPageState();

}

class StockInPageState extends State<StockInPage>{

  int goods_loadIndex = 0;
  int card_loadIndex = 0;

  bool _listStockGoods = true;
  bool indicator_list = false;
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> data_item = [];

  int all_goods_list = 0;
  int all_pie = 0;

  double all_cost = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if(_listStockGoods) {
          goods_loadIndex++;
          PrepareStkGoodsList(false);
        }else{
          card_loadIndex++;
        }

        print("load more...");
      }
    });

    PrepareStkInList(true);

  }

  void GoodsFilter(String findvalue){
    if(data.isNotEmpty){
      data_item.clear();
      if(findvalue.isNotEmpty) {
        String findVal = findvalue.toUpperCase();
        for (int i = 0; i < data.length; i++) {
          String cardNo = data[i]['cardNo'].toString();
          String skuCode = data[i]['skuCode'].toString();
          String skuName = data[i]['skuName'].toString();
          String barcode = data[i]['barcode'].toString();
          String remark = data[i]['remark'].toString();
          if (cardNo.toUpperCase().contains(findVal)
              || skuCode.toUpperCase().contains(findVal)
              || skuName.toUpperCase().contains(findVal)
              || barcode.toUpperCase().contains(findVal)
              || remark.toUpperCase().contains(findVal)
          ) {
            setState(() {
              data_item.add(data[i]);
            });
          }
        }
      }else{
        for (int i = 0; i < data.length; i++) {
          setState(() {
            data_item.add(data[i]);
          });
        }
      }
    }
  }

  void CardFilter(String findvalue){
    if(data.isNotEmpty){
      data_item.clear();
      if(findvalue.isNotEmpty) {
        String findVal = findvalue.toUpperCase();
        for (int i = 0; i < data.length; i++) {
          String cardNo = data[i]['cardno'].toString();
          String remark = data[i]['remark'].toString();
          if (cardNo.toUpperCase().contains(findVal)
              || remark.toUpperCase().contains(findVal)
          ) {
            setState(() {
              data_item.add(data[i]);
            });
          }
        }
      }else{
        for (int i = 0; i < data.length; i++) {
          setState(() {
            data_item.add(data[i]);
          });
        }
      }
    }
  }

  void Filter(String findvalue){
    if(_listStockGoods){
      GoodsFilter(findvalue);
    }else{
      CardFilter(findvalue);
    }

    GetSum();
  }

  void PrepareStkInList(bool newdata){
    setState(() {
      indicator_list = true;
    });

    if(newdata){
      setState(() {
        goods_loadIndex = 0;
        data.clear();
        data_item.clear();

        all_pie = 0;
        all_goods_list = 0;
      });
    }

    if(_listStockGoods){
      PrepareStkGoodsList(newdata);
    }else{
      PrepareStkCardList(newdata);
    }
  }

  void PrepareStkCardList(bool newdata){
    try{
      BLStock(context).GetStockCards(goods_loadIndex,
          DeclareValue.currentStoreId,
          StockPage.GStkDate).then((value){
        debugPrint(value.toString());

        try{
          for(int i=0;i < value.length;i++){
            setState(() {
              data.add(value[i]);
            });
          }

          Filter('');
        }finally{
          setState(() {
            indicator_list = false;
          });
        }
      }).onError((error, stackTrace){
        setState(() {
          indicator_list = false;
        });
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void PrepareStkGoodsList(bool newdata){
    try{
      BLStock(context).GetStockGoods(goods_loadIndex,
          DeclareValue.currentStoreId,
          StockPage.GStkDate).then((value){
        debugPrint(value.toString());

        try {
          for(int i=0;i < value.length;i++){
            setState(() {
              data.add(value[i]);
            });
          }

          Filter('');
        }finally{
          setState(() {
            indicator_list = false;
          });
        }
      }).onError((error, stackTrace) {
        setState(() {
          indicator_list = false;
        });
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
      Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: ()=>GoodsDialog(),
          child: Image.asset('assets/images/plus_icon.png',height: 35),
        ),
        body: Column(
          children: [
            ServiceUI.Indicater(indicator_list),
            Expanded(child: StkInList()),
          ],
        ),
        bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget StkInList(){
    return ListView.separated(
      itemCount: data_item.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context,int index){
        final item = data_item[index];
        return GestureDetector(
          onTap: ()=>{},
          child: _listStockGoods? GoodsListItem(item,index):CardListItem(item,index),
        );
      }, separatorBuilder: (BuildContext context, int index) {
      return const Divider();
    },
    );
  }

  Widget CardListItem(Map<String,dynamic> item,int index){
    int goodsCount = int.tryParse(item['goods'].toString()) ?? 0;
    int goodsPie = int.tryParse(item['piece'].toString()) ?? 0;

    String pieceValue = NumberFormat("#,##0", "en_US").format(goodsPie);
    String goodsValue = NumberFormat("#,##0", "en_US").format(goodsCount);

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
              DelStockIn(item['id'],item['cardno'], index);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'ยกเลิก',
          ),
        ],
      ), child: ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ServiceUI.ListNumberCircle(index+1, Colors.brown.shade200, Colors.black,15),
          const SizedBox(width: 5,),
          Expanded(child: Text(item['cardno'],style: const TextStyle(color: Colors.brown),)),
          GestureDetector(
            onTap: ()=>StkCardDialog(item['cardno']),
            child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                  child: Row(
                    children: [
                      Image.asset('assets/images/1670443.png',height: 22),
                      Text(' $goodsValue  ',),
                      Image.asset('assets/images/goods2.png',height: 22),
                      Text(' $pieceValue',),
                    ],
                  ),
                )
            ),
          ),
        ],
      ),
      subtitle: Column(
        children: [
          const SizedBox(height: 7,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/images/remark_icon.png',height: 22),
              const SizedBox(width: 5,),
              Expanded(child: Text(item['remark'],style: const TextStyle(color: Colors.black45),)),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget GoodsListItem(Map<String,dynamic> item,int index){
    double piece = double.tryParse(item['piece'].toString()) ?? 0.0;
    String pieceValue = NumberFormat("#,##0", "en_US").format(piece);

    return Slidable(
      key: ValueKey(index),
      child: ListTile(
      title: Row(
        children: [
          ServiceUI.ListNumberCircle(index+1, Colors.brown.shade200, Colors.black,15),
          const SizedBox(width: 5,),
          Expanded(child: Text(item['skuName'],style: const TextStyle(color: Colors.brown),)),
        ],
      ),
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
              GestureDetector(
                onTap: ()=>StkCardDialog(item['cardNo']),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/stk_card.png',height: 20,),
                    const SizedBox(width: 5,),
                    Text(item['cardNo'],style: const TextStyle(color: Colors.lightBlue),),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('รับ'),
                  const SizedBox(width: 7,),
                  Text(pieceValue,style: const TextStyle(color:Colors.blue,fontWeight: FontWeight.bold,fontSize: 17),),
                  const SizedBox(width: 7,),
                  Text(item['unitname']),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget Footer(){
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.brown.shade200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  itm_ShowListOnoff(),
                  _listStockGoods? ShowGoodsSumm():ShowCardSumm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ShowGoodsSumm(){
    double costVal = all_cost;
    String allCostValue = NumberFormat("#,##0", "en_US").format(all_cost);

    if(costVal > 9999){
      costVal = costVal / 1000.00;
      allCostValue = '${NumberFormat("#,##0", "en_US").format(costVal)}K';
    }

    String allPieValue = NumberFormat("#,##0", "en_US").format(all_pie);

    return GestureDetector(
      onTap: (){
        setState(() {
          _listStockGoods = false;
        });

        PrepareStkInList(true);
      },
      child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
            child: Row(
              children: [
                Image.asset('assets/images/goods2.png',height: 22),
                Text(' $allPieValue  ',),
                Image.asset('assets/images/cost2_icon.png',height: 22),
                Text(' $allCostValue',),
              ],
            ),
          )
      ),
    );
  }

  Widget ShowCardSumm(){
    String allGoodsValue = NumberFormat("#,##0", "en_US").format(all_goods_list);
    String allPieValue = NumberFormat("#,##0", "en_US").format(all_pie);

    return GestureDetector(
      onTap: (){
        setState(() {
          _listStockGoods = true;
        });

        PrepareStkInList(true);
      },
      child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
            child: Row(
              children: [
                Image.asset('assets/images/1670443.png',height: 22),
                Text(' $allGoodsValue  ',),
                Image.asset('assets/images/goods2.png',height: 22),
                Text(' $allPieValue',),
              ],
            ),
          )
      ),
    );
  }

  Widget itm_ShowListOnoff(){
    return Switch(
      // This bool value toggles the switch.
      value: _listStockGoods,
      trackColor: const MaterialStatePropertyAll<Color>(Colors.white38),
      thumbColor: const MaterialStatePropertyAll<Color>(Colors.brown),
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          _listStockGoods = value;

          data.clear();
          data_item.clear();

          all_goods_list = 0;
          all_pie = 0;
        });

        PrepareStkInList(true);

        if(_listStockGoods){
          ShowToast.Gravity(context,'แสดงรายการสินค้าเข้า',ToastGravity.CENTER).Show(MessageType.info);
        }else{
          ShowToast.Gravity(context,'แสดงเป็นสต๊อกการ์ด',ToastGravity.CENTER).Show(MessageType.info);
        }
      },
    );
  }

  void GoodsDialog(){
    try{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return const GoodsPage(mode: GoodsMode.AddStock,);
          }).then((result) {
          if (result != null && result is Map) {
            bool isAdded = result['stkadded'];
            if(isAdded){
              PrepareStkInList(true);
            }
          }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void StkCardDialog(String cardno){
    try{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return StockCardDetailPage(CardNo: cardno,);
          });
    }catch(e){
      throw Exception(e);
    }
  }
  
  Future<void> DelStockIn(String id,String cardno,int index) async {
    try{
      if (await confirm(context,
          title: const Text('รับเข้า'),
          content: Text('ต้องการยกเลิกรายการรับเข้า เลขที่ $cardno หรือไม่?'),
          textOK: const Text('ใช่'),
          textCancel: const Text('ยังก่อน'),
      )) {
        setState(() {
          indicator_list = true;
        });
        BLStock(context).delStockIn(id).then((value){
          debugPrint(value.toString());

          try {
            int msgIndex = int.parse(value!['id'].toString());
            if (msgIndex == 0) {
              setState(() {
                data_item.removeAt(index);
              });

              for (int i = 0; i < data.length; i++) {
                String dataId = data[i]['id'];
                if (dataId.toUpperCase() == id.toUpperCase()) {
                  setState(() {
                    data.removeAt(i);
                  });
                  break;
                }
              }

              ShowToast(context, 'ยกเลิกรายการเลขที่ $cardno แล้ว').Show(
                  MessageType.complete);

              GetSum();
            } else if (msgIndex == 2) {
              ShowToast(context, 'ไม่พบข้อมูลของรายการเลขที่ $cardno').Show(
                  MessageType.warn);
            } else {
              ShowToast(context, 'ผิดพลาด ไม่สามารถยกเลิก $cardno ได้').Show(
                  MessageType.error);
            }
          }finally{
            setState(() {
              indicator_list = false;
            });
          }
        }).onError((error, stackTrace) {
          setState(() {
            indicator_list = false;
          });
        });
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void GetSum(){
    setState(() {
      all_goods_list = 0;
      all_pie = 0;
      all_cost = 0;
    });

    if(_listStockGoods){
      for (int i = 0; i < data.length; i++) {
        double goodsCost= double.tryParse(data[i]['cost'].toString()) ?? 0.00;
        int goodsPie = int.tryParse(data[i]['piece'].toString()) ?? 0;

        setState(() {
          all_pie += goodsPie;
          all_cost += goodsCost * goodsPie;
        });
      }
    }else {
      for (int i = 0; i < data.length; i++) {
        int goodsCount = int.tryParse(data[i]['goods'].toString()) ?? 0;
        int goodsPie = int.tryParse(data[i]['piece'].toString()) ?? 0;

        setState(() {
          all_goods_list += goodsCount;
          all_pie += goodsPie;
        });
      }
    }
  }

}