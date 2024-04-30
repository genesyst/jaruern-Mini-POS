

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberPad{
  late BuildContext context;
  late TextEditingController cashController;
  late TextEditingController changeController;
  late Color buttonColor;
  late Color textColor;

  Image resetImg = Image.asset('assets/images/reset.png',width: 20,);

  double allpay = 0.00;
  double cash = 0.00;
  double change = 0.00;
  String cash_value = '';

  NumberPad(
      BuildContext _context,
      TextEditingController controller1,
      TextEditingController controller2,
      double payVal,
      Color btnColor,Color tColor){
    context = _context;
    cashController = controller1;
    changeController = controller2;
    allpay = payVal;
    buttonColor = btnColor;
    textColor = tColor;
  }

  Widget CashPad(){
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton('1'),
              NumberButton('2'),
              NumberButton('3'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton('4'),
              NumberButton('5'),
              NumberButton('6'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton('7'),
              NumberButton('8'),
              NumberButton('9'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ResetButton(),
              NumberButton('0'),
              NumberButton('.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget NumberButton(String text){
    return ElevatedButton(
      onPressed: () {
        if(text == '.'){
          if(!cash_value.contains(text)){
            cash_value += text;
          }
        }else {
          if(cash_value.contains('.')){
            String deci = cash_value.split('.')[1];
            if(deci.length < 2){
              cash_value += text;
            }
          }else{
            cash_value += text;
          }
        }

        cash = double.tryParse(cash_value) ?? 0.00;
        change = cash - allpay;
        cashController.text = NumberFormat("#,##0.00", "en_US").format(cash);
        changeController.text = NumberFormat("#,##0.00", "en_US").format(change);
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(buttonColor)),
      child: Text(
        text,
        style: TextStyle(fontSize: 24.0,color: textColor),
      ),
    );
  }

  Widget ResetButton(){
    return ElevatedButton(
      onPressed: () {
        if(cashController.text.isEmpty && changeController.text.isEmpty){
          Navigator.pop(context);
        }else{
          cashController.text = '';
          changeController.text = '';
          cash_value = '';
        }
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(buttonColor)),
      child: resetImg,
    );
  }
}