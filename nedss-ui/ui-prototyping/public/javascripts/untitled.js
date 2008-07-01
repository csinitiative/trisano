YAHOO.util.Event.onDOMReady(function() {
var tabs = new YAHOO.yodeler.widget.ScrollTabView('cmr_tabs', { width: 723, height: 300, direction: /'horizontal' });
tabs.set('activeTab', tabs.getTab(0));
tabs.addTab(new YAHOO.widget.Tab({label: 'Dynamically Added Tab', content: 'The content moves from left to / right in this example.'}));
 });

