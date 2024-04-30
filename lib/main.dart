
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blGoods.dart';
import 'package:jaruern_mini_pos/BL/blRepository.dart';
import 'package:jaruern_mini_pos/Models/mdlUnit.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/pages/welcomePage.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceLocation.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceNet.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini P.O.S.',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('th', 'TH'), // Thai
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue.shade300),
        primaryColor: Colors.lightBlue.shade200,
        primaryColorDark: Colors.lightBlue,
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState(){
    super.initState();

    SystemVerify();
  }

  void loadMasterData(){
    try {
      DeclareValue.UnitPrepareData(context);
      DeclareValue.ReasonXPrepareData(context,1);
      DeclareValue.ReasonXPrepareData(context,2);
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void SystemVerify(){
    try{
      BLRepository().RequestLocationPermission().then((value) {
        if(value){
          ServiceLocation().AccuracySetting(50);

          ServiceNet().isInternetConnected().then((isConnect){
            if(isConnect){
              loadMasterData();

              Future.delayed(const Duration(seconds: 3),
                      ()=>Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context)=>const WelcomePage()))
              );
            }else{
              ServiceMsgDialogCustom.showInternetErrorDialog(context,true);
            }
          });
        }else{
          CloseApp();
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void CloseApp(){
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade200,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/mini_pos_title.png',width: screenWidth * 0.65,),
            const CircularProgressIndicator(
              color: Colors.redAccent,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
