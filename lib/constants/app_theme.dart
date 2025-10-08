import 'package:fight_blight_bmore/constants/app_config.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './app_config.dart';

class AppTheme {
  AppTheme._();

  /// Default theme
  factory AppTheme.origin() {
    return AppTheme._();
  }

  /// Default theme
  factory AppTheme.light() {
    return AppTheme._()
      ..isDark = false
      ..primaryColor = Color(0xFFE16726)
      ..accentColor = Colors.black
      ..backgroundColor = Colors.white
      ..headerBgColor = Colors.white
      ..textColor = Color(0xff090A0B)
      ..hintColor = Color(0xff808080)
      ..tagColor = Color(0xff5A6872)
      ..staticColor = Color(0xff060606)
      ..blueColor = Color(0xff0A84FF)
      ..redColor = Color(0xFFFF3B30)
      ..greyColor = Color(0xFFC4C4C4)
      ..greenColor = Color(0xFF1FA645)
      ..darkGreyColor = Color(0xFF707070)
      ..yellowColor = Color(0xFFFFCD35)
      ..darkRedColor = Color(0xFFF42223);
  }

  bool isDark = true;
  Color primaryColor = Color(0xFFE16726);
  Color accentColor = Colors.black;
  Color backgroundColor = const Color(0xFFF2F2F2);
  Color headerBgColor = Colors.black;
  Color textColor = Color(0xff090A0B);
  Color hintColor = Color(0xff808080);
  Color tagColor = Color(0xff5A6872);
  Color staticColor = Color(0xff060606);
  Color blueColor = Color(0xff0A84FF);
  Color redColor = Color(0xFFFF3B30);
  Color greyColor = Color(0xFFC4C4C4);
  Color greenColor = Color(0xFF1FA645);
  Color darkGreyColor = Color(0xFF707070);
  Color darkRedColor = Color(0xFFF42223);
  Color yellowColor = Color(0xFFFFCD35);

  /// Build theme data
  ThemeData buildThemeData() {
    return ThemeData(
      secondaryHeaderColor: accentColor,
      fontFamily: 'SF Pro',
      pageTransitionsTheme: _buildPageTransitionsTheme(),
      buttonTheme: _buildButtonTheme(),
      textTheme: _buildTextTheme(),
      brightness: Brightness.light,
      primaryColor: Color(0xFFE16726),
      canvasColor: Colors.transparent,
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Color(0xffffffff),
      appBarTheme: AppBarTheme(
        actionsIconTheme: IconThemeData(
          color: Color(0xff495057),
        ),
        color: Color(0xffffffff),
        iconTheme: IconThemeData(color: Color(0xff495057), size: 24),
      ),
      navigationRailTheme: NavigationRailThemeData(
          selectedIconTheme:
              IconThemeData(color: Color(0xFFE16726), opacity: 1, size: 24),
          unselectedIconTheme:
              IconThemeData(color: Color(0xff495057), opacity: 1, size: 24),
          backgroundColor: Color(0xffffffff),
          elevation: 3,
          selectedLabelTextStyle: TextStyle(color: Color(0xFFE16726)),
          unselectedLabelTextStyle: TextStyle(color: Color(0xff495057))),
      colorScheme: ColorScheme.light(
          primary: Color(0xFFE16726),
          onPrimary: Colors.white,
          primaryVariant: Color(0xFF3aa668),
          secondary: Color(0xff495057),
          secondaryVariant: Color(0xff3cd278),
          onSecondary: Colors.white,
          surface: Color(0xffe2e7f1),
          background: Color(0xff090A0B),
          onBackground: Color(0xff808080)),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.4),
        elevation: 1,
        margin: EdgeInsets.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        errorStyle: TextStyle(fontSize: 12, color: Color(0xFFE03C32)),
        hintStyle: TextStyle(fontSize: 15, color: Color(0xaa495057)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Color(0xFFE16726)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Color(0xFFE03C32)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Color(0xFFE16726)),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: Color(0xFF808080))),
      ),
      splashColor: Colors.white.withAlpha(100),
      iconTheme: IconThemeData(
        color: Color(0xFFE16726),
      ),
      indicatorColor: Colors.white,
      disabledColor: Color(0xffdcc7ff),
      highlightColor: Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFE16726),
          splashColor: Colors.white.withAlpha(100),
          highlightElevation: 8,
          elevation: 4,
          focusColor: Color(0xFFE16726),
          hoverColor: Color(0xFFE16726),
          foregroundColor: Colors.white),
      dividerColor: Color(0xffd1d1d1),
      errorColor: Color(0xfff0323c),
      cardColor: Colors.white,
      popupMenuTheme: PopupMenuThemeData(
          color: Color(0xffffffff),
          textStyle: lightTextStyle(17, color: Color(0xff495057))),
      bottomAppBarTheme:
          BottomAppBarTheme(color: Color(0xffffffff), elevation: 2),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Color(0xff495057),
        labelColor: Color(0xFFE16726),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFFE16726), width: 2.0),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Color(0xFFE16726),
        inactiveTrackColor: Color(0xFFE16726).withAlpha(140),
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbColor: Color(0xFFE16726),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
        tickMarkShape: RoundSliderTickMarkShape(),
        inactiveTickMarkColor: Colors.red[100],
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  /// Custom page transitions theme
  PageTransitionsTheme _buildPageTransitionsTheme() {
    return const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
      },
    );
  }

  /// Custom button theme full width
  ButtonThemeData _buildButtonTheme() {
    return ButtonThemeData(
      minWidth: double.infinity,
      shape: const Border(),
      buttonColor: accentColor,
      textTheme: ButtonTextTheme.primary,
      padding: const EdgeInsets.all(16),
    );
  }

  /// Custom text theme
  TextTheme _buildTextTheme() {
    return const TextTheme();
  }
}

