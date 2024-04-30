

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blStore.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceNet.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceText.dart';

class StoreAddedPage extends StatelessWidget{
  const StoreAddedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StoreAddedPage();
  }

}

class _StoreAddedPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _StoreAddedPageState();
  }
}

class _StoreAddedPageState extends State<_StoreAddedPage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _storecodeController = TextEditingController();
  final TextEditingController _storenameController = TextEditingController();

  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  String title_msg = 'ร้านค้าของฉัน';

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _storecodeController.dispose();
    _storenameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //config Orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade200,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ร้านค้าของฉัน'),
            GestureDetector(
                onTap: ()=>{Navigator.pop(context,'Closed')},
                child: Image.asset('assets/images/close_cross.png',height: 20,)
            ),
          ],
        ),
      ),
      body: AddMain(),
    );
  }

  Widget AddMain(){
    return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AddForm(),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                        onTap: ()=>Adding(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/true_icon.jpg',height: 45,),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                              child: Text('เพิ่มร้านของฉัน',style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget AddForm(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: TextFormField(
              controller: _storecodeController,
              readOnly: false,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'รหัสร้านค้า',
                suffixIcon: IconButton(
                  onPressed: ()=>_storecodeController.clear(),
                  icon: const Icon(Icons.close),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาตั้งรหัสร้านค้า';
                }
                return null;
              },
            ),
            subtitle: const Text('สร้างรหัสร้านค้า โดยใช้ภาษาอังกฤษและตัวเลข',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: TextFormField(
              controller: _storenameController,
              readOnly: false,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'ชื่อร้านค้า',
                suffixIcon: IconButton(
                  onPressed: ()=>_storenameController.clear(),
                  icon: const Icon(Icons.close),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุชื่อร้านค้าของคุณ';
                }
                return null;
              },
            ),
            subtitle: const Text('ระบุชื่อร้านค้าของคุณ เป็นภาษาไทยหรืออังกฤษก็ได้',style: TextStyle(color: Colors.black26),),
          ),

        ],
      ),
    );
  }

  void Adding(){
    try{
      if(_formKey.currentState!.validate()){
        String storeCode = _storecodeController.text.trim();
        String storeName = _storenameController.text.trim();

        if(!ServiceText().TextIsEnglish(storeCode)){
          ServiceMsgDialogCustom.showErrorDialog(
                        context, title_msg, 'รหัสร้านค้าต้องเป็นภาษาอังกฤษและตัวเลขเท่านั้น');
          return;
        }

        ServiceNet().isInternetConnected().then((value) {
          if(value){
            ServiceMsgDialogCustom.showLoadingDialog(context,_keyLoader,IndicatType.itLoading);
            try {
              BLStore(context).AddStore(storeCode, storeName).then((value) {
                Navigator.pop(context);

                int msgIndex = int.parse(value['key'].toString());
                String msg = value['value'].toString();

                switch (msgIndex) {
                  case 0:
                    Map<String, dynamic> myStore = {
                      'id': msg,
                      'storeDisplayName': storeName
                    };

                    Navigator.pop(context, myStore);
                    break;
                  case 1:
                    ServiceMsgDialogCustom.showErrorDialog(
                        context, title_msg, 'ไม่สามารถเพิ่มร้านได้');
                    break;
                  case 2:
                    ServiceMsgDialogCustom.showWarnDialog(
                        context, title_msg, 'ร้านค้ามีอยู่แล้ว');
                    break;
                }
              });
            }catch(e){
              Navigator.pop(context);
            }
          }else{
            ServiceMsgDialogCustom.showInternetErrorDialog(context,false);
          }
        });
      }
    }catch(e){
      throw Exception(e);
    }
  }

}