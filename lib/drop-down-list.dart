part of flex4dart;

@Component (
    selector: 'fx-drop-down-list',
    templateUrl: 'package/dart4flex/drop-down-list/drop-down-list.html',
    cssUrl: 'package/dart4flex/drop-down-list/drop-down-list.css',
    publishAs: 'cmp'
)
class DropDownList implements ShadowRootAware {
  
  @observable
  List _dataProvider;
  @NgOneWay('data-provider')
  void set dataProvider (Iterable dp) {
    _dataProvider = toObservable (dp);
    (_dataProvider as ObservableList).listChanges.listen(_dataProviderListChangeHandler);
    displayOptions();
  }
  
  int _selectedIndex;
  @NgOneWay('selected-index')
  void set selectedIndex (int selIndex) {
    _selectedIndex = selIndex;
    displayOptions();
  }
  
  @NgOneWay('label-field')
  String labelField = "label";
  
  @NgOneWay('prompt')
  String prompt;
  
  @NgCallback('label-function')
  Function labelFunction;
  
  @NgCallback('change')
  Function changeCallBack;
    
  
  NgModel _selectedItem;
  
  ShadowRoot _shadowRoot;
  SelectElement _select;
  
  DropDownList (this._selectedItem);
  
  void onShadowRoot (ShadowRoot shadowRoot) { 
    print ("Shadow Root");
    _shadowRoot = shadowRoot;
    _select = _shadowRoot.querySelector ("#select") as SelectElement;
    _select.onChange.listen(_selectionChange);
    
    _selectedItem.render = (value) {
      selectedIndex = findIndex (value);
    };
    displayOptions ();
  }
  
  void _dataProviderListChangeHandler (List<ListChangeRecord> listChangeRecords) {
    displayOptions();
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
    _selectedItem.viewValue = _dataProvider[newSelectedIndex];
    changeCallBack({"event": new IndexChangeEvent(IndexChangeEvent.CHANGE, 
                                                  itemIndex: newSelectedIndex)});
  }
  
  void displayOptions () {
    if (_select != null) {
      clearOptions ();
      if (prompt != null) {
        _select.append(createPrompt());
      }
      if (_dataProvider != null) {
        for (int i = 0; i < _dataProvider.length; i++) {
          Object obj = _dataProvider[i];
          _select.append(createOption(obj, i));
        }
      }
    }
  }
  
  OptionElement createPrompt () {
    return new OptionElement(data: prompt, value: "-1", selected: (_selectedIndex == null || _selectedIndex == -1))
                 ..disabled=true;
    
  }
  
  OptionElement createOption (Object obj, int index) {
    String data = "$obj";
    String value = "$index";
    
    if (labelFunction != null) {
      data = labelFunction ({"item" : obj});
    }
    else if (labelField != null) {
      data = reflect(obj).getField(new Symbol(labelField)).reflectee;  
    }
    bool selected = _selectedItem != null && obj == _selectedItem.viewValue;
    return new OptionElement(data: data, value: value, selected: selected);
  }
  
  void clearOptions ()  {
    if (_select != null) 
      _select.children.clear();
  }
  
}