

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/pages/stock/stockBalancePage.dart';
import 'package:jaruern_mini_pos/pages/stock/stockInPage.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceDateTimeUtils.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class StockPage extends StatelessWidget{
  const StockPage({super.key});

  static late DateTime _GStkDate;

  static DateTime get GStkDate => _GStkDate;

  static set GStkDate(DateTime value) {
    _GStkDate = value;
  }

  @override
  Widget build(BuildContext context) {
    return _StockPage();
  }

}

class _StockPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _StockPageState();
  }

}

class _StockPageState extends State<_StockPage>{
  final _searchEditController = TextEditingController();
  int _search_length = 0;
  int currentTabIndex = 0;

  var _currentDate = DateTime.now();
  String _currentDateStr = '';

  final GlobalKey<StockInPageState> stockInPageState = GlobalKey();
  final GlobalKey<StockBalancePageState> stockBalancePageState = GlobalKey();

  @override
  void initState() {
    super.initState();

    StockPage.GStkDate = _currentDate;

    setState(() {
      _currentDateStr = ServiceDateTimeUtils.SetType(DateYearType.Buddhist)
          .DateToString(_currentDate, Date2String.fullmonth);
    });

    _searchEditController.addListener(() {
      setState(() => _search_length = _searchEditController.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    //config Orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.brown.shade200,
            title: SearchBoxBar(),
            automaticallyImplyLeading: true,
            bottom: TabBar(
              indicatorColor: Colors.black,
              tabs: [
                Tab(icon: Image.asset('assets/images/goods.png',height: 32,),text: 'สินค้าคงคลัง',),
                Tab(icon: Image.asset('assets/images/1524818.png',height: 32,),text: 'รับเข้า',),
                Tab(icon: Image.asset('assets/images/3271314.png',height: 32,),text: 'ขายออก',),
              ],
              onTap: (index){
                setState(() {
                  currentTabIndex = index;
                });
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.brown.shade200,
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
              Expanded(
                child: TabBarView(
                  children: [
                    StockBalancePage(key: stockBalancePageState),
                    StockInPage(key: stockInPageState),
                    const Icon(Icons.directions_bike),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget SearchBoxBar(){
    return TextField(
      controller: _searchEditController,
      decoration: InputDecoration(
        hintText: 'ค้นหา',
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 18,
          fontStyle: FontStyle.italic,
        ),
        border: InputBorder.none,
        suffixIcon: SearchBoxBtn(),
      ),
      onChanged: (text)=>SearchFilter(text),
    );
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

  SearchFilter(String value){
    try{
      switch(currentTabIndex){
        case 0:
          stockBalancePageState.currentState?.Filter(value);
          break;
        case 1:
          stockInPageState.currentState?.Filter(value);
          break;
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  DatePick() {
    try {
      ServiceUI.Style(Colors.brown.shade200, DeclareValue.DefaultCulture)
          .DatePicker(context,_currentDate).then((value){
        if(value!=null){
          setState(() {
            _currentDate = value;

            StockPage.GStkDate = _currentDate;

            _currentDateStr = ServiceDateTimeUtils.SetType(DateYearType.Buddhist)
                .DateToString(_currentDate, Date2String.fullmonth);

            switch(currentTabIndex){
              case 0:
                stockBalancePageState.currentState?.PrepareStockBal();
                break;
              case 1:
                stockInPageState.currentState?.PrepareStkInList(true);
                break;
            }

          });
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

}