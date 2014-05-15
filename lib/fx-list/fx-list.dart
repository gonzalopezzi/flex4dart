part of flex4dart;

@Component (
    selector: 'fx-list',
    templateUrl: 'packages/flex4dart/fx-list/fx-list.html',
    cssUrl: 'packages/flex4dart/fx-list/fx-list.css',
    publishAs: 'cmp'
)
class FxList implements ShadowRootAware {
  
  final String DEFAULT_HEIGHT = "10em";
  
  @observable
  List _dataProvider;
  @NgOneWay('data-provider')
  void set dataProvider (Iterable dp) {
    _dataProvider = dp;
    (_dataProvider as ObservableList).listChanges.listen((_) {_displayListItems(); });
    _displayListItems();
  }
  
  int _selectedIndex;
  @NgTwoWay('selected-index')
  void set selectedIndex (int selIndex) {
    _selectedIndex = selIndex;
    if (_selectedIndex != null && _dataProvider != null && 
          _selectedItem != _dataProvider[_selectedIndex]) {
      selectedItem = _dataProvider[_selectedIndex];
    }
    else {
      _displayListItems();
    }
  }
  int get selectedIndex => _selectedIndex;
  
  @NgOneWay('label-field')
  String labelField;
  
  @observable Object _selectedItem;
  @NgTwoWay('selected-item')
  void set selectedItem (Object sel) {
    _selectedItem = sel;
    _displayListItems();
  }
  Object get selectedItem => _selectedItem;
  
  @NgOneWay ('width')
  String width;
  
  @NgOneWay ('height')
  String height;
  
  Element _element;
  DivElement _mainDiv;
  
  FxList (this._element);
  
  void onShadowRoot (ShadowRoot shadowRoot) { 
    _mainDiv = shadowRoot.querySelector ("#fx-list-main-div") as DivElement;
    _setupSize();
    if (_selectedItem != null) {
      selectedIndex = findIndex (_selectedItem);
    }
    else if (_selectedIndex != null && _dataProvider != null) {
      selectedItem = _dataProvider [_selectedIndex];
    }
    _displayListItems();
  }
  
  void _setupSize () {
    if (width == null) {
      _element.style..display = "block"
                    ..width = null
                    ..clear = "left";
    }
    else if (width.trim() == "100%") {
      _element.style..display = "block"
                    ..clear = "left"
                    ..width = null;
    }
    else {
      _element.style..display = "inline-block"
                    ..float="left"
                    ..width = width;
    }
    
    if (height == null) {
      _element.style.height = DEFAULT_HEIGHT;
    }
    else {
      _element.style.height = height;
    }
  }
  
  int findIndex (value) {
    bool found = false;
    int i = 0;
    if (_dataProvider != null) {
      while (!found && (i < _dataProvider.length)) {
        found = _dataProvider[i] == value;
        if (!found) i++;
      }
    }
    return found ? i : -1;
  }
  
  void _displayListItems () {
    clearList ();
    if (_dataProvider != null && _mainDiv != null) {
      for (int i = 0; i < _dataProvider.length; i++) {
        Object obj = _dataProvider[i];
        DivElement itemElement = new DivElement ()
                                  ..className = "fx-list-item"
                                  ..onClick.listen((MouseEvent event) {_itemClickHandler(event, obj);})
                                  ..appendText(getLabel(obj, labelField));
        if (obj == _selectedItem) {
          itemElement.classes.add("fx-list-selected-item");
        }
        _mainDiv.append(itemElement);
      }
    }
  }
  
  void _itemClickHandler (MouseEvent event, Object obj) {
    selectedItem = obj;
    for (HtmlElement element in _mainDiv.children) {
      element.classes.remove("fx-list-selected-item");
    }
    (event.target as HtmlElement).classes.add("fx-list-selected-item");
  }
  
  void clearList () {
    if (_mainDiv != null) 
          _mainDiv.children.clear();
  }
  
  String getLabel (Object obj, String labelField) {
    String label;
    
    /*if (labelFunction != null) {
      label = labelFunction ({"item" : obj});
    }*/
    if (label == null && labelField != null) {
      label = reflect(obj).getField(new Symbol(labelField)).reflectee;
    }
    if (label == null) {
      label = "$obj";
    }
    return label;
  }
  
}