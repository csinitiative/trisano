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