$j(function(){
  $j('.staged-message-discard-link').click(function(){
    var staged_message = $j(this).closest('.staged-message').fadeTo('fast', 0.4);
    $j('.staged-message-link', staged_message).removeAttr('href');
  });
  var dialog;
  if (dialog == undefined) {
    var newDiv = $j(document.createElement('div'));
    newDiv.attr('class','hl7-dialog');
    newDiv.attr('style', 'display:none');
    dialog = newDiv.dialog({title:"HL7 Message", width:750, height: 250, autoOpen: false});
  }
  $j(".hl7-link").click(function(e) {
      dialog.html('<textarea>'+ $j(this).attr("data") +'</textarea>');
      dialog.dialog('open');
      e.stopPropagation();
      e.preventDefault();
  });
});