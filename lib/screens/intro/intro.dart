import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:fight_blight_bmore/widgets/rounded_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  AppTheme appTheme = AppTheme.light();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    Assets.getting_started,
                    fit: BoxFit.fitWidth,
                  )),
              Padding(
                padding: EdgeInsets.only(left: 14),
                child: Container(
                  height: 80,
                  alignment: Alignment.centerLeft,
                  child: Image.asset(Assets.logo),
                ),
              ),
              _buildTitle(),
              _buildDescription(),
              _buildStartedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Text(
        Strings.introTitle,
        style: normalTextStyle(
          28,
          fontFamily: FontFamily.sfProDisplay,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(Strings.introDescription,
          style: normalTextStyle(
            16,
            fontFamily: FontFamily.sfProText,
          )),
    );
  }

  Widget _buildStartedButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: RoundedButtonWidget(
        buttonText: Strings.get_started,
        buttonColor: appTheme.primaryColor,
        textColor: Colors.white,
        onPressed: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(Preferences.first_time, false);
            Navigator.of(context).pushReplacementNamed(Routes.login);
          });
        },
      ),
    );
  }
}
