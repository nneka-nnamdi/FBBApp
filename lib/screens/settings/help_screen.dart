import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/models/static_pages_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  AppTheme appTheme = AppTheme.light();
  List<StaticPagesModel> arrayHelpList = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.4,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Color(0xFFF8F8F8),
      title: Text(
        Strings.helpHeading,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(3),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Frequently Asked Questions',
                style: semiBoldTextStyle(20,
                    fontFamily: FontFamily.sfProDisplay,
                    color: appTheme.textColor),
              ),
            ),
            _buildListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: arrayHelpList.length,
        itemBuilder: (ctx, index) {
          return _buildSettingsButton(index);
        },
      ),
    );
  }

  _buildSettingsButton(int index) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          width: 22,
                          height: 30,
                          child: Image.asset(Assets.app_logo_without_image))),
                  Expanded(
                      flex: 5,
                      child: Container(
                          child: Text(
                        arrayHelpList[index].heading,
                        softWrap: true,
                        style: normalTextStyle(16,
                            fontFamily: FontFamily.sfProText,
                            color: appTheme.tagColor),
                      ))),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                        behavior: HitTestBehavior.deferToChild,
                        onTap: () {
                          if (arrayHelpList[index].showAnswer) {
                            arrayHelpList[index].setShowAnswer(false);
                            setState(() {});
                          } else {
                            arrayHelpList[index].setShowAnswer(true);
                            setState(() {});
                          }
                        },
                        child: Container(
                            width: 16,
                            height: 16,
                            child: arrayHelpList[index].showAnswer
                                ? Image.asset(
                                    Assets.o_arrow_up,
                                  )
                                : Image.asset(
                                    Assets.o_arrow_down,
                                  ))),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: Container(width: 30, height: 10)),
                  Expanded(
                      flex: 5,
                      child: Container(
                          child: Visibility(
                        child: Text(
                          arrayHelpList[index].text,
                          softWrap: true,
                          style: normalTextStyle(16,
                              fontFamily: FontFamily.sfProText,
                              color: appTheme.textColor),
                        ),
                        visible: arrayHelpList[index].showAnswer ? true : false,
                      ))),
                  Expanded(flex: 1, child: Container(width: 16, height: 10)),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          )),
    );
  }

  Future<List<StaticPagesModel>> _getData() async {
    try {
      await FirebaseFirestore.instance
          .collection('static_pages')
          .doc('help')
          .get()
          .then((snapshot) {
        if (snapshot.data()!.entries.first.value != null) {
          arrayHelpList.clear();
          snapshot.data()!.entries.first.value.forEach((element) {
            var tagModel = new StaticPagesModel();
            tagModel.fromMap(element);
            arrayHelpList.add(tagModel);
          });
        }

        setState(() {});
        return arrayHelpList;
      });
      return arrayHelpList;
    } on FirebaseException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
