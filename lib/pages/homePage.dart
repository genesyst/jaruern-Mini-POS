

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jaruern_mini_pos/BL/blRepository.dart';
import 'package:jaruern_mini_pos/BL/blSetting.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/pages/goodsPage.dart';
import 'package:jaruern_mini_pos/pages/myStorePage.dart';
import 'package:jaruern_mini_pos/pages/pos/holdOrderPage.dart';
import 'package:jaruern_mini_pos/pages/pos/retGoodsPage.dart';
import 'package:jaruern_mini_pos/pages/pos/salescanPage.dart';
import 'package:jaruern_mini_pos/pages/settingPage.dart';
import 'package:jaruern_mini_pos/pages/signinPage.dart';
import 'package:jaruern_mini_pos/pages/stock/stockPage.dart';
import 'package:jaruern_mini_pos/settingValues.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _searchEditController = TextEditingController();
  int _search_length = 0;

  int _selectedIndex = 0;
  String StoreId = '';
  String StoreName = 'Mini P.O.S.';

  final GlobalKey<SaleScanPageState> saleScanPageState = GlobalKey();
  final GlobalKey<RetGoodsPageState> retGoodsPageState = GlobalKey();
  final GlobalKey<HoldOrderPageState> holdOrderPageState = GlobalKey();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    SearchSubmit('');
  }

  @override
  void initState(){
    super.initState();

    _searchEditController.addListener(() {
      setState(() => _search_length = _searchEditController.text.length);
    });

    //load all setting
    DeclareValue().getAllSetting();

    StoreId = DeclareValue.currentStoreId;
    StoreName = DeclareValue.currentStoreName;

    BLRepository().RequestAllPermission();

    loadSettingValues();
  }

  void loadSettingValues(){
    BLSetting(context).getValues().then((value){
      debugPrint(value.toString());

      setState(() {
        DeclareValue.SettingData = value;
      });

      for(int i=0;i < DeclareValue.SettingData.length;i++){
        String key = DeclareValue.SettingData[i]['setkey'].toString().toUpperCase();

        switch(key){
          case 'VAT':
            String rawVal = DeclareValue.SettingData[i]['setvalDou'].toString();
            double val = double.tryParse(rawVal) ?? 0;
            SettingValues().setVAT(val);
            break;
          case 'VATIN':
            String rawVal = DeclareValue.SettingData[i]['setvalStr'].toString();
            bool value = true;
            if(rawVal == 'false'){
              value = false;
            }
            SettingValues().setVatinner(value);
            break;
        }
      }

    });
  }

  DateTime currentBackPressTime = DateTime.now();
  Future<bool> _onWillPop(BuildContext context) async {
    try {
      DateTime now = DateTime.now();
      if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        Fluttertoast.showToast(msg: 'กดอีกครั้งเพื่อออก');
        return Future.value(false);
      }
      return Future.value(true);
    }catch(e){
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    //config Orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return WillPopScope(
      onWillPop: ()=>_onWillPop(context),
      child: DefaultTabController(
        length: 3,
        child: SafeArea(child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lightBlue.shade200,
            title: SearchBoxBar(),
            automaticallyImplyLeading: true,
            bottom: TabBar(
              indicatorColor: Colors.black,
              tabs: [
                Tab(icon: Image.asset('assets/images/7801744.png',height: 32,),text: 'สแกนสินค้า',),
                Tab(icon: Image.asset('assets/images/goods_keep.png',height: 32,),text: 'สั่ง/จองสินค้า',),
                Tab(icon: Image.asset('assets/images/goods_rev.png',height: 32,),text: 'คืนสินค้า',),
              ],
              onTap: (index)=>_onItemTapped(index),
            ),
          ),
          body: TabBarView(
            children: [
              SaleScanPage(key: saleScanPageState),
              HoldOrderPage(key: holdOrderPageState),
              RetGoodsPage(key: retGoodsPageState),
            ],
          ),
          drawer: Drawer(
            child: DrawerMenuItems(),
          ),
        )),
      ),
    );
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
      onChanged: (text)=>SearchFilter(text),
      onSubmitted: (text)=>SearchSubmit(text),
    );
  }

  Widget? SearchBoxBtn(){
    if(_search_length > 0){
      return IconButton(
        onPressed: (){
          _searchEditController.text = '';
          SearchSubmit('');
          SearchFilter('');
        },
        icon: const Icon(Icons.clear),
      );
    }else{
      return null;/*IconButton(
        onPressed: _searchEditController.clear,
        icon: Icon(Icons.search),
      );*/
    }
  }

  SearchSubmit(String value){
    try{
      switch(_selectedIndex){
        case 2:
          retGoodsPageState.currentState?.FilterData(value);
          break;
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  SearchFilter(String value){
    try{
      switch(_selectedIndex){
        case 0:
          saleScanPageState.currentState?.FilterData(value);
          break;
        case 1:
          holdOrderPageState.currentState?.FilterData(value);
          break;
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget DrawerMenuItems(){
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.lightBlueAccent,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 110,
                child: Image.asset('assets/images/mini_pos_title.png',),
              ),
              Expanded(child: InkWell(
                onTap: ()=> Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const MyStorePage())),
                child: AutoSizeText(
                    StoreName,
                    style: const TextStyle(fontWeight: FontWeight.normal)
                ),
              )),
            ],
          ),
        ),
        StockMenuItem(),
        SalerMenuItem(),
        const Divider(),
        GoodsMenuItem(),
        SettingMenuItem(),
        const Divider(),
        SignoutMenuItem(),
      ],
    );
  }

  Widget StockMenuItem(){
    return ListTile(
      title: Row(
        children: [
          Image.asset('assets/images/1670443.png',height: 25,),
          const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: Text('จัดการคลังสินค้า'),
          ),
        ],
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context){
              return const StockPage();
            });
      },
    );
  }

  Widget SalerMenuItem(){
    return ListTile(
      title: Row(
        children: [
          Image.asset('assets/images/report.png',height: 25,),
          const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: Text('รายงานยอดขาย'),
          ),
        ],
      ),
      onTap: () {

      },
    );
  }

  Widget GoodsMenuItem(){
    return ListTile(
      title: Row(
        children: [
          Image.asset('assets/images/pd_icon.png',height: 28,),
          const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: Text('สินค้า'),
          ),
        ],
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context){
              return const GoodsPage(mode: GoodsMode.AddGoods,);
            });
      },
    );
  }

  Widget SettingMenuItem(){
    return ListTile(
      title: Row(
        children: [
          Image.asset('assets/images/setting_gear.png',height: 25,),
          const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: Text('ตั้งค่าการใช้งาน'),
          ),
        ],
      ),
      onTap: () => Settting(),
    );
  }

  Widget SignoutMenuItem(){
    return ListTile(
      title: Row(
        children: [
          Image.asset('assets/images/signout_icon.png',height: 25,),
          const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: Text('ลงชื่อออก'),
          ),
        ],
      ),
      onTap: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SignInPage()));
      },
    );
  }

  void Settting(){
    try{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return const SettingPage();
          });
    }catch(e){
      throw Exception(e);
    }
  }

  @override
  void dispose() {
    _searchEditController.dispose();
    super.dispose();
  }


}