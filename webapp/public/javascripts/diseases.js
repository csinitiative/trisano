$j(function() {
  $j('.apply_to_diseases').click(function() {
    var buttons = {};
    buttons[i18n.t('select_all')] = function() {
      $j('#dialog_disease_list input:checkbox').attr('checked', true);
    };
    buttons[i18n.t('update')] = function() {
      $j('#diseaseListSpinner').show();
      $j('#apply_to_disease_form').submit();
    };

    $j('.apply_to_disease_dialog').dialog({
      title: i18n.t('apply_to_diseases'),
      height: 300,
      width: 600,
      open: function(event, ui) {
        $j('#dialog_disease_list').empty();
        $j('#diseaseListSpinner').show();
        var diseasesUrl = $j('.apply_to_disease_dialog a').attr('href');
        $j.getJSON(diseasesUrl, function(data, textStatus) {
          $j('#diseaseListSpinner').hide();
          $j('#diseaseListTemplate').tmpl(data).appendTo('#dialog_disease_list');
        });
      },
      buttons: buttons
    });
  });

});
