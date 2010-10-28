$j(function() {
  $j('.apply_to_diseases').click(function() {
    var buttons = {};
    buttons[i18n.t('select_all')] = function() {
      $j('#dialog_disease_list input:checkbox').attr('checked', true);
    };
    buttons[i18n.t('update')] = function() {
      $j('#diseaseListSpinner').show();
      $j('#apply_core_fields_to_disease_form').submit();
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

  $j('a.hide, a.display').live('click', function(event) {
    event.preventDefault();
    var url = $j(this).attr('href');
    var rendered = $j(this).hasClass('display');
    $j(this).siblings('img').show();
    $j(this).hide();
    $j.ajax({
      context: $j(this).parents('li').first(),
      url: url,
      data: {
        core_field: {
          rendered_attributes: {
            rendered: rendered
          }
        }
      },
      dataType: 'script',
      type: 'PUT',
      success: function(data, status, xhr) {
        $j(this).replaceWith(data);
      }
    });
  });

});
