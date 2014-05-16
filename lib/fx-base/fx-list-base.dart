part of flex4dart;

abstract class FxListBase {
  
  final String DEFAULT_HEIGHT = "20em";
  
  @NgOneWay ('width')
  String width;
  
  @NgOneWay ('height')
  String height;
  
  @observable
  List _dataProvider;
  @NgOneWay('data-provider')
  void set dataProvider (Iterable dp) {
    _dataProvider = toObservable (dp);
    if (_dataProvider != null) {
      (_dataProvider as ObservableList).listChanges.listen(_dataProviderChangeHandler);
    }
    if (_element != null) 
      _commitProperties();
  }
  
  @observable Object _selectedItem;
  @NgTwoWay('selected-item')
  void set selectedItem (Object sel) {
    _selectedItem = sel;
    if (_selectedItem != null) {
      _selectedIndex = _findIndex (_selectedItem);
    }
    _commitProperties();
  }
  Object get selectedItem => _selectedItem;
  
  int _selectedIndex;
  @NgTwoWay('selected-index')
  void set selectedIndex (int selIndex) {
    _selectedIndex = selIndex;
    if (_selectedIndex != null && _selectedIndex >= 0 && _dataProvider != null && 
          _selectedItem != _dataProvider[_selectedIndex]) {
      selectedItem = _dataProvider[_selectedIndex];
    }
    else {
      _commitProperties();
    }
  }
  int get selectedIndex => _selectedIndex;
  
  int _findIndex (value) {
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
  
  Element _element;  
  
  FxListBase (this._element);
  
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
  
  void _commitProperties();
  void _updateDisplay();
  void _dataProviderChangeHandler (List<ListChangeRecord> listChangeRecords);
  
}