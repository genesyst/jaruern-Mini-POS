


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/pages/myStorePage.dart';
import 'package:jaruern_mini_pos/pages/signupPage.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceNet.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:jaruern_mini_pos/settingValues.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Wrap your SignInPage with MaterialApp
      home: Scaffold(
        backgroundColor: Colors.lightBlue.shade200,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/images/mini_pos_title.png',height: 170,),
                const Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 0),
                  child: SignInForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  _SignInFormState  createState() => _SignInFormState ();
}

class _SignInFormState extends State<SignInForm>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool input_enable = true;

  @override
  void initState(){
    super.initState();

    SettingValues().resetAuthen();

    //_emailController.text='arrays2003@hotmail.com';
    _emailController.text='arrays1981@gmail.com';
    _passwordController.text='123456';
  }

  @override
  Widget build(BuildContext context) {
    //config Orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return _parentView();
  }

  Widget _parentView(){
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              enabled: input_enable,
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุ email ที่ลงทะเบียนไว้';
                }
                return null;
              },
            ),
            TextFormField(
              enabled: input_enable,
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุรหัสผ่านที่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            ServiceUI.Indicater(!input_enable),
            Visibility(
              visible: input_enable,
              child: GestureDetector(
                  onTap: ()=>SignIn(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset('assets/images/unlock.png',height: 45,),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                        child: Text('ตรวจสอบ',style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ],
                  )
              ),
            ),
            const SizedBox(height: 30.0),
            TextButton(
              onPressed: () {
                _signUp();
              },
              child: const Text('ลงทะเบียนฟรี ได้ที่นี่',style: TextStyle(decoration: TextDecoration.underline,),),
            ),
          ],
        ),
      ),
    );
  }

  void SignIn() {
    String titleMsg = 'ตรวจสอบผู้ใช้';
    try {
      ServiceNet().isInternetConnected().then((isConnect){
        if(isConnect){
          setState(() {
            input_enable = false;
          });

          String email = _emailController.text.trim();
          String pass = _passwordController.text.trim();
          try {
            BLAuthen().GetTokenTicket(context,email,pass).then((value) {
              try {
                switch (value.id) {
                  case 0:
                    SettingValues().setEmail(email);
                    BLAuthen().TicketRegister(value.msg).then((val){
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context)=>const MyStorePage()));
                    });
                    break;
                  case 1:
                    ServiceMsgDialogCustom.showErrorDialog(
                        context, titleMsg,
                        'ไม่สามารถขอรหัสยืนยันตัวตนจากระบบได้');
                    setState(() {
                      input_enable = true;
                    });
                    break;
                  case 2:
                    ServiceMsgDialogCustom.showErrorDialog(
                        context, titleMsg, 'พบปัญหาการขอรหัสยืนยันตัวตน');
                    setState(() {
                      input_enable = true;
                    });
                    break;
                  case -1:
                    if(value.msg.toLowerCase() == 'user not activate'){
                      ServiceMsgDialogCustom.showErrorDialog(
                          context, titleMsg, 'ไม่พบผู้ใช้งาน\nหรือกรุณาตรวจสอบการยืนยันตัวตน');
                    }
                    setState(() {
                      input_enable = true;
                    });
                    break;
                }
              }catch(e){
                setState(() {
                  input_enable = true;
                });
                throw Exception(e);
              }
            });
          }catch(e){
            setState(() {
              input_enable = true;
            });
            throw Exception(e);
          }
        }else{
          ServiceMsgDialogCustom.showInternetErrorDialog(context,false);
        }
      });
    } catch (e) {
      ServiceMsgDialogCustom.showErrorDialog(context, titleMsg, 'ผิดพลาด $e');
    }
  }

  void _signUp(){
    try{
      showDialog(
          context: context,
          builder: (BuildContext context){
            return const SignUpPage();
          });
      //Navigator.push(context,
      //    MaterialPageRoute(builder: (context)=>SignUpPage()));
    }catch(e){
      throw Exception(e);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}