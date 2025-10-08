import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final String _kuserid = "userId";
  final String _kaccesstoken = "accesstoken";
  final String _kdevicetoken = "devicetoken";
  final String _kuserName = "userName";
  final String _kloginType = "loginType";
  final String _kminimumStamps = "minimumStamps";
  final String _kbusinessId = "businessId";
  final String _kisActive = "isActive";
  final String _klat = "lat";
  final String _klong = "long";

  late SharedPreferences prefs;

  SessionManager() {
    initPreference();
  }

  Future<void> initPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  double getLat() {
    return prefs.getDouble(_klat) ?? 0.0;
  }

  Future<bool> setLat(double value) async {
    return prefs.setDouble(_klat, value);
  }

  double getlang() {
    return prefs.getDouble(_klong) ?? 0.0;
  }

  Future<bool> setlang(double value) async {
    return prefs.setDouble(_klong, value);
  }

  int getMinimumStamps() {
    return prefs.getInt(_kminimumStamps) ?? 0;
  }

  Future<bool> setMinimumStamps(int value) async {
    return prefs.setInt(_kminimumStamps, value);
  }

  Future<bool> remove() async {
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  clearDataExceptBaseUrl() async {
    prefs.remove(_kuserid);
    prefs.remove(_kaccesstoken);
    prefs.remove(_kdevicetoken);
    prefs.remove(_kuserName);
    prefs.remove(_kloginType);
    prefs.remove(_kminimumStamps);
    prefs.remove(_kbusinessId);
    prefs.remove(_kisActive);
    prefs.remove(_klat);
    prefs.remove(_klong);
  }
}
