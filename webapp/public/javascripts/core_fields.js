$j(function() {
  $j('.copy_from_disease').click(function() {
    var buttons = {};
    buttons[i18n.t('copy')] = function() {
      $j('#diseaseListSpinner').show();
      $j('#disease_core_fields_copy_form').submit();
    };
    buttons[i18n.t('cancel')] = function() {
      $j(this).dialog("close");
    };

  $j('.copy_from_disease_dialog').dialog({
      title: i18n.t('copy_from_disease'),
      height: 300,
      width: 600,
      open: function(event, ui) {
        $j('#dialog_disease_list').empty();
        $j('#diseaseListSpinner').show();
        var diseasesUrl = $j('.copy_from_disease_dialog a').attr('href');
        $j.getJSON(diseasesUrl, function(data, textStatus) {
          $j('#diseaseListSpinner').hide();
          $j('#diseaseListTemplate').tmpl(data).appendTo('#dialog_disease_list');
        });
      },
      buttons: buttons
    });
  });
});
