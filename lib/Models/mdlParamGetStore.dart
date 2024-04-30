

class mdlParamGetStore{
    late int _load_index;
    late String _storegroup;
    late String _storetype;
    late String _filter;
    late String _location;

    int get load_index => _load_index;

  set load_index(int value) {
    _load_index = value;
  }

    String get storegroup => _storegroup;

    String get location => _location;

  set location(String value) {
    _location = value;
  }

  String get filter => _filter;

  set filter(String value) {
    _filter = value;
  }

  String get storetype => _storetype;

  set storetype(String value) {
    _storetype = value;
  }

  set storegroup(String value) {
    _storegroup = value;
  }
}