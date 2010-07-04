document.observe('trisano:dom:loaded', function() {
  Trisano.Ajax.hookLiveSearchFields();
  Trisano.Ajax.hookUpdateLinks();
});

Element.addMethods({
  associatedSpinner: function(element) {
    var spinnerId = element.identify() + "_spinner";
    return $(spinnerId) || spinnerId;
  },

  associatedSearchResults: function(element) {
    var searchResultsId = element.identify() + "_search_results";
    return $(searchResultsId) || searchResultsId;
  }

});

Trisano.Ajax = {

  liveSearch: function(field) {
    if (!Object.isElement(field.associatedSearchResults())) {
      document.body.insert( { bottom: new Element('div', { id: field.associatedSearchResults(), 'class': 'autocomplete' }) } );
    }
    if (!Object.isElement(field.associatedSpinner())) {
      field.insert({ after: Trisano.Ajax.spinnerImg(field) });
    }
    new Ajax.Autocompleter(field, field.associatedSearchResults(), field.getAttribute('data-url'), {
                             indicator: field.associatedSpinner(),
                             method: 'get',
                             afterUpdateElement: Trisano.Ajax.callbackUpdateRequest
                           });
  },

  callbackUpdateRequest: function(field, selection) {
    new Ajax.Request(field.getAttribute('data-update-url'), {
                       method: 'post',
                       parameters: { place_entity_id: selection.id },
                       onCreate: function() { field.associatedSpinner().show(); },
                       onFailure: function() {
                         field.associatedSpinner().hide();
                         Trisano.flashError(i18n.t('operation_failed')).fade({delay: 3.0});
                       }
                     });
  },

  hookLiveSearchFields: function(selector) {
    var css = selector || "input[data-live-search='true']";
    $$(css).each(function(searchable) {
      Trisano.Ajax.liveSearch(searchable);
    });
  },

  hookUpdateLinks: function(selector) {
    var css = selector || 'a[data-update-link=true]';
    $$(css).each(function(link) {
      if (!Object.isElement(link.associatedSpinner())) {
        link.insert({ after: Trisano.Ajax.spinnerImg(link) });
      }
      link.observe('click', function(event) {
        new Ajax.Request(link.href, { method: 'post',
                                      onCreate: function() { link.associatedSpinner().show(); },
                                      onFailure: function() {
                                        link.associatedSpinner().hide();
                                        Trisano.flashError(i18n.t('operation_failed')).fade({delay: 4.0});
                                      } });
        event.stop();
      });
    });
  },

  spinnerImg: function(node) {
    return new Element('img', {
                         src: Trisano.url('images/redbox_spinner.gif'),
                         style: 'display:none',
                         id: node.associatedSpinner()
                       });
  }
};
