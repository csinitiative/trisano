$j(function() {

  $j('.contacts_nav').change(function(event) {
    var selector = $j(this);

    var dialogButtons = function() {
      var buttons = {};

      buttons[i18n.t('save_and_exit')] = function() {
        $j('#contacts_nav_spinner').show();
        $j(formWatcher.form).append(redirectTo(
                                      build_url_with_tab_index(
                                        selector.val())));
        post_and_exit(formWatcher.form);
        $j(this).dialog('close');
      };

      buttons[i18n.t('leave_without_saving')] = function() {
        $j('#contacts_nav_spinner').show();
        formWatcher.submitted = true;
        send_url_with_tab_index(selector.val());
        $j(this).dialog('close');
      };

      return buttons;
    };

    var redirectTo = function(path) {
      return '<input id="contacts_nav_redirect" type="hidden" name="redirect_to" value="' + path + '"/>';
    };

    var formIsDirty = function() {
      if (window.formWatcher === undefined) {
        return false;
      } else {
        return formWatcher.isDirty();
      }
    };

    if ($j(this).val()) {
      if (formIsDirty()) {
        $j('#contacts_nav_dialog').dialog({
          title: i18n.t('unsaved_changes'),
          height: 300,
          width: 600,
          buttons: dialogButtons()
        });
      } else {
        $j('#contacts_nav_spinner').show();
        send_url_with_tab_index(selector.val());
      }
    }
  });

});
