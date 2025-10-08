import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/screens/property_detail/property_detail.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:fight_blight_bmore/widgets/loader_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkScreen extends StatefulWidget {
  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  //stores:---------------------------------------------------------------------
  final PostStore _postStore = PostStore();
  final UserStore _userStore = UserStore();

  AppTheme appTheme = AppTheme.light();
  var arrayProperties = [];

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder(
          future: _postStore.fetchBookmarkedProperties(_userStore),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print('>>>>>>>>>>${snapshot.data}');
              arrayProperties = (snapshot.data ?? []) as List;
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  elevation: 0.4,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  backgroundColor: Color(0xFFF8F8F8),
                  title: Text(
                    Strings.bookmarks,
                    style: semiBoldTextStyle(16,
                        fontFamily: FontFamily.sfProDisplay,
                        color: Colors.black),
                  ),
                  leading: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(Assets.back),
                      )),
                ),
                body: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(5),
                  child: _buildListView(),
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
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: arrayProperties.length,
      itemBuilder: (context, position) {
        return _buildListItem(position);
      },
    );
  }

  Widget _buildListItem(int position) {
    return InkWell(
      onTap: () {
        if (arrayProperties[position]['is_flagged']) {
          print('flagged property');
          _showErrorDialog(Strings.warnFlaggedProperty);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PropertyDetailScreen(),
                  settings: RouteSettings(
                      arguments: arrayProperties[position]['property_id'])));
        }
      },
      child: ListTile(
        dense: true,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.44,
                height: MediaQuery.of(context).size.width * 0.3,
                child: _setThumbnail(arrayProperties[position]['media']),
              ),
              arrayProperties[position]['is_flagged']
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.44,
                      height: MediaQuery.of(context).size.width * 0.3,
                      color: Colors.black54,
                      child: Center(
                        child: Text('Flagged',
                            style: normalTextStyle(
                              20,
                              color: Colors.white,
                              fontFamily: FontFamily.sfProText,
                            )),
                      ),
                    )
                  : Container()
            ],
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                arrayProperties[position]['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: boldTextStyle(16,
                    fontFamily: FontFamily.sfProText,
                    color: appTheme.textColor),
              ),
              Spacer(),
              Container(
                  child: Row(
                children: [
                  arrayProperties[position]['is_flagged']
                      ? Image.asset(
                          Assets.flag,
                          height: 26,
                        )
                      : Container(),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      if (_userStore.profileData['user_id'] !=
                          arrayProperties[position]['user_id']) {
                        showDialog(
                            context: context,
                            builder: (ctx) =>
                                _buildDismissibleDialog(ctx, position));
                      }
                    },
                    child: FutureBuilder(
                      future: ifBookMarked(arrayProperties[position]['property_id']),
                      builder: (context, snapshot) {
                        print(snapshot.data);
                        return ((snapshot.data as bool?)?? false) ? Image.asset(Assets.selectedBookmark, height: 26,)
                            : Container();
                      },
                    ),
                  ),
                ],
              )),
            ],
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

  Future<void> _bookmarkPost(arrayProperty) async {
    print(_userStore.profileData['bookmarks']);
    await _userStore.removeBookMark(arrayProperty['property_id']);
    setState(() {});
  }

  Widget _buildDismissibleDialog(BuildContext ctx, int position) {
    return AlertDialog(
      content: Text(
        Strings.removeBookmark,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(Strings.cancel),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
        TextButton(
          child: Text(Strings.remove),
          onPressed: () async {
            await _bookmarkPost(arrayProperties[position]);
            Navigator.of(ctx).pop();
          },
        ),
      ],
    );
  }

// General Methods:-----------------------------------------------------------

  ifBookMarked(int propertyId) async {
    await _userStore.getBookmarksFlaggedProperties();
    var bookmarkList =
    (_userStore.bookmarks.where((e) => e['property_id'] == propertyId && e['is_bookmarked'])).toList();
    print('checked bookmark ${bookmarkList.isNotEmpty}');
    return bookmarkList.isNotEmpty;
  }

  Widget _setThumbnail(List<dynamic> media) {
    print(media[0]);
    String data = media[0]['mediaUrl']!;

    return Image.network(
      data.contains('png') ? data : media[0]['thumbnail'] ?? '',
      fit: BoxFit.fitWidth,
    );
  }

  Future<void> _showErrorDialog(String errorMessage) async {
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
                    width: 70,
                    height: 70,
                    child: Image.asset(Assets.warning),
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
                        Navigator.of(context).pop();
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
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: normalTextStyle(16,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.darkRedColor),
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
}
