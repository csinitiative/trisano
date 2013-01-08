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
lazyLoader = {
  lazyQueue: {},

  init: function() {
    jQuery.each(this.lazyQueue, function(id, options) {
      $j('#' + id).load(options.url, null, options.after);
    });
  },

  afterLoad: function(id, after) {
    var element = $j("#" + id);
    if (element.html().match(/^\s+$/)) {
      element.html(Trisano.Ajax.spinnerImgNoID());
    }
    this.lazyQueue[id] = {
      url: element.attr('data-url'),
      after: after
    };
  }
}
