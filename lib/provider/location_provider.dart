import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LocationProvider extends ChangeNotifier {
  static LocationProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<LocationProvider>(context, listen: listen);

   LatLng? _lastIdleLocation;

  LatLng get lastIdleLocation => _lastIdleLocation ?? LatLng(20.5937, 78.9629);

  void setLastIdleLocation(LatLng lastIdleLocation) {
    if (_lastIdleLocation != lastIdleLocation) {
      _lastIdleLocation = lastIdleLocation;
      notifyListeners();
    }
  }
}
