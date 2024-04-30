


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blRegister.dart';
import 'package:jaruern_mini_pos/pages/storeAddedPage.dart';
import 'package:jaruern_mini_pos/pages/storeSelectPage.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceNet.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignUpForm();
  }

}

class SignUpForm extends StatefulWidget{
  const SignUpForm({super.key});

  @override
  _SignUpFormState  createState() => _SignUpFormState ();
}

class _SignUpFormState extends State<SignUpForm>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _empcodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _storenameController = TextEditingController();

  String selectStoreId = '';

  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  String title_msg = 'ลงทะเบียน';

  @override
  void initState(){
    super.initState();

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
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/regis.png',height: 25,),
            const Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: Text('ลงทะเบียน'),
            ),
            GestureDetector(
                onTap: ()=>{Navigator.pop(context)},
                child: Image.asset('assets/images/close_cross.png',height: 20,)
            ),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0),
                child: Regisform(),
              ),
            ],
          ),
      ),
    );
  }

  Widget Regisform(){
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CreateUser(),
          const SizedBox(height: 10.0),
          CreateStore(),
          const SizedBox(height: 20.0),
          GestureDetector(
              onTap: ()=>Register(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/true_icon.jpg',height: 45,),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                    child: Text('ลงทะเบียนผู้ใช้ใหม่',style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
          ),
          const SizedBox(height: 60.0),
        ],
      ),
    );
  }

  Widget CreateUser(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.email), // Icon at the left of the card
            title: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email ที่สามารถติดต่อได้',
                suffixIcon: IconButton(
                  onPressed: _emailController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุ email ';
                }

                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return "รูปแบบ e-mail ไม่ถูกต้อง";
                }
                return null;
              },
            ),
            subtitle: const Text('ตัวอย่าง johndoe@example.com',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: const Icon(Icons.person), // Icon at the left of the card
            title: TextFormField(
              controller: _empcodeController,
              decoration: InputDecoration(
                labelText: 'รหัสพนักงาน(ถ้ามี)',
                suffixIcon: IconButton(
                  onPressed: _empcodeController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                return null;
              
                /*if (value == null || value.isEmpty) {
                  return 'กรุณาระบุรหัสพนักงานที่ใช้ในระบบอื่นๆอยู่แล้ว ';
                }
                return null;*/
              },
            ),
            subtitle: const Text('สำหรับลูกค้าบริษัท',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: const Icon(Icons.password), // Icon at the left of the card
            title: TextFormField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                suffixIcon: IconButton(
                  onPressed: _passwordController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุสร้างรหัสผ่าน ';
                }

                if (value.length < 6) {
                  return 'รหัสผ่านมีจำนวนหลักน้อยเกินไป';
                }
                return null;
              },
            ),
            subtitle: Text('สร้างรหัสผ่านเป็นตัวเลขอย่างน้อย 6 หลัก',style: TextStyle(color: Colors.red.shade400),),
          ),
        ],
      ),
    );
  }

  Widget CreateStore(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.store), // Icon at the left of the card
            title: TextFormField(
              controller: _storenameController,
              readOnly: true,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'ชื่อร้าน',
                suffixIcon: IconButton(
                  onPressed: ()=>StoreMore(),
                  icon: const Icon(Icons.more),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุร้านค้า ';
                }
                return null;
              },
            ),
            subtitle: const Text('เพิ่มร้านค้าหรือเลือกร้านที่มีอยู่แล้ว',style: TextStyle(color: Colors.black26),),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20.0, 0),
                child: TextButton(
                    onPressed: ()=>AddStore(),
                    child: const Text('เพิ่มร้านของฉัน',
                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void StoreMore(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return const StoreSelectPage();
        }).then((value) {
          if(value!=null) {
            if (value.toString().toLowerCase() == 'closed') {
              _storenameController.text = '';
              selectStoreId = '';
            } else {
              _storenameController.text = value['storeDisplayName'];
              selectStoreId = value['id'];
            }
          }
        }
    );
  }

  void AddStore(){
    try{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return const StoreAddedPage();
          }).then((value) {
        if(value!=null) {
          if (value.toString().toLowerCase() == 'closed') {
            _storenameController.text = '';
            selectStoreId = '';
          } else {
            _storenameController.text = value['storeDisplayName'];
            selectStoreId = value['id'];
          }
        }
      }
      );

    }catch(e){
      throw Exception(e);
    }
  }

  void Register(){
    try{
      if(_formKey.currentState!.validate()){
        ServiceNet().isInternetConnected().then((value) {
          if(value){
            ServiceMsgDialogCustom.showLoadingDialog(context,_keyLoader,IndicatType.itLoading);
            BLRegister(context).NewRegister(
                _emailController.text.trim(),
                _empcodeController.text.trim(),
                _passwordController.text.trim(),
                selectStoreId,
                _storenameController.text.trim()
            ).then((value){
              Navigator.pop(context);

              int msgIndex = int.parse(value['key'].toString());
              String msg = value['value'].toString();

              switch (msgIndex) {
                case -1:
                  ServiceMsgDialogCustom.showErrorDialog(context,
                              title_msg, 'email หรือ รหัสพนักงานได้มีการลงทะเบียนแล้ว');
                  break;
                case 0:
                  ServiceMsgDialogCustom.showComplateAndCloseDialog(context,
                      title_msg, 'ลงทะเบียนสำเร็จ กรุณายืนยันตัวตนที่ email ของท่าน');
                  break;
                case 1:
                  ServiceMsgDialogCustom.showErrorDialog(context,
                      title_msg, 'เกิดข้อผิดพลาด ไม่สามารถลงทะเบียนได้');
                  break;
                case 3:
                  ServiceMsgDialogCustom.showErrorDialog(context,
                      title_msg, 'ไม่มีร้านค้าในระบบ');
                  break;
              }
            });
          }else{
            ServiceMsgDialogCustom.showInternetErrorDialog(context,false);
          }
        });
      }
    }catch(e){
      throw Exception(e);
    }
  }

  @override
  void dispose() {
    _storenameController.dispose();
    _empcodeController.dispose();
    _passwordController.dispose();
    _emailController.dispose();

    super.dispose();
  }

}