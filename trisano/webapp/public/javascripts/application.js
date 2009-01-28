// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function mark_for_destroy(element) {
  $(element).next('.should_destroy').value = 1;
  $(element).up('.role_membership').hide();
}

function toggle_investigator_forms(id_to_show) {

  id_to_hide = $("active_form").value;
  id_to_hide = "form_investigate_" + id_to_hide;

  $("active_form").value = id_to_show;
  id_to_show = "form_investigate_" + id_to_show;

  $(id_to_hide).hide();
  $(id_to_show).show();

}

function sendConditionRequest(path, element, event_id, question_element_id, spinner_id) {
  if (typeof spinner_id == "undefined")
    spinner_id = 'investigator_answer_' +  question_element_id + '_spinner';
  new Ajax.Request(path + '?question_element_id=' + question_element_id +'&response=' + element.value + '&event_id=' + event_id, {
    asynchronous: true,
    evalScripts:  true,
    onCreate:     function() { $(spinner_id).show(); },
    onComplete:   function() { $(spinner_id).hide(); }
  });
}

function sendCoreConditionRequest(path, element, event_id, core_path, spinner_id) {
  if (typeof spinner_id == "undefined")
    spinner_id = core_path + '_spinner';
  new Ajax.Request(path +'?core_path=' + core_path + '&response=' + element.value + '&event_id=' + event_id, {
    asynchronous: true,
    evalScripts:  true,
    onCreate:     function() { $(spinner_id).show(); },
    onComplete:   function() { $(spinner_id).hide(); }
  });
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
    url = url + "?tab_index=" + myTabs.get("activeIndex");
  }
  return url;
}

function send_url_with_tab_index(url) {
  url = build_url_with_tab_index(url);
  location.href = url;
}

function add_tab_index_to_action(form) {
  form.action = build_url_with_tab_index(form.action);
}

function post_and_return(form_id) {
  form = document.getElementById(form_id);
  form.action = build_url_with_tab_index(form.action);
  form.action = form.action + "&return=true";
  form.submit();
}

function post_and_exit(form_id) {
  form = document.getElementById(form_id);
  form.action = build_url_with_tab_index(form.action);
  form.submit();
}

function toggle_strike_through(element_id) {
  Element.toggleClassName(element_id, 'struck-through');
}

function safe_disable(target) {
    element = document.getElementById(target);
    if (element) {
        element.disabled=true;
    }
}

function toggle_save_buttons(state) {
  btn1 = document.getElementById('save_and_exit_btn');
  btn2 = document.getElementById('save_and_continue_btn');

  var btns = new Array(btn1, btn2);
  $A(btns).each(function(btn) {
    if (btn) {
      if (state == 'on') {
        btn.disabled=false
        } else {
        btn.disabled=true;
      }
    }
  })
}

function contact_parent_address(id) {
    new Ajax.Request('../../contact_events/copy_address/' + id, {
        asynchronous: true,
        evalScripts:  true,
        onComplete: function(transport, json) { 
            for (var key in json) 
                if (json[key])
                    document.getElementById('contact_event_active_patient__address_' + key).value = json[key];
        }
    });
}
