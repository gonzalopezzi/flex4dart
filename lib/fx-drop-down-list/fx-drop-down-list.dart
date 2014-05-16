part of flex4dart;

@Component (
    selector: 'fx-drop-down-list',
    templateUrl: 'packages/flex4dart/fx-drop-down-list/fx-drop-down-list.html',
    cssUrl: 'packages/flex4dart/fx-drop-down-list/fx-drop-down-list.css',
    publishAs: 'cmp'
)
class FxDropDownList extends FxListBase implements ShadowRootAware {
  
  final String DEFAULT_HEIGHT = "3em";
  
  DivElement _mainDiv;
  
  @NgOneWay('label-field')
  String labelField;
  
  @NgOneWay('prompt')
  String prompt;
  
  @NgCallback('label-function')
  Function labelFunction;
  
  @NgCallback('change')
  Function changeCallBack;
    
  ShadowRoot _shadowRoot;
  SelectElement _select;
  OptionElement _prompt;
  
  Element _element;
  
  FxDropDownList (Element _element) : super (_element) {
    this._element = _element;
  }
  
  void _commitProperties() {
    _selectedIndex = _findIndex(_selectedItem);
    _updateDisplay();
  }
  
  void _updateDisplay() {
    displayOptions();
    if (_prompt != null) {
      _prompt.disabled = _selectedItem != null;
      if (_selectedIndex != null && _selectedIndex < 0) {
        _prompt.disabled = false;
        _prompt.selected = true;
      }
    }
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
  
  void _dataProviderChangeHandler (List<ListChangeRecord> listChangeRecords) {
    _commitProperties();
  }
  
  void onShadowRoot (ShadowRoot shadowRoot) { 
    _shadowRoot = shadowRoot;
    _mainDiv = _shadowRoot.querySelector ("#fx-drop-down-list-main-div") as DivElement;
    _select = _shadowRoot.querySelector (".fx-drop-down-list-select") as SelectElement;
    _select.onChange.listen(_selectionChange);
    
    if (_selectedItem != null) {
      selectedIndex = _findIndex (_selectedItem);
    }
    else if (_selectedIndex != null && _selectedIndex >= 0 && _dataProvider != null) {
      selectedItem = _dataProvider [_selectedIndex];
    }
    _updateDisplay ();
  }
  
  void _dataProviderListChangeHandler (List<ListChangeRecord> listChangeRecords) {
    _updateDisplay();
  }
  
  void _selectedItemChangeHandler (List<ChangeRecord> changes) {
    selectedIndex = _findIndex (_selectedItem);
  }
  
  void _selectionChange (Event event) {
    int newSelectedIndex = int.parse((event.currentTarget as SelectElement).value);
    _selectedIndex = newSelectedIndex;
    selectedItem = _dataProvider[newSelectedIndex];
    changeCallBack({"event": new IndexChangeEvent(IndexChangeEvent.CHANGE, 
                                                  itemIndex: newSelectedIndex)});
  }
  
}