// Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
    window.location = joinAndPreserveLocale(this.root, "users/shortcuts/edit");
  },

  'new': function() {
    window.location = joinAndPreserveLocale(this.root, "cmrs/event_search");
  },

  'forms': function() {
    window.location = joinAndPreserveLocale(this.root, "forms");
  },

  'cmr_search': function() {
    window.location = joinAndPreserveLocale(this.root, "search/events");
  },

  'cmrs': function() {
    window.location = joinAndPreserveLocale(this.root, "cmrs");
  },

  'admin': function() {
    window.location = joinAndPreserveLocale(this.root, "admin");
  },

  'analysis': function() {
    window.location = joinAndPreserveLocale(this.root, "analysis");
  },

  'settings': function() {
    window.location = joinAndPreserveLocale(this.root, "users/settings");
  },

  'navigate_right': function() {
    myTabs.set('activeIndex', (
        myTabs.get('activeIndex') == myTabs.get('tabs').length-1 ?
        0 : myTabs.get('activeIndex') + 1
      ));
  },

  'navigate_left': function() {
    myTabs.set('activeIndex', (
        myTabs.get('activeIndex') == 0 ?
        myTabs.get('tabs').length-1 : myTabs.get('activeIndex')-1
      ));
  },

  'save': function() {
    $('save_and_exit_btn').focus();
  }
};
