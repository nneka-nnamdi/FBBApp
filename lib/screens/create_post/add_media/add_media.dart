import 'dart:io';

import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/models/asset_file/asset_file.dart';
import 'package:fight_blight_bmore/screens/create_post/create_post_details.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/widgets/add_image_video.dart';
import 'package:fight_blight_bmore/widgets/gallery_widget.dart';
import 'package:fight_blight_bmore/widgets/launch_camera.dart';
import 'package:fight_blight_bmore/widgets/loader_widget.dart';
import 'package:fight_blight_bmore/widgets/thumbnail_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:photo_manager/photo_manager.dart';

class AddMediaScreen extends StatefulWidget {
  @override
  _AddMediaScreenState createState() => _AddMediaScreenState();
}

class _AddMediaScreenState extends State<AddMediaScreen> {
  AppTheme appTheme = AppTheme.light();
  final PostStore _postStore = getIt<PostStore>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addPlaceholderImage();
  }

  void _addPlaceholderImage() {
    // storage reference
    if (_postStore.imageVideoList.length == 0) {
      FirebaseStorage _storage = FirebaseStorage.instance;
      Reference _placeholderReference = _storage.ref().child('placeholder.png');
      _placeholderReference.getDownloadURL().then((value) {
        _postStore.imageVideoList.add(AssetFile(
            id: UniqueKey().toString(),
            path: File(Assets.placeholderImage).path,
            type: AssetType.image,
            downloadUrl: value));
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return LoaderWidget(
        state: _postStore.loading,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(),
        ),
      );
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.4,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Color(0xFFF8F8F8),
      title: Text(
        Strings.add_media,
        textAlign: TextAlign.center,
        style: semiBoldTextStyle(16,
            fontFamily: FontFamily.sfProDisplay, color: Colors.black),
      ),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 20.0, right: 20.0),
            child: InkWell(
              onTap: () {
                if (_postStore.imageVideoList.length > 0) {
                  var vidCount = _postStore.imageVideoList
                      .where((element) => element.type == AssetType.video)
                      .toList()
                      .length;
                  var imgCount = _postStore.imageVideoList
                      .where((element) => element.type == AssetType.image)
                      .toList()
                      .length;
                  if (vidCount > 1) {
                    _showErrorDialog(Strings.maxVideoUploads);
                  } else if (imgCount > 4) {
                    _showErrorDialog(Strings.maxPhotoUploads);
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatePostDetailsScreen()));
                  }
                } else {
                  _showErrorDialog(Strings.minMedia);
                }
              },
              child: Text(
                Strings.add,
                style: normalTextStyle(16, color: appTheme.primaryColor),
              ),
            )),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(3),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          (_postStore.imageVideoList.length + 1),
          (index) {
            return _postStore.imageVideoList.length == index
                ? _postStore.imageVideoList.length < 5
                    ? InkWell(
                        child: AddImageVideo(),
                        onTap: () {
                          _showActionSheet(context);
                        },
                      )
                    : Container()
                : Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) {
                      return showDialog(
                          context: context,
                          builder: (ctx) =>
                              _buildDismissibleDialog(ctx, index));
                    },
                    onDismissed: (direction) {
                      // Remove the item from the data source.
                      setState(() {
                        _postStore.imageVideoList.removeAt(index);
                      });
                    },
                    child: ThumbnailView(
                      thumbnail: _postStore.imageVideoList[index],
                      delete: () => deleteMedia(index),
                    ),
                  );
          },
        ),
      ),
    );
  }

  deleteMedia(int index) {
    print('Deleting:  $index');
    showDialog(
        context: context,
        builder: (ctx) => _buildDismissibleDialog(ctx, index));
  }

  Widget _buildDismissibleDialog(BuildContext ctx, int index) {
    return AlertDialog(
      title: Text(Strings.areYouSure),
      content: Text(
        _postStore.imageVideoList[index].type == AssetType.image
            ? Strings.wantRemovePhoto
            : Strings.wantRemoveVideo,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(Strings.no),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
        TextButton(
          child: Text(Strings.yes),
          onPressed: () async {
            Navigator.of(ctx).pop();
            await _postStore.delete(
                _postStore.imageVideoList[index].filename ?? '', index);
            _addPlaceholderImage();
            setState(() {});
          },
        ),
      ],
    );
  }

  Future<void> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext ctx) => CupertinoActionSheet(
        title: Text(Strings.titleActionSheet),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
              child: Text(
                Strings.takePhoto, //#0A84FF
                style: normalTextStyle(20,
                    fontFamily: FontFamily.sfProDisplay,
                    color: appTheme.blueColor),
              ),
              onPressed: () async {
                var result = await Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => LaunchScreen(0)),
                );
                Navigator.of(ctx).pop();
                await _uploadMedia(result);
              }),
          CupertinoActionSheetAction(
              child: Text(
                Strings.takeVideo,
                style: normalTextStyle(20,
                    fontFamily: FontFamily.sfProDisplay,
                    color: appTheme.blueColor),
              ),
              onPressed: () async {
                var result = await Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => LaunchScreen(1)),
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

  Future<void> _uploadMedia(result) async {
    var isPlaceholder = _postStore.imageVideoList.where((element) => element.downloadUrl?.contains('placeholder') ?? false).toList();
    if (isPlaceholder.length > 0) {
      _postStore.imageVideoList.clear();
    }
    var vidCount = _postStore.imageVideoList
        .where((element) => element.type == AssetType.video)
        .toList()
        .length;
    var imgCount = _postStore.imageVideoList
        .where((element) => element.type == AssetType.image)
        .toList()
        .length;

    if (result != null) {
      if (result.type == AssetType.video && vidCount > 0) {
        _showErrorDialog(Strings.maxVideoUploads);
        return;
      } else if (result.type == AssetType.image && imgCount > 3) {
        _showErrorDialog(Strings.maxPhotoUploads);
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
      setState(() {});
    }
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
