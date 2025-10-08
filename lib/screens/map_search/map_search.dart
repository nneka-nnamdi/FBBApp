import 'dart:async';
import 'dart:convert';

import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/screens/property_detail/property_detail.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/utils/device/device_utils.dart';
import 'package:fight_blight_bmore/utils/log.dart';
import 'package:fight_blight_bmore/widgets/search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:location/location.dart' as loc;
import 'package:fight_blight_bmore/utils/location_utils.dart';
import 'package:location/location.dart';

class MapSearchScreen extends StatefulWidget {
  @override
  MapSearchScreenState createState() => MapSearchScreenState();
}

class MapSearchScreenState extends State<MapSearchScreen> {
  //stores:---------------------------------------------------------------------
  final PostStore _postStore = PostStore();
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  GoogleMapController? _controller;
  Completer<GoogleMapController> mapController = Completer();
  MapType _currentMapType = MapType.normal;
  final bool requiredGPS = true;
  LatLng initialCenter = LatLng(39.299236, -76.609383);
  final double initialZoom = 5;
  AppTheme appTheme = AppTheme.light();
  Map<dynamic, dynamic>? selectedGoogleProperty;
  bool showGooglePropertyCard = false;
  bool isInitialised = false;
  var arrayProperties = [];
  var arrayNearbyProperties = [];
  int count = 0;
  TextEditingController _searchController = TextEditingController();
  late Geoflutterfire geo;
  late LatLng _lastMapPosition;
  loc.Location currentLocation = loc.Location();
  final Set<Marker> listMarkers = {};
  Marker? markerHome;
  BitmapDescriptor? customIcon;
  String apiKey = 'AIzaSyCTBLiWcy6mPTGddhKDy5Vr1hsHihWTFjA';

// make sure to initialize before map loading
  @override
  void initState() {
    super.initState();
    setCustomMarker();
    geo = Geoflutterfire();
    googlePlace = GooglePlace(apiKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialised) {
      isInitialised = true;
      moveToCurrentLocation(initialCenter);
      _lastMapPosition = initialCenter;
    }
    getLocation();
  }

