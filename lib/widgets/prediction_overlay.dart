import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/widgets/textfield_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class PredictionOverlayField extends StatefulWidget {
  LatLng locationResult;
  final TextEditingController addressController;
  final bool validateAddress;

  PredictionOverlayField({
    required this.locationResult,
    required this.addressController,
    required this.validateAddress,
  });

  @override
  _PredictionOverlayFieldState createState() => _PredictionOverlayFieldState();
}

class _PredictionOverlayFieldState extends State<PredictionOverlayField> {
  AppTheme appTheme = AppTheme.light();
  final LayerLink _layerLink = LayerLink();
  List<AutocompletePrediction> predictions = [];
  GooglePlace? googlePlace;
  FocusNode _addressFocusNode = FocusNode();

  //Overlay properties
  OverlayEntry? _overlayEntry;
  bool _overlayShown = false;
  final PostStore _postStore = getIt<PostStore>();

  @override
  initState() {
    super.initState();
    String apiKey = 'AIzaSyCTBLiWcy6mPTGddhKDy5Vr1hsHihWTFjA';
    googlePlace = GooglePlace(apiKey);
  }

  Future<LatLng> getDetails(String placeId) async {
    var result = await this.googlePlace?.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      var detailResult = result.result;
      return LatLng(detailResult?.geometry?.location?.lat ?? 0.0,
          detailResult?.geometry?.location?.lng ?? 0.0);
    }
    return widget.locationResult;
  }

  void _showOverlay(BuildContext context) async {
    _overlayShown = true;
    // Declaring and Initializing OverlayState
    // and OverlayEntry objects
    OverlayState? overlayState = Overlay.of(context);
    // Generate the overlay entry
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        width: MediaQuery
            .of(context)
            .size
            .width - 30,
        height: 200,
        child: CompositedTransformFollower(
          link: this._layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, -200),
          child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: () {
                _overlayEntry?.remove();
                _overlayShown = false;
              },
              child: Material(
                elevation: 10.0,
                child: _buildPlacesOverlay(),
              )),
        ),
      );
    });
    // Inserting the OverlayEntry into the Overlay
    overlayState?.insert(_overlayEntry!);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace?.autocomplete.get(value);
    print(
        '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$value>>>>>>>>>>>>>>>>>>>>>>${result?.predictions}');
    if (result != null && result.predictions != null && mounted) {
      Overlay.of(context)?.setState(() {
        predictions = result.predictions!;
      });
    }
  }

  Widget _buildPlacesOverlay() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: predictions.length,
        itemBuilder: (context, index) {
          return IntrinsicHeight(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: appTheme.primaryColor,
                child: Icon(
                  Icons.pin_drop,
                  color: Colors.white,
                ),
              ),
              title: Text(predictions[index].description ?? ''),
              onTap: () async {
                print(predictions[index]);
                _postStore.setAddress(predictions[index].description ?? '');
                widget.addressController.text =
                    predictions[index].description ?? '';
                widget.locationResult =
                await getDetails(predictions[index].placeId ?? '');
                print(widget.locationResult);
                _postStore.latLng = widget.locationResult;
                _overlayEntry?.remove();
                _overlayShown = false;
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: this._layerLink,
      child: TextFieldWidget(
        maxLines: 1,
        enabled: true,
        textInputFormatter:
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z,/#]")),
        focusNode: _addressFocusNode,
        hint: Strings.enter_address,
        inputType: TextInputType.name,
        textController: widget.addressController,
        autoFocus: false,
        onChanged: (value) {
          _postStore.setAddress(widget.addressController.text);
          if (value.isNotEmpty) {
            autoCompleteSearch(value);
            if (!_overlayShown) {
              _showOverlay(context);
            }
          } else {
            if (predictions.length > 0 && mounted) {
              setState(() {
                predictions = [];
                _overlayEntry?.remove();
                _overlayShown = false;
              });
            }
          }
        },
        validator: (value) {
          _postStore.validateAddress(value);
        },
        onFieldSubmitted: (value) {
          if (_overlayEntry != null) {
            _overlayEntry?.remove();
            _overlayShown = false;
          }
        },
        maxLength: 200,
        errorText:
        widget.validateAddress ? _postStore.postErrorStore.address : null,
        margin: EdgeInsets.only(
          left: 5,
          top: 8,
          bottom: 0,
          right: 5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressFocusNode.dispose();
    super.dispose();
  }
}
