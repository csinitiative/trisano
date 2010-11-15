$j(function() {
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
