import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/firestore_keys.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/screens/profile/edit_profile.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewProfileScreen extends StatefulWidget {
  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  AppTheme appTheme = AppTheme.light();
  UserStore _userStore = UserStore();
  Map<String, dynamic> userData = {};

  String _getImageUrl(String url) {
    if (url.contains('graph.facebook.com')) {
      url = url + '?type=large';
    }
    return url;
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0.4,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Color(0xFFF8F8F8),
      title: Text(
        Strings.profile,
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
      body: FutureBuilder(
        future: _userStore.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              print(snapshot.data);
              userData = snapshot.data is Map<String, dynamic>
                  ? snapshot.data as Map<String, dynamic>
                  : {};
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserView(),
                    _buildEditButton(),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Image.asset(
                        Assets.profileGif,
                        fit: BoxFit.contain,
                      ),
                    )),
                  ]);
            } else {
              return Container();
            }
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildUserView() {
    return Center(
      child: Column(children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width / 2 - 10,
          height: MediaQuery.of(context).size.width / 2 - 10,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 4, color: appTheme.primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(
                  MediaQuery.of(context).size.width / 2 - 10))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width / 2 - 10),
            child: (userData['profile_image'] != null &&
                    userData['profile_image'] != '')
                ? Image.network(
                    _getImageUrl(userData['profile_image']),
                    fit: BoxFit.cover,
                  )
                : Image.asset(Assets.dummy_profile),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          userData[FirestoreKeys.username] ?? '',
          style: semiBoldTextStyle(
            17,
            fontFamily: FontFamily.sfProText,
          ),
          maxLines: 2,
          softWrap: true,
        ),
        Text(
          userData[FirestoreKeys.email] ?? '',
          style: normalTextStyle(
            12,
            fontFamily: FontFamily.sfProText,
            color: appTheme.primaryColor,
          ),
        ),
        Text(
          userData[FirestoreKeys.account_type] ?? '',
          style: normalTextStyle(
            12,
            fontFamily: FontFamily.sfProText,
          ),
        ),
      ]),
    );
  }

  Widget _buildEditButton() {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Monitored Blight (0)',
            style: normalTextStyle(15,
                fontFamily: FontFamily.sfProText,
                color: appTheme.primaryColor),
          ),
          Container(
            width: 120,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(width: 2.0, color: appTheme.primaryColor),
              ),
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileScreen()))
                    .then((value) => setState(() {}));
              },
              child: Text(TitleKey.editProfile),
            ),
          ),
        ],
      ),
    );
  }
}
