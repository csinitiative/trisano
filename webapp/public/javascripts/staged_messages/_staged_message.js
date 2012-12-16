$j(function(){
  $j('.staged-message-discard-link').click(function(){
    var staged_message = $j(this).closest('.staged-message').fadeTo('fast', 0.4);
    $j('.staged-message-link', staged_message).removeAttr('href');
  });
});