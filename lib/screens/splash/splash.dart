import 'dart:async';

import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/services/navigation_service.dart';
import 'package:fight_blight_bmore/stores/form/form_store.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final NavigationService _navigationService = getIt<NavigationService>();
  var dynamicLinkEmail = '';
  final _store = FormStore();

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    startTimer();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          print('Dynamic Link: ${dynamicLink?.link}');
          if (dynamicLink != null) {
            await _handleDynamicLink(dynamicLink);
          }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) {
      await _handleDynamicLink(data);
    }
  }

  Future<void> _handleDynamicLink(PendingDynamicLinkData dynamicLink) async {
    final Uri? deepLink = dynamicLink.link;
    if (deepLink != null) {
      FirebaseAuth auth = FirebaseAuth.instance;
      //Get actionCode from the dynamicLink
      final Uri? deepLink = dynamicLink.link;
      var actionCode = deepLink?.queryParameters['oobCode'];
      var mode = deepLink?.queryParameters['mode'];
      Uri? continueUrl =
          Uri.parse(deepLink?.queryParameters['continueUrl'] ?? '');
      dynamicLinkEmail = continueUrl.query.replaceAll('email=', '');
      switch (mode) {
        case 'verifyEmail':
          await _handleVerifyEmail(auth, actionCode ?? '');
          break;
        case 'signIn':
          await _handleSignInWithEmail(auth, deepLink ?? Uri.parse(''));
          break;
        case 'resetPassword':
          print('called Splash dynamic link');
          _navigationService.navigateWith(Routes.reset_password,
              ScreenArguments(dynamicLinkEmail, actionCode!));
          break;
        case 'propertyDetail':
          print('called Splash dynamic link');
          int propertyId = int.parse(deepLink?.queryParameters['property_id'] ?? '0');
          SharedPreferences preferences = await SharedPreferences.getInstance();
            if (preferences.getBool(Preferences.is_logged_in) ?? false) {
              _navigationService.navigateToDetail(Routes.tab, propertyId);
            }
          break;
      }
    }
  }

  Future<void> _handleSignInWithEmail(FirebaseAuth auth, Uri deepLink) async {
    if (FirebaseAuth.instance.isSignInWithEmailLink(dynamicLinkEmail)) {
      // The client SDK will parse the code from the link for you.
      auth
          .signInWithEmailLink(
              email: dynamicLinkEmail, emailLink: deepLink.toString())
          .then((value) async {
        // You can access the new user via value.user
        // Additional user info profile *not* available via:
        // value.additionalUserInfo.profile == null
        // value.additionalUserInfo.isNewUser;
        var userEmail = value.user;
        // If successful, reload the user:
        auth.currentUser?.reload();
        await Future.delayed(const Duration(seconds: 2), () {
          _store.updateVerifyEmail();
          print(auth.currentUser?.emailVerified);
          _navigationService.navigateTo(Routes.tab);
        });
        print('Successfully signed in with email link!$userEmail}');
      }).catchError((onError) {
        print('Error signing in with email link $onError');
      });
    }
  }

  Future<void> _handleVerifyEmail(FirebaseAuth auth, String actionCode) async {
    try {
      await auth.checkActionCode(actionCode);
      await auth.applyActionCode(actionCode);
      // If successful, reload the user:
      auth.currentUser?.reload();
      await Future.delayed(const Duration(seconds: 2), () {
        print(auth.currentUser?.emailVerified);
        _store.updateVerifyEmail();
        _navigationService.navigateTo(Routes.tab);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-action-code') {
        print('The code is invalid.');
        _showErrorDialog();
      } else if (e.code == 'expired-action-code') {
        print('The action code has expired.');
        _showErrorDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Image.asset(Assets.appLauncher),
      ),
    );
  }

  startTimer() {
    var _duration = Duration(milliseconds: 2000);
    return Timer(_duration, navigate);
  }

  navigate() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(Preferences.first_time) ?? true) {
      _navigationService.navigateTo(Routes.intro);
    } else {
      if (preferences.getBool(Preferences.is_logged_in) ?? false) {
        _navigationService.navigateTo(Routes.tab);
      } else {
        _navigationService.navigateTo(Routes.login);
      }
    }
  }

  Future<void> _showErrorDialog() async {
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
                  Strings.invalidCode,
                  textAlign: TextAlign.center,
                  style: normalTextStyle(16, fontFamily: FontFamily.sfProText),
                ),
                SizedBox(
                  height: 15,
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      var result =
                          await _store.resendVerificationCode(dynamicLinkEmail);
                      Navigator.of(context).pop();
                      print(result.toString());
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Text(
                    Strings.resendVerificationLink,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: Color(0xFFE16726),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
