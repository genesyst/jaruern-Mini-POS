

import 'package:flutter/material.dart';
import 'package:jaruern_mini_pos/declareValue.dart';

class PosWidget{
  static Widget SymbolRate(String cashStatus){
    switch(cashStatus.toUpperCase()){
      case 'M':
        return DeclareValue.m_custype_img;
      case 'D':
        return DeclareValue.d_custype_img;
      default :
        return DeclareValue.c_custype_img;
    }
  }

}