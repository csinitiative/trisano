/*
# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
*/
// Singleton class definition of FormWatcher
Trisano.FormWatcher = new function() {

  this.init = function (form_id) {
    this.form = $j(form_id);
    this.submitted = false;
   
    // Let's serialize this.form and store it...
    this.formcontents = this.form.serialize();
  };
  
  this.setSubmitted = function () {
    this.submitted = true;
  };

  this.formChanged = function () {
    this.newcontents = this.form.serialize();
    return this.formcontents != this.newcontents
  };

  this.needsConfirmation = function () {
    if(typeof(this.form) === "undefined"){
      return false;
    } else {
      return Trisano.FormWatcher.formChanged() && !(this.submitted);
    }
  };

  this.confirmUnload = function(event) {
    if (Trisano.FormWatcher.needsConfirmation()) {
      Trisano.FormWatcher.showDialog(event.target.href);
      return false; 
    } else {
      return true;
    }
  };

  this.showDialog = function(url){
    $j('#events_nav_dialog').dialog({
      title: i18n.t('unsaved_changes'),
      height: 300,
      width: 600,
      buttons: Trisano.FormWatcher.eventNavButtons(url),
      close: function(event, ui) {
        if($j(this).attr("data-clear-event-nav-selection") == "true") {
          // $j(".events_nav").val('');
          // the above line doesn't actually reset to the top selected value
          // because there are multiple empty values presented.
          // this however, does work:
          $j(".events_nav").val("any invalid option")
          $j(this).attr("data-clear-event-nav-selection", "true"); // reset default state
        }
      }
    });
  },

  this.eventNavButtons = function(url) {
    var buttons = {};
    buttons[i18n.t('save_and_exit')] = function() {
      $j('#events_nav_spinner').show();
      $j('#events_nav_dialog').attr("data-clear-event-nav-selection", "false");
      $j(Trisano.FormWatcher.form).append(Trisano.FormWatcher.redirectTo(build_url_with_tab_index(url)));
      post_form($j(Trisano.FormWatcher.form).attr("id"));
      $j(this).dialog('close');
    };

    buttons[i18n.t('leave_without_saving')] = function() {
      $j('#events_nav_spinner').show();
      Trisano.FormWatcher.setSubmitted();
      send_url_with_tab_index(url);
      $j('#events_nav_dialog').attr("data-clear-event-nav-selection", "false");
      $j(this).dialog('close');
    };

    buttons[i18n.t('stay_on_current_page')] = function() {
      $j(this).dialog('close');
    };

    return buttons;
  };

  this.redirectTo = function(path) {
    return '<input id="events_nav_redirect" type="hidden" name="redirect_to" value="' + path + '"/>';
  };
}
