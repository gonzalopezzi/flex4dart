part of flex4dart;

@Component (
    selector: 'fx-date-field',
    templateUrl: 'packages/flex4dart/fx-date-field/fx-date-field.html',
    cssUrl: 'packages/flex4dart/fx-date-field/fx-date-field.css',
    publishAs: 'cmp'
)
class DateField implements ShadowRootAware {
  ShadowRoot _shadowRoot;
  ButtonElement _btnCalendar; 
  DivElement _divCalendar;
  ButtonElement _btnClose;
  DateTime _selectedDate;
  
  @NgTwoWay ('selected-date')
  DateTime get selectedDate => _selectedDate;
  void set selectedDate (DateTime sd) {
    _selectedDate = sd;
    hideCalendar();
  }
  
  String get dateString => (_selectedDate != null ? 
                              new DateFormat("dd-MM-yyyy").format(_selectedDate) : 
                              "");
  
  void onShadowRoot (ShadowRoot shadowRoot) { 
    print ("Shadow Root");
    _shadowRoot = shadowRoot;
    _btnCalendar = shadowRoot.querySelector ("#btn-calendar") as ButtonElement;
    _divCalendar = shadowRoot.querySelector (".calendar") as DivElement;
    _btnClose = shadowRoot.querySelector ("#btn-close") as ButtonElement;
    _btnCalendar.onClick.listen(btnCalendarClick);
    _btnClose.onClick.listen(btnCloseClick);
  }
  
  void btnCalendarClick (MouseEvent event) {
    toggleCalendar();
  }
  
  void btnCloseClick (MouseEvent event) {
    hideCalendar();
  }
  
  void selectedDateChange () {
    print("SelectedDateChange");
    hideCalendar();
  }
  
  void hideCalendar () {
    if (_divCalendar != null) {
      _divCalendar.classes.remove("calendar-show");
    }
  }
  
  void toggleCalendar () {
    if (_divCalendar != null) {
      _divCalendar.classes.toggle("calendar-show");
    }
  }
}