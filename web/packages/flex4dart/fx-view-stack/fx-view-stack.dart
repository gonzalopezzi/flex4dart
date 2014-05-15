part of flex4dart;

@Component (
    selector: 'fx-view-stack',
    /*template: '<div id="view-stack-main-div"></div>',*/
    publishAs: 'cmp'
)
class FxViewStack implements ShadowRootAware {
  
  Element _element;
  ShadowRoot _shadowRoot;
  List<Element> _viewStackChildren;

  int _selectedIndex;
  @NgTwoWay ('selected-index')
  void set selectedIndex (int sel) {
    _selectedIndex = sel;
    _updateView();
  }
  int get selectedIndex => _selectedIndex;
  
  FxViewStack (this._element);

  List<Element> copyChildren (Element element) {
    List<Element> out = new List<Element> ();
    if (element != null) {
      for (Element element in element.children) {
        out.add(element);
      }
    }
    return out;
  }
  
  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    _shadowRoot = shadowRoot;
    _viewStackChildren = copyChildren(_element);
    _updateView();
  }
  
  void _updateView() {
    if (_element != null) {
      _shadowRoot.children.clear();
      if (_viewStackChildren.length > 0) {
        _shadowRoot.append(_viewStackChildren[(_selectedIndex != null ? _selectedIndex : 0)]);
      }
    }
  }
  
}