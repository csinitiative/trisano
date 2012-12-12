// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var FormWatch = Class.create();
FormWatch.prototype = {
   initialize : function(form, options) {
     this.submitted = false;
     this.form = $(form);
      // Let's serialize this.form and store it...
     this.formcontents = $(form).serialize();
      // Observe beforeunload event...
     Event.observe(this.form, 'submit', function() {this.submitted = true; }.bind(this));
     Event.observe(window, 'beforeunload', this.confirmExit.bind(this));
   },

  isDirty: function() {
    var newcontents = this.form.serialize();
    return this.formcontents != newcontents;
  },

  confirmExit : function(ev) {
    if (this.isDirty() && !(this.submitted)) {
      ev.returnValue = i18n.t('form_changed');
    }
  }
};

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

extractLocaleAsQueryString = function(path) {
  var qp = $H(path.toQueryParams());
  var l = qp.get('locale');
  if (l == undefined) {
    return "";
  } else {
    return "?" + "locale=" + l;
  }
};

joinAndPreserveLocale = function(base, ext) {
  var s = base.split("?");
  var p = s[0];
  if (s[1] == undefined) {
    var l = "";
  } else {
    var l = extractLocaleAsQueryString(base);
  }
  return p + ext + l;
};

scrollToTop = function() {
  $j(window).scrollTop(0);
  return null;
};

function sendConditionRequest(path, element, event_id, question_element_id, spinner_id) {
    if (typeof spinner_id == "undefined")
        spinner_id = 'investigator_answer_' +  question_element_id + '_spinner';
    if (path.indexOf('?') < 0) { path = path + "?"; }
    queryParams = path.toQueryParams();
    queryParams.question_element_id = question_element_id;
    if (element.type == "checkbox") {
      // We must collect all values of the checkboxes
      // so that each value can be checked for a matching condition.

      // Checkboxes share the same name, collect them all (jQuery)
      var checkboxes = $j("[name='" + element.name + "'][type='checkbox']");

      // Collect values for each checked checkbox
      var checkbox_values = $j.map(checkboxes, function(checkbox_element, index) {
                                                 if (checkbox_element.checked)
                                                   return checkbox_element.value;
                                                 else
                                                   return null;
                                               });

      // Response cannot be an array. Convert to string with seperator
      // that can be processed by FollowUpElement.condition_match? 
      queryParams.response = checkbox_values.join("\n");
    } else {
      queryParams.response = element.value;
    }
    queryParams.event_id = event_id;
    if (window.location.toString().toQueryParams().locale) { queryParams.locale = window.location.toString().toQueryParams().locale; }
    new Ajax.Request(path.sub(/\?.*/, '') + '?' + $H(queryParams).toQueryString(), {
        asynchronous: true,
        evalScripts:  true,
        onCreate:     function() {
            $(spinner_id).show();
        },
        onComplete:   function() {
            $(spinner_id).hide();
        }
    });
}

function sendCoreConditionRequest(path, element, event_id, core_path, spinner_id) {
    if (typeof spinner_id == "undefined")
        spinner_id = core_path + '_spinner';
    if (path.indexOf('?') < 0) { path = path + "?"; }
    queryParams = path.toQueryParams();
    queryParams.core_path = core_path;
    queryParams.response = element.value;
    queryParams.event_id = event_id;
    if (window.location.toString().toQueryParams().locale) { queryParams.locale = window.location.toString().toQueryParams().locale; }
    new Ajax.Request(path.sub(/\?.*/, '') + '?' + $H(queryParams).toQueryString(), {
        asynchronous: true,
        evalScripts:  true,
        onCreate:     function() {
            $(spinner_id).show();
        },
        onComplete:   function() {
            $(spinner_id).hide();
        }
    });
}

