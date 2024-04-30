

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blGoods.dart';
import 'package:jaruern_mini_pos/Models/mdlItem.dart';
import 'package:jaruern_mini_pos/Models/mdlParamGetGoods.dart';
import 'package:jaruern_mini_pos/declareTemp.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/goodsDetailPage.dart';
import 'package:jaruern_mini_pos/pages/goodsNewPage.dart';
import 'package:jaruern_mini_pos/pages/stock/stockCardPage.dart';
import 'package:jaruern_mini_pos/pages/stock/stockGoodsPage.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceNet.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceScan.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

enum GoodsMode{
  AddGoods,
  AddStock
}

class GoodsPage extends StatelessWidget{
  final GoodsMode mode;
  const GoodsPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return _GoodsPage(mode);
  }

}

class _GoodsPage extends StatefulWidget{
  late GoodsMode mode;

  _GoodsPage(GoodsMode _mode){
    mode = _mode;
  }

  @override
  State<StatefulWidget> createState() {
    return _GoodsPageState(mode);
  }
}

class _GoodsPageState extends State<_GoodsPage>{
  late GoodsMode mode;

  final _searchEditController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _goodsFilterFocusNode = FocusNode();

  int _search_length = 0;
  String barcode_find = '';
  String producttype_id = '';
  String productgroup_id = '';

  int loadIndex = 0;
  List<Map<String, dynamic>> goods_data = [];
  List<Map<String, dynamic>> goods_item = [];

  bool indicator_list = false;
  int selection_goods_index = -1;

  bool stock_added = false;

  bool fav_filter = false;

  List<mdlItem> productTypes = [];
  List<mdlItem> productGroups = [];

  _GoodsPageState(GoodsMode _mode){
    mode = _mode;
  }

  @override
  void initState(){
    _searchEditController.addListener(() {
      setState(() => _search_length = _searchEditController.text.length);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // We've reached the end of the ListView
        loadIndex++;
        SearchGoods(false,false);
        print("load more...");
      }
    });

    if(mode == GoodsMode.AddStock) {
      SearchGoods(true, false);
    }

