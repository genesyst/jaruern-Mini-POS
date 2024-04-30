

class mdlStockInGoods{
  late String _Goodid;
  late double _Saleprice;
  late double? _Discount;
  late double? _Memberprice;
  late double? _Cost;
  late String _Remark;
  late String _Tag;

  String get Goodid => _Goodid;

  String get Tag => _Tag;

  set Tag(String value) {
    _Tag = value;
  }

  String get Remark => _Remark;

  set Remark(String value) {
    _Remark = value;
  }

  double get Cost => _Cost!;

  set Cost(double? value) {
    _Cost = value;
  }

  double get Memberprice => _Memberprice!;

  set Memberprice(double? value) {
    _Memberprice = value;
  }

  double get Discount => _Discount!;

  set Discount(double? value) {
    _Discount = value;
  }

  double get Saleprice => _Saleprice;

  set Saleprice(double value) {
    _Saleprice = value;
  }

  set Goodid(String value) {
    _Goodid = value;
  }
}