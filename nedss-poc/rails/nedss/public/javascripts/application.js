// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function mark_for_destroy(element) { 
  $(element).next('.should_destroy').value = 1 
  $(element).up('.role_membership').hide(); 
}

function toggle_investigator_forms(id_to_show) {
  
  id_to_hide = $("active_form").value
  id_to_hide = "form_investigate_" + id_to_hide
  
  $("active_form").value = id_to_show
  id_to_show = "form_investigate_" + id_to_show

  $(id_to_hide).hide()
  $(id_to_show).show()
  
}

function process_follow_up_conditions(input, conditions) {
  
  conditions_array = conditions.split(",")
  
  for (var i = 0; i < conditions_array.length; i = i+2) {
    if (conditions_array[i] == input.value) {
      $("follow_up_investigate_" + conditions_array[i+1]).show()
    } else {
      $("follow_up_investigate_" + conditions_array[i+1]).hide()
    }
  }
}

function setUpSearchFields() {
  if (document.getElementById("name").value.length > 0) {
    document.getElementById("sw_first_name").disabled = true;
    document.getElementById("sw_last_name").disabled = true;
  }
  
  if (document.getElementById("sw_first_name").value.length > 0 || document.getElementById("sw_last_name").value.length > 0) {
    document.getElementById("name").disabled = true;
  }
}

function checkNameSearchFields(field) {
  if (field.id == "name") {
    if (field.value.length > 0) {
      document.getElementById("sw_first_name").disabled = true;
      document.getElementById("sw_last_name").disabled = true;
    }
    else {
      document.getElementById("sw_first_name").disabled = false;
      document.getElementById("sw_last_name").disabled = false;
    }
  }
  else if (field.id == "sw_first_name" || field.id == "sw_last_name") {
    first = document.getElementById("sw_first_name");
    last = document.getElementById("sw_last_name");
     
    if (first.value.length > 0 || last.value.length > 0) {
      document.getElementById("name").disabled = true;
    }
    else {
      document.getElementById("name").disabled = false;
    }
  }
}
