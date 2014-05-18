part of flex4dart;

@Component (
    selector: 'fx-data-grid',
    templateUrl: 'packages/flex4dart/fx-data-grid/fx-data-grid.html',
    cssUrl: 'packages/flex4dart/fx-data-grid/fx-data-grid.css',
    publishAs: 'cmp'
)
class FxDataGrid extends FxListBase implements ShadowRootAware, AttachAware, DetachAware {
  final String DEFAULT_HEIGHT = "20em";
  final int RESIZER_WIDTH = 4;
  final int SCROLL_WIDTH = 20;
  final int CELL_PADDING = 20;
  
  List<FxDataGridColumnElement> dataGridColumnElements = new List<FxDataGridColumnElement> ();
  List<FxDataGridColumn> columns = new List<FxDataGridColumn> ();
  
  bool _mustRedraw = false;
  
  void set dataProvider (List dp) {
    _dataProvider = toObservable (dp);
    if (_dataProvider != null) {
      (_dataProvider as ObservableList).listChanges.listen(_dataProviderChangeHandler);
    }
    if (_element != null) {
      _mustRedraw = true;
      _commitProperties();
    }
  }
  
  @NgOneWay ('row-height')
  int rowHeight = 32;
  
  ShadowRoot _shadowRoot;
  
  DivElement _datagrid;
  DivElement _datagridHeaders;
  DivElement _datagridVirtualRowsContainer;
  DivElement _datagridBody;
  DivElement _datagridDataDiv;
  
  List<Element> _headerElements;
  List<List<Element>> _cellElements;
  List<Element> _rowElements;
  
  /* Scroll */
  int _itemScrollStart;
  int _itemScrollEnd;
  bool _scrollReady = false;
  
  int _rowHover;
  
  /* Sort */
  int _currentSortColumnIndex = -1;
  bool _ascendingSort = true;
  
  bool _columnsReady = false;
  Element _element;
  
  FxDataGrid (Element _element) : super(_element) {
    this._element = _element;
  }
  
  void _dataProviderChangeHandler (List<ListChangeRecord> listChangeRecords) {
    _resetScroll(); 
    _refreshRows(); 
  }
  
  void _updateDisplay () {
    if (_shadowRoot != null) 
      _displayItems();
  }
  
  void _commitProperties () {
    if (_shadowRoot != null) {
      if (_mustRedraw) {
        _mustRedraw = false;
        _updateDisplay();
      }
      _refreshRows();
      _moveScrollToSelection();
    }
  }
  
  void _moveScrollToSelection () {
    /* If _selectedIndex is out of sight, animate the scroll to that position */
    if (_scrollReady && _selectedIndex != null && (_selectedIndex < _itemScrollStart || _selectedIndex > _itemScrollEnd)) {
      var properties = {
        'scrollTop': _selectedIndex * rowHeight
      };
      animate (_datagridBody, properties: properties, duration: 1000);
    }
  }
  
  void registerColumn (FxDataGridColumnElement dataGridColumnElement) {
    dataGridColumnElement.creationComplete.listen(columnCreatedHandler);
    dataGridColumnElements.add(dataGridColumnElement);
  }
  
  void columnCreatedHandler (FlexEvent event) {
    print ("columnCreatedHandler");
    bool allCreated = true;
    for(FxDataGridColumnElement columnElement in dataGridColumnElements) {
      allCreated = allCreated && columnElement.created;
    }
    _columnsReady = allCreated;
    if (allCreated) {
      _createTable();
    }
  }
  
  void onShadowRoot (ShadowRoot shadowRoot) {
    print ("Shadow Root");
    _setupSize();
    _shadowRoot = shadowRoot;
    _datagrid = _shadowRoot.querySelector(".fx-datagrid-main-div");
    _datagridHeaders = _shadowRoot.querySelector(".fx-datagrid-headers");
    _datagridVirtualRowsContainer = _shadowRoot.querySelector(".fx-datagrid-virtual-rows-container");
    
    _datagridBody = _shadowRoot.querySelector(".fx-datagrid-body");
    _datagridBody.onScroll.listen(_scrollHandler);
    _datagridBody.onMouseMove.listen(_mouseMoveHandler);
    _datagridBody.onMouseOut.listen((_) { _rowHover = -1; _clearRowHover(); });
    _datagridBody.onClick.listen(_clickHandler);
    
    _datagridDataDiv = _shadowRoot.querySelector(".fx-datagrid-data-div");
    if (_columnsReady) {
      _createTable();
    }
  }
  
