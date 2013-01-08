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
// Scrolls to the named anchor, just like normal hash linking (#somewhere),
// but offsets so the target location isn't hidden by the green bar

var LinkScroller = Class.create();
LinkScroller.prototype = {
  link: null,
  target: null,

  initialize: function(link) {
    this.scroll = this._scroll.bind(this);
    this.link = $(link);
    this.indexOfHash = link.href.indexOf('#');
    if (this.indexOfHash >= 0) {
      this.anchorName = link.href.substring(this.indexOfHash + 1);
      this.target = $$('a[name='+this.anchorName+']').first();
      Element.observe(this.link, 'click', this.scroll);
    }
  },

  _scroll: function(e) {
    Effect.ScrollTo(this.target, {duration: 0.5, offset: -200});
  }
};

document.observe('trisano:dom:loaded', function() {
  $$('.scroll-to-link').each(function(link) {
    new LinkScroller(link);
  });
});