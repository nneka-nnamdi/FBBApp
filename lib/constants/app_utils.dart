import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/flavor_settings.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/services/location_service.dart';
import 'package:fight_blight_bmore/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart'
as LocationPermission;
import 'package:location_permissions/location_permissions.dart';
import 'dart:ui' as ui;


final sl = GetIt.instance;

Future<bool> isLocationPermissionEnable() async {
  LocationPermission.PermissionStatus permissionStatus =
  await LocationPermissions().checkPermissionStatus();

  if (permissionStatus == LocationPermission.PermissionStatus.granted) {
    return true;
  }

  return false;
}

Future<bool> showLocationPermissionBottomSheet(BuildContext context) async {
  await showModalBottomSheet(
      enableDrag: false,
      isDismissible: false,
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0))),
      context: context,
      builder: (BuildContext bc) {
        return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 12, left: 12, right: 12, top: 20),
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2 +
                    MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.40 +
                          MediaQuery
                              .of(context)
                              .viewInsets
                              .bottom,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 100,
                              color: AppTheme
                                  .light()
                                  .primaryColor,
                            ),
                            Text(
                              'FBBMore Require Location Permission.',
                              textAlign: TextAlign.center,
                              style: mediumTextStyle(
                                14,
                                fontFamily: FontFamily.sfProText,
                              ),
                            ),
                            new Wrap(
                              children: <Widget>[
                                Text(
                                  'To provide the best offers near you, FBBMore need location access',
                                  textAlign: TextAlign.center,
                                  style: normalTextStyle(
                                    14,
                                    fontFamily: FontFamily.sfProText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment:
                      sl.get<SessionManager>().getLat() == 0.0
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceAround,
                      children: [
                        sl.get<SessionManager>().getLat() != 0.0
                            ? TextButton(
                          child: Text('Cancel',
                              style: normalTextStyle(14, color: AppTheme
                                  .light()
                                  .primaryColor)),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        )
                            : Container(),
                        TextButton(
                          child: Text('Give access',
                              style: normalTextStyle(14, color: AppTheme
                                  .light()
                                  .primaryColor)),
                          onPressed: () async {
                            LocationPermission.PermissionStatus permission =
                            await LocationPermissions()
                                .requestPermissions();
                            print('++++++++++++++++++++++++!1111');
                            bool isGPSEnable = await iisGPSServiceEnable();
                            print('++++++++++++++++++++++++222222');

                            if (permission ==
                                LocationPermission
                                    .PermissionStatus.granted &&
                                isGPSEnable) {
                              print('++++++++++++++++++++++++!33333');

                              await updateLocation();
                              print('++++++++++++++++++++++++!44444');

                              Navigator.pop(context);
                            } else if (permission ==
                                LocationPermission.PermissionStatus.granted) {
                              print('++++++++++++++++++++++++!55555');

                              Navigator.pop(context);
                            } else if (permission ==
                                LocationPermission.PermissionStatus.denied) {
                              print('++++++++++++++++++++++++!66666');

                              await LocationPermissions().openAppSettings();
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
      });

  return true;
}

Future<bool> iisGPSServiceEnable() async {
  LocationPermission.ServiceStatus serviceStatus =
  await LocationPermissions().checkServiceStatus();

  if (serviceStatus == LocationPermission.ServiceStatus.enabled) {
    return true;
  }

  return false;
}

Future<bool> updateLocation() async {
  var location = sl.get<LocationService>();
  print('++++++++++++++++++++++++!77777');
  if (Platform.isAndroid) {
     await location.getLocation();
  } else {
    location.getLocation();
  }
  print('++++++++++++++++++++++++88888');

  location.startLocationListner();

  return true;
}

Future<FlavorSettings> getFlavorSettings() async {
  String? flavor =
  await const MethodChannel('flavor').invokeMethod<String>('getFlavor');

  print('STARTED WITH FLAVOR $flavor');

  if (flavor == 'dev') {
    return FlavorSettings.dev();
  } else if (flavor == 'live') {
    return FlavorSettings.live();
  } else {
    throw Exception("Unknown flavor: $flavor");
  }
}

Future<bool> showGPSBottomSheet(BuildContext context,
    [bool isPopUpRequire = true]) async {

  bool isallowed = true;

  await showModalBottomSheet(
      enableDrag: false,
      isDismissible: false,
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0))),
      context: context,
      builder: (BuildContext bc) {
        return WillPopScope(
          onWillPop: () async { return false; },
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: 12, left: 12, right: 12, top: 20),
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 2 +
                  MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom,
              child: Column(
                  children: [
              Container(
              height: MediaQuery.of(context).size.height * 0.40 +
                  MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 100,
                      color: AppTheme.light().primaryColor,
                    ),
                    Text(
                      'GPS turned off.',
                      textAlign: TextAlign.center,
                      style: normalTextStyle(14, color: AppTheme.light().primaryColor),
                    ),
                    new Wrap(
                        children: <Widget>[
                          Text(
                            'To provide the best offers near you, FBBMore need location access.',
                            textAlign: TextAlign.center,
                            style: normalTextStyle(14, color: AppTheme
                                .light()
                                .primaryColor),
                          ),
                        ]
                    ),
                  ],
                ),
              ),
            ),
          Spacer(),
          Row(
            mainAxisAlignment:
            sl.get<SessionManager>().getLat() == 0.0
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceAround,
            children: [
              sl.get<SessionManager>().getLat() != 0.0
                  ? TextButton(
                child: Text('Cancel',
                    style: normalTextStyle(14, color: AppTheme
                        .light()
                        .primaryColor)),
                onPressed: () async {
                  isallowed = false;

                  Navigator.pop(context);
                },
              )
                  : Container(),
              TextButton(
                child: Text('Turn on GPS',
                    style: normalTextStyle(14, color: AppTheme
                        .light()
                        .primaryColor)),
                onPressed: () async {
                  bool _serviceEnabled =
                  await Location().requestService();
//400
                  if (_serviceEnabled && !isPopUpRequire) {
                    await Future.delayed(
                        const Duration(milliseconds: 100), () {});

                    await updateLocation();
                  } else if (_serviceEnabled && isPopUpRequire) {
                    await Future.delayed(
                        const Duration(milliseconds: 100), () {});

                    await updateLocation();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          )
          ],
        ),)
        ,
        )
        );
      });

  return isallowed;
}
Uint8List? markerIcon;

