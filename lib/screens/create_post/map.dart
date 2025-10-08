import 'dart:async';
import 'dart:convert';

import 'package:android_intent/android_intent.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/utils/arrow_clipper.dart';
import 'package:fight_blight_bmore/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:location/location.dart' as loc;
import 'package:fight_blight_bmore/models/location_result.dart';
import 'package:fight_blight_bmore/utils/location_utils.dart';

class MapPicker extends StatefulWidget {
  @override
  MapPickerState createState() => MapPickerState();
}

class MapPickerState extends State<MapPicker> {
  Completer<GoogleMapController> mapController = Completer();

  MapType _currentMapType = MapType.normal;
  final bool requiredGPS = true;
  LatLng initialCenter = LatLng(39.299236, -76.609383);
  final double initialZoom = 15;

  late LatLng _lastMapPosition;

  String _address = '';

  String _placeId = '';

  loc.Location currentLocation = loc.Location();
  AppTheme appTheme = AppTheme.light();

  final LayerLink _layerLink = LayerLink();

  bool isInitialised = false;

// make sure to initialize before map loading

  Future moveToCurrentLocation(LatLng currentLocation) async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLocation, zoom: initialZoom),
    ));
  }


  void getLocation() async {
    var location = await currentLocation.getLocation();
    initialCenter = LatLng(location.latitude ?? 0, location.longitude ?? 0);
    // currentLocation.onLocationChanged.listen((loc.LocationData loc) {
    //   _controller
    //       ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
    //     target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
    //     zoom: initialZoom,
    //   )));
    //   initialCenter = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);
    //   print(loc.latitude);
    //   print(loc.longitude);
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialised) {
      isInitialised = true;
      final arg = ModalRoute.of(context)?.settings.arguments;
      if ((arg as LatLng?) != null) {
        moveToCurrentLocation(LatLng(arg!.latitude, arg.longitude));
        initialCenter = arg;
        _lastMapPosition = arg;
      }
       else {
        setState(() {
          getLocation();
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    _backPressed();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (requiredGPS) {
      _checkGps();
      _checkGeolocationPermission();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Builder(builder: (context) {
          return Stack(
            children: [
              buildMap(),
              // (_currentPosition == null && requiredGPS)
              //     ? const Center(child: CircularProgressIndicator())
              //     : Container(),
            ],
          );
        }),
      ),
    );
  }

  Widget buildMap() {
    return Center(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: initialCenter,
              zoom: initialZoom,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController.complete(controller);
              _lastMapPosition = initialCenter;
            },
            onCameraMove: (CameraPosition position) {
              _lastMapPosition = position.target;
            },
            onCameraIdle: () async {
              print("onCameraIdle#_lastMapPosition = $_lastMapPosition");
              getAddress(_lastMapPosition);
            },
            onCameraMoveStarted: () {
              print(
                  "===============onCameraMoveStarted#_lastMapPosition = $_lastMapPosition");
            },
            mapType: _currentMapType,
            myLocationEnabled: true,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 20),
            child: TextButton(
              onPressed: () {
                _backPressed();
              },
              child: SizedBox(
                  width: 50,
                  child: Image.asset(
                    Assets.map_back,
                  )),
            ),
          ),
          pin(),
          _infoWindow(),
          _buildArrowClipper(),
        ],
      ),
    );
  }

  void _backPressed() {
    LocationResult result = LocationResult(
        latLng: _lastMapPosition, address: _address, placeId: _placeId);
    Navigator.pop(context, result);
  }

  CompositedTransformFollower _buildArrowClipper() {
    return CompositedTransformFollower(
      link: this._layerLink,
      showWhenUnlinked: false,
      offset: Offset(125, 15),
      child: ClipPath(
        clipper: ArrowClipper(),
        child: Container(
          width: 17,
          height: 17,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<Map<String, String>> getAddress(LatLng location) async {
    try {
      final endPoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}'
          '&key=AIzaSyCTBLiWcy6mPTGddhKDy5Vr1hsHihWTFjA&language=en';

      var response = jsonDecode((await http.get(Uri.parse(endPoint),
              headers: await LocationUtils.getAppHeaders()))
          .body);
      setState(() {
        _address = response['results'][0]['formatted_address'];
        _placeId = response['results'][0]['place_id'];
      });
      print(response);
      return {
        "placeId": response['results'][0]['place_id'],
        "address": response['results'][0]['formatted_address']
      };
    } catch (e) {
      print(e);
    }
    return {"placeId": '', "address": ''};
  }

  Widget pin() {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(height: 50, child: Image.asset(Assets.pin)),
            Container(
              decoration: ShapeDecoration(
                shadows: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black38,
                  ),
                ],
                shape: CircleBorder(
                  side: BorderSide(
                    width: 4,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  Widget _infoWindow() {
    return Center(
      child: FittedBox(
        child: Container(
          width: 280,
          margin: EdgeInsets.only(bottom: 220),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: normalTextStyle(12,
                          color: appTheme.darkGreyColor,
                          fontFamily: FontFamily.sfProText),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      _address,
                      style: normalTextStyle(12,
                          color: appTheme.textColor,
                          fontFamily: FontFamily.sfProText),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CompositedTransformTarget(
                      link: this._layerLink,
                      child: Text(
                        '${_lastMapPosition.latitude}, ${_lastMapPosition.longitude}',
                        style: normalTextStyle(12,
                            color: appTheme.greyColor,
                            fontFamily: FontFamily.sfProText),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  var dialogOpen;

  Future _checkGeolocationPermission() async {
    var geolocationStatus = await Geolocator.isLocationServiceEnabled();

    if (!geolocationStatus && dialogOpen == null) {
      d('showDialog');
      dialogOpen = showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(Strings.locationPermissionHeading),
            content: Text(Strings.locationPermissionMessage),
            actions: <Widget>[
              TextButton(
                child: Text(Strings.ok),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  // _initCurrentLocation();
                  dialogOpen = null;
                },
              ),
            ],
          );
        },
      );
    } else if (geolocationStatus) {
      if (dialogOpen != null) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = null;
      }
    }
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(Strings.locationFailureError),
              content: Text(Strings.locationFailureMessage),
              actions: <Widget>[
                TextButton(
                  child: Text(Strings.ok),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');

                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
