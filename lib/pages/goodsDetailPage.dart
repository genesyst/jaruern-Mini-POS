

import 'dart:io';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaruern_mini_pos/BL/blGoods.dart';
import 'package:jaruern_mini_pos/declareValue.dart';
import 'package:jaruern_mini_pos/defineType.dart';
import 'package:jaruern_mini_pos/plug-in/showSnack.dart';
import 'package:jaruern_mini_pos/plug-in/showToast.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceImage.dart';
import 'package:jaruern_mini_pos/serviceLib/serviceUI.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class GoodsDetailPage extends StatelessWidget{
  final String goodsname;
  final String goodsid;
  const GoodsDetailPage({super.key,required this.goodsid,required this.goodsname});

  @override
  Widget build(BuildContext context) {
    return _GoodsDetailPage(goodsid,goodsname);
  }

}

class _GoodsDetailPage extends StatefulWidget{
  late String goodsid;
  late String goodsname;

  _GoodsDetailPage(String id,String name){
    goodsid = id;
    goodsname = name;
  }

  @override
  State<StatefulWidget> createState() {
    return _GoodsDetailPageSate(goodsid,goodsname);
  }

}

class _GoodsDetailPageSate extends State<_GoodsDetailPage>{
  late String goodsid;
  late String goodsname;

  late String goods_image_baecode;
  late String goods_image_qrcode;

  String producttypename = '';
  String skubarcode = '';
  String skuqrcode = '';
  String skucode = '';
  String skuname = '';
  String skusize = '';
  String desp = '';
  String skudisplayname = '';
  String productgroupname = '';

  TextStyle captionStyle = const TextStyle(fontWeight: FontWeight.bold);

  String fav_image = 'assets/images/star_icon2.png';
  bool fav = false;

  bool indicator = false;
  bool img_indicator = false;

  ImagePicker _picker = ImagePicker();
  XFile? _imageUpdate;
  CroppedFile? _croppedFile;
  String ImageURL = '';

  _GoodsDetailPageSate(String id,String name){
    goodsid = id;
    goodsname = name;

    dummy_val();
  }

  void dummy_val(){
    goods_image_baecode = 'https://images.all-free-download.com/images/graphiclarge/barcode_198334.jpg';
    goods_image_qrcode = 'https://upload.wikimedia.org/wikipedia/commons/5/5b/Qrcode_wikipedia.jpg';
  }

