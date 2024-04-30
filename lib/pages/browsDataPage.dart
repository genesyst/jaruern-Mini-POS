

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';

class BrowsDataPage extends StatelessWidget{
  final String title;
  List<Map<String, dynamic>> data;
  final String display_field;

  BrowsDataPage({super.key, required this.title,required this.data,required this.display_field});

  @override
  Widget build(BuildContext context) {
    return _BrowsDataPage(title,data,display_field);
  }

}

class _BrowsDataPage extends StatefulWidget{
  late final String title;
  late List<Map<String, dynamic>> data;
  late final String display_field;

  _BrowsDataPage(String title_value,List<Map<String, dynamic>> data_val,String display_field_val){
    title = title_value;
    data = data_val;
    display_field = display_field_val;
  }

  @override
  State<StatefulWidget> createState() {
    return _BrowsDataPageState(title,data,display_field);
  }

}

class _BrowsDataPageState extends State<_BrowsDataPage>{
  late final String title;
  late final String display_field;
  late List<Map<String, dynamic>> data;


  bool indicator_list = false;

  final ScrollController _scrollController = ScrollController();

  _BrowsDataPageState(String title_value,List<Map<String, dynamic>> data_val,String display_field_val){
    title = title_value;
    data = data_val;
    display_field = display_field_val;
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
        title: Text(title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ServiceUI.Indicater(indicator_list),
            Expanded(child: DataListView(context)),
          ],
        ),
      ),
    );
  }

  Widget DataListView(BuildContext context){
    return ListView.separated(
      controller: _scrollController,
      itemCount: data.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context,int index){
        final item = data[index];
        return GestureDetector(
          onTap: ()=>DataTap(index),
          child: SizedBox(
            height: 50,
            child: ListTile(
              title: Row(
                children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                    child: Text(item[display_field]),
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

  void DataTap(int index) {
    try{
      Navigator.pop(context,data[index]);
    }catch(e){
      throw Exception(e);
    }
  }

}