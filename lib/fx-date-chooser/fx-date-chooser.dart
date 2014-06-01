part of flex4dart;

@Component (
    selector: 'fx-date-chooser',
    templateUrl: 'packages/flex4dart/fx-date-chooser/fx-date-chooser.html',
    cssUrl: 'packages/flex4dart/fx-date-chooser/fx-date-chooser.css',
    publishAs: 'cmp'
)
class FxDateChooser implements ShadowRootAware {
  DateTime _selectedDate;
  
  @NgCallback('date-change')
  Function changeCallback;
  
  @NgTwoWay('selected-date')
  DateTime get selectedDate => _selectedDate;
  void set selectedDate (DateTime sd) {
    _selectedDate = sd;
    if (sd != null) 
      _displayedDate = sd;
    changeCallback();
  }
  
  DateTime _displayedDate = new DateTime.now();
  
  @NgOneWay('first-day-of-week')
  int firstDayOfWeek;
  
  List<String> weekDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  List<String> monthNames = ["January", "February", "March", "April", 
                             "May", "June", "July", "August", "September", 
                             "October", "November", "December"];
  
  TableRowElement _trWeeks;
  TableSectionElement _tableBody;
  Map<ButtonElement, DateTime> buttonData = new Map<ButtonElement, DateTime> ();
  
  ShadowRoot _shadowRoot;
  
  FxDateChooser () {
  }
  
  void onShadowRoot (ShadowRoot shadowRoot) { 
    print ("Shadow Root");
    _shadowRoot = shadowRoot;
    _trWeeks = _shadowRoot.querySelector("#week-day-row") as TableRowElement;
    _tableBody = _shadowRoot.querySelector("#day-table-body") as TableSectionElement;
    displayWeekNames ();
    displayDays ();
  }
  
  String get monthLabel => "${monthNames[_displayedDate.month - 1]} - ${_displayedDate.year}";
  
  void _initButtonData () {
    buttonData = new Map<ButtonElement, DateTime> ();
  }
  
  void displayWeekNames () {
    SpanElement weekLabel;
    for (int i = firstDayOfWeek; i < 7 + firstDayOfWeek; i++) {
      TableCellElement cell = new TableCellElement();
      weekLabel = new SpanElement()
        ..className = "week-label"
        ..appendText(weekDayNames[(i % 7)]);
      cell.append (weekLabel);
      _trWeeks.append(cell);
    }
  }
  
  void displayDays () {
    int lastDayOfWeek = (firstDayOfWeek + 6) % 7; /* TODO: QUITAR ESTE HARDCODE. ESTO DEBE DEPENDER DE firstDayOfWeek */
    _initButtonData ();
    DateTime firstDate = new DateTime (_displayedDate.year, _displayedDate.month, 1, 12, 0);
    while ((firstDate.weekday % 7) > (firstDayOfWeek % 7)) {
      firstDate = firstDate.subtract(new Duration(days:1));
    }
    DateTime lastDate = new DateTime (_displayedDate.year, _displayedDate.month + 1, 1, 12, 0);
    lastDate.subtract(new Duration (days:1));
    while ((lastDate.weekday % 7) != (lastDayOfWeek % 7)) {
      lastDate = lastDate.add(new Duration(days:1));
    }
    
    _tableBody.children = new List<Element> ();
    
    DateTime currentDate = firstDate;
    int dayCounter = 0;
    TableRowElement tr;
    for (DateTime currentDate = firstDate; 
              currentDate.difference(lastDate).inDays <= 0; 
              currentDate = currentDate.add(new Duration (days:1))) {
      if (dayCounter % 7 == 0) { // Must create a new row
        tr = new TableRowElement();
        _tableBody.append(tr);
      }
      tr.append(new TableCellElement()
                  ..append(createButtonElement (currentDate))
                );
      dayCounter++;
    }
    
  }
  
  void dayButtonClick (MouseEvent event) {
    selectedDate = copyDateTime (buttonData[event.target]);
    displayDays();
  }
  
  DateTime copyDateTime (DateTime d) {
    return new DateTime (d.year, d.month, d.day);
  }
  
  ButtonElement createButtonElement (DateTime currentDate)  {
    ButtonElement button = new ButtonElement() 
      ..appendText("${currentDate.day}");
    if (currentDate.month != _displayedDate.month) {
      button.className = "day-button other-month-day-button";
    }
    else {
      if (_selectedDate != null && currentDate.difference(_selectedDate).inHours < 24 && 
          currentDate.difference(_selectedDate).inHours > 0) {
        button.className = "day-button selected-day";
      }
      else {
        button.className = "day-button";
      }
    }
    
    buttonData[button] = currentDate;
    button.onClick.listen(dayButtonClick);
    return button;
  }
  
  void prevMonth() {
    _displayedDate = new DateTime (_displayedDate.year, _displayedDate.month-1, _displayedDate.day);
    displayDays();
  }
  
  void nextMonth() {
    _displayedDate = new DateTime (_displayedDate.year, _displayedDate.month+1, _displayedDate.day);
    displayDays();
  }
}