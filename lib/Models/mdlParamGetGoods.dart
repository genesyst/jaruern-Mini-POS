

class mdlParamGetGoods{
  late int _load_index;
  late String _findvalue;
  late String _ptype;
  late String _pgroup;
  late String _barcode;
  late bool _favorite;


  bool get favorite => _favorite;

  set favorite(bool value) {
    _favorite = value;
  }

  int get load_index => _load_index;

  set load_index(int value) {
    _load_index = value;
  }

  String get findvalue => _findvalue;

  String get barcode => _barcode;

  set barcode(String value) {
    _barcode = value;
  }

  String get pgroup => _pgroup;

  set pgroup(String value) {
    _pgroup = value;
  }

  String get ptype => _ptype;

  set ptype(String value) {
    _ptype = value;
  }

  set findvalue(String value) {
    _findvalue = value;
  }
}