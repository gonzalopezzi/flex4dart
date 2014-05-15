part of flex4dart;

@Component (
    selector: 'fx-data-grid-column',
    useShadowDom: false, 
    publishAs: 'cmp'
)
class FxDataGridColumnElement implements AttachAware, DetachAware  {
  FxDataGrid _dataGrid;
  
  StreamController creationCompleteController = new StreamController.broadcast();
  Stream get creationComplete => creationCompleteController.stream;
  
  String _dataField;
  @NgOneWay ('data-field')
  void set dataField (String d) {
    _dataField = d;
  }
  String get dataField => _dataField;
  
  @NgOneWay ('header-text')
  String headerText;
  
  @NgOneWay ('resizable')
  bool resizable;
  
  @NgOneWay ('sortable')
  bool sortable;
  
  @NgOneWay ('text-align')
  String textAlign;
  
  bool created = false;
  
  Element _element;
  
  FxDataGridColumnElement (this._dataGrid, this._element) {
    _dataGrid.registerColumn(this);
  }
  
  void attach () {
    print ("Attached: $dataField $headerText");
    created = true;
    creationCompleteController.add(new FlexEvent("creationComplete", target: this));
  }
  
  @override
  void detach() {
    print ("Detached: $dataField $headerText");
    created = false;
  }
  
  get dataGridColumn {
    FxDataGridColumn out = new FxDataGridColumn(dataField, headerText);
    if (resizable != null) {
      out.resizable = resizable;
    }
    if (sortable != null) {
      out.sortable = sortable;
    }
    if (textAlign != null) {
      out.textAlign = textAlign;
    }
    return out;
  }
}

class FxDataGridColumn {
  String dataField;
  String headerText;
  bool resizable;
  bool sortable;
  String textAlign;
  
  FxDataGridColumn (this.dataField, 
                  this.headerText, 
                 {this.resizable : true, 
                  this.sortable : true,
                  this.textAlign : "left"});
}