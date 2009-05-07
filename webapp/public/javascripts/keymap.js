// Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
//
// This file is part of TriSano.
//
// TriSano is free software: you can redistribute it and/or modify it under the 
// terms of the GNU Affero General Public License as published by the 
// Free Software Foundation, either version 3 of the License, 
// or (at your option) any later version.
//
// TriSano is distributed in the hope that it will be useful, but 
// WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License 
// along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

keymap = {
  'configure': function() {
    window.location = this.root + "users/shortcuts/edit";
  },

  'new': function() {
    window.location = this.root + "cmrs/new";
  },

  'forms': function() {
    window.location = this.root + "forms";
  },

  'people': function() {
    window.location = this.root + "search/people";
  },

  'cmr_search': function() {
    window.location = this.root + "search/cmrs";
  },

  'cmrs': function() {
    window.location = this.root + "cmrs";
  },

  'navigate_right': function() {
    myTabs.set('activeIndex', (
        myTabs.get('activeIndex') == myTabs.get('tabs').length-1 ?
        0 : myTabs.get('activeIndex') + 1
      ));

    //Grab the first thing to focus in the tab
    YAHOO.util.Dom.getElementsBy(function(el) {
        return (el.tagName == 'SELECT' || el.tagName == 'INPUT' || el.tagName == 'A');
      }, '', myTabs.get('activeTab').get('contentEl'))[0].focus();
  },

  'navigate_left': function() {
    myTabs.set('activeIndex', (
        myTabs.get('activeIndex') == 0 ?
        myTabs.get('tabs').length-1 : myTabs.get('activeIndex')-1
      ));

    YAHOO.util.Dom.getElementsBy(function(el) {
        return (el.tagName == 'SELECT' || el.tagName == 'INPUT' || el.tagName == 'A');
      }, '', myTabs.get('activeTab').get('contentEl'))[0].focus();
  },

  'save': function() {
    $('save_and_exit_btn').focus();
  }
};
