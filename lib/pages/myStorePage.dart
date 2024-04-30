

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jaruern_mini_pos/BL/blStore.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/pages/homePage.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceLocation.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:jaruern_mini_pos/settingValues.dart';

class MyStorePage extends StatelessWidget {
  const MyStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _MyStorePage();
  }

}

class _MyStorePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _MyStorePageState();
  }

}

class _MyStorePageState extends State<_MyStorePage>{
  final _searchEditController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _storeFilterFocusNode = FocusNode();
  List<Map<String, dynamic>> store_data = [];
  List<Map<String, dynamic>> store_items = [];

  int _search_length = 0;
  late Position? currPosition;
  String title_msg = 'ร้านค้าของฉัน';
  String currentStoreId = '';
  bool indicator_list = false;

  @override
  void initState(){
    super.initState();
    _searchEditController.addListener(() {
      setState(() => _search_length = _searchEditController.text.length);
    });

    //check store selected id
    CheckRegisStoreSelected();

    ServiceLocation().LocationServiceEnable();
    PrepareData();
  }

  void CheckRegisStoreSelected() {
    try{
      SettingValues().doesKeyExist(SettingValues().key_currentstoreid).then((value){
        if(value){
          SettingValues().getCurrentStoreId().then((selectedStoreId){
            DeclareValue.currentStoreId = selectedStoreId;
            setState(() {
              currentStoreId = DeclareValue.currentStoreId;
            });
          });

          SettingValues().getCurrentStoreName().then((selectedStoreName){
            DeclareValue.currentStoreName = selectedStoreName;
          });
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void PrepareData(){
    try{
      if(store_items.isNotEmpty) return;
       ServiceLocation().GetCurrentPosition().then((value){
         currPosition = value;
         debugPrint('===> $currPosition');

         setState(() {
           indicator_list = true;
         });

         BLStore(context).getMyStore(currPosition).then((mystore) {
           debugPrint(mystore);
           try {
             List<Map<String, dynamic>> resultApi = json.decode(
                 mystore)['results'].cast<Map<String, dynamic>>();

             setState(() {
               store_data.addAll(resultApi);
               indicator_list = false;
             });

             DataFind('');

           }catch(e){
             setState(() {
               indicator_list = false;
             });

             throw Exception(e);
           }
         });
       });
    }catch(e){
      throw Exception(e);
    }
  }

  void DataFind(String value){
    try{
      if(value.isEmpty){
        setState(() {
          store_items.clear();
          store_items.addAll(store_data);
        });
      }else{
        setState(() {
          store_items.clear();
        });

        String findValue = value.trim().toUpperCase();
        for(int i=0;i < store_data.length;i++){
          String code = store_data[i]['storeCode'].toString();
          String name = store_data[i]['storeName'].toString();
          if(code.toUpperCase().contains(findValue)
              || name.toUpperCase().contains(findValue)){
            setState(() {
              store_items.add(store_data[i]);
            });
          }
        }
      }
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue.shade200,
        title: SearchBoxBar(),
      ),
      body: SafeArea(child: Column(
        children: [
          ServiceUI.Indicater(indicator_list),
          Expanded(child: StoreListView(context)),
        ],
      )),
      bottomNavigationBar: Footer(),
    );
  }

  Widget StoreListView(BuildContext context){
    return ListView.separated(
      controller: _scrollController,
      itemCount: store_items.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context,int index){
        final item = store_items[index];
        return GestureDetector(
          onTap: ()=>StoreListViewTap(index),
          child: SizedBox(
            height: 50,
            child: ListTile(
              title: Row(
                children: [
                  PinStore(item['id']),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                    child: Text(item['storeName']),
                  )),
                  Text(item['nearKM'],style: const TextStyle(color: Colors.black26,fontSize: 15),),
                ],
              ),
            ),
          ),
        );
      }, separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
    );
  }

  Widget Footer(){
    return Container(
      color: Colors.lightBlue.shade200,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
                onPressed: ()=>Next(),
                child: const Text('ถัดไป')
            ),
          ],
        ),
      ),
    );
  }

  void Next(){
    try{
      if(currentStoreId.isEmpty){
        ServiceMsgDialogCustom.showInfoDialog(context, title_msg, 'กรุณาเลือกร้านค้า');
      }else{
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context)=>const HomePage()));
      }
    }catch(e){
      throw Exception(e);
    }
  }

  Widget PinStore(String curid)  {
    if(currentStoreId.isNotEmpty){
      if(currentStoreId.toUpperCase() == curid.toUpperCase()){
        return Image.asset('assets/images/store_pin.png',height: 25);
      }
    }

    return Image.asset('assets/images/store_spe.png',height: 25);
  }

  Widget SearchBoxBar(){
    return TextField(
      controller: _searchEditController,
      focusNode: _storeFilterFocusNode,
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
      onChanged: (text)=> DataFind(text),
    );
  }

  Widget? SearchBoxBtn(){
    if(_search_length > 0){
      return IconButton(
        onPressed: _searchEditController.clear,
        icon: const Icon(Icons.clear),
      );
    }else{
      return null;/*IconButton(
        onPressed: _searchEditController.clear,
        icon: Icon(Icons.search),
      );*/
    }
  }

  StoreListViewTap(int index) {
    SettingValues().setCurrentStoreId(store_items[index]['id']);
    SettingValues().setCurrentStoreName(store_items[index]['storeName']);

    SettingValues().getCurrentStoreId().then((value){
      debugPrint(value);
      currentStoreId = value;

      CheckRegisStoreSelected();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context)=>const HomePage()));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _storeFilterFocusNode.dispose();
    super.dispose();
  }

}