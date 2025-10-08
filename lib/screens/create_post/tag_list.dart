import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/models/tags_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagListScreen extends StatefulWidget {
  @override
  _TagListScreenState createState() => _TagListScreenState();
}

class _TagListScreenState extends State<TagListScreen> {
  AppTheme appTheme = AppTheme.light();
  ThemeData themeData = AppTheme.light().buildThemeData();

  List<TagModel> arrayTags = [];
  bool isSelected = false;

  int getSelectedTags() {
    var selectedTags = arrayTags.where((e) {
      return e.isSelected && !e.isSaved;
    }).toList();
    return selectedTags.length;
  }

  Future<void> _saveTags() async {
    if (getSelectedTags() > 0) {
      SharedPreferences.getInstance().then((prefs) async {
        bool? noPopup = prefs.getBool(Preferences.showTagsPopup);
        if (noPopup ?? false) {
          for (TagModel tag in arrayTags) {
            tag.isSaved = tag.isSelected;
          }
          print(arrayTags.where((element) => element.isSaved));
          Navigator.pop(context, arrayTags);
        } else {
          await _showMyDialog();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    arrayTags = ModalRoute.of(context)?.settings.arguments as List<TagModel>;
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
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
        Strings.post_tags,
        style: semiBoldTextStyle(16,
            fontFamily: FontFamily.sfProDisplay, color: Colors.black),
      ),
      leading: Padding(
          padding: EdgeInsets.all(10.0),
          child: TextButton(
            onPressed: () {
              for (TagModel tag in arrayTags) {
                if (!tag.isSaved) {
                  tag.isSelected = false;
                }
              }
              Navigator.of(context).pop();
            },
            child: Image.asset(Assets.back),
          )),
      actions: [
        Padding(
            padding: EdgeInsets.only(
              right: 10.0,
            ),
            child: TextButton(
              onPressed: () async {
                await _saveTags();
              },
              child: Text(
                Strings.saveTags,
                style: normalTextStyle(16,
                    color: getSelectedTags() > 0
                        ? appTheme.greenColor
                        : appTheme.darkGreyColor),
              ),
            )),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 17.0),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            Strings.titleTags,
            style: normalTextStyle(
              18,
              fontFamily: FontFamily.sfProText,
              color: appTheme.hintColor,
            ),
          ),
        ),
       _buildList(),
      ],
    );
  }

  Widget _buildList() {
    return Observer(builder: (context) {
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return Column(
              children: [
                Divider(
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      bool alreadySelected =
                          arrayTags[index].isSaved && arrayTags[index].isSelected;
                      if (!alreadySelected) {
                        arrayTags[index].isSelected =
                        !arrayTags[index].isSelected;
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 35),
                                  child: Text(arrayTags[index].title,
                                      style: normalTextStyle(16,
                                          fontFamily: FontFamily.sfProText,
                                          color: appTheme.textColor)),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                arrayTags[index].subtitle != ''
                                    ? Padding(
                                  padding: const EdgeInsets.only(right: 35),
                                  child: Text(arrayTags[index].subtitle,
                                      style: normalTextStyle(12,
                                          fontFamily: FontFamily.sfProText,
                                          color: appTheme.textColor)),
                                )
                                    : Container(),
                              ]),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildImageCheck(index),
                        ),
                      ],
                    ),
                  ),
                ),
                arrayTags.length == index + 1
                    ? _buildBottomButtons()
                    : Container()
              ],
            );
          },
          itemCount: arrayTags.length,
        ),
      );
    });
  }

  Widget _buildBottomButtons() {
    return Observer(
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Column(children: [
            Divider(
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text(
                    Strings.cancel,
                    style: normalTextStyle(18,
                        fontFamily: FontFamily.sfProText,
                        color: appTheme.redColor),
                  ),
                  onPressed: () {
                    for (TagModel tag in arrayTags) {
                      if (!tag.isSaved) {
                        tag.isSelected = false;
                      }
                    }
                    Navigator.of(context).pop();
                  },
                ),
                Container(
                    height: 60,
                    child: VerticalDivider(color: appTheme.textColor)),
                TextButton(
                  child: Text(
                    Strings.saveTags,
                    style: normalTextStyle(18,
                        fontFamily: FontFamily.sfProText,
                        color: getSelectedTags() > 0
                            ? appTheme.greenColor
                            : appTheme.darkGreyColor),
                  ),
                  onPressed: () async {
                    await _saveTags();
                  },
                ),
              ],
            ),
          ]),
        );
      },
    );
  }

  Image _buildImageCheck(int index) {
    bool alreadySelected =
        arrayTags[index].isSaved && arrayTags[index].isSelected;
    var assetName = alreadySelected
        ? Assets.check
        : (arrayTags[index].isSelected
            ? Assets.greenTickCircle
            : Assets.add_circle);
    return Image.asset(
      assetName,
      height: 30,
    );
  }

  Future<void> _showMyDialog() async {
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
          content: StatefulBuilder(builder: (ctx, setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    Strings.warnSaveTags,
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
                                    Preferences.showTagsPopup, isSelected);
                              });
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              Strings.no,
                              style: normalTextStyle(16,
                                  fontFamily: FontFamily.sfProDisplay,
                                  color: appTheme.tagColor),
                            )),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool(
                                Preferences.showTagsPopup, isSelected);
                          });
                          for (TagModel tag in arrayTags) {
                            tag.isSaved = tag.isSelected;
                          }
                          print(arrayTags.where((element) => element.isSaved));
                          Navigator.of(ctx).pop();
                          Navigator.pop(context, arrayTags);
                        },
                        child: Text(Strings.yes,
                            style: normalTextStyle(16,
                                fontFamily: FontFamily.sfProDisplay,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          primary: appTheme.tagColor,
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
                                setState(() {
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


}
