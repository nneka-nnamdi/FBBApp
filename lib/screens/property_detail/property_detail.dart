import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/app_utils.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/enums.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/models/asset_file/asset_file.dart';
import 'package:fight_blight_bmore/models/tags_model.dart';
import 'package:fight_blight_bmore/screens/create_post/tag_list.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:fight_blight_bmore/utils/map_utils.dart';
import 'package:fight_blight_bmore/widgets/gallery_widget.dart';
import 'package:fight_blight_bmore/widgets/launch_camera.dart';
import 'package:fight_blight_bmore/widgets/loader_widget.dart';
import 'package:fight_blight_bmore/widgets/rounded_button_widget.dart';
import 'package:fight_blight_bmore/widgets/textfield_widget.dart';
import 'package:fight_blight_bmore/widgets/video_player.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:page_indicator/page_indicator.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyDetailScreen extends StatefulWidget {
  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  AppTheme appTheme = AppTheme.light();
  PostStore _postStore = PostStore();
  UserStore _userStore = UserStore();
  late Future propertyDetailFuture;
  final _formKey = GlobalKey<FormState>();
  final _flagKey = GlobalKey<FormState>();
  int propertyId = 0;
  List<TagModel> arrayTags = [];
  List<TagModel> selectedArrayTags = [];
  bool commentPressed = true;
  bool isFocus = false;
  bool isSelected = false;
  String selectedEviction = '';
  bool isEvictionReported = false;

  var arraySubmenu = [
    'Add Photo',
    'Add Video',
    'Add Tag',
    'Add Comment',
    'Bookmark Post',
    'Share Post',
    'Flag Post',
  ];
  PageController _controller = PageController(
    initialPage: 0,
  );

  TextEditingController _commentController = TextEditingController();
  TextEditingController _flagController = TextEditingController();
  FocusNode _focus = new FocusNode();
  FocusNode _flagFocusNode = FocusNode();
  bool _validateComment = false;
  bool _validateFlag = false;
  bool isSelectionOpen = false;

  // Custom marker icon
  gm.BitmapDescriptor? icon;

  //Google maps
  Completer<gm.GoogleMapController> mapController = Completer();

  @override
  void initState() {
    super.initState();
    print('initState');
    _focus.addListener(() {
      print('focus being called');
      if (_focus.hasFocus) setState(() {});
    });
  }

  @override
  didChangeDependencies() {
    print('didChangeDependencies');
    propertyId = ModalRoute.of(context)?.settings.arguments as int;
    propertyDetailFuture = _postStore.getPropertyDetail(propertyId, _userStore);
    super.didChangeDependencies();
  }

  _setupTagsView() {
    arrayTags = arrayTags.map((e) {
      if (_postStore.propertyDetails['tags'].contains(e.id)) {
        e.isSaved = true;
        e.isSelected = true;
      }
      return e;
    }).toList();
    selectedArrayTags = arrayTags
        .where((element) => element.isSelected && element.isSaved)
        .toList();
    print(selectedArrayTags);
  }

  void _onMapCreated(gm.GoogleMapController controller) {
    mapController.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    _postStore.context = context;
    print('build');
    return Observer(
      builder: (context) {
        return LoaderWidget(
          state: _postStore.loading,
          child: FutureBuilder(
            future: propertyDetailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                _postStore.propertyDetails =
                    snapshot.data as Map<String, dynamic>;
                _postStore.media = _postStore.propertyDetails['media'];
                isEvictionReported =
                    _postStore.propertyDetails['is_evicted'] ?? false;
                selectedEviction =
                    _postStore.propertyDetails['eviction_type'] ?? '';
                if (arrayTags.isEmpty) {
                  arrayTags = _postStore.arrayTags;
                  _setupTagsView();
                }
                return Scaffold(
                  appBar: _buildAppBar(),
                  body: _buildBody(),
                );
              }
              return Container();
            },
          ),
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
        _postStore.propertyDetails['name'] ?? '',
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
      actions: [
        _buildPopupMenuButton(),
      ],
    );
  }

  PopupMenuButton<String> _buildPopupMenuButton() {
    BuildContext? ctxt;
    return PopupMenuButton<String>(
      elevation: 4,
      offset: Offset(0, 35),
      shape: OutlineInputBorder(
          borderSide: BorderSide(
        color: appTheme.primaryColor,
        width: 2,
      )),
      onSelected: (value) async {
        print('value selected: $value');
        await _onSelectPopMenuItem(ctxt!, value);
      },
      icon: Icon(
        Icons.more_horiz,
        color: appTheme.primaryColor,
        size: 35,
      ),
      itemBuilder: (BuildContext ctx) {
        ctxt = ctx;
        return arraySubmenu.map((option) {
          return PopupMenuItem<String>(
            height: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option,
                  style: normalTextStyle(
                    14,
                    color: appTheme.primaryColor,
                    fontFamily: FontFamily.sfProText,
                  ),
                ),
                Divider(
                  thickness: 2,
                  color:
                      option != 'Flag Post' ? appTheme.greyColor : Colors.white,
                ),
              ],
            ),
            value: option,
          );
        }).toList();
      },
    );
  }

  _onSelectPopMenuItem(BuildContext ctx, String value) async {
    FocusScope.of(ctx).requestFocus(new FocusNode());
    switch (value) {
      case 'Add Photo':
        if (checkMediaCount()['imgCount'] < 4) {
          _showActionSheet(ctx, 0);
        } else {
          _showErrorDialog(Strings.maxPhotoUploads, false);
        }
        break;
      case 'Add Video':
        if (checkMediaCount()['vidCount'] < 1) {
          _showActionSheet(ctx, 1);
        } else {
          _showErrorDialog(Strings.maxVideoUploads, false);
        }
        break;
      case 'Add Tag':
        _addTags(context);
        break;
      case 'Add Comment':
        setState(() {
          commentPressed = true;
        });
        _focus.requestFocus();
        break;
      case 'Bookmark Post':
        if (_userStore.profileData['user_id'] !=
            _postStore.propertyDetails['user_id']) {
          await _bookmarkPost();
        }
        break;
      case 'Share Post':
        _onShare(ctx);
        break;
      case 'Flag Post':
        await _showFlagPopup(ctx);
        break;
    }
  }

  void _onShare(BuildContext context) async {
    var linkToShare = await _createDynamicLink(true);
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
        'I am using the FBB app to report blight at ${_postStore.propertyDetails['address']}.\nJoin me in reporting Bmore blight by downloading the FBB app. $linkToShare',
        subject: 'Bmore blight is being reported with the FBB App.',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  Future<Uri> _createDynamicLink(bool short) async {
    final settings = await getFlavorSettings();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://${settings.dynamicLinkDomain}',
      link: Uri.parse(settings.url.replaceAll(
          '?email=', '?property_id=$propertyId&mode=propertyDetail')),
      androidParameters: AndroidParameters(
        packageName: settings.androidPackageName,
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: settings.iOSBundleId,
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }
    return url;
  }

  Widget _buildBody() {
    return Observer(builder: (context) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildPageControlView(),
                _buildBookmarkView(),
              ],
            ),
            _buildCreatedAt(),
            _buildDescription(),
            _buildMapView(),
            _buildAddress(),
            _buildNeighborhoodTitle(),
            _postStore.propertyDetails['neighborhood'].isEmpty
                ? Container()
                : _buildNeighborhood(),
            _buildEvictionButton(),
            _buildTagsView(),
            _buildCommentHistoryView(),
            commentPressed ? _buildCommentView() : _buildHistoryView(),
          ],
        ),
      );
    });
  }

  Widget _buildMapView() {
    return Observer(builder: (context) {
      return Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.35,
        child: Stack(children: [
          gm.GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: false,
            initialCameraPosition: gm.CameraPosition(
              target: gm.LatLng(_postStore.propertyDetails['latitude'],
                  _postStore.propertyDetails['longitude']),
              zoom: 14.0,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: TextButton(
              onPressed: () {
                MapUtils.openMap(_postStore.propertyDetails['latitude'],
                    _postStore.propertyDetails['longitude']);
              },
              child: Container(
                width: 60,
                height: 30,
              ),
            ),
          )
        ]),
      );
    });
  }

  Widget _buildPageControlView() {
    return Observer(
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 0.75,
          child: PageIndicatorContainer(
            align: IndicatorAlign.bottom,
            indicatorSpace: 10.0,
            padding: const EdgeInsets.all(10),
            indicatorColor: appTheme.greyColor,
            indicatorSelectorColor: appTheme.primaryColor,
            shape: IndicatorShape.circle(size: 12),
            length: _postStore.media.length,
            child: PageView(
              controller: _controller,
              children: List.generate(_postStore.media.length, (index) {
                return _setPageImage(_postStore.media[index]);
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarkView() {
    return Observer(builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.78,
        padding: EdgeInsets.only(right: 10),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: isEvictionReported,
                child: Container(
                  width: 30,
                  child: isEvictionReported
                      ? Image.asset(
                          Assets.evicted,
                          scale: 1,
                        )
                      : Container(),
                ),
              ),
              Container(
                width: 40,
                child: TextButton(
                  onPressed: () async {
                    if (!(_postStore.propertyDetails['tree_plantation'] ??
                        false)) {
                      SharedPreferences.getInstance().then((prefs) async {
                        bool? noPopup =
                            prefs.getBool(Preferences.showTreePopup);
                        if (noPopup ?? false) {
                          setState(() {
                            _postStore.propertyDetails['tree_plantation'] =
                                true;
                          });
                          await _postStore.updateTreePlantation(
                              _postStore.propertyDetails['tree_plantation']);
                        } else {
                          await _showTreePopup();
                        }
                      });
                    }
                  },
                  child: _postStore.propertyDetails['tree_plantation']
                      ? Image.asset(Assets.tree)
                      : Image.asset(Assets.tree_grey),
                ),
              ),
              Container(
                width: 40,
                child: TextButton(
                  onPressed: () async {
                    if (_userStore.profileData['user_id'] !=
                        _postStore.propertyDetails['user_id']) {
                      await _bookmarkPost();
                    }
                  },
                  child: FutureBuilder(
                    future:
                        ifBookMarked(_postStore.propertyDetails['property_id']),
                    builder: (context, snapshot) {
                      print(snapshot.data);
                      return (snapshot.data as bool? ?? false)
                          ? Image.asset(Assets.selectedBookmark)
                          : Image.asset(Assets.remove_bookmark);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  ifBookMarked(int propertyId) async {
    await _userStore.getBookmarksFlaggedProperties();
    var bookmarkList = (_userStore.bookmarks
            .where((e) => e['property_id'] == propertyId && e['is_bookmarked']))
        .toList();
    print('checked bookmark ${bookmarkList.isNotEmpty}');
    return bookmarkList.isNotEmpty;
  }

  Future<void> _bookmarkPost() async {
    print(_userStore.bookmarks);
    var result = _userStore.bookmarks
        .where((e) =>
            e['property_id'] == _postStore.propertyDetails['property_id'])
        .toList();
    if (result.length > 0) {
      await _userStore
          .removeBookMark(_postStore.propertyDetails['property_id']);
    } else {
      await _userStore.addBookMark(
          _postStore.propertyDetails['property_id'], _postStore.documentId);
    }
    setState(() {});
  }

  _buildCreatedAt() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        getElapsedTime(_postStore.propertyDetails['created_at'] ?? 0),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: normalTextStyle(12,
            fontFamily: FontFamily.sfProText, color: appTheme.tagColor),
      ),
    );
  }

  _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        _postStore.propertyDetails['description'] ?? '',
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: normalTextStyle(14,
            fontFamily: FontFamily.sfProText, color: appTheme.textColor),
      ),
    );
  }

  _buildAddress() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        _postStore.propertyDetails['address'] ?? '',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: normalTextStyle(14,
            fontFamily: FontFamily.sfProText, color: appTheme.textColor),
      ),
    );
  }

  _buildNeighborhoodTitle() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        'Neighborhood',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: normalTextStyle(14,
            fontFamily: FontFamily.sfProText, color: appTheme.tagColor),
      ),
    );
  }

  _buildNeighborhood() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        _postStore.propertyDetails['neighborhood'],
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: normalTextStyle(14,
            fontFamily: FontFamily.sfProText, color: appTheme.textColor),
      ),
    );
  }

  TextButton _buildEvictionButton() {
    return TextButton(
        onPressed: () async {
          if (!isEvictionReported) {
            await _showEvictionOptionsPopup();
          }
        },
        child: Text(
          isEvictionReported
              ? Strings.evictionReported
              : Strings.clickForEviction,
          style: normalTextStyle(15,
              fontFamily: FontFamily.sfProText, color: appTheme.darkRedColor),
        ));
  }

  Widget _buildTagsView() {
    return Observer(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 0),
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            InkWell(
              onTap: () async {
                await _addTags(context);
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
                    Assets.forward_grey,
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

  Future<void> _addTags(BuildContext context) async {
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
      print("tags-----$value");
      if (value != null) {
        setState(() {
          arrayTags = value as List<TagModel>;
          selectedArrayTags = arrayTags
              .where((element) => element.isSelected && element.isSaved)
              .toList();
        });
        _postStore.setTags(selectedArrayTags);
        _postStore.updateTags();
      }
    });
  }

  _buildCommentHistoryView() {
    return Observer(
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.47,
                child: Column(children: [
                  TextButton(
                      onPressed: () {
                        setState(() => commentPressed = true);
                      },
                      child: Text('Comments')),
                  commentPressed
                      ? Divider(
                          color: appTheme.primaryColor,
                          thickness: 4,
                        )
                      : Container(),
                ]),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.47,
                child: Column(children: [
                  TextButton(
                    onPressed: () {
                      setState(() => commentPressed = false);
                    },
                    child: Text('History'),
                  ),
                  !commentPressed
                      ? Divider(
                          color: appTheme.primaryColor,
                          thickness: 4,
                        )
                      : Container(),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildCommentView() {
    return Observer(
      builder: (context) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 5, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCommentField()),
                  Visibility(
                    child: _buildPostCommentButton(),
                    visible: _focus.hasFocus,
                  )
                ],
              ),
            ),
            _buildCommentList(),
          ],
        );
      },
    );
  }

  Widget _buildCommentField() {
    return Observer(builder: (context) {
      return Form(
        key: _formKey,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65,
          child: TextFieldWidget(
            hint: Strings.add_comment,
            inputType: TextInputType.text,
            textController: _commentController,
            autoFocus: false,
            focusNode: _focus,
            textInputFormatter:
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
            onChanged: (value) {
              _postStore.setComment(_commentController.text);
            },
            validator: (value) {
              _postStore.validateComment(value);
            },
            onFieldSubmitted: (value) {
              if (value.isEmpty) {
                _validateComment = false;
              }
              setState(() {});
            },
            maxLength: 200,
            errorText:
                _validateComment ? _postStore.postErrorStore.comment : null,
            margin: EdgeInsets.all(0),
          ),
        ),
      );
    });
  }

  Widget _buildPostCommentButton() {
    return RoundedButtonWidget(
      width: MediaQuery.of(context).size.width * 0.18,
      padding: EdgeInsets.only(left: 10),
      buttonText: Strings.post,
      textSize: 16,
      align: Alignment.centerLeft,
      buttonColor: appTheme.primaryColor,
      textColor: Colors.white,
      onPressed: () async {
        print('Post comment now if not empty');
        if (_formKey.currentState!.validate()) {
          setState(() {
            _validateComment = true;
          });
          if (_commentController.text.isNotEmpty) {
            FocusScope.of(_formKey.currentState!.context).unfocus();
            await _showErrorDialog(Strings.warnAddComment, true);
          } else {}
        }
      },
    );
  }

  Widget _buildCommentList() {
    print(_postStore.propertyDetails['comments']);
    return Container(
      height: _commentListHeight(),
      child: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: _postStore.propertyDetails['comments']?.length ?? 0,
          itemBuilder: (context, index) {
            List comments = _postStore.propertyDetails['comments'];
            print(comments);
            comments.sort((a, b) => b['created_at'].compareTo(a['created_at']));
            return SizedBox(
              child: FutureBuilder(
                  future: comments[index]['user'].get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic>? commentData =
                          (snapshot.data as DocumentSnapshot).data()
                              as Map<String, dynamic>?;
                      print('CommentData: ${commentData?.toString()}');
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(19.0),
                          child: Container(
                            color: Colors.grey,
                            child: commentData == null
                                ? Image.asset(
                                    Assets.dummy_profile,
                                    width: 38,
                                    height: 38,
                                  )
                                : Image.network(
                                    commentData['profile_image'] ?? '',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              Text(
                                commentData?['username'] ?? '',
                                style: boldTextStyle(16,
                                    fontFamily: FontFamily.sfProText,
                                    color: appTheme.textColor),
                              ),
                              Spacer(),
                              Text(
                                getElapsedTime(comments[index]['created_at']),
                                style: normalTextStyle(12,
                                    fontFamily: FontFamily.sfProText,
                                    color: appTheme.tagColor),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Text(
                            comments[index]['comment'],
                            style: normalTextStyle(
                              13,
                              fontFamily: FontFamily.sfProText,
                              color: appTheme.textColor,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
            );
          }),
    );
  }

  double _commentListHeight() {
    if (_postStore.propertyDetails['comments'] == null ||
        _postStore.propertyDetails['comments'].length == 0) {
      return 0;
    } else if (_postStore.propertyDetails['comments'].length == 1) {
      return 100;
    } else
      return 200;
  }

  _buildHistoryView() {
    return Container(
      height: 30,
    );
  }

//general methods---------------------------------------------------------------

  Widget _setPageImage(Map<String, dynamic> media) {
    if (media['mediaUrl'] == null) {
      return Container();
    }
    String data = media['mediaUrl'];

    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 30),
          child: Image.network(
            data.contains('png') ? data : media['thumbnail'] ?? '',
            fit: BoxFit.fitWidth,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: data.contains('png')
              ? Container()
              : InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(pathUrl: data)));
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.26,
                      child: Image.asset(Assets.play)),
                ),
        ),
      ],
    );
  }

  Future<void> _showErrorDialog(String errorMessage, bool showButtons) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Container(
            height: 80,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 50,
                    height: 50,
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
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: normalTextStyle(16,
                color: showButtons ? appTheme.textColor : appTheme.redColor),
          ),
          actions: showButtons
              ? [
                  Container(
                    padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            child: Text(
                              Strings.no,
                              style: TextStyle(color: appTheme.darkGreyColor),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text(Strings.yes),
                            onPressed: () async {
                              await _postStore
                                  .addComment(_commentController.text);
                              _commentController.clear();
                              Navigator.of(ctx).pop();
                              setState(() => _validateComment = false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : [],
        );
      },
    );
  }

  Future<void> _showActionSheet(BuildContext contxt, int type) {
    return showCupertinoModalPopup<void>(
      context: contxt,
      builder: (BuildContext ctx) => CupertinoActionSheet(
        title: Text(Strings.titleActionSheet),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
              child: Text(
                type == 0 ? Strings.takePhoto : Strings.takeVideo, //#0A84FF
                style: normalTextStyle(20,
                    fontFamily: FontFamily.sfProDisplay,
                    color: appTheme.blueColor),
              ),
              onPressed: () async {
                _postStore.loading = true;
                var result = await Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => LaunchScreen(type)),
                );
                Navigator.of(ctx).pop();
                await _uploadMedia(result);
              }),
          CupertinoActionSheetAction(
            child: Text(
              Strings.photoLibrary,
              style: normalTextStyle(20,
                  fontFamily: FontFamily.sfProDisplay,
                  color: appTheme.blueColor),
            ),
            onPressed: () async {
              var result = await Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => Gallery()),
              );
              Navigator.of(ctx).pop();
              await _uploadMedia(result);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            Strings.cancel,
            style: normalTextStyle(20,
                fontFamily: FontFamily.sfProDisplay, color: appTheme.redColor),
          ),
          onPressed: () {
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  checkMediaCount() {
    var vidCount = _postStore.media
        .where((element) {
          print(element);
          return element['mediaUrl']?.contains('mp4') ?? false;
        })
        .toList()
        .length;
    print(vidCount);
    var imgCount = _postStore.media
        .where((element) => element['mediaUrl']?.contains('png') ?? false)
        .toList()
        .length;
    print(imgCount);
    return {'imgCount': imgCount, 'vidCount': vidCount};
  }

  Future<void> _uploadMedia(result) async {
    setState(() {
      _postStore.loading = true;
    });
    var isPlaceholder = _postStore.media
        .where(
            (element) => element['mediaUrl']?.contains('placeholder') ?? false)
        .toList();
    if (isPlaceholder.length > 0) {
      await _postStore.removePlaceholderImage();
      propertyDetailFuture =
          _postStore.getPropertyDetail(propertyId, _userStore);
      // setState(() {});
    }
    var mediaCount = checkMediaCount();
    var imgCount = mediaCount['imgCount'];
    var vidCount = mediaCount['vidCount'];

    if (result != null) {
      if (result.type == AssetType.video && vidCount > 0) {
        _showErrorDialog(Strings.maxVideoUploads, false);
        return;
      } else if (result.type == AssetType.image && imgCount > 3) {
        _showErrorDialog(Strings.maxPhotoUploads, false);
        return;
      }
      _postStore.imageVideoList.add(result);
      if ((result as AssetFile).path == null) {
        result.type == AssetType.video
            ? await _postStore.uploadVideo(result.file!.path)
            : await _postStore.uploadImage(result.file!.path);
      } else {
        result.type == AssetType.video
            ? await _postStore.uploadVideo(result.path!)
            : await _postStore.uploadImage(result.path!);
      }
      await _postStore.addMedia();
      _postStore.loading = false;
      setState(() {});
    }
  }

  Future<void> _showTreePopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctx) {
        return AlertDialog(
          elevation: 20.0,
          title: Container(
            height: 110,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 60,
                    height: 60,
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
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: StatefulBuilder(builder: (ctxt, changeState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    Strings.warnRequestTree,
                    textAlign: TextAlign.center,
                    style:
                        normalTextStyle(16, fontFamily: FontFamily.sfProText),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: OutlinedButton(
                            onPressed: () {
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setBool(
                                    Preferences.showTreePopup, isSelected);
                              });
                              Navigator.of(ctxt).pop();
                            },
                            child: Text(
                              Strings.no,
                              style: normalTextStyle(16,
                                  fontFamily: FontFamily.sfProDisplay,
                                  color: appTheme.tagColor),
                            )),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool(
                                Preferences.showTreePopup, isSelected);
                          });
                          if (!(_postStore.propertyDetails['tree_plantation'] ??
                              false)) {
                            await _postStore.updateTreePlantation(true);
                          }
                          _postStore.propertyDetails['tree_plantation'] = true;
                          setState(() {
                            Navigator.of(ctxt).pop();
                          });
                        },
                        child: Text(Strings.yes,
                            style: normalTextStyle(16,
                                fontFamily: FontFamily.sfProDisplay,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          primary: appTheme.primaryColor,
                          fixedSize: Size(100, 40),
                        ),
                      )
                    ],
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 30,
                          child: TextButton(
                              onPressed: () {
                                changeState(() {
                                  isSelected = !isSelected;
                                });
                              },
                              child: Image.asset(
                                isSelected
                                    ? Assets.checkedBox
                                    : Assets.emptyBox,
                                fit: BoxFit.fill,
                              )),
                        ),
                        Text(
                          Strings.dontShowMessage,
                          textAlign: TextAlign.center,
                          style: normalTextStyle(12,
                              fontFamily: FontFamily.sfProText,
                              color: appTheme.tagColor),
                        ),
                      ]),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _showFlagPopup(BuildContext buildCtx) async {
    _postStore.setFlagReason('');
    _validateFlag = false;
    return showDialog<void>(
      context: buildCtx,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctxt) {
        return AlertDialog(
          elevation: 20.0,
          title: Container(
            width: MediaQuery.of(ctxt).size.width - 20,
            height: 110,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 60,
                    height: 60,
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
                        _flagController.clear();
                        Navigator.of(ctxt).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: StatefulBuilder(builder: (ctext, changeState) {
            return Form(
              key: _flagKey,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      Strings.warnFlagPost,
                      textAlign: TextAlign.center,
                      style: normalTextStyle(14,
                          fontFamily: FontFamily.sfProText,
                          color: appTheme.redColor),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 140,
                      child: TextFieldWidget(
                        borderColor: Colors.red,
                        hint: 'Reason',
                        focusNode: _flagFocusNode,
                        inputType: TextInputType.text,
                        textController: _flagController,
                        autoFocus: false,
                        minLines: 5,
                        maxLines: 5,
                        textInputFormatter: FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z0-9]")),
                        onChanged: (value) {
                          print(_validateFlag);
                          _postStore.setFlagReason(value);
                          if (value.isEmpty) {
                            _validateFlag = false;
                          } else {
                            _validateFlag = true;
                          }
                          // });
                        },
                        validator: (value) {
                          _postStore.validateFlagReason(value);
                        },
                        maxLength: 200,
                        errorText: _validateFlag
                            ? _postStore.postErrorStore.flagReason
                            : null,
                        margin: EdgeInsets.all(15),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: OutlinedButton(
                              onPressed: () {
                                _flagController.clear();
                                Navigator.of(ctext).pop();
                              },
                              child: Text(
                                Strings.cancel,
                                style: normalTextStyle(16,
                                    fontFamily: FontFamily.sfProDisplay,
                                    color: appTheme.textColor),
                              )),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_flagKey.currentState!.validate()) {
                              changeState(() {
                                _validateFlag = true;
                              });
                            }
                            if (_flagController.text.isNotEmpty) {
                              changeState(() {
                                _validateFlag = false;
                              });
                              await _postStore.flagPost();
                              Navigator.of(ctext).pop();
                              _flagController.clear();
                              _showFlagSuccessPopup();
                            }
                          },
                          child: Text(Strings.flag,
                              style: normalTextStyle(16,
                                  fontFamily: FontFamily.sfProDisplay,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            primary: appTheme.redColor,
                            fixedSize: Size(100, 40),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _showFlagSuccessPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctx) {
        return AlertDialog(
          elevation: 20.0,
          title: Container(
            height: 110,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 60,
                    height: 60,
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
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: StatefulBuilder(builder: (ctx, setState) {
            return SingleChildScrollView(
              child: ListBody(children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  Strings.successFlaggedProperty,
                  textAlign: TextAlign.center,
                  style: normalTextStyle(14,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.textColor),
                ),
                SizedBox(
                  height: 20,
                ),
              ]),
            );
          }),
        );
      },
    );
  }

  Future<void> _showEvictionOptionsPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctx) {
        return AlertDialog(
          elevation: 20.0,
          title: Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(Strings.reportEviction,
                      style: semiBoldTextStyle(17,
                          fontFamily: FontFamily.sfProText,
                          color: appTheme.primaryColor)),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    child: TextButton(
                      child: Image.asset(
                        Assets.close,
                        scale: 2,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: StatefulBuilder(builder: (ctxt, changeState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    Strings.infoEviction,
                    textAlign: TextAlign.center,
                    style:
                        normalTextStyle(15, fontFamily: FontFamily.sfProText),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _buildEvictionOption(EvictionType.witness, changeState),
                  _buildEvictionOption(EvictionType.resident, changeState),
                  _buildEvictionOption(EvictionType.sheriff, changeState),
                  _buildEvictionOption(EvictionType.propertyOwner, changeState),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedEviction.isNotEmpty) {
                            Navigator.of(ctx).pop();
                            await _showEvictionSuccessPopup();
                          }
                        },
                        child: Text(
                          Strings.reportEviction,
                          style: normalTextStyle(18,
                              fontFamily: FontFamily.sfProDisplay,
                              color: Colors.white),
                        ),
                      )),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildEvictionOption(String type, Function changeState) {
    return InkWell(
      onTap: () {
        print(type);
        changeState(() {
          selectedEviction = type;
        });
      },
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.only(left: 12),
        child: Row(
          children: [
            SizedBox(
              child: Image.asset(selectedEviction == type
                  ? Assets.selected_radio
                  : Assets.unselected_radio),
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Report as $type',
                style: normalTextStyle(
                  15,
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

  Future<void> _showEvictionSuccessPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext ctx) {
        return AlertDialog(
          elevation: 20.0,
          title: Container(
            height: 180,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: Image.asset(Assets.evictionSymbol),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 50,
                    child: TextButton(
                      child: Image.asset(
                        Assets.close,
                        scale: 1,
                      ),
                      onPressed: () async {
                        isEvictionReported = true;
                        await _postStore.updateEviction(
                            isEvictionReported, selectedEviction);
                        propertyDetailFuture = _postStore.getPropertyDetail(
                            propertyId, _userStore);
                        setState(() {});
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: StatefulBuilder(builder: (ctx, setState) {
            return SingleChildScrollView(
              child: ListBody(children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Text(
                  Strings.doorWindowBroken,
                  textAlign: TextAlign.center,
                  style: semiBoldTextStyle(17,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.primaryColor),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  Strings.evictionReported2,
                  textAlign: TextAlign.center,
                  style: normalTextStyle(15,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.tagColor),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  Strings.thanksFbb,
                  textAlign: TextAlign.center,
                  style: normalTextStyle(15,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.tagColor),
                ),
              ]),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }
}
