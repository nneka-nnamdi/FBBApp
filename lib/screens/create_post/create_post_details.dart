import 'dart:async';

import 'package:android_intent/android_intent.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/enums.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/models/tags_model.dart';
import 'package:fight_blight_bmore/models/location_result.dart';
import 'package:fight_blight_bmore/screens/create_post/map.dart';
import 'package:fight_blight_bmore/screens/create_post/tag_list.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:fight_blight_bmore/utils/device/device_utils.dart';
import 'package:fight_blight_bmore/utils/log.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:fight_blight_bmore/widgets/loader_widget.dart';
import 'package:fight_blight_bmore/widgets/no_border_textfield.dart';
import 'package:fight_blight_bmore/widgets/prediction_overlay.dart';
import 'package:fight_blight_bmore/widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as loc;

class CreatePostDetailsScreen extends StatefulWidget {
  @override
  _CreatePostDetailsScreenState createState() =>
      _CreatePostDetailsScreenState();
}

class _CreatePostDetailsScreenState extends State<CreatePostDetailsScreen> {
  AppTheme appTheme = AppTheme.light();
  ThemeData themeData = AppTheme.light().buildThemeData();
  final PostStore _postStore = getIt<PostStore>();
  List arrayThumbnails = [];
  List<TagModel> arrayTags = [];
  List<TagModel> selectedArrayTags = [];
  bool isPlantingRequired = false;
  bool isEvictionReported = false;
  bool openEvictionOption = false;
  String selectedEviction = '';
  final ScrollController _scrollController = ScrollController();

