


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blAuthen.dart';
import 'package:jaruern_mini_pos/pages/myStorePage.dart';
import 'package:jaruern_mini_pos/pages/signinPage.dart';
import 'package:jaruern_mini_pos/settingValues.dart';

class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _WelcomePage();
  }

}

class _WelcomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _WelcomePageState();
  }

}

class _WelcomePageState extends State<_WelcomePage>{

  @override
  void initState(){
    super.initState();

    VerifyUserAuthen();
  }

  void VerifyUserAuthen(){
    try{
      SettingValues().doesKeyExist('token').then((isExist){
        if(isExist){
          SettingValues().getAuthenToken().then((token) {
            if(token.isNotEmpty) {
              BLAuthen().VerifyAccessToken(context, token).then((value) {
                debugPrint('verify token => $value');
                if (value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const MyStorePage()));
                }else{
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const SignInPage()));
                }
              });
            }
          });
        }else{
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SignInPage()));
        }
      } );

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

    return const Scaffold(
      body: Column(),
    );
  }

}