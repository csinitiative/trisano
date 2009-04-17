module CsvFieldsHelper
  # a little simple editor because the plugin assumes a full form_for
  # structure
  def in_place_editor(id, url)
    <<-JS
    <script type="text/javascript">
      document.observe('dom:loaded', function() {
        new Ajax.InPlaceEditor('#{id}', '#{url}', {
          externalControl: 'edit_link_#{id}',
          externalControlOnly: true,
          onFailure: function(transport, ipe) {            
            alert(ipe.responseText.stripTags());             
          },
          onLeaveHover: Prototype.emptyFunction,
          onEnterHover: Prototype.emptyFunction
        });
      });
    </script>
    JS
  end
end