  //Google maps
  Completer<GoogleMapController> mapController = Completer();
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(39.264969, -76.598633),
    zoom: 5.0,
  );
  late Geoflutterfire geo;

  //stores:---------------------------------------------------------------------
  bool _validateName = false;
  bool _validateDescription = false;
  bool _validateAddress = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _postNameController = TextEditingController();
  TextEditingController _postDescriptionController = TextEditingController();
  TextEditingController _neighborhoodController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  //Overlay properties
  loc.Location _location = loc.Location();
  bool haveSelectedAddress = false;

  // Custom marker icon
  BitmapDescriptor? icon;
  LatLng locationResult = LatLng(39.264969, -76.598633);

  // List for storing markers
  List<Marker> allMarkers = [];
  List<AutocompletePrediction> predictions = [];

  //Focus nodes
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _neighborhoodFocusNode = FocusNode();

  // this also checks for location permission.
  Future<void> _initCurrentLocation() async {
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      d("position = $currentPosition");
    } on PlatformException catch (e) {
      currentPosition = null;
      d("_initCurrentLocation#e = $e");
    }

    if (!mounted) return;

    print(
        'Map _currentPosition called-------++++++++++++++-------------++++++++++++++----------------');
    if (currentPosition != null)
      moveToCurrentLocation(
          LatLng(currentPosition.latitude, currentPosition.longitude));
  }

  Future moveToCurrentLocation(LatLng currentLocation) async {
    print('****************$currentLocation**************************');
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLocation, zoom: 16),
    ));
  }

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
    geo = Geoflutterfire();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(1, 1)), Assets.pin)
        .then((value) {
      icon = value;
      allMarkers = [
        Marker(
            markerId: MarkerId("retrieved"),
            icon: icon!,
            position: locationResult)
      ];
    });
    _location.getLocation().then((value) {
      print(
          'Getlocation called*****************************************************************');
      _postStore.latLng =
          LatLng(value.latitude ?? 39.264969, value.longitude ?? -76.598633);
    });
    _nameFocusNode.addListener(() {
      _postNameController.text = _nameFocusNode.hasFocus &
              (_postNameController.text.compareTo(Strings.placeholderName) == 0)
          ? ''
          : _postNameController.text.isEmpty
              ? Strings.placeholderName
              : _postNameController.text;
      _postStore.setName(_postNameController.text);
    });
    _descriptionFocusNode.addListener(() {
      _postDescriptionController.text = _descriptionFocusNode.hasFocus &
              (_postDescriptionController.text
                      .compareTo(Strings.placeholderDescription) ==
                  0)
          ? ''
          : _postDescriptionController.text.isEmpty
              ? Strings.placeholderDescription
              : _postDescriptionController.text;
      _postStore.setDescription(_postDescriptionController.text);
    });
    _postNameController.text = Strings.placeholderName;
    _postDescriptionController.text = Strings.placeholderDescription;
    _postStore.setName(_postNameController.text);
    _postStore.setDescription(_postDescriptionController.text);
  }

  void _onMapCreated(GoogleMapController controller) {
    _location.onLocationChanged.listen((l) {
      if (_postStore.latLng.longitude.toString().isEmpty) {
        print(
            'Map created called-------++++++++++++++--------${_postStore.latLng}-----++++++++++++++----------------');
        _postStore.latLng =
            LatLng(l.latitude ?? 39.264969, l.longitude ?? -76.598633);
      }
    });
    mapController.complete(controller);
  }

  /*
  Add property details and save to firestore
   */
  Future<void> saveDataToFirestore() async {
    isConnectedToInternet().then((isConnected) {
      if (isConnected) {
        _postStore.loading = true;
        var tags = _postStore.tags.map((e) => e.id).toList();
        var media = _postStore.imageVideoList.map((e) {
          return {
            'thumbnail': e.thumbnailUrl,
            'mediaUrl': e.downloadUrl,
          };
        }).toList();
        GeoFirePoint center = geo.point(
            latitude: _postStore.latLng.latitude,
            longitude: _postStore.latLng.longitude);
        FirebaseFirestore.instance.collection('property').add({
          "name": _postStore.name,
          "description": _postStore.description,
          "address": _postStore.address,
          "latitude": _postStore.latLng.latitude,
          "longitude": _postStore.latLng.longitude,
          "point": center.data,
          "neighborhood": _postStore.neighborhood,
          "tags": tags,
          "media": media,
          "tree_plantation": isPlantingRequired,
          "property_id": DateTime.now().millisecondsSinceEpoch,
          "created_at": DateTime.now().millisecondsSinceEpoch,
          "user_id": FirebaseAuth.instance.currentUser?.uid,
          "comments": [],
          "is_evicted": selectedEviction.isNotEmpty,
          'eviction_type': selectedEviction,
          "is_flagged": false,
        }).then((result) {
          result.get().then((value) {
            print(value['property_id']);
            _showMyDialog(value['property_id'], result.id);
          });
        }).catchError((error) {
          _postStore.loading = false;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        });
      } else {
        _postStore.loading = false;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please check your network connection.')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _postStore.context = context;

    _checkGps();
    _checkGeolocationPermission();

    return Observer(
      builder: (context) {
        return LoaderWidget(
          child: Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(),
          ),
          state: _postStore.loading,
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.4,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Color(0xFFF8F8F8),
      title: Text(
        Strings.add_property,
        style: semiBoldTextStyle(16,
            fontFamily: FontFamily.sfProDisplay, color: Colors.black),
      ),
      leading: Padding(
          padding: EdgeInsets.all(10.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Image.asset(Assets.back),
          )),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 20.0, right: 20.0),
            child: GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _validateName = true;
                    _validateDescription = true;
                    _validateAddress = true;
                  });
                } else {
                  setState(() {
                    _validateName = true;
                    _validateDescription = true;
                    _validateAddress = true;
                  });
                }
                DeviceUtils.hideKeyboard(context);
                if (_postStore.canPostProperty) {
                  //post property
                  print('Name -> ${_postStore.name}\n '
                      'Description -> ${_postStore.description}\n '
                      'Address -> ${_postStore.address}\n '
                      'Neighborhood -> ${_postStore.neighborhood}\n '
                      'Tags -> ${_postStore.tags}\n');
                  saveDataToFirestore();
                } else {
                  print('Saved till now: ---${_postStore.latLng}---');

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(Strings.emptyPropertyDetails)));
                }
              },
              child: Text(
                Strings.post,
                style: normalTextStyle(16, color: appTheme.primaryColor),
              ),
            )),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 17.0),
            _buildNameField(),
            _buildMaximumCount(50),
            SizedBox(height: 25.0),
            Divider(),
            _buildDescriptionField(),
            _buildMaximumCount(250),
            Divider(),
            _buildAddressField(),
            Divider(),
            _buildNeighborhoodField(),
            Divider(),
            _buildTagsView(),
            Divider(),
            _buildTreePlantation(),
            Divider(),
            _buildEvictionView(),
            Visibility(
              child: _buildEvictionOptions(),
              visible: openEvictionOption,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTreePlantation() {
    return Container(
      padding: EdgeInsets.only(top: 8, left: 14, right: 8, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Strings.requestTreePlantation,
            style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  isPlantingRequired = !isPlantingRequired;
                });
              },
              child: Container(
                  height: 24,
                  child: isPlantingRequired
                      ? Image.asset(Assets.tree)
                      : Image.asset(Assets.deselect)))
        ],
      ),
    );
  }

  Widget _buildEvictionView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
          top: 8, left: 14, right: 8, bottom: openEvictionOption ? 10 : 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            // width: 200,
            child: Row(
              children: [
                AutoSizeText(
                  selectedEviction.isEmpty
                      ? Strings.checkEviction
                      : Strings.reportingEviction,
                  style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
                ),
                Visibility(
                  visible: selectedEviction.isNotEmpty,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        openEvictionOption = true;
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent + 100.0,
                        );
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Image.asset(
                          Assets.selected_radio,
                          scale: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            selectedEviction,
                            style:
                                normalTextStyle(16, fontFamily: FontFamily.sfProText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                isEvictionReported = !isEvictionReported;
                openEvictionOption =
                    isEvictionReported && selectedEviction.isEmpty;
                if (openEvictionOption) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent + 100.0,
                  );
                }
              });
              // print(scrollKey.currentState?.context);
              // Scrollable.ensureVisible(
              //     scrollKey.currentState?.context ?? context);
            },
            child: Container(
                height: 24,
                child: selectedEviction.isEmpty
                    ? isEvictionReported
                        ? Image.asset(Assets.selected_circle)
                        : Image.asset(Assets.deselect)
                    : Image.asset(Assets.evicted)),
          ),
        ],
      ),
    );
  }

  Widget _buildEvictionOptions() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 0, left: 18, right: 8, bottom: 30),
      child: Card(
          elevation: 5.0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          openEvictionOption = false;
                          isEvictionReported = selectedEviction.isNotEmpty;
                        });
                      },
                      child: Container(
                          height: 24, child: Image.asset(Assets.orange_cross))),
                  Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.2),
                    child: Text(
                      Strings.reportAs,
                      style:
                          normalTextStyle(16, fontFamily: FontFamily.sfProText),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEvictionOption(EvictionType.witness),
                  _buildEvictionOption(EvictionType.resident),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEvictionOption(EvictionType.sheriff),
                  _buildEvictionOption(EvictionType.propertyOwner),
                ],
              ),
              SizedBox(
                height: 10,
              )
            ],
          )),
    );
  }

  Widget _buildEvictionOption(String type) {
    return InkWell(
      onTap: () {
        print(type);
        setState(() {
          selectedEviction = type;
          isEvictionReported = false;
          openEvictionOption = false;
        });
      },
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              child: Image.asset(selectedEviction == type
                  ? Assets.selected_radio
                  : Assets.unselected_radio),
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: AutoSizeText(
                type,
                style: normalTextStyle(
                  16,
                  fontFamily: FontFamily.sfProText,
                  color: appTheme.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextfieldTitle(String text) {
    return Padding(
        padding: EdgeInsets.only(left: 5.0),
        child: Text(
          text,
          style: normalTextStyle(16,
              fontFamily: FontFamily.sfProText, color: appTheme.tagColor),
        ));
  }

  Widget _buildMaximumCount(int charCount) {
    return Padding(
        padding: EdgeInsets.only(right: 14, top: 0, bottom: 2),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 12,
                child: Image.asset(Assets.count),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                '(maximum of $charCount characters)',
                style: normalTextStyle(12,
                    fontFamily: FontFamily.sfProText,
                    color: appTheme.greyColor),
              ),
            ]));
  }

  Widget _buildNameField() {
    return Observer(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: TextFieldWidget(
          hint: Strings.property_name,
          inputType: TextInputType.name,
          focusNode: _nameFocusNode,
          textController: _postNameController,
          autoFocus: false,
          textInputFormatter:
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
          onChanged: (value) {
            if (_postNameController.text.contains(Strings.placeholderName)) {
              _postNameController.text = _postNameController.text
                  .replaceAll(Strings.placeholderName, '');
            }
            _postStore.setName(_postNameController.text);
          },
          validator: (value) {
            _postStore.validateName(value);
          },
          maxLength: 50,
          errorText: _validateName ? _postStore.postErrorStore.name : null,
          margin: EdgeInsets.only(
            left: 5,
            top: 8,
            bottom: 0,
            right: 5,
          ),
        ),
      );
    });
  }

  Widget _buildDescriptionField() {
    return Observer(builder: (context) {
      return Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 30, // - 130,
                height: 155,
                child: NoBorderTextField(
                  textInputFormatter:
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                  hintText: Strings.post_description,
                  inputType: TextInputType.name,
                  editingController: _postDescriptionController,
                  inputAction: TextInputAction.newline,
                  focusNode: _descriptionFocusNode,
                  autoFocus: false,
                  onChanged: (value) {
                    _postStore.setDescription(_postDescriptionController.text);
                  },
                  validator: (value) {
                    _postStore.validateDescription(value);
                  },
                  maxLines: 10,
                  maxLength: 250,
                  errorText: _validateDescription
                      ? _postStore.postErrorStore.description
                      : null,
                ),
              ),
              // InkWell(
              //   onTap: () {},
              //   child: Container(
              //     height: 155,
              //     width: 100,
              //     child: ListView.builder(
              //       itemBuilder: (ctx, index) {
              //         return Center(
              //             child: Container(
              //                 height: 60,
              //                 width: 100,
              //                 child: Image.asset(Assets.home_selected)));
              //       },
              //       itemCount: arrayThumbnails.length,
              //     ),
              //   ),
              // ),
            ]),
      );
    });
  }

  Widget _buildAddressField() {
    return Observer(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                DeviceUtils.hideKeyboard(context);
                print(
                    'Location Result- $locationResult,----- postStore.LatLng- ${_postStore.latLng}');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPicker(),
                      settings: RouteSettings(arguments: _postStore.latLng),
                    )).then((value) {
                  print(value);
                  LocationResult location = value as LocationResult;
                  _addressController.text = location.address ?? '';
                  _postStore.setAddress(_addressController.text);
                  locationResult =
                      location.latLng ?? LatLng(39.264969, -76.598633);
                  moveToCurrentLocation(locationResult);
                  _postStore.latLng = locationResult;
                  print(
                      '&&&&&&&&&&&&&&&&&&${_postStore.latLng}&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                  haveSelectedAddress = true;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextfieldTitle(Strings.address),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                      top: 8,
                      bottom: 8,
                      right: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          child: GoogleMap(
                            markers: Set.from(allMarkers),
                            onMapCreated: _onMapCreated,
                            myLocationButtonEnabled: false,
                            initialCameraPosition: _initialCameraPosition,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Strings.pinpoint_location,
                            style: normalTextStyle(16,
                                fontFamily: FontFamily.sfProText, height: 1.5),
                          ),
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            Assets.forward,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PredictionOverlayField(
                    addressController: _addressController,
                    locationResult: locationResult,
                    validateAddress: _validateAddress,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNeighborhoodField() {
    return Observer(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTextfieldTitle(Strings.neighborhood),
          TextFieldWidget(
            textInputFormatter:
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9,/#]")),
            hint: Strings.exNeighborhood,
            inputType: TextInputType.name,
            textController: _neighborhoodController,
            focusNode: _neighborhoodFocusNode,
            autoFocus: false,
            onChanged: (value) {
              _postStore.setNeighborhood(_neighborhoodController.text);
            },
            validator: (value) {
              // _store.validateNeigh(value);
            },
            maxLength: 100,
            errorText: null,
            margin: EdgeInsets.only(
              left: 5,
              top: 8,
              bottom: 0,
              right: 5,
            ),
          ),
        ]),
      );
    });
  }

  Widget _buildTagsView() {
    return Observer(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 0),
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            InkWell(
              onTap: () async {
                if (arrayTags.length > 0) {
                  setState(() {
                    _postStore.loading = false;
                  });
                } else {
                  arrayTags = await _postStore.getTags();
                  print(arrayTags);
                }
                setState(() {
                  _postStore.loading = false;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TagListScreen(),
                      settings: RouteSettings(arguments: arrayTags),
                    )).then((value) {
                  print("tags-----${value.toString()}");
                  if (value != null) {
                    setState(() {
                      arrayTags = value as List<TagModel>;
                      selectedArrayTags = arrayTags
                          .where((element) =>
                              element.isSelected && element.isSaved)
                          .toList();
                    });
                    _postStore.setTags(selectedArrayTags);
                  }
                });
              },
              child: Stack(children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    Strings.post_tags,
                    style: normalTextStyle(
                      16,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.hintColor,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    Assets.forward,
                    height: 20,
                  ),
                )
              ]),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedArrayTags.length,
                  itemBuilder: (BuildContext context, int index) => Padding(
                    padding: EdgeInsets.only(right: 10, bottom: 2),
                    child: Card(
                      color: Color(0xFFE5E5E5),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Container(
                          padding: EdgeInsets.only(right: 15, left: 15),
                          child: Center(
                              child: Text(
                            selectedArrayTags[index].title,
                            style: normalTextStyle(
                              12,
                              fontFamily: FontFamily.sfProText,
                              color: appTheme.tagColor,
                            ),
                          ))),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ]),
        ),
      );
    });
  }

  Future<void> _showMyDialog(int propertyId, String documentId) async {
    UserStore _userStore = UserStore();
    await _userStore.getUserProfile();
    _userStore.addBookMark(propertyId, documentId);
    _postStore.loading = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 20.0,
          title: Container(
            height: 120,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Image.asset(Assets.tick),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 50,
                    height: 50,
                    child: TextButton(
                      child: Image.asset(Assets.close),
                      onPressed: () {
                        _postStore.clear();
                        Navigator.of(context).pushNamed(Routes.tab);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  Strings.successPost,
                  textAlign: TextAlign.center,
                  style:
                      normalTextStyle(20, fontFamily: FontFamily.sfProDisplay),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _postNameController.dispose();
    _postDescriptionController.dispose();
    _addressController.dispose();
    _neighborhoodController.dispose();

    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _neighborhoodFocusNode.dispose();

    super.dispose();
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
                  _initCurrentLocation();
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
