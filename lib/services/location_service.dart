import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:location/location.dart';
import 'package:fight_blight_bmore/utils/session_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  late UserLocation _currentLocation;

  var location = Location();

  Future<UserLocation?> getLocation() async {
    if (await Permission.location.request().isGranted) {
      try {
        var userLocation = await location.getLocation();
        _currentLocation = UserLocation(
          // need to change it as per location
          latitude: userLocation.latitude!,
          longitude: userLocation.longitude!,
        );

        var sessionManager = sl.get<SessionManager>();
        sessionManager.setLat(userLocation.latitude!);
        sessionManager.setlang(userLocation.longitude!);
      } on Exception catch (e) {
        print('Could not get location: ${e.toString()}');
      }
      return _currentLocation;
    } else {
      print('++++++++++++++++++++++++101111111111');
      return null;
    }
  }

  startLocationListner() {
    location.changeSettings(
        accuracy: LocationAccuracy.balanced,
        interval: 5000,
        distanceFilter: 500);

    location.onLocationChanged.listen((LocationData currentLocation) {
      print(
          '========================  LISTNERRRRRR  Current Location ${currentLocation.latitude.toString()}   ${currentLocation.longitude.toString()}');

      if (currentLocation != null) {
        var sessionManager = sl.get<SessionManager>();
        sessionManager.setLat(currentLocation.latitude!);
        sessionManager.setlang(currentLocation.longitude!);
      }
    }).onError((err) {});
  }
}

class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({required this.latitude, required this.longitude});
}
