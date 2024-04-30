

import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';



class ShowSnack{
  late BuildContext context;
  Duration duration = const Duration(seconds: 3);
  late String msg;


  ShowSnack(BuildContext cont,String message){
    context = cont;
    msg = message;
  }

  void Show(MessageType stype){
    Image snackImage;
    switch(stype){
      case MessageType.warn:
        snackImage = DeclareValue.message_warn_icon;
        break;
      case MessageType.error:
        snackImage = DeclareValue.message_error_icon;
        break;
      default:
        snackImage = DeclareValue.message_info_icon;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            snackImage,
            const SizedBox(width: 8.0,),
            Flexible(child: Text(msg)),
          ],
        ),
          duration: duration,));
  }

}