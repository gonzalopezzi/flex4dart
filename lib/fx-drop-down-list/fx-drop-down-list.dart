part of flex4dart;

@Component (
    selector: 'fx-drop-down-list',
    templateUrl: 'packages/flex4dart/fx-drop-down-list/fx-drop-down-list.html',
    cssUrl: 'packages/flex4dart/fx-drop-down-list/fx-drop-down-list.css',
    publishAs: 'cmp'
)
class FxDropDownList implements ShadowRootAware {
  
  @observable
  List _dataProvider;
  @NgOneWay('data-provider')
  void set dataProvider (Iterable dp) {
    _dataProvider = toObservable (dp);
    if (_dataProvider != null) {
      (_dataProvider as ObservableList).listChanges.listen(_dataProviderListChangeHandler);
    }
    displayOptions();
  }
  
  DivElement _mainDiv;
  String _width; 
  void set width (String w) {
    _width = w;
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
      displayOptions();
      if (_prompt != null) 
        _prompt.disabled = _selectedItem != null;
    }
  }
  int get selectedIndex => _selectedIndex;
  
  @NgOneWay('label-field')
  String labelField;
  
  @NgOneWay('prompt')
  String prompt;
  
  @NgCallback('label-function')
  Function labelFunction;
  
  @NgCallback('change')
  Function changeCallBack;
    
  @observable Object _selectedItem;
  @NgTwoWay('selected-item')
  void set selectedItem (Object sel) {
    _selectedItem = sel;
    displayOptions();
    if (_prompt != null) 
      _prompt.disabled = _selectedItem != null;
  }
  Object get selectedItem => _selectedItem;
  
  ShadowRoot _shadowRoot;
  SelectElement _select;
  OptionElement _prompt;
  
  FxDropDownList (/*this._selectedItem*/);
  
  void onShadowRoot (ShadowRoot shadowRoot) { 
    _shadowRoot = shadowRoot;
    _mainDiv = _shadowRoot.querySelector ("#fx-drop-down-list-main-div") as DivElement;
    _select = _shadowRoot.querySelector (".fx-drop-down-list-select") as SelectElement;
    _select.onChange.listen(_selectionChange);
    
    if (_selectedItem != null) {
      selectedIndex = findIndex (_selectedItem);
    }
    else if (_selectedIndex != null && _dataProvider != null) {
      selectedItem = _dataProvider [_selectedIndex];
    }
    displayOptions ();
  }
  
  void _dataProviderListChangeHandler (List<ListChangeRecord> listChangeRecords) {
    displayOptions();
  }
  
  void _selectedItemChangeHandler (List<ChangeRecord> changes) {
    selectedIndex = findIndex (_selectedItem);
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
  
  void _selectionChange (Event event) {
    int newSelectedIndex = int.parse((event.currentTarget as SelectElement).value);
    _selectedIndex = newSelectedIndex;
    selectedItem = _dataProvider[newSelectedIndex];
    changeCallBack({"event": new IndexChangeEvent(IndexChangeEvent.CHANGE, 
                                                  itemIndex: newSelectedIndex)});
  }
  
  void displayOptions () {
    if (_select != null) {
      clearOptions ();
      _prompt = createPrompt();
      _select.append(_prompt);
      if (_dataProvider != null) {
        for (int i = 0; i < _dataProvider.length; i++) {
          Object obj = _dataProvider[i];
          _select.append(createOption(obj, i));
        }
      }
    }
  }
  
  OptionElement createPrompt () {
    return new OptionElement(data: (prompt != null ? prompt : ""), value: "-1", selected: (_selectedIndex == null || _selectedIndex == -1))
                 ..disabled=false;
    
  }
  
  OptionElement createOption (Object obj, int index) {
    String data;
    String value = "$index";
    
    if (labelFunction != null) {
      data = labelFunction ({"item" : obj});
    }
    if (data == null && labelField != null) {
      data = reflect(obj).getField(new Symbol(labelField)).reflectee;
    }
    if (data == null) {
      data = "$obj";
    }
    bool selected = _selectedItem != null && obj == _selectedItem;
    return new OptionElement(data: data, value: value, selected: selected);
  }
  
  void clearOptions ()  {
    if (_select != null) {
      _select.children.clear();
      _select.value = "-1";
    }
  }
  
}