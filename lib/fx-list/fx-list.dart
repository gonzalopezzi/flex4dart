part of flex4dart;

@Component (
    selector: 'fx-list',
    templateUrl: 'packages/flex4dart/fx-list/fx-list.html',
    cssUrl: 'packages/flex4dart/fx-list/fx-list.css',
    publishAs: 'cmp'
)
class FxList extends FxListBase implements ShadowRootAware {
  
  final String DEFAULT_HEIGHT = "10em";
  
  @NgOneWay('label-field')
  String labelField;
  
  Element _element;
  DivElement _mainDiv;
  
  FxList (Element _element) : super (_element) {
    this._element = _element;
  }
  
  void _commitProperties() {
    _updateDisplay();
  }
  
  void _updateDisplay() {
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
  
  void _dataProviderChangeHandler (List<ListChangeRecord> listChangeRecords) {
    _updateDisplay();
  }
  
  void onShadowRoot (ShadowRoot shadowRoot) { 
    _mainDiv = shadowRoot.querySelector ("#fx-list-main-div") as DivElement;
    _setupSize();
    if (_selectedItem != null) {
      selectedIndex = _findIndex (_selectedItem);
    }
    else if (_selectedIndex != null && _dataProvider != null) {
      selectedItem = _dataProvider [_selectedIndex];
    }
    _updateDisplay();
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
    
    if (label == null && labelField != null) {
      label = reflect(obj).getField(new Symbol(labelField)).reflectee;
    }
    if (label == null) {
      label = "$obj";
    }
    return label;
  }
  
}