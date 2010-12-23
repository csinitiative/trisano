$j(function() {
  $j('#input_type').live('change', function() {
    if (!$j(this).val()) return false;

    $j('#inputPane').children('.inputMessage').remove().end().append(
      $j('.templates.'+$j(this).val()+'Input').children().clone().addClass('inputMessage')
    );
    $j('option[value=""]',this).remove();
  }).change();
});
