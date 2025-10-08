import 'dart:async';

import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/data/sharedpref/constants/preferences.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/screens/create_post/add_media/add_media.dart';
import 'package:fight_blight_bmore/screens/home/home.dart';
import 'package:fight_blight_bmore/screens/map_search/map_search.dart';
import 'package:fight_blight_bmore/screens/property_detail/property_detail.dart';
import 'package:fight_blight_bmore/screens/search/search.dart';
import 'package:fight_blight_bmore/screens/settings/settings.dart';
import 'package:fight_blight_bmore/services/navigation_service.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:fight_blight_bmore/widgets/common_navigation_bar.dart';
import 'package:fight_blight_bmore/widgets/custom_animated_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  AppTheme appTheme = AppTheme.light();
  int _currentIndex = 0;
  final _inactiveColor = Color(0xFFE5E5E5);
  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // final NavigationService _navigationService = getIt<NavigationService>();
  var propertyId = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if ((ModalRoute.of(context)?.settings.arguments as int?) != null) {
      propertyId = ModalRoute.of(context)?.settings.arguments as int;
      setState(() => _currentIndex = 0);
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // body methods:--------------------------------------------------------------

  Widget _buildBottomBar() {
    return CustomAnimatedBottomBar(
      containerHeight: 70,
      backgroundColor: Color(0xff090A0B),
      selectedIndex: _currentIndex,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) {
        _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
        setState(() => _currentIndex = index);
      },
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: ImageIcon(AssetImage(Assets.home_selected)),
          activeColor: appTheme.primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: ImageIcon(AssetImage(Assets.map)),
          activeColor: appTheme.primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: ImageIcon(AssetImage(Assets.add)),
          activeColor: appTheme.primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: ImageIcon(AssetImage(Assets.search)),
          activeColor: appTheme.primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: ImageIcon(AssetImage(Assets.settings)),
          activeColor: appTheme.primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return CommonBottomNavigationBar(
      selectedIndex: _currentIndex,
      navigatorKeys: _navigatorKeys,
      childrens: [
        HomeScreen(propertyId),
        MapSearchScreen(),
        AddMediaScreen(),
        SearchScreen(),
        SettingsScreen(),
      ],
    );
  }
}
