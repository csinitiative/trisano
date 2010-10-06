$j(function() {
  $j('#input_choice_type').change(function() {
    $j('#inputPane').children('.inputMessage').remove().end().append(
      $j('.templates.'+$j(this).val()+'Input').children().clone().addClass('inputMessage')
    );
    $j('option[value=""]',this).remove();
  });
});