class AppThemeProvider with ChangeNotifier {
  AppTheme get theme => AppConfig.I.theme;

  set theme(AppTheme value) {
    AppConfig.I.theme = value;
    notifyListeners();
  }
}
// ThemeData(
// brightness: Brightness.light,
// primaryColor: Color(0xFFE16726),
// canvasColor: Colors.transparent,
// backgroundColor: Colors.white,
// scaffoldBackgroundColor: Color(0xffffffff),
// appBarTheme: AppBarTheme(
// textTheme: lightAppBarTextTheme,
// actionsIconTheme: IconThemeData(
// color: Color(0xff495057),
// ),
// color: Color(0xffffffff),
// iconTheme: IconThemeData(color: Color(0xff495057), size: 24),
// ),
// navigationRailTheme: NavigationRailThemeData(
// selectedIconTheme:
// IconThemeData(color: Color(0xFFE16726), opacity: 1, size: 24),
// unselectedIconTheme:
// IconThemeData(color: Color(0xff495057), opacity: 1, size: 24),
// backgroundColor: Color(0xffffffff),
// elevation: 3,
// selectedLabelTextStyle: TextStyle(color: Color(0xFFE16726)),
// unselectedLabelTextStyle: TextStyle(color: Color(0xff495057))),
// colorScheme: ColorScheme.light(
// primary: Color(0xFFE16726),
// onPrimary: Colors.white,
// primaryVariant: Color(0xFF3aa668),
// secondary: Color(0xff495057),
// secondaryVariant: Color(0xff3cd278),
// onSecondary: Colors.white,
// surface: Color(0xffe2e7f1),
// background: Color(0xff090A0B),
// onBackground: Color(0xff808080)),
// cardTheme: CardTheme(
// color: Colors.white,
// shadowColor: Colors.black.withOpacity(0.4),
// elevation: 1,
// margin: EdgeInsets.all(0),
// ),
// inputDecorationTheme: InputDecorationTheme(
// hintStyle: TextStyle(fontSize: 15, color: Color(0xaa495057)),
// focusedBorder: OutlineInputBorder(
// borderRadius: BorderRadius.all(Radius.circular(4)),
// borderSide: BorderSide(width: 1, color: Color(0xFFE16726)),
// ),
// errorBorder: OutlineInputBorder(
// borderRadius: BorderRadius.all(Radius.circular(4)),
// borderSide: BorderSide(width: 1, color: Color(0xFFE03C32)),
// ),
// enabledBorder: OutlineInputBorder(
// borderRadius: BorderRadius.all(Radius.circular(4)),
// borderSide: BorderSide(width: 1, color: Color(0xFFE16726)),
// ),
// border: OutlineInputBorder(
// borderRadius: BorderRadius.all(Radius.circular(4)),
// borderSide: BorderSide(width: 1, color: Color(0xFF808080))),
// ),
// splashColor: Colors.white.withAlpha(100),
// iconTheme: IconThemeData(
// color: Color(0xFFE16726),
// ),
// textTheme: lightTextTheme,
// indicatorColor: Colors.white,
// disabledColor: Color(0xffdcc7ff),
// highlightColor: Colors.white,
// floatingActionButtonTheme: FloatingActionButtonThemeData(
// backgroundColor: Color(0xFFE16726),
// splashColor: Colors.white.withAlpha(100),
// highlightElevation: 8,
// elevation: 4,
// focusColor: Color(0xFFE16726),
// hoverColor: Color(0xFFE16726),
// foregroundColor: Colors.white),
// dividerColor: Color(0xffd1d1d1),
// errorColor: Color(0xfff0323c),
// cardColor: Colors.white,
// accentColor: Color(0xFFE16726),
// popupMenuTheme: PopupMenuThemeData(
// color: Color(0xffffffff),
// textStyle:
// lightTextTheme.bodyText2!.merge(TextStyle(color: Color(0xff495057))),
// ),
// bottomAppBarTheme:
// BottomAppBarTheme(color: Color(0xffffffff), elevation: 2),
// tabBarTheme: TabBarTheme(
// unselectedLabelColor: Color(0xff495057),
// labelColor: Color(0xFFE16726),
// indicatorSize: TabBarIndicatorSize.label,
// indicator: UnderlineTabIndicator(
// borderSide: BorderSide(color: Color(0xFFE16726), width: 2.0),
// ),
// ),
// sliderTheme: SliderThemeData(
// activeTrackColor: Color(0xFFE16726),
// inactiveTrackColor: Color(0xFFE16726).withAlpha(140),
// trackShape: RoundedRectSliderTrackShape(),
// trackHeight: 4.0,
// thumbColor: Color(0xFFE16726),
// thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
// overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
// tickMarkShape: RoundSliderTickMarkShape(),
// inactiveTickMarkColor: Colors.red[100],
// valueIndicatorShape: PaddleSliderValueIndicatorShape(),
// valueIndicatorTextStyle: TextStyle(
// color: Colors.white,
// ),
// ),
// );
