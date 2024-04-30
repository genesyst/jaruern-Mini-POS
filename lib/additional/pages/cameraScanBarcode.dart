

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jaruern_mini_pos/BL/blSale.dart';
import 'package:jaruern_mini_pos/declareTemp.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/pages/pos/scanProdSummPage.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceScan.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

class add_CameraScanBarcodePage extends StatelessWidget{
  final DateTime currentDate;
  const add_CameraScanBarcodePage({super.key,required this.currentDate});

  @override
  Widget build(BuildContext context) {
    return _add_CameraScanBarcodePage(currentDate);
  }
}

class _add_CameraScanBarcodePage extends StatefulWidget{
  late DateTime _currentDate;

  _add_CameraScanBarcodePage(DateTime currentDate){
    _currentDate = currentDate;
  }

  @override
  State<StatefulWidget> createState() {
    return _add_CameraScanBarcodePageState(_currentDate);
  }
}

class _add_CameraScanBarcodePageState extends State<_add_CameraScanBarcodePage>{
  late DateTime _currentDate;

  ServiceSound serviceSound = ServiceSound();
  MobileScannerController cameraController = MobileScannerController();
  final TextEditingController _pieceController = TextEditingController();

  List<String> BarcodeList = [];

  String BarcodeValue = '';
  String SkuDisplayName = '';
  String lightStatus = 'เปิดไฟ';

  int listCount = 0;
  int cash_stt_index = 0;
  String cash_status = 'C';
  String cash_caption = '';

  bool load_complete = false;
  List<Map<String, dynamic>> product_data=[];

  double prodNetCash = 0;
  int prodNetPie = 0;

  String title = 'ขายสินค้า';

  bool isNewRecriptAction = false;

  String memberid = 'เลขสมาชิก';
  bool isMember = false;

  _add_CameraScanBarcodePageState(DateTime currentDate){
    _currentDate = currentDate;
  }

  @override
  void initState(){
    super.initState();

    DeclareTemp.sale_recript = [];
    PrepareSaleProd();
  }

