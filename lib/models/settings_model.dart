import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/strings.dart';

class SettingsModel {
  String image;

  String name;

  SettingsModel({
    required this.image,
    required this.name,
  });
}

class SettingsData {
  List<SettingsModel> items = [
    SettingsModel(image: Assets.profile, name: Strings.profile),
    SettingsModel(image: Assets.changePassword, name: Strings.change_password),
    SettingsModel(image: Assets.bookmark, name: Strings.bookmarks),
    SettingsModel(image: Assets.notification, name: Strings.notifications),
    SettingsModel(image: Assets.subscription, name: Strings.subscriptions),
    SettingsModel(image: Assets.help, name: Strings.help),
    SettingsModel(image: Assets.privacy, name: Strings.privacy_terms),
    SettingsModel(image: Assets.admin, name: Strings.contact_admin),
    SettingsModel(image: Assets.about, name: Strings.aboutFightBlight),
    SettingsModel(image: Assets.logout, name: Strings.logOut),
  ];

  List<SettingsModel> socialItems = [
    SettingsModel(image: Assets.profile, name: Strings.profile),
    SettingsModel(image: Assets.bookmark, name: Strings.bookmarks),
    SettingsModel(image: Assets.notification, name: Strings.notifications),
    SettingsModel(image: Assets.subscription, name: Strings.subscriptions),
    SettingsModel(image: Assets.help, name: Strings.help),
    SettingsModel(image: Assets.privacy, name: Strings.privacy_terms),
    SettingsModel(image: Assets.admin, name: Strings.contact_admin),
    SettingsModel(image: Assets.about, name: Strings.aboutFightBlight),
    SettingsModel(image: Assets.logout, name: Strings.logOut),
  ];
}
