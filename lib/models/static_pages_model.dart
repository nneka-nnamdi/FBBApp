class StaticPagesModel {
  String heading = "";
  String text = "";
  bool showAnswer=false;

  StaticPagesModel({this.heading= "", this.text = "",this.showAnswer=false});

  void fromMap(Map map) {
    this.heading = map["heading"];
    this.text = map["text"];
  }

  String getHeading() {
    return this.heading.isNotEmpty ? this.heading : "";
  }
  String getText() {
    return this.text.isNotEmpty ? this.text : "";
  }

  bool isShowAnswer() {
    return this.showAnswer;
  }

  setShowAnswer(bool showAnswer) {
    this.showAnswer=showAnswer;
  }

}
