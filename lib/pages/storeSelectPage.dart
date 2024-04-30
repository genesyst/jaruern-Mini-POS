

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blStore.dart';
import 'package:jaruern_mini_pos/Models/mdlParamGetStore.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceNet.dart';

class StoreSelectPage extends StatelessWidget{
  const StoreSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StoreSelectPage();
  }

}

class _StoreSelectPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _StoreSelectPageState();
  }
}

class _StoreSelectPageState extends State<_StoreSelectPage>{
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final _storeFilterEditController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _storeFilterFocusNode = FocusNode();

  int loadIndex = 0;
  List<Map<String, dynamic>> store_items = [];
  String title_msg = 'ร้านค้าของฉัน';

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // We've reached the end of the ListView
        loadIndex++;
        SearchStores(false);
        print("load more...");
      }
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    _storeFilterFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //config Orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade200,
        title: Column(
          children: [
            TextField(
              controller: _storeFilterEditController,
              focusNode: _storeFilterFocusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (value)=>SearchStores(true),
              decoration: InputDecoration(
                hintText: 'ค้นหา',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: ()=>SearchStores(true),
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: StoreListView(context)),
    );
  }

  Widget StoreListView(BuildContext context){
    return ListView.separated(
      controller: _scrollController,
      itemCount: store_items.length,
        itemBuilder: (BuildContext context,int index){
          final item = store_items[index];
          return GestureDetector(
            onTap: ()=>StoreListViewTap(index),
            child: SizedBox(
              height: 50,
              child: ListTile(
                title: Row(
                  children: [
                    Image.asset('assets/images/store_spe.png',height: 25),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                      child: Flexible(child: Text(item['storeDisplayName'])),
                    )),
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

  void StoreListViewTap(int index){
    debugPrint(store_items[index]['id']);
    debugPrint(store_items[index]['storeDisplayName']);

    Navigator.of(context).pop(store_items[index]);
  }

  void SearchStores(bool newdata){
    try{
      ServiceNet().isInternetConnected().then((value){
        if(value){
          if(newdata) {
            loadIndex = 0;
            store_items.clear();
          }

          FocusScope.of(context).unfocus();
          PrepareData();
        }else{
          ServiceMsgDialogCustom.showInternetErrorDialog(context,false);
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void PrepareData(){
    try{
      ServiceMsgDialogCustom.showLoadingDialog(context,_keyLoader,IndicatType.itLoading);

      mdlParamGetStore params = mdlParamGetStore();
      params.load_index = loadIndex;
      params.storetype = '';
      params.storegroup = '';
      params.filter = _storeFilterEditController.text.trim();
      params.location = '';
      BLStore(context).getStoreList(params).then((value) {
        List<Map<String,dynamic>> resultApi = json.decode(value).cast<Map<String,dynamic>>();
        setState(() {
          store_items.addAll(resultApi);
        });

        Navigator.pop(context);

      });
    }catch(e){
      throw Exception(e);
    }
  }
}