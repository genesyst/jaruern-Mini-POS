
import 'package:shared_preferences/shared_preferences.dart';

class SettingValues{
  final String _domain = 'api_domain';
  String key_currentstoreid = 'current_store_id';
  String key_currentstorename = 'current_store_name';
  String key_scanspeed = 'scanspeed';
  String key_light_onoff = 'scanspeed';
  String key_userid = 'user_id';
  String key_accesstoken = 'token';
  String key_email = 'email';
  String key_vat = 'vat';
  String key_vatinner = 'vatin';

  Future<bool> doesKeyExist(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> setVAT(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(key_vat, value);
  }

  Future<double?> getVAT() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key_vat);
  }

  Future<bool> setVatinner(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key_vatinner, value);
  }

  Future<bool?> getVatinner() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key_vatinner);
  }

  Future<bool> setLightOnOff(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key_light_onoff, value);
  }

  Future<bool?> getLightOnOff() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key_light_onoff);
  }

  Future<bool> setScanSpeed(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key_scanspeed, value);
  }

  Future<int?> getScanSpeed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key_scanspeed);
  }

  Future<bool> setCurrentStoreId(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key_currentstoreid, value);
  }

  Future<String> getCurrentStoreId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key_currentstoreid) ?? "";
  }

  Future<bool> setCurrentStoreName(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key_currentstorename, value);
  }

  Future<String> getCurrentStoreName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key_currentstorename) ?? "";
  }

  Future<bool> setAuthenToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key_accesstoken,value);
  }

  Future<String> getAuthenToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key_accesstoken) ?? "";
  }

  Future<bool> setEmail(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key_email,value);
  }

  Future<String> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key_email) ?? "";
  }

  Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key_userid) ?? "";
  }

  Future<void> resetAuthen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key_accesstoken);
    prefs.remove(key_userid);
    prefs.remove(key_email);
    prefs.remove(key_currentstoreid);
    prefs.remove(key_currentstorename);
  }

  Future<String> getDomain() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_domain) ?? '';
  }

  Future<bool> setDomain(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_domain, value);
  }
}