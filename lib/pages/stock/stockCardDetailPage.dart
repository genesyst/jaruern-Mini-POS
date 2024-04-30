

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blStock.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class StockCardDetailPage extends StatelessWidget{
  final String CardNo;
  const StockCardDetailPage({super.key,required this.CardNo});

  @override
  Widget build(BuildContext context) {
    return _StockCardDetailPage(CardNo);
  }

}

class _StockCardDetailPage extends StatefulWidget{
  late String CardNo;
  _StockCardDetailPage(String cardno){
    CardNo = cardno;
  }

  @override
  State<StatefulWidget> createState() {
    return _StockCardDetailPageState(CardNo);
  }

}

class _StockCardDetailPageState extends State<_StockCardDetailPage>{
  late String CardNo;
  List<Map<String, dynamic>> data = [];
  bool indicator_list = false;

  int all_pie = 0;
  double all_cost = 0;

  _StockCardDetailPageState(String cardno){
    CardNo = cardno;

  }

  @override
  void initState() {
    super.initState();

    PrepareData();
  }

  void PrepareData(){
    setState(() {
      indicator_list = true;
    });

    BLStock(context).GetStockCardsDetail(CardNo, DeclareValue.currentStoreId).then((value){
      debugPrint(value.toString());

      setState(() {
        data = value;
        for(int i=0;i< data.length;i++){
          int piece = int.tryParse(data[i]['piece'].toString()) ?? 0;
          double cost = double.tryParse(data[i]['cost'].toString()) ?? 0.0;

          all_pie += piece;
          all_cost += piece * cost;
        }

        indicator_list = false;
      });

    }).onError((error, stackTrace) {
      setState(() {
        indicator_list = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown.shade200,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/1670443.png',height: 30,),
            AutoSizeText(CardNo),
            ServiceUI.CloseCrossButton(context, 0),
          ],
        ),
      ),
      body: Column(
        children: [
          ServiceUI.Indicater(indicator_list),
          Expanded(child: GoodsList()),
        ],
      ),
      bottomNavigationBar: Footer(),
    ));
  }

  Widget GoodsList(){
    return ListView.separated(
      itemCount: data.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context,int index){
        final item = data[index];
        return GestureDetector(
          onTap: ()=>{},
          child: GoodsListItem(item,index),
        );
      }, separatorBuilder: (BuildContext context, int index) {
      return const Divider();
    },
    );
  }

  Widget GoodsListItem(Map<String,dynamic> item,int index){
    int piece = int.tryParse(item['piece'].toString()) ?? 0;
    String pieceValue = NumberFormat("#,##0", "en_US").format(piece);

    double price = double.tryParse(item['saleprice'].toString()) ?? 0.0;
    String priceValue = NumberFormat("#,##0.00", "en_US").format(price);

    double discount = double.tryParse(item['discount'].toString()) ?? 0.0;
    String discountValue = NumberFormat("#,##0.00", "en_US").format(discount);

    double member = double.tryParse(item['memberprice'].toString()) ?? 0.0;
    String memberValue = NumberFormat("#,##0.00", "en_US").format(member);

    double cost = double.tryParse(item['cost'].toString()) ?? 0.0;
    String costValue = NumberFormat("#,##0.00", "en_US").format(cost);

    String unit = item['unit${DeclareValue.DefaultCulture.toLowerCase()}'];

    return Slidable(
      key: ValueKey(index),
      child: ListTile(
        title: Row(
          children: [
            ServiceUI.ListNumberCircle(index+1, Colors.brown.shade200, Colors.black,15),
            const SizedBox(width: 5,),
            Expanded(child: Text(item['skuname'],style: const TextStyle(color: Colors.brown),)),
          ],
        ),
        subtitle: Column(
          children: [
            const SizedBox(height: 7,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['skubarcode']),
                Row(
                  children: [
                    Image.asset('assets/images/size_icon.png',height: 25,),
                    Text(item['skusize']),
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
                      Text(priceValue),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Image.asset('assets/images/dis_icon.png',width: 20,),
                      Text(discountValue!='0.00'? item['discount'].toString():''),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Image.asset('assets/images/member_icon.png',width: 20,),
                      Text(memberValue!='0.00'? item['member'].toString():''),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Image.asset('assets/images/cost_icon.png',width: 20,),
                      Text(costValue!='0.00'? item['cost'].toString():''),
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
                Text(pieceValue,style: const TextStyle(color:Colors.blue,fontWeight: FontWeight.bold,fontSize: 17),),
                const SizedBox(width: 7,),
                Text(unit),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShowGoodsSumm(),
                ],
              ),
            ),
          ),
        )
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

}