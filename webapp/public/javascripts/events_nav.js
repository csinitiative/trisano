$j(function() {

  $j('.events_nav').on('change', function(event) {
    var selector = $j(this);

    if (Trisano.FormWatcher.needsConfirmation()) {
      Trisano.FormWatcher.showDialog(selector.val());
    } else {
      $j('#events_nav_spinner').show();
      send_url_with_tab_index(selector.val());
    }
  });

});