    PrepareDataFilter();

  }

  Future<void> PrepareDataFilter() async {
    try{
      setState(() {
        indicator_list = true;
      });

      var pts = await BLGoods(context).getProductType();
      var pgs = await BLGoods(context).getProductGroup();

      for(var pt in pts){
        mdlItem item = mdlItem();
        item.Key = pt['producttypecode'];
        item.Text = pt['producttypename'];
        item.Value = pt['id'];

        setState(() {
          productTypes.add(item);
        });
      }

      for(var pg in pgs){
        mdlItem item = mdlItem();
        item.Key = pg['id'];
        item.Text = pg['productgroupname'];
        item.Value = pg['producttypeid'];

        setState(() {
          productGroups.add(item);
        });
      }

    }catch(e){
      debugPrint(e.toString());
    }finally{
      setState(() {
        indicator_list = false;
      });
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    try {
      if(mode == GoodsMode.AddStock) {
        if (DeclareTemp.stockin_card.isNotEmpty) {
          if (await confirm(context,
            title: const Text('รับสินค้า'),
            content: Text('คุณกำลังทำรายการรับเข้า ${DeclareTemp.stockin_card.length} รายการ ต้องการยกเลิกหรือไม่?'),
            textOK: const Text('ใช่'),
            textCancel: const Text('ยังก่อน'),
          )) {
            DeclareTemp.stockin_card = [];
            return Future.value(true);
          }else{
            return Future.value(false);
          }
        }else{
          return Future.value(true);
        }
      }else{
        return Future.value(true);
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

    return WillPopScope(
      onWillPop: ()=>_onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue.shade200,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _onWillPop(context).then((value){
                if(value){
                  if(mode==GoodsMode.AddStock){
                    Navigator.of(context).pop({'stkadded':stock_added});
                  }else {
                    Navigator.of(context).pop();
                  }
                }
              });
            },
          ),
          title: SearchBox(),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: (){
                setState(() {
                  fav_filter = false;
                  productgroup_id = '';
                  producttype_id = '';
                });

                SearchGoods(true,false);
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list_alt),
              onPressed: () => FilterGoodsDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.barcode_reader),
              onPressed: () => ScanBarcode(),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: true,
          child: floatButton(),
        ),
        body: SafeArea(child: Column(
          children: [
            ServiceUI.Indicater(indicator_list),
            Expanded(child: GoodsListView(context)),
          ],
        )
        ),
      ),
    );
  }

  void FilterGoodsDialog(){
    showDialog(
      context: context,
        builder: (context){
        //Declare
          var PTitems = productTypes.map((item) {
            return DropdownMenuItem<mdlItem>(
              key:  UniqueKey(),
              value: item,
              child: Text(item.Text),
            );
          }).toList();

          List<DropdownMenuItem<mdlItem>> PGitems = [];

          mdlItem? PTValue ;
          mdlItem? PGValue ;

          bool XValueProcess = false;

          void FilterGroup(){
            var isGroup = productGroups.where(
                    (e) => e.Value.toString().contains(producttype_id)).toList();
            if(isGroup.length == 0){
              setState(() {
                productgroup_id = '';
              });
            }else{
              PGValue = isGroup.first;
              setState(() {
                PGitems = isGroup.map((item) {
                  return DropdownMenuItem<mdlItem>(
                    key:  UniqueKey(),
                    value: item,
                    child: Text(item.Text),
                  );
                }).toList();
              });
            }
          }

      return AlertDialog(
        title: const Text('กรองสินค้า',style: TextStyle(fontSize: 15)),
          content: StatefulBuilder(
            builder: (context,setState){
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ประเภท',style: TextStyle(fontWeight: FontWeight.bold),),
                        DropdownButton<mdlItem>(
                          items: PTitems,
                          value: PTValue,
                          onChanged: (mdlItem? value) {
                            setState(() {
                              PTValue = value;
                              debugPrint(PTValue!.Value.toString());

                              producttype_id = PTValue!.Value.toString();
                            });

                            FilterGroup();
                          },
                        ),
                      ],
                    ),
                    Visibility(
                      visible: PGitems.isNotEmpty,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('กลุ่ม',style: TextStyle(fontWeight: FontWeight.bold),),
                          DropdownButton<mdlItem>(
                            items: PGitems ,
                            value: PGValue,
                            onChanged: (value) {
                              setState(() {
                                PGValue = value;
                                debugPrint(PGValue!.Value.toString());

                                productgroup_id = PGValue!.Value.toString();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: (){
                              setState(() {
                                if(fav_filter) {
                                  fav_filter = false;
                                } else {
                                  fav_filter = true;
                                }
                              });
                            },
                            child: (fav_filter==true)?
                                      Image.asset('assets/images/star_icon.png',height: 30,)
                                : Image.asset('assets/images/star_icon2.png',height: 30,)
                        ),
                        const SizedBox(width: 7,),
                        const Text('เฉพาะทำการบุ๊คไว้'),
                      ],
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                    onTap: (){
                      SearchGoods(true,false);
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/images/true_icon.jpg',height: 27,)
                ),
              ],
            ),
          ),
        ],
      );
    },
    );
  }

  Widget floatButton(){
    if(mode == GoodsMode.AddGoods) {
      return FloatingActionButton(
        onPressed: () => AddGoodsDialog(),
        child: Image.asset('assets/images/plus_icon.png', height: 35),
      );
    }else {
      return FloatingActionButton(
        onPressed: () => StockCardDialog(),
        child: Image.asset('assets/images/5164023.png', height: 35),
      );
    }
  }

  Widget GoodsListView(BuildContext context){
    return ListView.separated(
      controller: _scrollController,
      itemCount: goods_item.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context,int index){
        final item = goods_item[index];
        return GestureDetector(
          onTap: ()=>GoodsListViewTap(index),
          child: ListTile(
            title: Row(
              children: [
                Image.asset('assets/images/label_icon3.png',height: 25),
                const SizedBox(width: 8,),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['skuname'],),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 32,),
                Expanded(child: Text(item['skudisplayname'],style: const TextStyle(fontSize: 15,color: Colors.blueAccent),)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset('assets/images/size_icon.png',height: 20),
                      Text(item['skusize'],style: const TextStyle(fontSize: 15,color: Colors.black45),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }, separatorBuilder: (BuildContext context, int index) {
      return const Divider();
    },
    );
  }

  void ScanBarcode(){
    try{
      ServiceScan().scanBarcodeNormal().then((value) {
        if(value!='-1') {
          ServiceSound().ScanSound();

          setState(() {
            barcode_find = value;
          });

          ShowToast(context,barcode_find).Show(MessageType.info);

          DataFind(barcode_find, true);
        }else{
          barcode_find = '';
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void StockCardDialog(){
    try{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return const StockCardPage();
          }).then((result) {
        if (result != null && result is Map) {
          stock_added = result['added'];
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void AddGoodsDialog(){
    try{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return const GoodsNewPage();
          });
    }catch(e){
      throw Exception(e);
    }
  }

  Widget SearchBox(){
    return TextField(
      controller: _searchEditController,
      focusNode: _goodsFilterFocusNode,
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
      onChanged: (text)=> DataFind(text,false)
    );
  }

  void DataFind(String value,bool bybarcode){
    try{
      if(value.isEmpty){
        setState(() {
          goods_item.clear();
          goods_item.addAll(goods_data);
        });
      }else{
        setState(() {
          goods_item.clear();
        });

        String findValue = value.trim().toUpperCase();
        for(int i=0;i < goods_data.length;i++){
          if(bybarcode){
            String barcode = goods_data[i]['skubarcode'].toString();
            String qrcode = goods_data[i]['skuqrcode'].toString();
            if (barcode.toUpperCase().contains(findValue)
                || qrcode.toUpperCase().contains(findValue)) {
              setState(() {
                goods_item.add(goods_data[i]);
              });
            }
          }else {
            String code = goods_data[i]['skucode'].toString();
            String name = goods_data[i]['skuname'].toString();
            String display = goods_data[i]['skudisplayname'].toString();
            if (code.toUpperCase().contains(findValue)
                || name.toUpperCase().contains(findValue)
                || display.toUpperCase().contains(findValue)) {
              setState(() {
                goods_item.add(goods_data[i]);
              });
            }
          }
        }

        if(bybarcode){
          if(goods_item.isEmpty){
            SearchGoods(false, true);
          }else{
            GoodsListViewTap(0);
            //DataFind('', false);
          }
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
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

  Widget FilterButton(){
    return GestureDetector(
        onTap: (){},
        child: Image.asset('assets/images/barcode_scanner.png')
    );
  }

  void SearchGoods(bool newdata,bool bybarcode){
    ServiceNet().isInternetConnected().then((value){
      if(!value){
        ServiceMsgDialogCustom.showInternetErrorDialog(context,false);
        return;
      }
    });

    setState(() {
      indicator_list = true;
    });

    if(newdata){
      loadIndex = 0;
      goods_data.clear();
      goods_item.clear();
    }

    try {
      mdlParamGetGoods params = mdlParamGetGoods();
      if(bybarcode){
        params.load_index = 0;
        params.findvalue = '';
        params.ptype = '';
        params.pgroup = '';
        params.barcode = barcode_find;
        params.favorite = fav_filter;
      }else {
        params.load_index = loadIndex;
        params.findvalue = _searchEditController.text.trim();
        params.ptype = producttype_id;
        params.pgroup = productgroup_id;
        params.barcode = barcode_find;
        params.favorite = fav_filter;
      }

      BLGoods(context).getGoodsList(params).then((value) {
        debugPrint(value.toString());
        try {
          setState(() {
            goods_data.addAll(value);
          });

          DataFind('', false);

          if (bybarcode) {
            if(goods_item.isEmpty) {
              ShowToast(context, 'ไม่พบสินค้าที่ตรงกับ $barcode_find').Show(
                  MessageType.warn);
            }
          }
        }finally{
          setState(() {
            indicator_list = false;
          });
        }
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        setState(() {
          indicator_list = false;
        });
      });
    }catch(e){
      debugPrint(e.toString());
      setState(() {
        indicator_list = false;
      });
    }
  }

  GoodsListViewTap(int index) {
      setState(() {
        selection_goods_index = index;
      });

      if(mode == GoodsMode.AddGoods) {
        try {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return GoodsDetailPage(
                    goodsid: goods_item[selection_goods_index]['id'],
                    goodsname: goods_item[selection_goods_index]['skuname']);
              });
          //Navigator.push(context,
          //    MaterialPageRoute(builder: (context)=>SignUpPage()));
        } catch (e) {
          throw Exception(e);
        }
      }else if(mode == GoodsMode.AddStock) {
        AddStock();
      }
  }

  Future AddStock() async {
    try{
      return showDialog(
        context: context,
          builder: (context){
            return StockGoodsPage(
                goodsId: goods_item[selection_goods_index]['id'],
                goodsName: goods_item[selection_goods_index]['skuname'],
                goodsBarcode: goods_item[selection_goods_index]['skubarcode'],
                goodsSize: goods_item[selection_goods_index]['skusize'],);
          }
      ).then((value){
        DataFind('', false);
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _goodsFilterFocusNode.dispose();
    _searchEditController.dispose();
    super.dispose();
  }
}