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

function sendConditionRequest(element, event_id, question_element_id) {
  new Ajax.Request('../../question_elements/process_condition?question_element_id=' + question_element_id +'&response=' + element.value + '&event_id=' + event_id, {asynchronous:true, evalScripts:true})
}

function sendCoreConditionRequest(element, event_id, core_path) {
  new Ajax.Request('../../follow_up_elements/process_core_condition?core_path=' + core_path + '&response=' + element.value + '&event_id=' + event_id, {asynchronous:true, evalScripts:true})
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

function build_url_with_tab_index(url) {
  if (!(window.myTabs === undefined)) {
    url = url + "?tab_index=" + myTabs.get("activeIndex")
  }
  return url
}

function send_url_with_tab_index(url) {
  url = build_url_with_tab_index(url)
  location.replace(url)
}

function add_tab_index_to_action(form) {
  form.action = build_url_with_tab_index(form.action);
}
