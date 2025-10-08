import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/models/settings_model.dart';
import 'package:fight_blight_bmore/screens/bookmarks/bookmark.dart';
import 'package:fight_blight_bmore/screens/change_password/change_password.dart';
import 'package:fight_blight_bmore/screens/profile/view_profile.dart';
import 'package:fight_blight_bmore/screens/settings/about_us.dart';
import 'package:fight_blight_bmore/screens/settings/help_screen.dart';
import 'package:fight_blight_bmore/screens/settings/privacy_policy.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppTheme appTheme = AppTheme.light();
  var settingsList = [];

  //stores:---------------------------------------------------------------------
  final PostStore _postStore = getIt<PostStore>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    settingsList =
        FirebaseAuth.instance.currentUser?.providerData.first.providerId ==
                'password'
            ? SettingsData().items
            : SettingsData().socialItems;
  }

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser?.providerData);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0.4,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Color(0xFFF8F8F8),
        title: Text(
          Strings.account_settings,
          textAlign: TextAlign.center,
          style: semiBoldTextStyle(16,
              fontFamily: FontFamily.sfProDisplay, color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(3),
        child: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: settingsList.length,
          itemBuilder: (ctx, index) {
            return settingsList.length == index + 1
                ? _buildLogoutButton(index)
                : _buildSettingsButton(index);
          },
        ),
      ),
    );
  }

  _buildSettingsButton(int index) {
    return InkWell(
      onTap: () => _handleTap(index),
      child: Container(
        height: 50,
        padding: EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 35,
              padding: EdgeInsets.all(10),
              child: Image.asset(
                settingsList[index].image,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              settingsList[index].name,
              style: semiBoldTextStyle(16,
                  fontFamily: FontFamily.sfProDisplay,
                  color: appTheme.textColor),
            ),
            Spacer(),
            Image.asset(Assets.forward_small),
          ],
        ),
      ),
    );
  }

  _buildLogoutButton(int index) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context, builder: (ctx) => _buildDismissibleDialog(ctx));
      },
      child: Container(
        height: 120,
        child: Column(children: [
          Divider(),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            padding: EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    width: 36,
                    padding: EdgeInsets.all(10),
                    child: Image.asset(settingsList[index].image)),
                SizedBox(
                  width: 10,
                ),
                Text(settingsList[index].name,
                    style: semiBoldTextStyle(
                      16,
                      fontFamily: FontFamily.sfProDisplay,
                      color: appTheme.textColor,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(),
        ]),
      ),
    );
  }

  _handleTap(int index) {
    switch (settingsList[index].name) {
      case Strings.profile:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewProfileScreen()),
        );
        break;
      case Strings.change_password:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
        );
        break;
      case Strings.bookmarks:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookmarkScreen()),
        );
        break;
      case Strings.help:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HelpScreen()));
        break;
      case Strings.privacy_terms:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
        break;
      case Strings.aboutFightBlight:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AboutUsScreen()));
        break;
    }
  }

  Widget _buildDismissibleDialog(BuildContext ctx) {
    return AlertDialog(
      // title: Text(Strings.areYouSure),
      content: Text(
        Strings.confirmLogout,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(Strings.cancel),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
        TextButton(
          child: Text(Strings.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            SharedPreferences.getInstance().then((preference) {
              preference.setBool(Preferences.is_logged_in, false);
              _postStore.clear();
              Navigator.of(ctx).pushReplacementNamed(Routes.login);
            });
          },
        ),
      ],
    );
  }
}
