import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/screens/property_detail/property_detail.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/utils/device/device_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fight_blight_bmore/widgets/search_field_widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //stores:---------------------------------------------------------------------
  final PostStore _postStore = PostStore();

  AppTheme appTheme = AppTheme.light();
  var arrayProperties = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  Future _searchResult(String searchText) async {
    arrayProperties.clear();
    var result = await _postStore.searchProperties(searchText);
    print('back result $result');
    var uniquePropertyIds = result.map(
            (c) => c['property_id'])
        .toSet().toList();
    print(uniquePropertyIds);
    for (var n in uniquePropertyIds) {
      arrayProperties.add(result.where((element) => element['property_id'] == n).first);
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0.4,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Color(0xFFF8F8F8),
          title: Text(
            Strings.search,
            style: semiBoldTextStyle(16,
                fontFamily: FontFamily.sfProDisplay,
                color: Colors.black),
          ),
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              SearchFieldWidget(
                onPressed: () {
                  DeviceUtils.hideKeyboard(context);
                  _searchController.clear();
                  setState(() {
                    _searchResult('');
                  });
                },
                textController: _searchController,
                onChanged: (value) async {
                  await _searchResult(value);
                },
              ),
              Visibility(
                child: _buildListView(),
                visible: arrayProperties.length > 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: arrayProperties.length,
        itemBuilder: (context, position) {
          return _buildListItem(position);
        },
      ),
    );
  }

  Widget _buildListItem(int position) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PropertyDetailScreen(),
                settings: RouteSettings(
                    arguments: arrayProperties[position]['property_id'])));
      },
      child: ListTile(
        dense: true,
        title:
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Stack(
            children: [
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.44,
                height: MediaQuery
                    .of(context)
                    .size
                    .width * 0.3,
                child: _setThumbnail(arrayProperties[position]['media']),
              ),
            ],
          ),
          Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.44,
              height: MediaQuery
                  .of(context)
                  .size
                  .width * 0.3,
              child: AbsorbPointer(
                absorbing: true,
                child: GoogleMap(
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        arrayProperties[position]['latitude'],
                        arrayProperties[position]['longitude'],
                      ),
                      zoom: 15.0,
                    )),
              )),
        ]),
        subtitle:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 8,
          ),
          Text(
            arrayProperties[position]['name'],
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
            arrayProperties[position]['address'],
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
            getElapsedTime(arrayProperties[position]['created_at']),
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
    print(media[0]);
    String data = media[0]['mediaUrl']!;

    return Image.network(
      data.contains('png') ? data : media[0]['thumbnail'] ?? '',
      fit: BoxFit.fitWidth,
    );
  }

}
