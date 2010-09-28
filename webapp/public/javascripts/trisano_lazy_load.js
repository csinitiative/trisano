lazyLoader = {
  lazyQueue: {},

  init: function() {
    jQuery.each(this.lazyQueue, function(id, url) {
      $j("#" + id).load(url);
    });
  },

  afterLoad: function(id) {
    var element = $j("#" + id);
    if (element.html().match(/^\s+$/)) {
      element.html('<image src="/images/redbox_spinner.gif" />');
    }
    this.lazyQueue[id] = element.attr('data-url');
  }
}
