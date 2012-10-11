document.observe('trisano:dom:loaded', function() {
  Trisano.Tabs.highlightTabsWithErrors();
});

Trisano.Tabs = {
  highlightTabsWithErrors: function() {
    $j("div.fieldWithErrors").each(function(index, element) { Trisano.Tabs.markElementsParentTab(element); }  );
    $j("div.errorExplanation").each(function(index, element) { Trisano.Tabs.markElementsParentTab(element); } );
  },

  navigateToError: function() {
    var error_tab_index = $j("ul#tabs a.tab-link-with-error").data("tab-index");
    myTabs.set("activeIndex", error_tab_index);
    var error_position = $j('div.errorExplanation').offset().top - $j("#head").height();
    $j(window).scrollTop(error_position);    
  },

  markElementsParentTab: function(element) {
    var tab_div = $j(element).parents("div.tab");
    if (tab_div.attr("class") == 'tab') {
      var id = tab_div.attr("id");
      $j("ul#tabs li a[href='#" + id + "']").css("color", "red").addClass('tab-link-with-error');
    }
  }
};
