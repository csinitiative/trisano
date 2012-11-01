document.observe('trisano:dom:loaded', function() {
  Trisano.Ajax.hookLiveSearchFields();
  Trisano.Ajax.hookUpdateLinks();
  Trisano.Ajax.setupRepeaters();
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
      var searchResults = new Element('div', { id: field.associatedSearchResults() });
      Element.extend(document.body).insert( { bottom: searchResults } );
      searchResults.addClassName('autocomplete');
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
    var spinner = Trisano.Ajax.spinnerImgNoID();
    spinner.setStyle({display: 'none'});
    spinner.id = node.associatedSpinner();
    return spinner;
  },

  spinnerImgNoID: function() {
    return new Element('img', {
                         src: Trisano.url('images/redbox_spinner.gif')
                       });
  },

  getRepeaterAjaxActions: function() {
    return $j("div#hospitalization_facilities").find("span.ajax-actions");
  },

  hideRepeaterAjaxActions: function() {
    var repeaters = Trisano.Ajax.getRepeaterAjaxActions();
      repeaters.each(function(index) {
        this.remove();
      });
  },

  setupRepeaters: function() {
    if($j("form[class^=new_][class$=_event]").length!=0) {
      // New mode
      Trisano.Ajax.hideRepeaterAjaxActions();
      $j("a#add-hospitalization-facilities").live("click", function() {
        Trisano.Ajax.hideRepeaterAjaxActions();
      });
    
    } else {
      // Edit mode
      $j("a.save-new-hospital-participation").live("click", Trisano.Ajax.saveHospitalization);

      $j("a.discard-new-hospital-participation").live("click", function() {
        $j(this).closest("div.hospital").remove();
        $j("a#add-hospitalization-facilities").show();
        return false;
      });

      $j("a#add-hospitalization-facilities").live("click", function() {
        this.hide();
      });

      if(Trisano.Ajax.getRepeaterAjaxActions().length != 0) {
        // A blank template is being shown
        $j("a#add-hospitalization-facilities").hide();
      }
    }
  },

  saveRepeaters: function() {
    return Trisano.Ajax.saveHospitalizations();
  },
 
  saveHospitalizations: function() {
    var deferreds = [];
    $j("div.hospital a.save-new-hospital-participation").closest("div.hospital").each(function() {
      deferreds.push(Trisano.Ajax.postHospitalization($j(this)));
    });
    return deferreds;
  },

  saveHospitalization: function() {
    var data_source = $j(this).closest("div.hospital");
    var result = Trisano.Ajax.postHospitalization(data_source);
    if(result.length == 0){
      // No inputs were populated. We want to do this here so that this message is only shown
      // when an individual hospitalization is saved, not when Save & Continue is used. 
      data_source.prepend("<strong class='required'>Please fill out at least one field.</strong>");
    };
    return false;
  },

  postHospitalization: function(data_source) {
    var hospitalization_fields = data_source.find(":input");
    var target = data_source;

    var at_least_one_field_populated = false;
    data_source.find(":input:visible").each(function(idx, elem){
      if($j(elem).val().length != 0){
        at_least_one_field_populated = true;
      }
    });
    if(!at_least_one_field_populated) {
      return [];
    }

    // Immediately following the div.hospital the hospitalization_facilities id is
    // rendered. We must include this in the POST to avoid creating a new
    // HospitalizationFacility
    var facilities_hidden_fields = data_source.next(":input[type=hidden]");
    hospitalization_fields = hospitalization_fields.add(facilities_hidden_fields);
    var hospitalization_data = hospitalization_fields.serialize();

    var url = Trisano.url("/human_events/" + $j("#id").attr('value') +"/hospitalization_facilities");

    return $j.ajax({
      url: url, 
      data: hospitalization_data,
      dataType: 'html',
      type: "POST",
      beforeSend: function( xhr) {
        data_source.find("span.ajax-actions").replaceWith(Trisano.Ajax.spinnerImgNoID());
      },
      error: function(request, textStatus, error) {
        target.replaceWith(request.responseText);

        // Because of the error the user's answer will be lost, so we must add it back

        // References to data_source and hospitalization_fields are now invalid since we've replaced target
        // with responseText. We must determine which hospitalization in the response has the errors
        var new_save_link = $j("#" + $j(request.responseText).find("div.errorExplanation")
                                                             .parent()
                                                             .children("a.save-new-hospital-participation")
                                                             .attr('id'));

        var new_hospitalization_fields = new_save_link.closest("div.hospital").find(":input");

        // So we can deserialize our data back into the forms
        // uses jquery.deserialize
        new_hospitalization_fields.deserialize(hospitalization_data); 
      },
      success: function(data, textStatus, request) {
        // Must be run before attempting to show a#add-hospitalization-facilities
        target.replaceWith(request.responseText);
        $j("a#add-hospitalization-facilities").show();
      }
    });
  }
};

// Prototype is lame. JQuery bits
$j('a.ajaxy.delete').livequery(function() {
  $j(this).click(function(evt) {
    evt.preventDefault();
    if ($j(evt.target).attr('data-confirm') != undefined && confirm($j(evt.target).attr('data-confirm'))) {
      $j($j(evt.target).attr('data-spinner')).show();
      $j.ajax({
        url: this.href,
        data: { _method: 'delete' },
        success: function() { $j($j(evt.target).attr('data-remove')).remove() },
        error: function() {
          $j($j(evt.target).attr('data-message-box')).text($j(evt.target).attr('data-error-message'))
        },
        complete: function() { $j($j(evt.target).attr('data-spinner')).hide() },
        type: "POST",
        dataType: "script"
      });
    }
  });
});