  @override
  void initState(){
    super.initState();

    PrepareData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> GetBarcodeImage() async {
    String barcodeUrl = await BLGoods(context).getGoodsImageBarcode(skubarcode);
    debugPrint(barcodeUrl);
    if(barcodeUrl.isNotEmpty){
      setState(() {
        goods_image_baecode = barcodeUrl;
      });
    }

    if(skuqrcode.isNotEmpty) {
      String qrcodeUrl = await BLGoods(context).getGoodsImageQRcode(
          skubarcode, skuqrcode);
      debugPrint(qrcodeUrl);
      if (qrcodeUrl.isNotEmpty) {
        setState(() {
          goods_image_qrcode = qrcodeUrl;
        });
      }
    }
  }

  void PrepareData(){
    try{
      setState(() {
        indicator = true;
        img_indicator = true;
      });

      BLGoods(context).getGoods(goodsid).then((value){
        debugPrint(value.toString());

        try {
          if (value != null) {
            setState(() {
              skubarcode = value['skubarcode'];
              producttypename = value['producttypename'];
              productgroupname = value['productgroupname'];
              skuqrcode = value['skuqrcode'];
              skucode = value['skucode'];
              skuname = value['skuname'];
              skusize = value['skusize'];
              desp = value['desp'];
              skudisplayname = value['skudisplayname'];
              fav = value['favorite'];
            });

            SetFavStatus();

            LoadGoodsImage();
            GetBarcodeImage();
          } else {
            ShowToast(context, 'ไม่พบข้อมูลสินค้า โปรดตรวจสอบ').Show(
                MessageType.error);
          }
        }finally{
          setState(() {
            indicator = false;
            img_indicator = false;
          });
        }
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> LoadGoodsImage() async {
    String _url = await BLGoods(context).getGoodsImageUrl(
                          skubarcode, 'O', DeclareValue.currentStoreId);
    debugPrint(_url);

    if(_url.isNotEmpty){
      setState(() {
        ImageURL = _url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //config Orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return WillPopScope(
      onWillPop: () async{
        SetGoodsUpdate();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(goodsname),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: ()=>SetGoodsUpdate(),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ServiceUI.Indicater(indicator),
                ServiceUI.HerizonLine(null, null),
                Favorite(),
                Detail(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void SetFavStatus(){
    setState(() {
      if(fav){
        fav_image = 'assets/images/star_icon.png';
      }else{
        fav_image = 'assets/images/star_icon2.png';
      }
    });
  }

  Widget Favorite(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: (){
            BLGoods(context).getSetGoodsFavorite(goodsid).then((value){
              if(value){
                setState(() {
                  if(fav){
                    fav = false;
                    fav_image = 'assets/images/star_icon2.png';
                    ShowSnack(context,'เอา $goodsname ออกจากสินค้าโปรด').Show(MessageType.info);
                  }else{
                    fav = true;
                    fav_image = 'assets/images/star_icon.png';
                    ShowSnack(context,'เพิ่ม $goodsname เป็นสินค้าโปรด').Show(MessageType.info);
                  }
                });
              }
            });
          },
          child: Image.asset(fav_image,height: 30,),
        ),
        const SizedBox(width: 10,)
      ],
    );
  }

  Widget Detail(){
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              SizedBox(width: 80,child: Image.network(goods_image_baecode,width: 75,)),
              const SizedBox(width: 10,),
              Expanded(child: Text(skubarcode,
                  style: const TextStyle(fontSize: 20,color: Colors.redAccent)),),
            ],
          ),
        ),
        Visibility(
          visible: skuqrcode.isNotEmpty? true: false,
          child: ListTile(
            title: Row(
              children: [
                SizedBox(width: 80, child: Image.network(goods_image_qrcode,width: 75,)),
                const SizedBox(width: 10,),
                Expanded(child: Text(skuqrcode,
                    style: const TextStyle(fontSize: 20,color: Colors.blueAccent))),
              ],
            ),
          ),
        ),
        ServiceUI.HerizonLine(null, null),
        ListTile(
          title: Row(
            children: [
              SizedBox(width: 80, child: Text('รหัสสินค้า',style: captionStyle,)),
              const SizedBox(width: 10,),
              Expanded(child: Text(skucode,
                style: const TextStyle(fontSize: 20,color: Colors.blueAccent),)),
            ],
          ),
        ),
        ListTile(
          title: Row(
            children: [
              SizedBox(width: 80, child: Text('ชื่อสินค้า',style: captionStyle,)),
              const SizedBox(width: 10,),
              Expanded(child: Text(skuname)),
            ],
          ),
        ),
        ListTile(
          title: Row(
            children: [
              SizedBox(width: 80, child: Text('ชื่อเรียก',style: captionStyle,)),
              const SizedBox(width: 10,),
              Expanded(child: Text(skudisplayname)),
            ],
          ),
        ),
        ListTile(
          title: Row(
            children: [
              SizedBox(width: 80, child: Text('ขนาด/\nน้ำหนัก',style: captionStyle,)),
              const SizedBox(width: 10,),
              Expanded(child: Text(skusize)),
            ],
          ),
        ),
        Visibility(
          visible: desp.isNotEmpty? true:false,
          child: ListTile(
            title: Row(
              children: [
                const SizedBox(width: 80, child: Text('')),
                const SizedBox(width: 10,),
                Expanded(child: Text(desp)),
              ],
            ),
          ),
        ),
        ListTile(
          title: Row(
            children: [
              SizedBox(width: 80, child: Text('ประเภท',style: captionStyle,)),
              const SizedBox(width: 10,),
              Expanded(child: Text(producttypename)),
            ],
          ),
        ),
        Visibility(
          visible: productgroupname.isNotEmpty? true:false,
          child: ListTile(
            title: Row(
              children: [
                SizedBox(width: 80, child: Text('กลุ่ม',style: captionStyle,)),
                const SizedBox(width: 10,),
                Expanded(child: Text(productgroupname)),
              ],
            ),
          ),
        ),
        ListTile(
          title: Column(
            children: [
              ServiceUI.Indicater(img_indicator),
              GoodsImage(),
            ],
          ),
        ),
        const SizedBox(height: 40,),
      ],
    );
  }

  Widget GoodsImage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: ()=>UpdateGoodsImage(),
          child: GoodsImageView(),
        ),
      ],
    );
  }

  Widget GoodsImageView(){
    return Container(
      width: MediaQuery.of(context).size.width - 80,
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ImageView(),
      ),
    );
  }

  Widget ImageView(){
    if(ImageURL.isNotEmpty){
      return Image.network(ImageURL);
    }else {
      if (_imageUpdate == null) {
        return DeclareValue.NoImage;
      } else {
        if (_croppedFile != null) {
          return Image.file(File(_croppedFile!.path));
        } else {
          return Image.file(File(_imageUpdate!.path));
        }
      }
    }
  }

  Future<void> UpdateGoodsImage() async {
    try{
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if(image!=null){
        setState(() {
          _imageUpdate = image;
        });

        CroppedFile? cropImage = await ServiceImage(context).CropImage(_imageUpdate);
        setState(() {
          _croppedFile = cropImage;
          ImageURL = '';
        });
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> SetGoodsUpdate() async {
    if(_imageUpdate!=null || _croppedFile!=null){
      if (await confirm(context,
          title: const Text('สินค้า'),
          content: Text('ต้องการปรับปรุงรูปสินค้า "$skuname" หรือไม่?'),
          textOK: const Text('ใช่'),
          textCancel: const Text('ยังก่อน'),
      )) {
        File? file;
        if(_croppedFile!=null){
          file = File(_croppedFile!.path);
        }else if(_imageUpdate!=null){
          file = File(_imageUpdate!.path);
        }

        try {
          setState(() {
            img_indicator = true;
          });

          File? imageUpload = await ServiceImage(context)
                                        .JpegCompressLimit(file!, 0,
                                            DeclareValue.limitImageKBSize);

          Map<String, dynamic>? res = await BLGoods(context).SetGoodsImage(
              imageUpload ?? file, skubarcode, 'O', DeclareValue.currentStoreId);

          debugPrint(res.toString());

          int id = int.tryParse(res!['id'].toString()) ?? -1;
          if (id == 0) {
            ShowToast(context, 'บันทึกการปรับปรุงแล้ว').Show(
                MessageType.complete);
            Navigator.pop(context);
          } else if (id == 1) {
            ShowToast(context, 'ไม่พบไล์ภาพที่ต้องการบันทึก').Show(
                MessageType.error);
          } else if (id == 3) {
            ShowToast(context, 'ผิดพลาด ไม่สามารถปรับปรุงข้อมูลได้').Show(
                MessageType.error);
          }
        }finally{
          setState(() {
            img_indicator = false;
          });
        }
      }else{
        Navigator.pop(context);
      }
    }else{
      Navigator.pop(context);
    }
  }



}