function updateStatusRequest(path, value) {
    separator = (path.indexOf("?") > 0) ? "&" : "?";
    new Ajax.Request(path + separator + 'task[status]=' + value, {
        asynchronous:true,
        evalScripts:true,
        method:'put'
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
        if (url.indexOf('?') < 0) {
          url = url + "?";
        }
        queryParams = $H(url.toQueryParams());
        queryParams.set("tab_index", myTabs.get("activeIndex"));
        url = url.sub(/\?.*/, '') + "?" + queryParams.toQueryString();
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

function post_form(form_id, should_return) {
      if (Trisano.CmrsModifiedTabs) {
          Trisano.CmrsModifiedTabs.setChangedTabs();
      }

      form = document.getElementById(form_id);
      form.action = build_url_with_tab_index(form.action);
      form.action += form.action.match(/\?/) ? "" : "?";
      if(should_return) {
        form.action = form.action + "&return=true";
      }
      formWatcher.submitted = true;
      form.submit();
}

function post_and_return(form_id) {
      post_form(form_id, true);
}

function post_and_exit(form_id) {
      post_form(form_id, false);
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
    var btn1 = $j('#save_and_exit_btn');
    var btn2 = $j('#save_and_continue_btn');
    var indicator = $j("#save_indicator");
    var indicator_img = $j("#save_indicator_img");

    var btns = new Array(btn1, btn2);
    $j.each(btns, function(index, btn) {
      if (state == 'on') {
          btn.attr('disabled', false);
          btn.show();
          indicator.hide();
          indicator_img.hide();
      } else {
          btn.attr('disabled', true);
          btn.hide();
          indicator.show();
          indicator_img.show();
      }
    });
}

function contact_parent_address(path) {
  new Ajax.Request(path, {
    asynchronous: true,
    evalScripts:  true,
    method:       'get',
    onComplete: function(transport, json) {
      $H(json).each(function(pair) {
        $('contact_event_address_attributes_' + pair.key).value = pair.value;
      });
    }
  });
}

function shortcuts_init(home_path, shortcuts_path) {
  this.root = home_path;
  new Ajax.Request(shortcuts_path, {
    method:      'get',
    asynchronous: true,
    evalScripts:  true,
    onComplete: function(transport, json) {
      $H(json).each(function(pair) {
        shortcut.add(pair.value, keymap[pair.key]);
      });
    }
  });
}

function shortcut_set(target) {
  var ele = $('user_shortcut_settings_' + target);
  var prev = ele.previous();
  ele.style.display = "none";
  prev.innerHTML = ele.value || i18n.t('undefined');
  prev.style.display = "inline";

  $$('input[type=text]').each(function(box) { if (box.style.display == "inline") return; });

  document.onkeydown = function (e) {
    e = e || window.event;
    if(e.preventDefault)
      e.preventDefault();

    submit_shortcuts(KeyCode.translate_event(e));
  };

  document.onkeypress = null;
  document.onkeyup = null;
}

function submit_shortcuts()
{
    var dirty, inline = false;

    if (!$('user_submit').disabled) {
      $('shortcut_form').submit();
    } else {
      $$('input[type=text]').each(function(box) {
        if (box.dirty)
          dirty = true;
        if (box.style.display == "inline")
          inline = true;
      });
      if (dirty && inline)
        alert(i18n.t('unresolved_conflicts'));
    }
}

function change_shortcut(ele) {
  shortcut.kill_shortcuts();
  ele.style.display = "inline";
  ele.previous().style.display = "none";
  ele.focus();

  document.onkeydown = function(e) {
    e = e || window.event;
    if(e.preventDefault)
      e.preventDefault();

    var key = KeyCode.translate_event(e);

    if (!(key.shift || key.alt || key.ctrl || key.meta)) {
      var ary = $$('input[type=text]');

      if (key.code == 13) {
        window.onkeydown = null;
        submit_shortcuts();
      }

      if (key.code == 38 || key.code == 40) {
        var i = ary.indexOf(ele) - (39 - key.code);
        if (i >= 0 && i < ary.length)
            change_shortcut(ary[i]);
      }

    } else if ((key.code < 16 || key.code > 18) && key.code != 224) {
      ele.value = KeyCode.hot_key(key);
      ele.dirty = "1";
      check_conflicts();
    }

    KeyCode.key_down(e);
    return false;
  };

  document.onkeypress = function(e) {
    //This event isn't sent in IE so we don't need to check preventDefault
    e.preventDefault();
    return false;
  };

  document.onkeyup = KeyCode.key_up;
}

function check_conflicts() {
  var button = $('user_submit');
  var fields = $$('input[type=text]');

  button.enable();

  fields.each(function(ele) {
    var conflict = false;

    fields.each(function(box) {
      if ((box.value != '') && (box != ele) && (box.value == ele.value)) {
        box.style.color = "#F00";
        box.previous().style.color = "#F00";
        ele.style.color = "#F00";
        ele.previous().style.color = "#F00";
        button.disable();
        conflict = true;
      }
    });

    if (!conflict) {
      ele.style.color = "";
      ele.previous().style.color = (ele.dirty ? "#4b4" : "");
    }
  });
}

function focus_first() {
    if (typeof(myTabs) != "undefined" && typeof(myTabs.get('activeTab')) != "undefined") {
        activeTab = myTabs.get('activeTab').get('contentEl');
    } else {
        activeTab = $('main-content');
    }
    try {
      YAHOO.util.Dom.getElementsBy(function(el) {
        return (el.tagName == 'SELECT' || el.tagName == 'INPUT' || el.tagName == 'A') && (el.type != "hidden");
      }, '', activeTab)[0].focus();
    } catch(error) {
      // no-op, the element cannot receive focus. Catch to allow further JS to not be interfered with on IE8
    }

    // focusing on an element that is far down the page may scroll the page in some browsers,
    // so ensure we are at the top
    jQuery('html, body').animate({ scrollTop: 0 }, 0);
}

function focus_init() {
  focus_first();
  if (typeof(myTabs) != "undefined")
    myTabs.addListener("activeIndexChange", focus_first);
}

function getLabOptions(select_list, url) {
  if (select_list.options[select_list.selectedIndex].value == "-1") {
    new Ajax.Updater(select_list,  url, {asynchronous:true, method: 'get'});
  }
}

function useGoogleApi(action) {
  if (Trisano.Geo.initialized) {
    action();
  } else {
    loadGoogleApi({ onSuccess: action });
  }
}

 function loadGoogleApi(options) {
   loadScript(Trisano.Geo.scriptSrc);
   options.onSuccess = options.onSuccess || Prototype.K;
   new PeriodicalExecuter(function(pe) {
     if (Trisano.Geo.initialized) {
       options.onSuccess();
       pe.stop();
     }
   }, 0.2);
 }

function googleMapsLoaded() {
  googleMapsInit();
}

Trisano = {
  baseUrl: null,

  url: function(path) {
    return Trisano.baseUrl + path.gsub(/^\/+/, '');
  },

  setBaseUrl: function(url) {
    Trisano.baseUrl = url || $$("script[@src*='javascripts/prototype.js']")[1]
            .getAttribute('src').gsub(/javascripts\/(.+).js.*$/, '');
  },

  flashError: function(msg) {
    if (!Object.isElement($('flash-message'))) {
      $$('#title_area .container')[0].insert( { top: new Element('div', { id: 'flash-message' }) } );
    }
    var element = $('flash-message');
    element.setAttribute('class', 'error-message');
    element.update(msg).show();
    return element;
  }
};

Trisano.setBaseUrl();

function moveMultiple(item, where) {
  liAncestor = $j(item).closest('li');
  ulAncestor = $j(liAncestor).closest('ul');

  switch(where) {
    case 'top':
      liAncestor.remove().prependTo(ulAncestor);
      break;
    case 'bottom':
      liAncestor.remove().appendTo(ulAncestor);
      break;
    case 'up':
      previousLi = liAncestor.prevAll('li:first');
      if (previousLi.size() != 0) { liAncestor.insertBefore(previousLi); }
      break;
    case 'down':
      nextLi = liAncestor.nextAll('li:first');
      if (nextLi.size() != 0) { liAncestor.insertAfter(nextLi); }
      break;
    default:
      // no-op
  }
  
  setMultiplesPositionAttributes(ulAncestor);
  return false;
}

function setMultiplesPositionAttributes(ul) {
  ul.find("li > input[name*='position']").each(function (index, element) { element.value = index+1; });
}
