$j(function(){
  $j('.staged-message-discard-link').click(function(){
    var staged_message = $j(this).closest('.staged-message').fadeTo('fast', 0.4);
    $j('.staged-message-link', staged_message).removeAttr('href');
  });
  $j(".hl7-link").click(function(e) {
      var title = $j(this).parents(".staged-message").find(".header").text().strip();
      var msg = $j(this).attr("data");
      var w = window.open('', '_blank','width=750,height=300,resizable=yes,directories=0,titlebar=0,scrollbars=1,toolbar=0,location=0,menubar=0');
      w.document.write("<html><body><head><title>" + title + "</title></head>" + msg + "</body></html>");
      e.stopPropagation();
      e.preventDefault();
  });
});