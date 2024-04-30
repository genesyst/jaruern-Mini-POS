

class mdlItem{
  late String _Key;
  late String _Text;
  late Object? _Value;

  String get Key => _Key;

  set Key(String value) {
    _Key = value;
  }

  String get Text => _Text;

  Object get Value => _Value ?? '';

  set Value(Object value) {
    _Value = value;
  }

  set Text(String value) {
    _Text = value;
  }
}