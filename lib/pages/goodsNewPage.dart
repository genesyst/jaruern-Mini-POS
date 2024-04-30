

import 'dart:io';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaruern_mini_pos/BL/blGoods.dart';
import 'package:jaruern_mini_pos/Models/mdlNewGoods.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/localLib/pickImage.dart';
import 'package:jaruern_mini_pos/pages/browsDataPage.dart';
import 'package:jaruern_mini_pos/plug-in/showSnack.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/ServiceMsgDialogCustom.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceImage.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceNet.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceScan.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceSound.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

class GoodsNewPage extends StatelessWidget{
  const GoodsNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _GoodsNewPage();
  }
  
}

class _GoodsNewPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _GoodsNewPageState();
  }
  
}

class _GoodsNewPageState extends State<_GoodsNewPage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _qrcodeController = TextEditingController();
  final TextEditingController _skucodeController = TextEditingController();
  final TextEditingController _skunameController = TextEditingController();
  final TextEditingController _skudisplaynameController = TextEditingController();
  final TextEditingController _skusizeController = TextEditingController();
  final TextEditingController _skudetailController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _productGroupController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _memberpriceController = TextEditingController();

  bool prepare_progress = false;
  late List<Map<String, dynamic>> product_types;
  late List<Map<String, dynamic>> product_groups;
  late List<Map<String, dynamic>> product_groups_selection;

  late FToast fToast;

  String title = 'เพิ่มสินค้าใหม่';
  String producttype_id = '';
  String producttype_name = '';

  String productgroup_id = '';
  String productgroup_name = '';

  bool acl_g = true;
  bool acl_s = false;

  ImagePicker _picker = ImagePicker();
  XFile? _imageUpdate;
  CroppedFile? _croppedFile;
  bool _saving = false;

  @override
  void initState(){
    super.initState();

    fToast = FToast();
    fToast.init(context);

    PrepareData();
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
        backgroundColor: Colors.lightBlueAccent,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/goods.png',height: 25,),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
              child: Text(title),
            ),
            GestureDetector(
                onTap: ()=>{Navigator.pop(context)},
                child: Image.asset('assets/images/close_cross.png',height: 20,)
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ServiceUI.Indicater(prepare_progress),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0),
              child: AddGoodsform(),
            ),
          ],
        ),
      ),
    );
  }

  void PrepareData(){
    try{
      ServiceNet().isInternetConnected().then((isConnect){
        if(isConnect){
          setState(() {
            prepare_progress = true;
          });

          BLGoods(context).getProductType().then((ptype){
            product_types = ptype;

            BLGoods(context).getProductGroup().then((pgroup){
              product_groups = pgroup;

              setState(() {
                prepare_progress = false;
              });

            });

          });
        }else{
          ServiceMsgDialogCustom.showInternetErrorDialog(context, false);
        }
      });
    }catch(e){
      setState(() {
        prepare_progress = false;
      });
      throw Exception(e);
    }
  }

  Future<void> AddGoods() async {
    try{
      if(_formKey.currentState!.validate()){
        String skuname = _skunameController.text;
        if (await confirm(context,
        title: Text(title),
        content: Text('ต้องการเพิ่มสินค้า $skuname หรือไม่?'),
        textOK: const Text('ใช่'),
        textCancel: const Text('ยังก่อน'),
        )) {
          if(await AddGoodsImage(_barcodeController.text)) {
            mdlNewGoods newGoods = mdlNewGoods();
            newGoods.Skubarcode = _barcodeController.text;
            newGoods.Skuqrcode = _qrcodeController.text;
            newGoods.Skucode = _skucodeController.text;
            newGoods.Skuname = _skunameController.text;
            newGoods.Skudisplayname = _skudisplaynameController.text;
            newGoods.Skusize = _skusizeController.text;
            newGoods.Desp = _skudetailController.text;
            newGoods.Producttypeid = null;
            newGoods.Productgroupid = null;

            if (_productTypeController.text.isNotEmpty) {
              newGoods.Producttypeid = producttype_id;
            }

            if (_productGroupController.text.isNotEmpty) {
              newGoods.Productgroupid = productgroup_id;
            }

            BLGoods(context).setNewGoods(newGoods).then((res) {
              debugPrint(res.toString());
              debugPrint(res?['id'].toString());
              if (int.parse(res!['id'].toString()) == 0) {
                Navigator.pop(context);
              }
            });
          }
        }
      }
    }catch(e){
      throw Exception(e);
    }
  }

  Future<bool> AddGoodsImage(String skubarcode) async {
    if (_imageUpdate == null && _croppedFile == null) {
      return Future.value(true);
    } else {
      File? file;
      if (_croppedFile != null) {
        file = File(_croppedFile!.path);
      } else if (_imageUpdate != null) {
        file = File(_imageUpdate!.path);
      }

      File? imageUpload = await ServiceImage(context)
          .JpegCompressLimit(file!, 0,
          DeclareValue.limitImageKBSize);

      Map<String, dynamic>? res = await BLGoods(context).SetGoodsImage(
          imageUpload ?? file, skubarcode, 'O', DeclareValue.currentStoreId);

      int id = int.tryParse(res!['id'].toString()) ?? -1;
      if (id == 0) {
        return Future.value(true);
      } else if (id == 1) {
        ShowToast(context, 'ไม่พบไล์ภาพที่ต้องการบันทึก').Show(
            MessageType.error);
      } else if (id == 3) {
        ShowToast(context, 'ผิดพลาด ไม่สามารถปรับปรุงข้อมูลได้').Show(
            MessageType.error);
      }
    }

    return Future.value(false);
  }

  Widget AddGoodsform() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          GoodsCode(),
          const SizedBox(height: 10.0),
          GoodsDetail(),
          const SizedBox(height: 10.0),
          //GoodsPrices(),
          //const SizedBox(height: 10.0),
          GoodsType(),
          const SizedBox(height: 5.0),
          //AccessLevel(),
          GoodsImageView(),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ServiceUI.Indicater(_saving),
              Visibility(
                  visible: !_saving,
                  child: SaveBtn()),
            ],
          ),
          const SizedBox(height: 60.0),
        ],
      ),
    );
  }

  Widget SaveBtn(){
    return GestureDetector(
        onTap: ()=>AddGoods(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/images/true_icon.jpg',height: 38,),
            const Padding(
              padding: EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
              child: Text('บันทึกสินค้า',style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        )
    );
  }

  Widget GoodsImageView(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: SizedBox(height: 25, width: 25,
              child: Image.asset('assets/images/img_icon.png'),
            ), // Icon at the left of the card
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                          onTap: ()=>PickGoodsImage(),
                          child: ImageView()),
                      )
                    ),
                  ],
                ),
                Visibility(
                  visible: (_imageUpdate!=null || _croppedFile!=null),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                            onTap: (){
                              setState(() {
                                _imageUpdate = null;
                                _croppedFile = null;
                              });
                            },
                            child: Image.asset('assets/images/close_cross.png',width: 20,)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget ImageView(){
    if(_imageUpdate == null){
      return DeclareValue.NoImage;
    }else{
      if(_croppedFile!=null){
        return Image.file(File(_croppedFile!.path));
      }else{
        return Image.file(File(_imageUpdate!.path));
      }
    }
  }

  Future<void> PickGoodsImage() async {
    try{
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if(image!=null){
        setState(() {
          _imageUpdate = image;
        });

        var cropFile = await ServiceImage(context).CropImage(_imageUpdate);
        setState(() {
          _croppedFile = cropFile;
        });
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Widget AccessLevel(){
    return Column(
      children: [
        CheckboxListTile(
          value: acl_g,
          onChanged: (bool? value) {
            setState(() {
              acl_g = value!;
              if(value){
                acl_s = false;
              }
            });
          },
          title: const Text('ข้อมูลทั่วไป'),
          subtitle: const Text('ข้อมูลสินค้าแชร์ให้คนอื่นใช้งานได้'),
        ),
        CheckboxListTile(
          value: acl_s,
          onChanged: (bool? value) {
            setState(() {
              acl_s = value!;
              if(value){
                acl_g = false;
              }
            });
          },
          title: const Text('ข้อมูลเฉพาะใช้ในร้าน'),
          subtitle: const Text('ข้อมูลสินค้าแชร์ให้เฉพาะคนที่อยู่ในร้าน'),
        ),
      ],
    );
  }

  Widget GoodsPrices(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.price_change), // Icon at the left of the card
            title: TextFormField(
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
            subtitle: const Text('ลักษณะตัวเลข บาท . สตางค์ (00.00)',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: const Icon(Icons.price_check), // Icon at the left of the card
            title: TextFormField(
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
            subtitle: const Text('ลักษณะตัวเลข บาท . สตางค์ (00.00)',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: const Icon(Icons.person), // Icon at the left of the card
            title: TextFormField(
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
            subtitle: const Text('ลักษณะตัวเลข บาท . สตางค์ (00.00)',style: TextStyle(color: Colors.black26),),
          ),
        ],
      ),
    );
  }

  Widget GoodsCode(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.barcode_reader), // Icon at the left of the card
            title: TextFormField(
              controller: _barcodeController,
              readOnly: true,
              style: const TextStyle(color: Colors.red),
              onTap: ()=>ScanBarcode(),
              decoration: InputDecoration(
                labelText: 'รหัสบาร์โค๊ต',
                suffixIcon: IconButton(
                  onPressed: _barcodeController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุรหัสบาร์โค๊ต';
                }
                return null;
              },
            ),
            subtitle: const Text('ลักษณะจะเป็นชุดตัวเลขเท่านั้น',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code), // Icon at the left of the card
            title: TextFormField(
              controller: _qrcodeController,
              readOnly: true,
              style: const TextStyle(color: Colors.blue),
              onTap: ()=>ScanQRcode(),
              decoration: InputDecoration(
                labelText: 'รหัสคิวอาร์โค๊ต',
                suffixIcon: IconButton(
                  onPressed: _qrcodeController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            subtitle: const Text('ลักษณะจะเป็นตัวเลขและตัวอักษร',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: const Icon(Icons.code), // Icon at the left of the card
            title: TextFormField(
              controller: _skucodeController,
              readOnly: false,
              style: const TextStyle(color: Colors.red),
              decoration: InputDecoration(
                labelText: 'รหัสสินค้า',
                suffixIcon: IconButton(
                  onPressed: _skucodeController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุรหัสสินค้า';
                }
                return null;
              },
            ),
            subtitle: const Text('รหัสที่ตั้งขึ้นหรือใช้บาร์โค๊ต',style: TextStyle(color: Colors.black26),),
          ),
        ],
      ),
    );
  }

  Widget GoodsDetail(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: SizedBox(height: 25, width: 25,
              child: Image.asset('assets/images/label_icon.png'),
            ), // Icon at the left of the card
            title: TextFormField(
              controller: _skunameController,
              readOnly: false,
              decoration: InputDecoration(
                labelText: 'ชื่อสินค้า',
                suffixIcon: IconButton(
                  onPressed: _skunameController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุชื่อสินค้า';
                }
                return null;
              },
            ),
          ),
          ListTile(
            leading: SizedBox(height: 25, width: 25,
              child: Image.asset('assets/images/label_icon2.png'),
            ), // Icon at the left of the card
            title: TextFormField(
              controller: _skudisplaynameController,
              readOnly: false,
              decoration: InputDecoration(
                labelText: 'ชื่อเรียกสินค้า',
                suffixIcon: IconButton(
                  onPressed: _skudisplaynameController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            subtitle: const Text('ชื่อเรียก ชื่อตามป้าย',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: SizedBox(height: 25, width: 25,
              child: Image.asset('assets/images/size_icon.png'),
            ), // Icon at the left of the card
            title: TextFormField(
              controller: _skusizeController,
              readOnly: false,
              decoration: InputDecoration(
                labelText: 'ขนาดสินค้า',
                suffixIcon: IconButton(
                  onPressed: _skusizeController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            subtitle: const Text('เช่น 200g , 25x45cm',style: TextStyle(color: Colors.black26),),
          ),
          ListTile(
            leading: SizedBox(height: 25, width: 25,
              child: Image.asset('assets/images/detail_icon.png'),
            ), // Icon at the left of the card
            title: TextFormField(
              controller: _skudetailController,
              readOnly: false,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'รายละเอียดสินค้า',
                suffixIcon: IconButton(
                  onPressed: _skudetailController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            subtitle: const Text('ข้อมูลเพิ่มเติมเกี่ยวกับสินค้า',style: TextStyle(color: Colors.black26),),
          ),
        ],
      ),
    );
  }

  Widget GoodsType(){
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: SizedBox(height: 25, width: 25,
              child: Image.asset('assets/images/goods3.png'),
            ), // Icon at the left of the card
            title: TextFormField(
              controller: _productTypeController,
              readOnly: true,
              onTap: ()=>PrepareGoodsType(),
              decoration: InputDecoration(
                labelText: 'ประเภทสินค้า',
                suffixIcon: IconButton(
                  onPressed: (){
                    _productTypeController.text = '';
                    setState(() {
                      producttype_id = '';
                      producttype_name = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาระบุประเภทสินค้า';
                }
                return null;
              },
            ),
          ),
          ListTile(
            leading: SizedBox(height: 25, width: 25,
              child: Image.asset('assets/images/goods2.png'),
            ), // Icon at the left of the card
            title: TextFormField(
              controller: _productGroupController,
              readOnly: true,
              onTap: ()=>PrepareGoodsGroup(),
              decoration: InputDecoration(
                labelText: 'กลุ่มสินค้า',
                suffixIcon: IconButton(
                  onPressed: (){
                    _productGroupController.text='';
                    setState(() {
                      productgroup_id = '';
                      productgroup_name = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void PrepareGoodsGroup(){
    try{
      if(product_groups_selection.isEmpty) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BrowsDataPage(
              title: 'กลุ่มสินค้า',
              data: product_groups_selection,
              display_field: 'productgroupname'
          ),
        ),
      ).then((value){
        if(value!=null){
          debugPrint(value.toString());
          setState(() {
            productgroup_id = value['id'];
            productgroup_name = value['productgroupname'];
            _productGroupController.text = productgroup_name;
          });
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void PrepareGoodsType(){
    try{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BrowsDataPage(
              title: 'ประเภทสินค้า',
              data: product_types,
              display_field: 'producttypename'
          ),
        ),
      ).then((value) {
        if(value!=null){
          debugPrint(value.toString());
          setState(() {
            if(producttype_id!=value['id']){
              productgroup_id = '';
              productgroup_name = '';
              _productGroupController.text = '';
            }

            producttype_id = value['id'];
            producttype_name = value['producttypename'];
            _productTypeController.text = producttype_name;

            product_groups_selection = product_groups.where((e) => e['producttypeid'] == producttype_id).toList();
          });

          debugPrint(product_groups_selection.toString());

          if(product_groups_selection.isEmpty) {
            //ShowToast(context,'$producttype_name ไม่มีกลุ่มสินค้า').Show(MessageType.info);
            ShowSnack(context,'$producttype_name ไม่มีกลุ่มสินค้า').Show(MessageType.info);
          }
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void ScanBarcode(){
    try{
      ServiceScan().scanBarcodeNormal().then((value) {
        if(value!='-1') {
          ServiceSound().ScanSound();
          _barcodeController.text = value;
          _skucodeController.text = value;
        }else{
          _barcodeController.clear();
          _skucodeController.clear();
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }

  void ScanQRcode(){
    try{
      ServiceScan().scanBarcodeNormal().then((value) {
        if(value!='-1') {
          ServiceSound().ScanSound();
          _qrcodeController.text = value;
        }else{
          _qrcodeController.clear();
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }
  
}