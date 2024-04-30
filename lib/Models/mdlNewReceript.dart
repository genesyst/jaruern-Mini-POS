

class mdlNewReceript{
  late String _culture;
  late String _atdate;
  late String _storeid;
  late double? _cash;
  late double? _vat;
  late double? _discount;
  late String _remark;
  late double? _vatRate;
  late double? _taxRate;
  late double? _fullprice;
  late double? _deposit;

  late int _cashType;
  late double? _cusCash;
  late double? _cusChange;
  late String _creditNo;
  late double? _cusCredit;
  late String _memberId;
  late String _typeCode;
  late String _refid;

  String get refid => _refid;

  set refid(String value) {
    _refid = value;
  }

  double get fullprice => _fullprice ?? 0;

  set fullprice(double value) {
    _fullprice = value;
  }

  double get deposit => _deposit ?? 0;

  set deposit(double value) {
    _deposit = value;
  }

  String get typeCode => _typeCode;

  set typeCode(String value) {
    _typeCode = value;
  }

  String get memberId => _memberId;

  set memberId(String value) {
    _memberId = value;
  }

  int get cashType => _cashType;

  set cashType(int value) {
    _cashType = value;
  }

  String get culture => _culture;

  set culture(String value) {
    _culture = value;
  }

  String get atdate => _atdate;

  double get taxRate => _taxRate ?? 0;

  set taxRate(double value) {
    _taxRate = value;
  }

  double get vatRate => _vatRate ?? 0;

  set vatRate(double value) {
    _vatRate = value;
  }

  String get remark => _remark;

  set remark(String value) {
    _remark = value;
  }

  double get discount => _discount ?? 0;

  set discount(double value) {
    _discount = value;
  }

  double get vat => _vat ?? 0;

  set vat(double value) {
    _vat = value;
  }

  double get cash => _cash ?? 0;

  set cash(double value) {
    _cash = value;
  }

  String get storeid => _storeid;

  set storeid(String value) {
    _storeid = value;
  }

  set atdate(String value) {
    _atdate = value;
  }

  double get cusCash => _cusCash ?? 0;

  set cusCash(double value) {
    _cusCash = value;
  }

  double get cusChange => _cusChange ?? 0;

  set cusChange(double value) {
    _cusChange = value;
  }

  String get creditNo => _creditNo;

  set creditNo(String value) {
    _creditNo = value;
  }

  double get cusCredit => _cusCredit ?? 0;

  set cusCredit(double value) {
    _cusCredit = value;
  }
}