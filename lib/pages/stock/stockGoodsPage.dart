

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaruern_mini_pos/BL/blStock.dart';
import 'package:jaruern_mini_pos/Models/mdlUnit.dart';
import 'package:jaruern_mini_pos/declareTemp.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceText.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

class StockGoodsPage extends StatelessWidget{
  final String goodsId;
  final String goodsName;
  final String goodsBarcode;
  final String goodsSize;

  const StockGoodsPage({super.key,
    required this.goodsId,
    required this.goodsName,
    required this.goodsBarcode,
    required this.goodsSize});

  @override
  Widget build(BuildContext context) {
    return _StockGoodsPage(goodsId, goodsName,goodsBarcode,goodsSize);
  }

}

class _StockGoodsPage extends StatefulWidget{
  late String goodsId;
  late String goodsName;
  late String goodsBarcode;
  late String goodsSize;
  _StockGoodsPage(String goodsid,String goodsname,String barcode,String size){
    goodsId = goodsid;
    goodsName = goodsname;
    goodsBarcode = barcode;
    goodsSize = size;
  }

  @override
  State<StatefulWidget> createState() {
    return _StockGoodsPageState(goodsId, goodsName,goodsBarcode,goodsSize);
  }

}

class _StockGoodsPageState extends State<_StockGoodsPage>{
  late String goodsId;
  late String goodsName;
  late String goodsBarcode;
  late String goodsSize;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pieceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _memberpriceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  bool _storelastsale = false;
  bool _marketlastsale = false;

  bool indicator = false;
  mdlUnit? unitValue = DeclareValue.units.first;

