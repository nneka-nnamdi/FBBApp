/// Contains the hard-coded settings per flavor.
class FlavorSettings {
  final String  url;
  final String dynamicLinkDomain;
  final String androidPackageName;
  final String iOSBundleId;

  // TODO Add any additional flavor-specific settings here.

  FlavorSettings.dev()
      : url = "https://fightblightbmore.page.link/openapp?email=",
        dynamicLinkDomain = "fightblightbmore.page.link",
        androidPackageName = "com.fbb.fightblightbmore",
        iOSBundleId = "com.fbb.fightblightbmore";

  FlavorSettings.live()
      : url = "https://fightblightbaltimore.page.link/openapp?email=",
        dynamicLinkDomain = "fightblightbaltimore.page.link",
        androidPackageName = "com.fightblightbmore.fbb",
        iOSBundleId = "com.fightblightbmore.fbb";
}
