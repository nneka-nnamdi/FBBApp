class Dimens {
  Dimens._();

  //for all screens
  static const double horizontal_padding = 12.0;
  static const double vertical_padding = 12.0;
}

class EvictionType {
  EvictionType._();

  static String witness = "Witness";
  static String resident = "Resident";
  static String sheriff = "Sheriff";
  static String propertyOwner = "Property Owner";
}

enum VideoProcess {
  start,
  pause,
  resume,
  stop,
  none,
}
