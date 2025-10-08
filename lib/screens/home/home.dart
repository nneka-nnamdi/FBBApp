import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/screens/property_detail/property_detail.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/widgets/loader_widget.dart';
import 'package:fight_blight_bmore/widgets/top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(this.propertyId);

  final int propertyId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //stores:---------------------------------------------------------------------
  final PostStore _postStore = PostStore();

  AppTheme appTheme = AppTheme.light();
  var arrayProperties = [];
  late Future propertyListFuture;

  @override
  void initState() {
    super.initState();
    propertyListFuture = _postStore.getProperties();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.propertyId > 0) {
      Future.delayed(Duration(seconds: 2), () {
        _navigateToProductDetailPage(widget.propertyId);
      });
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder(
          future: _postStore.getProperties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              arrayProperties = (snapshot.data ?? []) as List;
              return Scaffold(
                body: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBar(),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Recent Community Posts',
                          style: normalTextStyle(20,
                              fontFamily: FontFamily.sfProDisplay,
                              color: appTheme.tagColor),
                        ),
                      ),
                      _buildListView(),
                    ],
                  ),
                ),
              );
            } else {
              return LoaderWidget(
                state: _postStore.loading,
                child: Container(
                  color: Colors.white,
                ),
              );
            }
          }),
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
        _navigateToProductDetailPage(arrayProperties[position]['property_id']);
      },
      child: ListTile(
        dense: true,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.44,
            height: MediaQuery.of(context).size.width * 0.3,
            child: _setThumbnail(arrayProperties[position]['media']),
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.44,
              height: MediaQuery.of(context).size.width * 0.3,
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

  void _navigateToProductDetailPage(int propertyId) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PropertyDetailScreen(),
                settings: RouteSettings(arguments: propertyId)))
        .then((value) => setState(() {}));
  }

// General Methods:-----------------------------------------------------------

  Widget _setThumbnail(List<dynamic> media) {
    String data = media[0]['mediaUrl'] ?? '';

    return Image.network(
      data.contains('png') ? data : media[0]['thumbnail'] ?? '',
      fit: BoxFit.fitWidth,
    );
  }
}
