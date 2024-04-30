

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';


class ShowToast{
  late FToast fToast;
  late String msg;
  int show_sec = 3;

  Color info_bg = Colors.black87;
  Color warn_bg = Colors.orange.shade400;
  Color error_bg = Colors.red.shade300;
  Color complete_bg = Colors.green.shade300;

  Color info_text = Colors.white;
  Color warn_text = Colors.black;
  Color error_text = Colors.black;
  Color complete_text = Colors.green.shade900;

  ToastGravity grvity = ToastGravity.BOTTOM;

  ShowToast(BuildContext context,String message){
    fToast = FToast();
    fToast.init(context);

    msg = message;
  }

  ShowToast.Gravity(BuildContext context,String message,ToastGravity grvity){
    fToast = FToast();
    fToast.init(context);

    msg = message;
    grvity = grvity;
  }

  Widget infoToast(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: info_bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DeclareValue.message_info_icon,
          const SizedBox(
            width: 12.0,
          ),
          Flexible(child: Text(msg,style: TextStyle(color: info_text),)),
        ],
      ),
    );
  }

  Widget warnToast(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: warn_bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DeclareValue.message_warn_icon,
          const SizedBox(
            width: 12.0,
          ),
          Flexible(child: Text(msg,style: TextStyle(color: warn_text),)),
        ],
      ),
    );
  }

  Widget errorToast(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: error_bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DeclareValue.message_error_icon,
          const SizedBox(
            width: 12.0,
          ),
          Flexible(child: Text(msg,style: TextStyle(color: error_text),)),
        ],
      ),
    );
  }

  Widget completeToast(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: complete_bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DeclareValue.message_complete_icon,
          const SizedBox(
            width: 12.0,
          ),
          Flexible(child: Text(msg,style: TextStyle(color: complete_text),)),
        ],
      ),
    );
  }

  void Show(MessageType ttype){
    Widget toastLayout;
    switch(ttype){
      case MessageType.warn:
        toastLayout = warnToast();
        break;
      case MessageType.error:
        toastLayout = errorToast();
        break;
      case MessageType.complete:
        toastLayout = completeToast();
        break;
      default:
        toastLayout = infoToast();
        break;
    }

    fToast.showToast(
      child: toastLayout,
      gravity: grvity,
      toastDuration: Duration(seconds: show_sec),
    );
  }

}