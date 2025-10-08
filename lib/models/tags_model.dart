class TagModel {
  int id = 0;
  String title = "";
  String subtitle = "";
  bool isSelected = false;
  bool isSaved = false;

  TagModel({this.id = 0, this.title= "", this.subtitle = "", isSelected = false, isSaved= false});

  void fromMap(Map map) {
    this.id = map["id"];
    this.title = map["title"];
    this.subtitle = map["subtitle"];
  }

  String getTitle() {
    return this.title;
  }
  String getSubTitle() {
    return this.subtitle;
  }
}