getBytesFromAsset() async {
  ByteData data = await rootBundle.load(Assets.pin);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: 45, targetHeight: 67);
  ui.FrameInfo fi = await codec.getNextFrame();
  markerIcon = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<bool> isConnectedToInternet() async {
var connectivityResult = await (Connectivity().checkConnectivity());
if (connectivityResult == ConnectivityResult.mobile ||
connectivityResult == ConnectivityResult.wifi) {
return Future.value(true);
} else {
return Future.value(false);
}
}

String getElapsedTime(int timestamp) {
  var now = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds == 0) {
    time = 'Just now';
  } else if (diff.inSeconds > 0 && diff.inSeconds < 60) {
    time = diff.inSeconds.toString() +
        (diff.inSeconds == 1 ? ' second ago' : ' seconds ago');
  } else if (diff.inMinutes > 0 && diff.inMinutes < 60) {
    time = diff.inMinutes.toString() +
        (diff.inMinutes == 1 ? ' minute ago' : ' minutes ago');
  } else if (diff.inHours > 0 && diff.inHours < 24) {
    time = diff.inHours.toString() +
        (diff.inHours == 1 ? ' hour ago' : ' hours ago');
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    // if (diff.inDays == 1) {
    //   time = diff.inDays.toString() + ' day ago';
    // } else {
      time = diff.inDays.toString() + ' day(s) ago';
    // }
  } else {
    // if (diff.inDays == 7) {
    //   time = (diff.inDays / 7).floor().toString() + ' week ago';
    // } else {
      time = (diff.inDays / 7).floor().toString() + ' week(s) ago';
    // }
  }

  return time;
}