  _StockGoodsPageState(String goodsid,String goodsname,String barcode,String size){
    goodsId = goodsid;
    goodsName = goodsname;
    goodsBarcode = barcode;
    goodsSize = size;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.lightBlue.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/1524818.png',height: 25,),
            const Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: Text('รับสินค้าเข้า'),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              GoodsCap(),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      PieceForm(),
                      PriceRef(),
                    ],
                  )
              ),
              ServiceUI.Indicater(indicator),
              Visibility(
                  visible: !indicator,
                  child: PriceForm()),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: ()=>StockInSubmit(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/true_icon.jpg',height: 45,),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                              child: Text('รับสินค้า',style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60.0),
            ],
          ),
        ),
      ),
    ));
  }

  Widget PieceForm(){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        child: Column(
          children: [
            TextFormField(
              controller: _pieceController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsFormatter(allowFraction: true)
              ],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                labelText: 'จำนวน(หน่วย)',
                suffixIcon: IconButton(
                  onPressed: _pieceController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุจำนวนสินค้า';
                }
                return null;
              },
            ),
            const SizedBox(height: 10,),
            UnitDD(),
          ],
        ),
      ),
    );
  }

  Widget UnitDD(){

    var items = DeclareValue.units.map((item) {
      return DropdownMenuItem<mdlUnit>(
        value: item,
        child: Text(item.unit),
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<mdlUnit>(
          items: items,
          value: unitValue,
          onChanged: (mdlUnit? value) {
            setState(() {
              unitValue = value;
              debugPrint(unitValue!.id.toString());
            });
          },
        ),
      ],
    );
  }

  Widget PriceForm(){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _priceController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                ThousandsFormatter(allowFraction: true)
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                labelText: 'ราคาขาย(บาท)',
                suffixIcon: IconButton(
                  onPressed: _priceController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุราคาขาย';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _discountController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                ThousandsFormatter(allowFraction: true)
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                labelText: 'ราคาส่วนลด(บาท)',
                suffixIcon: IconButton(
                  onPressed: _discountController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            TextFormField(
              controller: _memberpriceController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                ThousandsFormatter(allowFraction: true)
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                labelText: 'ราคาสมาชิก(บาท)',
                suffixIcon: IconButton(
                  onPressed: _memberpriceController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            TextFormField(
              controller: _costController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                ThousandsFormatter(allowFraction: true)
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                labelText: 'ราคาต้นทุน(บาท)',
                suffixIcon: IconButton(
                  onPressed: _costController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            TextFormField(
              controller: _remarkController,
              textAlign: TextAlign.start,
              maxLines: 3,
              decoration: InputDecoration(
                fillColor: Colors.yellow.shade200,
                filled: true,
                labelText: 'หมายเหตุ',
                suffixIcon: IconButton(
                  onPressed: _remarkController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget GoodsCap(){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goodsBarcode,style: const TextStyle(fontSize: 13,color: Colors.black87,fontWeight: FontWeight.bold),),
                Text(goodsName,style: const TextStyle(fontSize: 17,color: Colors.brown),),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget PriceRef(){
    return Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: _storelastsale,
            onChanged: (bool? value) {
              setState(() {
                _storelastsale = value!;
                if(_storelastsale){
                  _marketlastsale = false;
                  GetPrice(DeclareValue.currentStoreId);
                }
              });
            },
            title: const Text('ใช้ราคาขายล่าสุด'),
            subtitle: const Text('ราคาล่าสุดของร้านหรือที่คุณที่เคยตั้งไว้'),
          ),
          CheckboxListTile(
            value: _marketlastsale,
            onChanged: (bool? value) {
              setState(() {
                _marketlastsale = value!;
                if(_marketlastsale){
                  _storelastsale = false;
                  GetPrice(null);
                }
              });
            },
            title: const Text('ใช้ราคาตลาดล่าสุด'),
            subtitle: const Text('ราคาล่าสุดที่ขายในตลาด'),
          ),
        ],
      ),
    );
  }

  void GetPrice(String? storeId){
    try{
      setState(() {
        indicator = true;
      });

      BLStock(context).getGoodsLastPrice(goodsId, storeId).then((value) {
        try {
          if(value['id'].toString()==DeclareValue.GuidEmpty){
            _priceController.text = '';
            _discountController.text = '';
            _memberpriceController.text = '';
            _costController.text = '';

            ShowToast(context,'ไม่พบราคาล่าสุดของสินค้า').Show(MessageType.info);
          }else {
            _priceController.text = value['salePrice'].toString();
            _discountController.text =
                ServiceText().DoubleString(value['discount'].toString(), 2);
            _memberpriceController.text = ServiceText().DoubleString(
                value['memberPrice'].toString(), 2);
            _costController.text =
                ServiceText().DoubleString(value['cost'].toString(), 2);
          }
                }finally{
          setState(() {
            indicator = false;
          });
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  void StockInSubmit() async {
    if(_formKey.currentState!.validate()){
      try {
        double sale = double.parse(_priceController.text.replaceAll(',', ''));
        double? discount;
        if (_discountController.text.isNotEmpty) {
          discount = double.parse(_discountController.text.replaceAll(',', ''));
        }

        double? member;
        if (_memberpriceController.text.isNotEmpty) {
          member =
              double.parse(_memberpriceController.text.replaceAll(',', ''));
        }

        double? cost;
        if (_costController.text.isNotEmpty) {
          cost = double.parse(_costController.text.replaceAll(',', ''));
        }

        if(discount!=null) {
          if (sale < discount) {
            ShowToast(context,'ราคาหักส่วนลดต้องต่ำกว่าราคาขาย').Show(MessageType.error);
            return;
          }
        }

        String unitid = unitValue!.id.toString();
        if(!DeclareTemp.isStockDupp(goodsBarcode,unitid)) {
          DeclareTemp.stockin_card.add({
            'goodsid': goodsId,
            'goodsname': goodsName,
            'barcode': goodsBarcode,
            'saleprice': sale,
            'discount': discount,
            'member': member,
            'cost': cost,
            'remark': _remarkController.text,
            'size': goodsSize,
            'piece': _pieceController.text,
            'unitid': unitid,
            'unitname': unitValue!.unit.toString()
          });

          ShowToast(context,'เพิ่มในรายการแล้ว').Show(MessageType.info);
          debugPrint(DeclareTemp.stockin_card.length.toString());
          Navigator.pop(context);
        }else{
          ShowToast(context,'สินค้าซ้ำซ้อน').Show(MessageType.warn);
        }
      }catch(e){
        debugPrint(e.toString());
      }
    }
  }

}