  void PrepareSaleProd(){
    setState(() {
      load_complete = false;
    });

    BLSale(context).GetSaleProduct(DeclareValue.currentStoreId).then((value){
      debugPrint(value.toString());

      setState(() {
        product_data = value;
        load_complete = true;
      });
    }).onError((error, stackTrace) {
      setState(() {
        load_complete = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        CheckClose();
        return Future.value(false);
      },
      child: Scaffold(
        body: load_complete? Scaning() : ServiceUI.Indicater(true),
        bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget Scaning(){
    return MobileScanner(
      // fit: BoxFit.contain,
      fit: BoxFit.none,
      //controller: cameraController,
      controller: MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        detectionTimeoutMs: DeclareValue.sett_scanspeed,
        torchEnabled: DeclareValue.sett_light_onoff,
      ),
      startDelay: true,
      onDetect: (capture)  {
        final List<Barcode> barcodes = capture.barcodes;
        //final Uint8List? image = capture.image;
        for (final barcode in barcodes) {
          //debugPrint('Barcode found! ${barcode.rawValue}');
          //Fluttertoast.showToast(msg: barcode.rawValue ?? '');
          setState(() {
            var newCode = barcode.rawValue ?? '';
            if(newCode.isNotEmpty) {
              BarcodeList.add(newCode);
              BarcodeValue = BarcodeList.last;

              GetScanDetail(newCode);
            }
          });
          serviceSound.ScanSound();
        }
      },
    );
  }

  void GetScanDetail(String code){
      setState(() {
        prodNetPie = 0;
        prodNetCash = 0;
        SkuDisplayName = '';
      });


      String custype = cash_status.toUpperCase();
      double cuscash = 0;

      double prodNetPay = 0;
      double prodNetDiscount = 0;
      int pie = 1;

      try {
        if (_pieceController.text.isNotEmpty) {
          pie = int.tryParse(_pieceController.text.toString()) ?? 1;
        }

        Map<String, dynamic>? prod;
        try {
          prod = product_data.firstWhere((e) =>
          e['skuBarcode'].toString().toUpperCase() ==
              BarcodeValue.toUpperCase());
        }catch(e){
          ShowToast(context,'ไม่มีสินค้าหรือสินค้าหมด').Show(MessageType.error);
        }

        if (prod!=null) {
            int amtPie = int.tryParse(prod['amt_Pie'].toString()) ?? 0;
            setState(() {
              SkuDisplayName = prod!['skuname'];
            });

            if(pie > amtPie){
              ShowToast(context,'จำนวนสินค้าไม่เพียงพอต่อการจำหน่าย').Show(MessageType.warn);
          }else {
            double price = double.tryParse(prod['price'].toString()) ?? 0.0;
            double discount = double.tryParse(prod['discount'].toString()) ?? 0.0;
            double member = double.tryParse(prod['member'].toString()) ?? 0.0;

            setState(() {
              switch (cash_status.toUpperCase()) {
                case 'M':
                  cuscash = member;
                  break;
                case 'C':
                  cuscash = price;
                  break;
                case 'D':
                  cuscash = discount;
                  break;
              }

              prodNetCash = pie * cuscash;
              if (prodNetCash == 0.00) {
                custype = 'C';
                prodNetCash = pie * price;

                ShowToast(context, 'ไม่มี$cash_caption').Show(MessageType.warn);
              }

              prodNetPay = pie * price;
              prodNetDiscount = prodNetPay - prodNetCash;

              prodNetPie = pie;
              listCount += pie;

              var uuid = const Uuid();
              DeclareTemp.sale_recript.add({
                'id': uuid.v4(),
                'barcode': code,
                'goodsid': prod!['goodsId'],
                'goodsname': prod['skuname'],
                'custype': custype,
                'pie': pie,
                'cash_peru': cuscash,
                'cash': prodNetCash,
                'net_pay': prodNetPay,
                'net_discount': prodNetDiscount
              });
            });

            _pieceController.text = '';
          }
        }
      }catch(e){
        debugPrint(e.toString());
      }
  }

  Widget Footer(){
    return Container(
      color: Colors.lightBlue.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SetCash(),
          LabelDisplay(),
          LabelSumList(),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //FlashLightBtn(),
                SetCusType(),
                CloseBtn(),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Image CheckCusType(){
    switch(cash_status.toUpperCase()){
      case 'M':
        setState(() {
          cash_caption = 'ราคาสมาชิก';
        });

        return DeclareValue.m_custype_img;
        break;
      case 'D':
        setState(() {
          cash_caption = 'ราคาส่วนลด';
        });

        return DeclareValue.d_custype_img;
        break;
      default :
        setState(() {
          cash_caption = 'ราคาปกติ';
        });

        return DeclareValue.c_custype_img;
        break;
    }
  }

  Widget SetCusType(){
    Image cusImg = CheckCusType();
    debugPrint(cash_caption);

    return Row(
      children: [
        GestureDetector(
          onTap: (){
            setState(() {
              cash_stt_index++;
              if(cash_stt_index >= DeclareValue.cash_stts.length){
                cash_stt_index = 0;
              }

              cash_status = DeclareValue.cash_stts[cash_stt_index];
            });

            debugPrint(cash_status);
          },
          child: Row(
            children: [
              cusImg,
              const SizedBox(width: 5,),
              Text(cash_caption,style: const TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ],
    );
  }

  Widget SetCash(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: ()=>SetMemberNumber(),
            onLongPress: (){
              if(isMember) {
                Vibration.vibrate(duration: 100);
                setState(() {
                  isMember = false;
                  memberid = 'เลขสมาชิก';

                  cash_status = 'C';
                });

                CheckCusType();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/memcard.png',height: 30,),
                const SizedBox(width: 5,),
                Text(memberid,style: const TextStyle(fontSize: 15),),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              autofocus: false,
              controller: _pieceController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsFormatter(allowFraction: true)
              ],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText:'จำนวน',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: _pieceController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void SetMemberNumber(){
    try{
      ServiceScan().scanBarcodeNormal().then((value) {
        if(value!='-1') {
          ServiceSound().ScanSound();

          setState(() {
            memberid = value;
            isMember = true;
            cash_status = 'M';
          });

          CheckCusType();
        }else{
          setState(() {
            memberid = 'เลขสมาชิก';
            isMember = false;
          });
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget LabelDisplay(){
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/bcode_icon.png',height: 25),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                      child: Text(BarcodeValue,style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Image.asset('assets/images/label_icon.png',height: 25),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                      child: Text(SkuDisplayName),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget LabelSumList(){
    String listcountValue = NumberFormat("#,##0", "en_US").format(listCount);
    String cacheValue = NumberFormat("#,##0.00", "en_US").format(prodNetCash);
    String pieValue = NumberFormat("#,##0", "en_US").format(prodNetPie);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          child: ElevatedButton(
            onPressed: ()=>CancelLastProduct(cacheValue,pieValue),
            child: Row(
              children: [
                Image.asset('assets/images/money.png',height: 27,),
                const SizedBox(width: 5,),
                AutoSizeText('$cacheValue | $pieValue',style: const TextStyle(fontSize: 17,color: Colors.green)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          child: ElevatedButton(
            onPressed: ()=>SaleListPage(),
            child: Row(
              children: [
                Image.asset('assets/images/goods3.png',height: 27,),
                const SizedBox(width: 5,),
                AutoSizeText(listcountValue,style: const TextStyle(fontSize: 17,color: Colors.red)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> SaleListPage() async {
    if(DeclareTemp.sale_recript.isNotEmpty) {
      final value = await Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              ScanProdSummPage(currentDate: _currentDate,memberid: isMember==true? memberid:'',)));

      debugPrint(value.toString());

      PrepareSumm();
      Update(value as Map<String, dynamic>);
    }
  }

  void Update(Map<String,dynamic> value){
    bool isSaved = bool.tryParse(value['saved'].toString()) ?? false;
    if (isSaved) {
      PrepareSaleProd();

      if (DeclareTemp.sale_recript.isEmpty) {
        BarcodeList.clear();
        BarcodeValue = '';
        SkuDisplayName = '';
      }

      setState(() {
        isNewRecriptAction = true;
      });
    }
    }

  void PrepareSumm(){
    setState(() {
      listCount = 0;
      prodNetCash = 0.00;
      prodNetPie = 0;
    });

    for(int i =0;i < DeclareTemp.sale_recript.length;i++){
      int sPie = int.tryParse(DeclareTemp.sale_recript[i]['pie'].toString()) ?? 0;

      setState(() {
        listCount += sPie;
      });
    }
  }

  Future<void> CancelLastProduct(String cash,String pie) async {
    try{
      if(cash!='0.00') {
        if (await confirm(context,
          title: Text(title),
          content: Text(
              'ต้องการยกเลิกสินค้าจำนวน $pie รายการ รวม $cash บาท หรือไม่?'),
          textOK: const Text('ใช่'),
          textCancel: const Text('ยังก่อน'),
        )) {
          if (DeclareTemp.sale_recript.isNotEmpty) {
            setState(() {
              DeclareTemp.sale_recript.removeAt(
                  DeclareTemp.sale_recript.length - 1);
              listCount = listCount - prodNetPie;
              prodNetCash = 0.00;
              prodNetPie = 0;
            });
          }
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget FlashLightBtn(){
    return Row(
      children: [
        Switch(
          value: DeclareValue.sett_light_onoff,
          activeColor: Colors.amber,
          onChanged: (bool value) {
            setState(() {
              DeclareValue.sett_light_onoff = value;
              debugPrint(DeclareValue.sett_light_onoff.toString());

              if(value){
                lightStatus = 'ปิดไฟ';
              }else{
                lightStatus = 'เปิดไฟ';
              }
            });
          },
        ),
        Text(lightStatus),
      ],
    );
  }

  Widget CloseBtn(){
    return GestureDetector(
        onTap: () => CheckClose(),
        child: Image.asset('assets/images/close_cross.png',height: 27,)
    );
  }

  Future<void> CheckClose() async {
    int saleCont = DeclareTemp.sale_recript.length;
    if(saleCont > 0) {
      if (await confirm(context,
        title: Text(title),
        content: Text(
            "มีข้อมูลสินค้าขายที่ยังทำไม่สำเร็จ \n $saleCont รายการ \n ต้องการยกเลิกหรือไม่?"),
        textOK: const Text('ใช่'),
        textCancel: const Text('ยังก่อน'),
      )) {
        Navigator.pop(context,{'reload': isNewRecriptAction});
      }
    }else{
      Navigator.pop(context,{'reload': isNewRecriptAction});
    }
  }
}