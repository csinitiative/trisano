document.observe('trisano:dom:loaded', function() {
  Trisano.Ajax.hookLiveSearchFields();
  Trisano.Ajax.hookUpdateLinks();
  $j("a.save-new-hospital-participation").live("click", Trisano.Ajax.saveHospitalization);
  $j("a.discard-new-hospital-participation").live("click", function() {
    $j(this).closest("div.hospital").remove();
    $j("a#add-hospitalization-facilities").show();
    return false;
  });
  $j("a#add-hospitalization-facilities").live("click", function() {
    this.hide();
  });
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
    spinner.style = 'display:none';
    spinner.id = node.associatedSpinner();
    return spinner;
  },

  spinnerImgNoID: function() {
    return new Element('img', {
                         src: Trisano.url('images/redbox_spinner.gif')
                       });
  },

  saveHospitalizations: function() {
    $j.when(
      //$j("div.hospital").each(function(index) {
        Trisano.Ajax.postHospitalization($j($j("div.hospital").first())),
        Trisano.Ajax.postHospitalization($j($j("div.hospital").last()))
      //})
    ).then(
      function() {
        // Done callbacks
        // Do Nothing.
        alert('all success');
        return true;
      },
      function() {
	// Failed callbacks
        alert('someone failed');
        return false;
      }
    );
  },

  saveHospitalization: function() {
    var data_source = $j(this).closest("div.hospital");
    Trisano.Ajax.postHospitalization(data_source);
    return false;
  },

  postHospitalization: function(data_source) {
    var hospitalization_fields = data_source.find(":input");
    var target = $j("#hospitalization_facilities");

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
