import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/models/static_pages_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  AppTheme appTheme = AppTheme.light();
  List<StaticPagesModel> arrayPrivacyList = [];

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.4,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Color(0xFFF8F8F8),
      title: Text(
        Strings.privacyPolicyHeading,
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
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(3),
        child: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: arrayPrivacyList.length,
          itemBuilder: (ctx, index) {
            return _buildSettingsButton(index);
          },
        ),
      ),
    );
  }

  _buildSettingsButton(int index) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 5,
          ),
          Text(
            arrayPrivacyList[index].heading,
            softWrap: true,
            style: boldTextStyle(16,
                fontFamily: FontFamily.sfProText, color: appTheme.textColor),
          ),
          SizedBox(
            height: 10,
          ),
          index == 4
              ? Html(data: arrayPrivacyList[index].text, style: {
                  "body": Style(
                    fontSize: FontSize(16),
                  )
                })
              : Text(
                  arrayPrivacyList[index].text.replaceAll('/n', '\n'),
                  softWrap: true,
                  style: normalTextStyle(16,
                      fontFamily: FontFamily.sfProText,
                      color: appTheme.textColor),
                ),
        ]),
      ),
    );
  }

  Future<List<StaticPagesModel>> _getData() async {
    try {
      await FirebaseFirestore.instance
          .collection('static_pages')
          .doc('privacy_policy')
          .get()
          .then((snapshot) {
        if (snapshot.data()!.entries.first.value != null) {
          arrayPrivacyList.clear();
          snapshot.data()!.entries.first.value.forEach((element) {
            var tagModel = new StaticPagesModel();
            tagModel.fromMap(element);
            arrayPrivacyList.add(tagModel);
          });
        }

        setState(() {});
        return arrayPrivacyList;
      });
      return arrayPrivacyList;
    } on FirebaseException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
