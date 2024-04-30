

class mdlGoodsOrder{
  late String _id;
  late String _goodsId;
  late String _goodsName;
  late String _barcode;
  late String _size;
  late int _piece;
  late double _saleprice;
  double? _price;
  double? _discount;
  late int _amtpiece;


  double get saleprice => _saleprice;

  set saleprice(double value) {
    _saleprice = value;
  }

  double get discount => _discount ?? 0;

  set discount(double value) {
    _discount = value;
  }

  String get goodsId => _goodsId;

  set goodsId(String value) {
    _goodsId = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get goodsName => _goodsName;

  double get price => _price ?? 0;

  set price(double value) {
    _price = value;
  }

  int get piece => _piece;

  set piece(int value) {
    _piece = value;
  }

  String get size => _size;

  set size(String value) {
    _size = value;
  }

  String get barcode => _barcode;

  set barcode(String value) {
    _barcode = value;
  }

  set goodsName(String value) {
    _goodsName = value;
  }

  int get amtpiece => _amtpiece;

  set amtpiece(int value) {
    _amtpiece = value;
  }
}