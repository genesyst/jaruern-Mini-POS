

class mdlRetGoodsEdit{
  late String _id;
  late String _goodsid;
  late String _goodsName;
  late String _barcode;
  late String _qrCode;
  late String _size;
  late int _piece;
  late double _salePrice;
  late double _cash;
  late String _cashType;

  late bool _isSelected;

  late String _reason;

  late int _RetType;

  int get RetType => _RetType;

  set RetType(int value) {
    _RetType = value;
  }

  String get reason => _reason;

  set reason(String value) {
    _reason = value;
  }

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    _isSelected = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get goodsid => _goodsid;

  String get cashType => _cashType;

  set cashType(String value) {
    _cashType = value;
  }

  double get cash => _cash;

  set cash(double value) {
    _cash = value;
  }

  double get salePrice => _salePrice;

  set salePrice(double value) {
    _salePrice = value;
  }

  int get piece => _piece;

  set piece(int value) {
    _piece = value;
  }

  String get size => _size;

  set size(String value) {
    _size = value;
  }

  String get qrCode => _qrCode;

  set qrCode(String value) {
    _qrCode = value;
  }

  String get barcode => _barcode;

  set barcode(String value) {
    _barcode = value;
  }

  String get goodsName => _goodsName;

  set goodsName(String value) {
    _goodsName = value;
  }

  set goodsid(String value) {
    _goodsid = value;
  }
}