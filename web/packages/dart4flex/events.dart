part of flex4dart;


class FlexEvent {
  String type;
  FlexEvent (this.type);
}

class ListEvent extends FlexEvent {
  static final String CHANGE = "change";
  
  int rowIndex;
  ListEvent (String type, {this.rowIndex}) : super (type);
}

class IndexChangeEvent extends FlexEvent {
  static final String CHANGE = "change";
  
  int itemIndex;
  IndexChangeEvent (String type, {this.itemIndex}) : super(type);
}