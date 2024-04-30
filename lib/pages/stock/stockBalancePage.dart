


import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blStock.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/pages/stock/stockPage.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class StockBalancePage extends StatefulWidget{
  const StockBalancePage({Key? key}) : super(key: key);

  @override
  StockBalancePageState createState()=>StockBalancePageState();
}

class StockBalancePageState extends State<StockBalancePage>{

  bool indicator_list = false;
  List<Map<String,dynamic>> data = [];
  List<Map<String,dynamic>> data_item = [];

  late double screenWidth;
  double value_col_width = 60;
  double numColSize = 20;

  @override
  void initState() {
    super.initState();

    PrepareStockBal();
  }


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> PrepareStockBal() async {
    try{
      indicator_list = true;
      List<Map<String,dynamic>> res = await BLStock(context).GetStockBalance(
                                              StockPage.GStkDate, DeclareValue.currentStoreId);
      if(res!=null){
        setState(() {
          data = res;
        });
      }

      Filter('');

      debugPrint(res.toString());
    }catch(e){
      debugPrint(e.toString());
    }finally{
      indicator_list = false;
    }
  }

  void Filter(String findValue){
    setState(() {
      data_item = [];
    });
    try{
      for(var d in data){
        if(findValue.isEmpty){
          data_item.add(d);
        }else{
          String name =d['goodsName'].toString().toUpperCase();
          if(name.contains(findValue.toUpperCase())){
            data_item.add(d);
          }
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(child: Scaffold(
      body: Column(
        children: [
          ServiceUI.Indicater(indicator_list),
          Expanded(child: BalanceTable()),
        ],
      ),
    ));
  }

  Widget BalanceTable(){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: screenWidth,
        child: DataTable(
          columnSpacing: 5,
            border: TableBorder.all(width: 0.5,color: Colors.black45,),
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.brown.shade200),
            columns: [
              const DataColumn(label: Expanded(child: Text('#'))),
              const DataColumn(
                  label: Expanded(child: Text('สินค้า',))
              ),
              DataColumn(label: Container(
                alignment: Alignment.center,
                //width: value_col_width,
                child: Image.asset('assets/images/arr_r.png',width: 20,),
                ),
                numeric: true,
              ),
              DataColumn(label: Container(
                alignment: Alignment.center,
                //width: value_col_width,
                child: Image.asset('assets/images/arr_d.png',width: 20,),
                ),
                numeric: true,
              ),
              DataColumn(label: Container(
                alignment: Alignment.center,
                //width: value_col_width,
                child: Image.asset('assets/images/arr_u.png',width: 20,),
                ),
                numeric: true,
              ),
              DataColumn(label: Container(
                alignment: Alignment.center,
                //width: value_col_width,
                child: Image.asset('assets/images/arr_r.png',width: 20,),
                ),
                numeric: true,
              ),
            ],
            rows: PrepareDataRow(),
        ),
      ),
    );
  }

  List<DataRow> PrepareDataRow(){
    List<DataRow> rows = [];
    for(int i=0;i < data_item.length;i++){
      String goodsName = data_item[i]['goodsName'];
      int tbfPiece = int.tryParse(data_item[i]['tbfPiece'].toString()) ?? 0;
      int inPiece = int.tryParse(data_item[i]['inPiece'].toString()) ?? 0;
      int outPiece = int.tryParse(data_item[i]['outPiece'].toString()) ?? 0;
      int tcfPiece = int.tryParse(data_item[i]['tcfPiece'].toString()) ?? 0;

      String tbfPieceValue = NumberFormat("#,##0", "en_US").format(tbfPiece);
      String inPieceValue = NumberFormat("#,##0", "en_US").format(inPiece);
      String outPieceValue = NumberFormat("#,##0", "en_US").format(outPiece);
      String tcfPieceValue = NumberFormat("#,##0", "en_US").format(tcfPiece);

      rows.add(
        DataRow(
          cells: [
            DataCell(Text('${i+1}')),
            DataCell(Text(goodsName,style: const TextStyle(fontSize: 12),)),
            DataCell(Container(
                //width: value_col_width,
                alignment: Alignment.centerRight,
                child: Text(tbfPieceValue,style: const TextStyle(fontSize: 12,color: Colors.blue),))),
            DataCell(Container(
                //width: value_col_width,
                alignment: Alignment.centerRight,
                child: Text(inPieceValue,style: const TextStyle(fontSize: 12,color: Colors.green),))),
            DataCell(Container(
                //width: value_col_width,
                alignment: Alignment.centerRight,
                child: Text(outPieceValue,style: const TextStyle(fontSize: 12,color: Colors.green),))),
            DataCell(Container(
                //width: value_col_width,
                alignment: Alignment.centerRight,
                child: Text(tcfPieceValue,style: const TextStyle(fontSize: 12,color: Colors.blue),))),
          ],
        ),
      );
    }

    return rows;
  }

}