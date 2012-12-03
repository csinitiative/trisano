document.observe('trisano:dom:loaded', function() {
  Trisano.Tabs.highlightTabsWithErrors();
});

Trisano.Tabs = {
  highlightTabsWithErrors: function() {
    Trisano.Tabs.clearErrorsFromTabs();
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
      Trisano.Tabs.setTabError($j("ul#tabs li a[href='#" + id + "']"));
    }
  },

 
  clearErrorsFromTabs: function() {
    $j("a.tab-link-with-error").each(function(index, element) {
      var tab_id = $j(this).attr("href");  // will return #clinical_tab for example
      var tab_errors = $j("div"+tab_id).find("div.errorExplanation");
      if(tab_errors.length == 0) {
        Trisano.Tabs.clearTabError(this);
      }
    });
  },
  
  clearTabError: function(element) {
    if($j(element).parent("li").attr("title")=="active"){
      $j(element).removeClass('tab-link-with-error');
    } else {
      $j(element).removeClass('tab-link-with-error');
    }
  },

  setTabError: function(element) {
    $j(element).addClass('tab-link-with-error');
  }
};
