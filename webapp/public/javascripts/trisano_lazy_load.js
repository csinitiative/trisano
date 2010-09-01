lazyLoader = {
  lazyQueue: {},

  init: function() {
    jQuery.each(this.lazyQueue, function(id, url) {
      $j("#" + id).load(url);
    });
  },

  afterLoad: function(id, url) {
    if ( $j("#"+id).html() == '' ) {
      $j("#"+id).html('<image src="/images/redbox_spinner.gif" />');
    }
    this.lazyQueue[id] = url;
  }
}