  @override
  void attach() {
    print ("Attach");
  }
  
  @override
  void detach() {
    dataGridColumnElements = new List<FxDataGridColumnElement> ();
    _columnsReady = false;
  }
  
  List<FxDataGridColumn> _getColumnsFromElements() {
    List<FxDataGridColumn> out = new List<FxDataGridColumn> ();
    for (FxDataGridColumnElement element in dataGridColumnElements) {
      out.add(element.dataGridColumn);
    }
    return out;
  }
  
  void _clearRowHover () {
    if (_rowElements != null) {
      for (Element row in _rowElements) {
        row.classes.remove("fx-datagrid-row-hover");
      }
    }
  }
  
  void _renderRowHover () {
    _clearRowHover();
    if (_rowElements != null && (_rowHover - _itemScrollStart) >= 0 &&
        (_rowHover - _itemScrollStart) < _rowElements.length)  
      _rowElements[_rowHover - _itemScrollStart].classes.add("fx-datagrid-row-hover");
  }
  
  int _getRowByCursorY (int cursorY) {
    int row = -1;
    if (_dataProvider != null) {
      row = ((cursorY - (_datagridBody.scrollTop % rowHeight)) / rowHeight).floor();
      if (row < 0) {
        row = 0;
      }
      if (row >= _dataProvider.length) {
        row = _dataProvider.length -1;
      }
    }
    return row;
  }
  
  void _clickHandler (MouseEvent event) {
    int _rowClick = _getRowByCursorY (event.offset.y);
    selectedItem = _dataProvider[_rowClick];
  }
  
  void _mouseMoveHandler (MouseEvent event) {
    _rowHover = _getRowByCursorY (event.offset.y);
    _renderRowHover();
  }
  
  void _setRowBackground (int dataProviderIndex, int rowElementIndex) {
    if (dataProviderIndex%2 == 0) 
      _rowElements[rowElementIndex].classes.add("fx-datagrid-row-dark");
    else
      _rowElements[rowElementIndex].classes.remove("fx-datagrid-row-dark");
    if (_dataProvider[dataProviderIndex] == selectedItem) 
      _rowElements[rowElementIndex].classes.add("fx-datagrid-row-selected");
    else 
      _rowElements[rowElementIndex].classes.remove("fx-datagrid-row-selected");
  }
  
