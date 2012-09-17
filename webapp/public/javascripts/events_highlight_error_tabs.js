document.observe('trisano:dom:loaded', function() {
  Trisano.Tabs.highlightTabsWithErrors();
});

Trisano.Tabs = {
  highlightTabsWithErrors: function() {
    jQuery("div.fieldWithErrors").parentsUntil("div.tab").each( Trisano.Tabs.markParentTab );
    jQuery("div.errorExplanation").parentsUntil("div.tab").each( Trisano.Tabs.markParentTab );
  },

  markParentTab: function(index, tab) {
    var parent = jQuery(tab).parent();
    if (parent.attr("class") == 'tab') {
      var id = parent.attr("id");
      jQuery("ul#tabs li a[href='#" + id + "']").css("color", "red");
    }
  }
};