  void getLocation() async {
    var location = await currentLocation.getLocation();
    initialCenter = LatLng(location.latitude ?? 0, location.longitude ?? 0);
    currentLocation.onLocationChanged.listen((LocationData loc) {
      if (listMarkers
              .where((element) => element.markerId == MarkerId('Home'))
              .length ==
          0) {
        _lastMapPosition = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);
        _controller
            ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
          target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
          zoom: 8,
        )));
        _lastMapPosition = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);
        markerHome = Marker(
            markerId: MarkerId('Home'),
            icon: customIcon == null
                ? BitmapDescriptor.defaultMarker
                : customIcon!,
            position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0));
        listMarkers.add(markerHome!);
        _showNearbyProperties();

      }
    });
    setState(() {});
  }

  void _showNearbyProperties() {
    GeoFirePoint center = geo.point(
        latitude: _lastMapPosition.latitude,
        longitude: _lastMapPosition.longitude);
    print(center);
    _postStore.getNearestProperties(center).then((result) {
      arrayNearbyProperties = result;
      setState(() {
        _setNearbyMarkers();
      });
    });
  }

  void setCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 6.9, size: Size(2, 2)),
      Assets.pinSmall,
    );
  }

  Future moveToCurrentLocation(LatLng currentLocation) async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLocation, zoom: initialZoom),
    ));
  }

  Future _searchResult(String searchText) async {
    arrayProperties.clear();
    var result = await _postStore.searchProperties(searchText);
    var uniquePropertyIds =
        result.map((c) => c['property_id']).toSet().toList();
    for (var n in uniquePropertyIds) {
      arrayProperties
          .add(result.where((element) => element['property_id'] == n).first);
    }
    await autoCompleteSearch(searchText);
  }

  Future autoCompleteSearch(String value) async {
    try {
      var result = await googlePlace?.autocomplete.get(value);
      for (var i in arrayProperties) {
        if (i is QueryDocumentSnapshot) {
          print(i.toString());
        } else {
          arrayProperties.remove(i);
        }
      }
      if (result != null && result.predictions != null && mounted) {
        predictions = result.predictions!;
        for (AutocompletePrediction prediction in predictions) {
          var metadata = await getDetails(prediction.placeId ?? '');
          arrayProperties.add({'prediction': prediction, 'details': metadata});
        }
      }

      _setMarkers();
      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  _setNearbyMarkers() {
    listMarkers.clear();

    if (markerHome != null) {
      listMarkers.add(markerHome!);
    }
    for (var i in arrayNearbyProperties) {
      listMarkers.add(Marker(
        markerId: MarkerId('${count++}'),
        position: LatLng(i['latitude'] ?? 0, i['longitude'] ?? 0),
        icon: customIcon == null ? BitmapDescriptor.defaultMarker : customIcon!,
        onTap: () {},
      ));
    }
    return listMarkers;
  }

  _setMarkers() {
    if (!showGooglePropertyCard) {
      listMarkers.clear();
      if (markerHome != null) {
        listMarkers.add(markerHome!);
      }
    }
    for (var i in arrayProperties) {
      if (i is QueryDocumentSnapshot) {
        listMarkers.add(Marker(
          markerId: MarkerId('${count++}'),
          position: LatLng(i['latitude'] ?? 0, i['longitude'] ?? 0),
          icon:
              customIcon == null ? BitmapDescriptor.defaultMarker : customIcon!,
          onTap: () {},
        ));
      } else {
        var value = '${i['prediction'].placeId ?? ''}';
        listMarkers.add(Marker(
            markerId: MarkerId('$value'),
            position: LatLng(
                i['details']?.latitude ?? 0, i['details']?.longitude ?? 0),
            icon: customIcon == null
                ? BitmapDescriptor.defaultMarker
                : customIcon!,
            onTap: () async {
              for (i in arrayProperties) {
                if (!(i is QueryDocumentSnapshot)) {
                  if (i['prediction'].placeId == value) {
                    selectedGoogleProperty = i;
                    DeviceUtils.hideKeyboard(context);
                    _searchController.clear();
                    arrayProperties.clear();
                    setState(() {
                      showGooglePropertyCard = true;
                    });
                    print('Element---$selectedGoogleProperty}');
                    break;
                  }
                }
              }
            }));
      }
    }
    return listMarkers;
  }

  Future getDetails(String placeId) async {
    var result = await this.googlePlace?.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      var detailResult = result.result;
      return LatLng(detailResult?.geometry?.location?.lat ?? 0.0,
          detailResult?.geometry?.location?.lng ?? 0.0);
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _postStore.context = context;
    if (requiredGPS) {
      _checkGps();
      _checkGeolocationPermission();
    }
    _setMarkers();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            buildMap(),
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    print(listMarkers);
    return Center(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: initialCenter,
              zoom: initialZoom,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: listMarkers,
            onCameraMove: (CameraPosition position) {
              _lastMapPosition = position.target;
            },
            onCameraIdle: () async {
              print("onCameraIdle#_lastMapPosition = $_lastMapPosition");
              _showNearbyProperties();
              getAddress(_lastMapPosition);
            },
            onCameraMoveStarted: () {
              print(
                  "===============onCameraMoveStarted#_lastMapPosition = $_lastMapPosition");
            },
            mapType: _currentMapType,
            myLocationEnabled: false,
          ),
          // pin(),
          Padding(
            padding: const EdgeInsets.only(top: 46, left: 8.0, right: 8.0),
            child: Column(
              children: [
                SearchFieldWidget(
                  onTap: () {
                    setState(() {
                      showGooglePropertyCard = false;
                    });
                  },
                  onPressed: () {
                    _clearData();
                  },
                  textController: _searchController,
                  onChanged: (value) async {
                    await _searchResult(value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Visibility(
                      child: _buildListView(),
                      visible: arrayProperties.length > 0,
                    ),
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: showGooglePropertyCard,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.4,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showGooglePropertyCard = false;
                    });
                  },
                  child: Card(
                    elevation: 5,
                    shadowColor: appTheme.textColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: appTheme.primaryColor,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        )),
                    child: Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Location',
                                    style: semiBoldTextStyle(16),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      selectedGoogleProperty?['prediction']
                                              ?.description ??
                                          '',
                                      style: normalTextStyle(14, height: 1.5)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Container(
                                  color: appTheme.greyColor,
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    'https://maps.googleapis.com/maps/api/streetview?size=400x400&location=${selectedGoogleProperty?['details']?.latitude},${selectedGoogleProperty?['details']?.longitude}&fov=90&heading=235&pitch=10&key=$apiKey',
                                    fit: BoxFit.fitWidth,
                                  )),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearData() {
    DeviceUtils.hideKeyboard(context);
    _searchController.clear();
    arrayProperties.clear();
    showGooglePropertyCard = false;
    setState(() {
      _searchResult('');
    });
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 20),
      itemCount: arrayProperties.length,
      itemBuilder: (context, position) {
        return _buildListItem(position);
      },
    );
  }

  Widget _buildListItem(int position) {
    return InkWell(
      onTap: () {
        if (arrayProperties[position] is QueryDocumentSnapshot) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PropertyDetailScreen(),
                  settings: RouteSettings(
                      arguments: arrayProperties[position]['property_id'])));
        } else {
          DeviceUtils.hideKeyboard(context);
          selectedGoogleProperty = arrayProperties[position];
          arrayProperties.clear();
          _searchController.clear();
          setState(() {
            _searchResult('');
            showGooglePropertyCard = true;
          });
        }
      },
      child: ListTile(
        dense: true,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.3,
                child: (arrayProperties[position] is QueryDocumentSnapshot)
                    ? _setThumbnail(arrayProperties[position]['media'])
                    : Image.network(
                        'https://maps.googleapis.com/maps/api/streetview?size=400x400&location=${arrayProperties[position]['details']?.latitude},${arrayProperties[position]['details']?.longitude}&fov=90&heading=235&pitch=10&key=$apiKey',
                        fit: BoxFit.fitWidth,
                      ),
              ),
            ],
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.3,
              child: AbsorbPointer(
                absorbing: true,
                child: GoogleMap(
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        (arrayProperties[position] is QueryDocumentSnapshot)
                            ? arrayProperties[position]['latitude']
                            : arrayProperties[position]['details']?.latitude ??
                                0,
                        (arrayProperties[position] is QueryDocumentSnapshot)
                            ? arrayProperties[position]['longitude']
                            : arrayProperties[position]['details']?.longitude ??
                                0,
                      ),
                      zoom: initialZoom,
                    )),
              )),
        ]),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 8,
          ),
          Text(
            (arrayProperties[position] is QueryDocumentSnapshot)
                ? arrayProperties[position]['name']
                : (arrayProperties[position]['prediction']
                        as AutocompletePrediction)
                    .description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: boldTextStyle(16,
                fontFamily: FontFamily.sfProText, color: appTheme.textColor),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            (arrayProperties[position] is QueryDocumentSnapshot)
                ? arrayProperties[position]['address']
                : '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: normalTextStyle(16,
                fontFamily: FontFamily.sfProText, color: appTheme.textColor),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            (arrayProperties[position] is QueryDocumentSnapshot)
                ? getElapsedTime(arrayProperties[position]['created_at'])
                : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: normalTextStyle(12,
                fontFamily: FontFamily.sfProText, color: appTheme.tagColor),
          ),
          SizedBox(
            height: 15,
          ),
        ]),
      ),
    );
  }

// General Methods:-----------------------------------------------------------

  Widget _setThumbnail(List<dynamic> media) {
    if (media.length > 0) {
      String data = media[0]['mediaUrl']!;

      return Image.network(
        data.contains('png') ? data : media[0]['thumbnail'] ?? '',
        fit: BoxFit.fitWidth,
      );
    } else {
      return Container(
        color: appTheme.greyColor,
      );
    }
  }

  Future<Map<String, String>> getAddress(LatLng location) async {
    try {
      final endPoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}'
          '&key=AIzaSyCTBLiWcy6mPTGddhKDy5Vr1hsHihWTFjA&language=en';

      var response = jsonDecode((await http.get(Uri.parse(endPoint),
              headers: await LocationUtils.getAppHeaders()))
          .body);
      
      return {
        "placeId": response['results'][0]['place_id'],
        "address": response['results'][0]['formatted_address']
      };
    } catch (e) {
      print(e);
    }
    return {"placeId": '', "address": ''};
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
