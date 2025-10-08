import 'package:fight_blight_bmore/screens/create_post/map.dart';
import 'package:fight_blight_bmore/screens/create_post/create_post_details.dart';
import 'package:fight_blight_bmore/screens/create_post/tag_list.dart';
import 'package:fight_blight_bmore/screens/home/home.dart';
import 'package:fight_blight_bmore/screens/profile/view_profile.dart';
import 'package:fight_blight_bmore/screens/property_detail/property_detail.dart';
import 'package:fight_blight_bmore/screens/settings/about_us.dart';
import 'package:fight_blight_bmore/screens/settings/help_screen.dart';
import 'package:fight_blight_bmore/screens/settings/privacy_policy.dart';
import 'package:fight_blight_bmore/screens/tabbar/tab.dart';
import 'package:fight_blight_bmore/screens/intro/intro.dart';
import 'package:fight_blight_bmore/screens/login/login.dart';
import 'package:fight_blight_bmore/screens/reset_password/forgot_password.dart';
import 'package:fight_blight_bmore/screens/reset_password/reset_password.dart';
import 'package:fight_blight_bmore/screens/signup/signup.dart';
import 'package:fight_blight_bmore/screens/splash/splash.dart';
import 'package:fight_blight_bmore/widgets/gallery_widget.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String intro = '/intro';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgot_password = '/forgot_password';
  static const String reset_password = '/reset_password';
  static const String tab = '/tab';
  static const String home = '/home';
  static const String gallery = '/gallery';
  static const String add_property_details = '/add_property_details';
  static const String tag_list = '/tag_list';
  static const String map = '/map';
  static const String view_profile = '/view_profile';
  static const String property_detail = '/property_detail';
  static const String privacy_policy = '/privacy_policy';
  static const String about_us = '/about_us';
  static const String help_screen = '/help_screen';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    intro: (BuildContext context) => IntroScreen(),
    login: (BuildContext context) => LoginScreen(),
    signup: (BuildContext context) => SignUpScreen(),
    forgot_password: (BuildContext context) => ForgotPasswordScreen(),
    reset_password: (BuildContext context) => ResetPasswordScreen(),
    home: (BuildContext context) => HomeScreen(0),
    tab: (BuildContext context) => TabScreen(),
    gallery: (BuildContext context) => Gallery(),
    add_property_details: (BuildContext context) => CreatePostDetailsScreen(),
    tag_list: (BuildContext context) => TagListScreen(),
    map: (BuildContext context) => MapPicker(),
    view_profile: (BuildContext context) => ViewProfileScreen(),
    property_detail: (BuildContext context) => PropertyDetailScreen(),
    privacy_policy: (BuildContext context) => PrivacyPolicyScreen(),
    about_us: (BuildContext context) => AboutUsScreen(),
    help_screen: (BuildContext context) => HelpScreen(),
  };
}
