$j(function() {
  $j('form:has(div#cmr_tabs)')
    .append('<input id="contacts_nav_redirect" type="hidden" name="redirect_to"/>');

  $j('.contacts_nav').change(function(event) {
    $j('#contacts_nav_redirect').val($j(this).val());
  });
});