  void _populateCells (int itemStart, int itemEnd) {
    int j = 0;
    for (int i = itemStart; i <= itemEnd && j < _cellElements.length; i++) {
      _setRowBackground (i,j);
      for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        FxDataGridColumn column = columns[columnIndex];
        _cellElements[j][columnIndex]..children.clear()
                                ..appendText(_getCellLabel(_dataProvider[i], column.dataField));  
      }
      j++;
    }
  }
  
  void _populateDataProvider (int scrollTop, int scrollHeight) {
    _itemScrollStart = (scrollTop / rowHeight).floor();
    _itemScrollEnd = ((scrollTop + scrollHeight) / rowHeight).floor();
    
    if (_itemScrollEnd >= _dataProvider.length) {
      _itemScrollEnd = _dataProvider.length - 1;
    }
    _scrollReady = true;
    _populateCells (_itemScrollStart, _itemScrollEnd);
  }
  
  void _refreshRows () {
    if (_datagridBody != null && _columnsReady) {
      _setDataDivHeight(_dataProvider, rowHeight);
      _populateDataProvider(_datagridBody.scrollTop, _datagridBody.offsetHeight);
    }
  }
  
  void _resetScroll () {
    _scrollReady = false;
    if (_datagridBody != null)
      _datagridBody.scrollTop = 0;    
  }
  
  void _scrollHandler (Event event) {
    HtmlElement target = event.target as HtmlElement;
    _populateDataProvider(target.scrollTop, target.offsetHeight);
    _clearRowHover();
  }
  
  Element _createHeaderElement (FxDataGridColumn column, int columnIndex, String width) {
    DivElement headerElement = new DivElement() 
      ..className = "fx-datagrid-cell"
      ..appendText(column.headerText)
      ..style.width = width
      ..onClick.listen((MouseEvent event) { headerClickHandler (event, columnIndex);})
      /*..onDragOver.listen(columnDragOverHandler)
      ..onDragEnter.listen(columnDragEnterHandler)
      ..onDragLeave.listen(columnDragLeave)
      ..onDrop.listen(columnDropHandler)*/;
    if (column.sortable) {
      headerElement.classes.add("sortable");
    }
    return headerElement;
  }
  
  Element _createResizerElement (FxDataGridColumn column, int columnIndex) {
    return new DivElement()
      ..classes.add("fx-datagrid-headers-border")
      ..style.width = "$RESIZER_WIDTH px"
      ..draggable = (column.resizable ? true : false)
      ..style.cursor = (column.resizable ? "e-resize" : "pointer")
      /*..onDragStart.listen((MouseEvent event) {resizerDragStartHandler(event, columnIndex); })
      ..onDragEnd.listen(resizerDragEndHandler)*/;
  }
  
  void _createHeaders (int currentTableWidth, List<FxDataGridColumn> columns) {
    _headerElements = new List<Element> ();
    int defaultHeaderWidth = ((currentTableWidth - (columns.length - 1) * RESIZER_WIDTH - SCROLL_WIDTH) / columns.length).floor();
    for (int i = 0; i < columns.length; i++) {
      FxDataGridColumn column = columns [i];
      String width = "calc(${100 / columns.length}% - ${SCROLL_WIDTH}px / ${columns.length}";
      if (i != (columns.length -1)) {
        width += " - ${RESIZER_WIDTH}px";
      }
      width += ")";
      print ("Width: $width");
      DivElement header = _createHeaderElement (column, i, width);
      _datagridHeaders.append(header);
      _headerElements.add(header);
      if (i < (columns.length-1)) {
        _datagridHeaders.append(_createResizerElement (column, i));
      }
    }
  }
  
  Element _createCellElement (Object object, String width, FxDataGridColumn column) {
    DivElement cellElement = new DivElement ()
        ..className = "fx-datagrid-cell"
        ..style.width = width
        ..style.height = "${rowHeight}px"
        ..style.lineHeight = "${rowHeight}px"
        ..style.paddingLeft = "${CELL_PADDING}px"
        ..style.paddingRight = "${CELL_PADDING}px"
        ..style.textAlign = column.textAlign;
    /*if (column.itemRenderer != null) {
      column.itemRenderer.data = getObjectField (object, column.dataField);
      // The Item Renderers must be wrapped in its own div
      
      /* TODO: Quitar los estilos de padding y demás de este cellElement,
       * para que el programador pueda poner un fondo a la celda y los padding no fastidien 
      */
      cellElement..append (new DivElement()
                            ..style.display = "block"
                            ..style.position = "relative" 
                            ..style.lineHeight = "1.231"  /* Reset lineHeight as many users will not expect line-height to be changed */
                            ..appendHtml(column.itemRenderer.renderHTML()))
                 ..style.paddingLeft = "0px" /* Reset padding to 0 so the user sets the desired padding */
                 ..style.paddingRight = "0px"
                 ..style.width = "${cellWidth + 2 * CELL_PADDING}px"; /* Add the padding to the width */
    }
    else {
      cellElement.appendText(getCellLabel(object, column.dataField));
    }*/
    return cellElement;
  }
  
  void clearAllSortStyles () {
    for (Element headerElement in _headerElements) {
      headerElement.classes.remove("ascending-sort");
      headerElement.classes.remove("descending-sort");
    }
  }
  
  void setSortStyles (Element element, ascendingSort) {
    if (ascendingSort) {
      element.classes.remove("descending-sort");
      element.classes.add   ("ascending-sort");
    }
    else {
      element.classes.add   ("descending-sort");
      element.classes.remove("ascending-sort");
    }
  }
  
  void headerClickHandler (MouseEvent event, int columnIndex) {
    FxDataGridColumn column = columns[columnIndex];
    
    if (column.sortable) {
      if (_currentSortColumnIndex == columnIndex) 
        _ascendingSort = !_ascendingSort;
      else 
        _ascendingSort = true;
      _currentSortColumnIndex = columnIndex;
      
      clearAllSortStyles();
      setSortStyles (event.target as HtmlElement, _ascendingSort);
      
      _dataProvider.sort((Object a, Object b) { 
            return ((_ascendingSort ? 1 : -1) * (_getObjectField(a, column.dataField) as Comparable).compareTo(
              _getObjectField (b, column.dataField) as Comparable));  
         });
      /* Not necessary because the list is observable: _refreshRows();*/
    }
  }
  
  
  String _getCellLabel (Object obj, String labelField) {
    return "${reflect(obj).getField(new Symbol(labelField)).reflectee}";
  }
  
  Object _getObjectField (Object obj, String field) {
    return reflect(obj).getField(new Symbol(field)).reflectee;
  }
  
  int calculateHowManyRows (List _dataProvider, int rowHeight, int offsetHeight) {
    int out = 0;
    if (_dataProvider.length * rowHeight < offsetHeight) {
      out = _dataProvider.length;
    }
    else {
      out = (offsetHeight / rowHeight).ceil();
    }
    return out;
  }
  
  void _setDataDivHeight (List _dataProvider, int rowHeight) {
    _datagridDataDiv..style.height = "${_dataProvider.length * rowHeight}px";
  }
  
  void _displayItems () {
    _cellElements = new List<List<Element>> ();
    _rowElements = new List<Element> ();
    int rowCount = 0;
    int howManyRows = calculateHowManyRows (_dataProvider, rowHeight, _datagrid.offsetHeight);
    _setDataDivHeight(_dataProvider, rowHeight);
    _datagridVirtualRowsContainer.children.clear();
    for (int i = 0; i < howManyRows; i++) {
      Object obj = _dataProvider[i];
      int clickIndex = rowCount;
      DivElement datagrid_row = new DivElement()
                                  ..classes.add("fx-datagrid-row")
                                  /*..classes.add("fx-datagrid-alternating-row-colors")*/
                                  /*..onClick.listen((MouseEvent event) {rowClickHandler(event, clickIndex);})*/;
      /*if (obj == selectedItem) {
        datagrid_row..classes.remove("datagrid-alternating-row-colors")
                    ..classes.add("datagrid-selected-item");
      }*/
      
      List<Element> rowCells = new List<Element> ();
      for (int i = 0; i < columns.length; i++) {
        FxDataGridColumn column = columns[i];
        String width = "calc(${100 / columns.length}% - ${SCROLL_WIDTH/columns.length}px - ${2 * CELL_PADDING}px)";
        Element cell =_createCellElement (obj, width, column);
        datagrid_row.append(cell);
        rowCells.add(cell);
      }
      datagrid_row.append (new DivElement()
                              ..className="fx-datagrid-row-end"
                              ..style.height = "${rowHeight}px");
      _datagridVirtualRowsContainer.append(datagrid_row);
      _rowElements.add(datagrid_row);
      _cellElements.add(rowCells);
      rowCount++;
    }
  }
  
  void _createTable () {
    if (_datagrid != null && _columnsReady) {
      columns = _getColumnsFromElements();
      int currentTableWidth = _datagrid.offsetWidth;
      int currentTableHeight = _datagrid.offsetHeight;
      _datagridHeaders.children.clear();
      _datagridVirtualRowsContainer.children.clear();
      if (columns != null && columns.length > 0) {
        _createHeaders (currentTableWidth, columns);
        if (_dataProvider != null) {
          _displayItems ();
          _populateDataProvider(0, _datagridBody.offsetHeight);
        }
      }
    }
  }
}