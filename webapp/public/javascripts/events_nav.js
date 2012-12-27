$j(function() {

  $j('.events_nav').change(function(event) {
    var selector = $j(this);
    var cancelled = true;

    var dialogButtons = function() {
      var buttons = {};
      buttons[i18n.t('save_and_exit')] = function() {
        cancelled = false;
        $j('#events_nav_spinner').show();
        $j(formwatch.form).append(redirectTo(
                                      build_url_with_tab_index(
                                        selector.val())));
        post_and_exit(formwatch.form.attributes["id"].value);
        $j(this).dialog('close');
      };

      buttons[i18n.t('leave_without_saving')] = function() {
        cancelled = false;
        $j('#events_nav_spinner').show();
        formwatch.submitted = true;
        send_url_with_tab_index(selector.val());
        $j(this).dialog('close');
      };

      return buttons;
    };

    var redirectTo = function(path) {
      return '<input id="events_nav_redirect" type="hidden" name="redirect_to" value="' + path + '"/>';
    };

    var formIsDirty = function() {
      if (typeof(formwatch) === 'undefined') {
        return false;
      } else {
        return formwatch.needsConfirmation();
      }
    };

    if ($j(this).val()) {
      if (formIsDirty()) {
        $j('#events_nav_dialog').dialog({
          title: i18n.t('unsaved_changes'),
          height: 300,
          width: 600,
          buttons: dialogButtons(),
          beforeClose: function(event, ui) {
            if (cancelled) {
              selector.val('');
            }
          }
        });
      } else {
        $j('#events_nav_spinner').show();
        send_url_with_tab_index(selector.val());
      }
    }
  });

});
