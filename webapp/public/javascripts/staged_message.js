$j(function() {
  $j('#input_choice_type').change(function() {
    var inputType = $j(':selected', this).val();
    if (!inputType) return false;

    var inputPane = $j('#inputPane');
    $j('.inputMessage', inputPane).remove();
    $j('.templates.'+inputType+'Input').children().clone()
      .addClass('inputMessage').appendTo(inputPane);

    $j('input[type="submit"]').attr('disabled', false);
  });
});
