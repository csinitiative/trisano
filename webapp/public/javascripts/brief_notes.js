$j(function(){
    $j(".save-brief-note-button").click(function(event) {
      var f = $j(this).parents("form").prev("form");
      f.find(".brief-note-text").val($j(this).prev(".brief-note-text").val());
      f.submit();
      event.stopPropagation();
      event.preventDefault();
    });
});