document.observe('trisano:dom:loaded', function() {
  jQuery("div.fieldWithErrors").parentsUntil("div.tab").each(
    function(index, tab){
      var parent = jQuery(tab).parent();
      if (parent.attr("class") == 'tab') {
        var id = parent.attr("id");
        jQuery("ul#tabs li a[href='#" + id + "']").css("color", "red");
      }
    }
  );
});