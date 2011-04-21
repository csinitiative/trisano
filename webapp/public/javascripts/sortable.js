// Handle tables that are sortable with javascript alone
$j('table.sortable').livequery(function() {
  $j(this).tablesorter({ textExtraction: 'complex' });
});

// Handle tables that require an ajax request to fetch the newly sorted table data
$j('.sort_link').livequery(function() {
  $j(this).click(function(evt) {
    // don't want the default click action to fire
    evt.preventDefault();

    // locate the target element (where the newly loaded data goes)
    var target = $j(evt.target).parents('#' + $j(evt.target).attr('data-replace'));
    target.html('').siblings('#loader').show();

    // load the new data and insert it in the target
    $j.get($j(evt.target).attr('href'), null, function(data, status, xhr) {
      target.html(data).siblings('#loader').hide();
    });
  });
});

// Handle pagination links with the 'ajaxy' class
$j('.pagination.ajaxy > a').livequery(function() {
  $j(this).click(function(evt) {
    evt.preventDefault();

    // locate the target element (where the newly loaded data goes)
    var target = $j(evt.target).parents('#' + $j(evt.target).parent().attr('data-replace'));
    target.html('').siblings('#loader').show();

    // load the new data and insert it in the target
    $j.get($j(evt.target).attr('href'), null, function(data, status, xhr) {
      target.html(data).siblings('#loader').hide();
    });
  });
});