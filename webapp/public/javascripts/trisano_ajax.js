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

  getHosFacRepeaterAjaxActions: function() {
    return $j("div#hospitalization_facilities").find("span.ajax-actions");
  },

  getPatientTeleRepeaterAjaxActions: function() {
    return $j("div#telephones").find("span.ajax-actions");
  },

  getRepeaterAjaxActions: function() {
    var repeaters = Trisano.Ajax.getHosFacRepeaterAjaxActions();
    repeaters = repeaters.add(Trisano.Ajax.getPatientTeleRepeaterAjaxActions());
    return repeaters;
  },

  hideRepeaterAjaxActions: function() {
    var repeaters = Trisano.Ajax.getRepeaterAjaxActions();
      repeaters.each(function(index) {
        this.remove();
      });
  },

  hidePatientTeleRepeaterAjaxActions: function() {
    var repeaters = Trisano.Ajax.getPatientTeleRepeaterAjaxActions();
      repeaters.each(function(index) {
        this.remove();
      });
  },

  hideHosFacRepeaterAjaxActions: function() {
    var repeaters = Trisano.Ajax.getHosFacRepeaterAjaxActions();
      repeaters.each(function(index) {
        this.remove();
      });
  },

  hideRepeaterAjaxActionsAfterAddingRepeater: function() {
    $j("a#add-patient-telephone").live("click", function() {
      Trisano.Ajax.hidePatientTeleRepeaterAjaxActions();
    });
    $j("a#add-hospitalization-facilities").live("click", function() {
      Trisano.Ajax.hideHosFacRepeaterAjaxActions();
    });
  },

  enableRepeaterAjaxActions: function() {
    Trisano.Ajax.enableHosFacRepeaterAjaxActions();
    Trisano.Ajax.enablePatientTeleRepeaterAjaxActions();
  },

  enablePatientTeleRepeaterAjaxActions: function() {
    $j("a.save-new-patient-telephone").live("click", Trisano.Ajax.savePatientTelephone);

    $j("a.discard-new-patient-telephone").live("click", function() {
      $j(this).closest("div.phone").remove();
      $j("a#add-patient-telephone").show();
      return false;
    });

    $j("a#add-patient-telephone").live("click", function() {
      this.hide();
    });

    if(Trisano.Ajax.getPatientTeleRepeaterAjaxActions().length != 0) {
      // A blank template is being shown
      $j("a#add-patient-telephone").hide();
    }
  },

  

  enableHosFacRepeaterAjaxActions: function() {
    $j("a.save-new-hospital-participation").live("click", Trisano.Ajax.saveHospitalization);

    $j("a.discard-new-hospital-participation").live("click", function() {
      $j(this).closest("div.hospital").remove();
      $j("a#add-hospitalization-facilities").show();
      return false;
    });

    $j("a#add-hospitalization-facilities").live("click", function() {
      this.hide();
    });

    if(Trisano.Ajax.getHosFacRepeaterAjaxActions().length != 0) {
      // A blank template is being shown
      $j("a#add-hospitalization-facilities").hide();
    }
  },

  

  setupRepeaters: function() {
    if($j("form[class^=new_][class$=_event]").length!=0) {
      // New mode
      Trisano.Ajax.hideRepeaterAjaxActions();
      Trisano.Ajax.hideRepeaterAjaxActionsAfterAddingRepeater();
    } else {
      // Edit mode
      Trisano.Ajax.enableRepeaterAjaxActions();
    }
  },

  saveRepeaters: function() {
    var deferreds = Trisano.Ajax.saveHospitalizations();
    deferreds = $j.merge(deferreds, Trisano.Ajax.savePatientTelephones());
    return deferreds;
  },
 
  savePatientTelephones: function() {
    var deferreds = [];
    $j("div.phone a.save-new-patient-telephone").closest("div.phone").each(function() {
      deferreds.push(Trisano.Ajax.postPatientTelephone($j(this)));
    });
    return deferreds;
  },

  saveHospitalizations: function() {
    var deferreds = [];
    $j("div.hospital a.save-new-hospital-participation").closest("div.hospital").each(function() {
      deferreds.push(Trisano.Ajax.postHospitalization($j(this)));
    });
    return deferreds;
  },

  savePatientTelephone: function() {
    var data_source = $j(this).closest("div.phone");
    var result = Trisano.Ajax.postPatientTelephone(data_source);
    if(result.length == 0){
      // No inputs were populated. We want to do this here so that this message is only shown
      // when an individual hospitalization is saved, not when Save & Continue is used. 
      data_source.prepend("<strong class='required'>Please fill out at least one field.</strong>");
    };
    return false;
  },

  saveHospitalization: function() {
    var data_source = $j(this).closest("div.hospital");
    var result = Trisano.Ajax.postHospitalization($j(data_source));
    if(result.length == 0){
      // No inputs were populated. We want to do this here so that this message is only shown
      // when an individual hospitalization is saved, not when Save & Continue is used. 
      data_source.prepend("<strong class='required'>Please fill out at least one field.</strong>");
    };
    return false;
  },


  fieldsPopulated: function(data_source) {
    var populated = false;
    $j(data_source).find(":input[type!=hidden]").each(function(idx, elem){
      if($j(elem).is("[type=radio]") || $j(elem).is("[type=checkbox]")){
        if($j(elem).is(":checked")){
          populated = true;
          return true;
        }
      } else {
        if($j(elem).val().length != 0){
          populated = true;
          return true;
        }
      }
    });
    return populated;
  },

  postRepeater: function(data_source, fields, url, target, new_repeater_id) {
    if(!Trisano.Ajax.fieldsPopulated(data_source)) {
      return [];
    }

    var data = fields.serialize();

    // Because form questions name attribute does not match it's ID attribute,
    // if invalid data is submitted, Rails's form builder doesn't know how to 
    // insert the form data back into the correct form question.
    // Here we collect all the visible questions IDs and map to their values
    // so that if we hit an error, we can repopulate below.
    var text_data = {};

    // Must refind elements directly form data source
    data_source.find(":input[type!=hidden][type!=checkbox][type!=radio]").each(function(i,e) { 
      text_data[$j(e).attr('id')] = $j(e).val(); // { element_id: element_value }
    });
    
    // Must handle radio buttons and checkboxes seperately.
    var checked_data = {};
    data_source.find(":input[type!=hidden][type=checkbox]:checked").each(function(i,e) { 
      checked_data[$j(e).attr('id')] = $j(e).val(); // { element_id: element_value }
    });
    data_source.find(":input[type!=hidden][type=radio]:checked").each(function(i,e) { 
      checked_data[$j(e).attr('id')] = $j(e).val(); // { element_id: element_value }
    });

    return $j.ajax({
      url: url, 
      data: data,
      dataType: 'html',
      type: "POST",
      beforeSend: function( xhr) {
        data_source.find("span.ajax-actions").replaceWith(Trisano.Ajax.spinnerImgNoID());
      },
      error: function(request, textStatus, error) {
        target.replaceWith(request.responseText);
        Trisano.Tabs.highlightTabsWithErrors();

        // Must manually repopulate the form fields data on an error
        $j.each(text_data, function(element_id,element_value) {
          // Strangly, you MUST operate on the DOM via $j, not $j(target) or $j(request.response)
          // otherwise changes won't be applied.
           var element = $j.find("#" + element_id);
           if(element){
              $j(element).val(element_value);   
 
              // This line is required to make the testing system be able to see the value was
              // actually inserted. The Selenium RC version we're using cannot read the DOM
              // manipulation directly.
              $j(element).attr('value', element_value);
           }
        });

        // And again for checkboxes and radio buttons
        $j.each(checked_data, function(element_id,element_value) {
           var element = $j.find("#" + element_id);
           if(element){
              $j(element).prop("checked", true);   
              $j(element).attr('checked', "checked"); //maybe redundant?
           }
        });
      },
      success: function(data, textStatus, request) {
        // Must be run before attempting to show a#add-hospitalization-facilities
        target.replaceWith(request.responseText);
        $j(new_repeater_id).show();
        Trisano.Tabs.clearErrorsFromTabs();
      }
    });
  },

  postPatientTelephone: function(data_source) {
    var patient_telephone_fields = data_source.find(":input");
    var url = Trisano.url("/human_events/" + $j("#id").attr('value') +"/patient_telephones");
    var target = data_source;
    var new_repeater_id = "a#add-patient-telephone";

    return Trisano.Ajax.postRepeater(data_source, patient_telephone_fields, url, target, new_repeater_id);
  },
  postHospitalization: function(data_source) {
    var hospitalization_fields = data_source.find(":input");
    // Immediately following the div.hospital the hospitalization_facilities id is
    // rendered. We must include this in the POST to avoid creating a new
    // HospitalizationFacility
    var facilities_hidden_fields = data_source.next(":input[type=hidden]");
    hospitalization_fields = hospitalization_fields.add(facilities_hidden_fields);

    var url = Trisano.url("/human_events/" + $j("#id").attr('value') +"/hospitalization_facilities");
    var target = data_source;
    var new_repeater_id = "a#add-hospitalization-facilities";

    return Trisano.Ajax.postRepeater(data_source, hospitalization_fields, url, target, new_repeater_id);
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
