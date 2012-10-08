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
