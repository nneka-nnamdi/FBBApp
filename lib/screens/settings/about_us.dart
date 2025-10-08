import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/models/static_pages_model.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  AppTheme appTheme = AppTheme.light();
  List<StaticPagesModel> arrayAboutList = [new StaticPagesModel()];

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.4,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Color(0xFFF8F8F8),
      title: Text(
        Strings.aboutUsHeading,
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
    _getData();
    return Scaffold(
        appBar: _buildAppBar(),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: 1,
              itemBuilder: (ctx, index) {
                return _buildSettingsButton();
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 20),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 2.0, color: appTheme.primaryColor),
                  ),
                  onPressed: () {
                    _launchURLApp();
                  },
                  child: Text(
                    'Learn More',
                    style: normalTextStyle(
                      18,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.primaryColor,
                    ),
                  ),
                ),
              ))
        ]));
  }

  _launchURLApp() async {
    const url = 'https://www.fightblightbmore.com/';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  _buildSettingsButton() {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 350,
            height: MediaQuery.of(context).size.height*0.37,
            child: Image.asset(Assets.appLauncher),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            arrayAboutList[0].heading,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: normalTextStyle(20,
                fontFamily: FontFamily.sfProDisplay, color: appTheme.staticColor),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            arrayAboutList[0].text.replaceAll("/n", "\n"),
            softWrap: true,
            style: normalTextStyle(16,
                fontFamily: FontFamily.sfProText, color: appTheme.staticColor),
          ),
        ]),
      ),
    );
  }

  Future<List<StaticPagesModel>> _getData() async {
    try {
      await FirebaseFirestore.instance
          .collection('static_pages')
          .doc('terms')
          .get()
          .then((snapshot) {
        if (snapshot.data()!.entries.first.value != null) {
          arrayAboutList.clear();
          snapshot.data()!.entries.first.value.forEach((element) {
            var tagModel = new StaticPagesModel();
            tagModel.fromMap(element);
            arrayAboutList.add(tagModel);
          });
        }

        setState(() {});
        return arrayAboutList;
      });
      return arrayAboutList;
    } on FirebaseException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
